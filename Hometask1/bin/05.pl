#!/usr/bin/perl

use strict;
use warnings;

=encoding UTF8
=head1 SYNOPSYS

Поиск количества вхождений строки в подстроку.

=head1 run ($str, $substr)

Функция поиска количества вхождений строки $substr в строку $str.
Пачатает количество вхождений в виде "$count\n"
Если вхождений нет - печатает "0\n".

Примеры: 

run("aaaa", "aa") - печатает "2\n".

run("aaaa", "a") - печатает "4\n"

run("abcab", "ab") - печатает "2\n"

run("ab", "c") - печатает "0\n"

=cut

sub run {
    my ($str, $substr) = @_;
    my $num = 0;


    my $index = 0;      #место строки, с которого происходит проверка вхождения
                
    while (1) {    #цикл завершится в любом случае, так как число вхождений подстроки конечно и функция index вернет -1
        my $find = index($str, $substr, $index);
        if ($find != -1) {
            $num++;
            $index = $find + length($substr);      #новое место поиска - это место нахождения подстроки + длина подстроки
        } else {
            last        
        }
    }

    print "$num\n";
}

1;