package Anagram;

use 5.010;
use strict;
use warnings;

=encoding UTF8

=head1 SYNOPSIS

Поиск анаграмм

=head1 anagram($arrayref)

Функцию поиска всех множеств анаграмм по словарю.

Входные данные для функции: ссылка на массив - каждый элемент которого - слово на русском языке в кодировке utf8

Выходные данные: Ссылка на хеш множеств анаграмм.

Ключ - первое встретившееся в словаре слово из множества
Значение - ссылка на массив, каждый элемент которого слово из множества, в том порядке в котором оно встретилось в словаре в первый раз.

Множества из одного элемента не должны попасть в результат.

Все слова должны быть приведены к нижнему регистру.
В результирующем множестве каждое слово должно встречаться только один раз.
Например

anagram(['пятак', 'ЛиСток', 'пятка', 'стул', 'ПяТаК', 'слиток', 'тяпка', 'столик', 'слиток'])

должен вернуть ссылку на хеш


{
    'пятак'  => ['пятак', 'пятка', 'тяпка'],
    'листок' => ['листок', 'слиток', 'столик'],
}

=cut

sub anagram {
    my $words_list = shift;
    my %result;
    use utf8;
    use Encode;
    #
    # Поиск анаграмм
    #
    my @words_list = @$words_list;

    foreach (@words_list) {           
        my $word = lc decode_utf8($_, 1);    
        
        my $key = join '', sort split //, $word;

        push @{$result{$key}}, $word unless grep {$_ eq $word} @{$result{$key}};

    }

    foreach (keys %result) {            

        if (@{$result{$_}} != 1) {
            my @array = map {encode_utf8 $_} @{$result{$_}};
            my $key = $array[0];
            @array = sort @array;
            delete $result{$_};
            $result{$key} = \@array;
        }
        else {
            delete $result{$_};
        }
    }

    return \%result;
}

1;
