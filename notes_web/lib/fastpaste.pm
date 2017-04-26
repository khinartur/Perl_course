package fastpaste;
use utf8;
use Dancer2;
use Dancer2::Plugin::Database;
use Digest::CRC qw/crc64/;
use HTML::Entities;
use Digest::MD5 'md5_hex';
use FindBin;
use lib "$FindBin::Bin/../lib";
use mydb;

set session => "YAML";

our $VERSION = '0.1';

sub is_valid_user {                         #аутентификация пользователя
    my ($log, $pass) = (shift, shift);

    my $person = database->quick_select('user', { login => $log });
    
    return 1 if $log eq $person->{login} && md5_hex($pass) eq $person->{password};
}

sub get_notes_and_friends {                 #найти в базе друзей пользователя и его заметки
    my $login = shift;

    my $notes = mydb::select_my_notes($login);
    for (@$notes) {
        $_->{title} = encode_entities($_->{title}, '<>&"');
        $_->{id} = unpack 'H*', pack 'Q', $_->{id};
    }

    my $user = database->quick_select('user', { login => $login });
    my $friends = mydb::select_my_friends($user->{id});
        
    for (@$friends) {
        $_->{login} = encode_entities($_->{login}, '<>&"');
    }

    return (scalar @$notes ? $notes : 0, scalar @$friends ? $friends : 0);
}

sub guest_page {            #получение информации, которая должна отображаться на чужой странице
    my $person = shift;

    my $logged_user = database->quick_select('user', { login => session('user') });
    my $friend = mydb::is_friend($logged_user->{id}, $person->{id});
    my $button_value = ($friend == 1) ? "У вас в друзьях" : "Добавить в друзья";
    
    my $can_read = ($friend == 1) ? 'friends' : 'all';          #если друг, то можно читать заметки "только для друзей"
    my $notes = mydb::select_guest_notes($person->{login}, $can_read);
    for (@$notes) {
        $_->{title} = encode_entities($_->{title}, '<>&"');
        $_->{id} = unpack 'H*', pack 'Q', $_->{id};
    }

    return (scalar @$notes ? $notes : 0, $button_value);
}

hook before => sub {
    if (!session('user') && request->dispatch_path !~ m/^\/(login|new)/) {
        forward '/login', {
          err => 'Для использования сайта необходима авторизация!'
        }
    }
};

hook before_template_render => sub {
    my $tokens = shift;
    if (session('user')) {
        $tokens->{exit_button} = 1;          #отображение кнопок Выйти и Пользователи
        $tokens->{people} = 1;
        $tokens->{logged_user} = session('user');
    }
};

get '/' => sub {
    redirect '/login';
};

get '/login' => sub {
    return template 'login';
};

post '/login' => sub {                  #обработчик формы авторизации
    my $login = params->{login};
    my $password = params->{password};

    if (is_valid_user $login, $password) {
        session user => $login;
        redirect '/' . $login;
    } 
    else {
        return template 'login.tt' => {err => 'Неправильный логин или пароль!'}
    }
};

get '/new' => sub {                    
    return template 'new';
};

post '/new' => sub {                    #обработчик формы регистрации

    my $login = params->{login};
    my $password = md5_hex(params->{password});

    if (!$login || !$password) {
        return template 'new' => {err => 'Оба поля обязательны!'}
    }

    my $sth = mydb::ppr_insert_user();

    $sth->execute($login, $password);

    session user => $login;
    redirect '/' . $login;
};

get '/people' => sub {              #страница вывода всех пользователей

    my $people_list = mydb::get_people_list();

    return template 'people' => {people_list => $people_list}
};

get qr{^/([a-z0-9]{16})$} => sub {          #страница отображения заметки

    my ($id) = splat;
    $id = unpack 'Q', pack 'H*', $id;
    my $sth = mydb::ppr_select_note();

    unless ($sth->execute($id)) {
        response->status(404);
        return template 'profile' => {err => ['Заметка не найдена.']};
    }
    my $db_res = $sth->fetchrow_hashref();
    
    my $text = $db_res->{content};
    for ($text) {
        $_ = encode_entities($_, '<>&"');
        s/\t/&nbsp;&nbsp;&nbsp;&nbsp;/g;
        s/^ /&nbsp;/g;
    }
    $db_res->{title} = encode_entities($db_res->{title}, '<>&"');

    return template 'note_show' => {text => $text, title => $db_res->{title}};
};

post qr{^/([a-z0-9]{16})$} => sub {
    redirect '/'.session('user');
};

get qr{^/([a-zA-Z0-9]+)$} => sub {      #страница профиля пользователя
    
    my ($login) = splat;

    if (session('user') eq $login) {    #если это страница авторизованного пользователя
        my ($notes, $friends) = get_notes_and_friends($login);

        return template 'profile.tt' => { login => $login, notes => $notes, friends => $friends }
    }
    elsif (session('user')) {           #если пользователь зашел на страницу другого пользователя

        my $person = database->quick_select('user', { login => $login });
        
        if ($person) {
            my ($notes, $button_value) = guest_page($person);
            return template 'guest' => {login => $login, notes => $notes, btn_value => $button_value}
        }
        else {
            return template 'profile' => {login => session('user'), err => 'Пользователя не существует.'}
        }
        
    }
    else {              #если незарегистрированный пользователь пытается прочитать чьи-то заметки
        return template 'login' => {err => 'Нужна авторизация для доступа к пользователям.'}
    }

};

post qr{^/([a-zA-Z0-9]+)$} => sub {             #добавление друга/выход из профиля/создание новой заметки
    my ($login) = splat;

    if (params->{add}) {
        my $first_login = database->quick_select('user', { login => session('user') });
        my $second_login = database->quick_select('user', { login => $login });
        mydb::insert_friend($first_login->{id}, $second_login->{id});

        redirect '/'.session('user');
    }

    if (params->{exit}) {
        session user => undef;
        redirect '/login';
    }

    my $user = database->quick_select('user', { login => $login });

    my $title = params->{title};
    my $text = params->{text};
    my $rule = params->{rule};
    my $create_time = time();

    my @err = ();               #валидация входных параметров
    if (!$title) {
        push @err, 'Empty title!';
    }
    if (!$text) {
        push @err, 'Empty text!';
    }
    if (@err) {
        $text = encode_entities($text, '<>&"');
        $title = encode_entities($title, '<>&"');
        return template 'profile' => {login => $login, text => $text, title => $title, rule => $rule, err => \@err};
    }

    my $sth = mydb::ppr_insert_note();

    my $id = '';               #если не удается занести заметку в базу данных
    my $try_count = 10;
    while (!$id) {
        last unless --$try_count;
        $id = crc64($text.$create_time.$id);
        $id = undef unless $sth->execute($id, $user->{id}, $title, $text, $create_time, $rule);
    }
    unless ($id) {
        die "Try later";
    }

    redirect '/' . unpack 'H*', pack 'Q', $id;    
};

true;