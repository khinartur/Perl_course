package DeepClone;

use 5.010;
use strict;
use warnings;

=encoding UTF8

=head1 SYNOPSIS

Клонирование сложных структур данных

=head1 clone($orig)

Функция принимает на вход ссылку на какую либо структуру данных и отдаюет, в качестве результата, ее точную независимую копию.
Это значит, что ни один элемент результирующей структуры, не может ссылаться на элементы исходной, но при этом она должна в точности повторять ее схему.

Входные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив и хеш, могут быть любые из указанных выше конструкций.
Любые отличные от указанных типы данных -- недопустимы. В этом случае результатом клонирования должен быть undef.

Выходные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив или хеш, не могут быть ссылки на массивы и хеши исходной структуры данных.

=cut


############################################# МОЙ КОД

sub deep_clone {
	my ($element, $hash_of_refs) = (shift, shift);		#очередной копируемый элемент структуры

	my $iteration_result;
	if (my $ref = ref $element) {	#если очередной элемент - ссылка
		
		if ($ref eq 'ARRAY') {		#если очередной элемент - ссылка на массив
			
			return $hash_of_refs->{$element} if exists $hash_of_refs->{$element};

			$iteration_result = [];
			$hash_of_refs->{$element} = $iteration_result;
			foreach (@$element) {push @$iteration_result, deep_clone($_, $hash_of_refs)};

			foreach (@$iteration_result) {
				return sub {} if ref $_ && ref $_ eq 'CODE';
			}

		}
		elsif ($ref eq 'HASH') {	#если очередной элемент - ссылка на хэш

			return $hash_of_refs->{$element} if exists $hash_of_refs->{$element};

			$iteration_result = {};
			$hash_of_refs->{$element} = $iteration_result;
			while (my ($k, $v) = each %$element) {
				$iteration_result->{$k} = deep_clone($v, $hash_of_refs);
			}
			foreach (values %$iteration_result) {
				return sub {} if ref $_ && ref $_ eq 'CODE';
			}			

		}

		else {						#если очередной элемент - ссылка на нечто иное - недопустимый тип
			return sub {} if ref $element eq 'CODE';
			return undef;
		}
	} else {						#если очередной элемент не ссылка и не недопустимый тип
		$iteration_result = $element;
	}

	return $iteration_result;
}

sub clone {
	my $orig = shift;
	my $cloned;
	# ...
	# deep clone algorith here
	# ...
	
	my %hash_of_refs;	#хэш ссылок, которые уже были копированы в структуру (на случай рекурсивных структур)
	my $deep = deep_clone($orig, \%hash_of_refs);
	unless (ref $deep && ref $deep eq 'CODE') {
		$cloned = $deep;
	}
	else {
		$cloned = undef;
	}

	return $cloned;
}

#############################################


1;
