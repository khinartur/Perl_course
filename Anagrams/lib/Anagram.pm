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

sub hash_of_chars($) {	#преобразует переданное слово в хэш символов, из которых состоит слово (символ => undef).
						#Хэш можно использовать в качестве множества символов слова (с повторениями)
	my %result;
	my $chars = shift;
	@result{@$chars} = ();

	return %result;
}

sub is_anagram($$) {	#проверяет, являются ли переданные слова анаграммами

	use utf8;
	my ($first_word, $second_word) = (shift, shift);
	my %first_chars = hash_of_chars([split //, $first_word]);
	my %second_chars = hash_of_chars([split //, $second_word]);

	my $count_of_eq = 0;
	while (my ($k, $v) = each %first_chars) {
		++$count_of_eq if exists $second_chars{$k}; 
	}

	return $count_of_eq == scalar keys %first_chars;

}

sub in_array($$) {		#проверяет, входит ли заданный элемент в массив
	my ($array, $element) = (shift, shift);
	my $result;

	foreach (@$array) {
		last if $result = $_ eq $element;	
	}

	return $result;
}


sub anagram {
    my $words_list = shift;
    my %result;
    use utf8;

    #
    # Поиск анаграмм
    #
   	use Encode;

    foreach (@$words_list) {			#цикл по каждому переданному слову
    	my $word = lc decode_utf8($_, 1);	 #привести очередное слово к utf8, чтобы иметь возможность применить lc
    	$word = encode_utf8($word);			
    	my $anagram_flag = 0;			#anagram_flag = 1 если очередное слово является анаграммой к уже существующему множеству анаграмм 
    									#в результирующем хэше
    	foreach (keys %result) {								#проверка, является ли очередное слово анаграммой к какому-нибудь множеству
    															#результирующего хэша
    		if ($anagram_flag = is_anagram($_, $word)) {		#если очередное слово соответствующая анаграмма
    			push ($result{$_}, $word) unless (exists $result{$_} && in_array($result{$_}, $word));
    											#добавить слово в множество соответствующих анаграмм, если конечно оно туда уже не входит
    			last;		#завершить цикл по ключам - очередное слово уже обработано
    		}
    	}

    	unless ($anagram_flag) {		#если слово не является анаграммой, то добавить новое множество анаграмм с этим единственным словом
    		$result{$word} = [$word];
    	}
    }

    foreach (keys %result) {			#удаление множеств только с одним словом
    	delete $result{$_} if scalar @{$result{$_}} == 1;
    }

    foreach (keys %result) {			#сортировка множеств анаграмм по возрастанию
    	my @array = sort {$a cmp $b} @{$result{$_}};
    	$result{$_} = \@array;
    }
   

    return \%result;
}

1;
