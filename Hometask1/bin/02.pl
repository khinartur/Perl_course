#!/usr/bin/perl

use strict;
use warnings;

=encoding UTF8
=head1 SYNOPSYS

Вычисление простых чисел

=head1 run ($x, $y)

Функция вычисления простых чисел в диапазоне [$x, $y].
Пачатает все положительные простые числа в формате "$value\n"
Если простых чисел в указанном диапазоне нет - ничего не печатает.

Примеры: 

run(0, 1) - ничего не печатает.

run(1, 4) - печатает "2\n" и "3\n"

=cut

sub run {
    my ($x, $y) = @_;
    for (my $i = $x; $i <= $y; $i++) {

        my $current = $i - 1;   #current - текущий проверяемый делитель 
        while ($current > 1) {  
            if ($i % $current == 0) {last}  #если делитель не 1 и не само число, то число не простое
            $current--
        } 
        if ($current != 1) {next}   #если у числа есть делитель, не равный 1 и самому числу, 
                                    #то оно не простое и его печатать не нужно

	print "$i\n";
    }
}

1;
