#!/usr/bin/perl

use strict;
use warnings;
our $VERSION = 1.0;


my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;

sub parse_file {
    my $file = shift;

    # you can put your code here ВЫДЕЛЕН ДОБАВЛЕННЫЙ МНОЙ КОД
    #######################################################

    use List::Util qw/min/;

    my $query_count;    #количество запросов в общем
    my %total_minutes;      #все минуты, в которых происходят запросы
    my $total_data;     #количество несжатых данных всего
    my %data_of_status;     #статусы запросов и сжатые данные которые были переданы при них
    my %hash_of_ip;     #хэш всех ip, с которых происходили запросы. Включает необходимые для вывода данные    
    my ($ip, $minute, $status, $compressed_data, $indices);     #информация из строки лога
    my @top_10_ip;     #топ десять ip адресов для вывода в результат
    my %top10_hash;    #вспомогательный массив для формирования @top_10_ip

    #######################################################

    my $result;
    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";
    while (my $log_line = <$fd>) {

        # you can put your code here
        # $log_line contains line from log file
    #######################################################

        $query_count++;
        ($ip, $minute, $status, $compressed_data, $indices) = $log_line =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) \[\d{1,2}\/[JFMASOND][a-z]{2}\/\d{4}:(\d{2}:\d{2}):\d{2} \+\d{4}\] ["](?:.+)["] (\d{3}) (\d{1,}) ["](?:.+)["] ["](?:.+)["] ["](.+)["]$/;
        my ($a, $b) = $minute =~ /(\d{2}):(\d{2})/;
        $minute = $a.$b;    #храним минуты в формате HHMM
        $indices = 1 if $indices eq "-";

        my $uncompressed_data = $compressed_data * $indices;    #количество несжатых данных

        $total_data += $uncompressed_data;              #добавляем к счетчику несжатых данных
        $total_minutes{$minute} = 1;                    #минута, в которой произошел запрос
        $data_of_status{$status} += $compressed_data;   #количество сжатых данных по статусам запросов 
        $hash_of_ip{$ip}{"count"}++;                    #количество запросов от данного ip адреса
        $hash_of_ip{$ip}{"minutes"}{$minute} = 1;       #минуты, в которых происходили запросы от данного ip адреса
        $hash_of_ip{$ip}{"data"} += $uncompressed_data; #количество несжатых данных от данного ip
        $hash_of_ip{$ip}{$status} += $compressed_data;  #количество сжатых данных по каждому статусу от ip


        my $min_val = min values %top10_hash;
        
        if (scalar keys %top10_hash == 10) {            #формируем в процессе хэш 10 ip адресов с наибольшим количеством запросов
                if ($hash_of_ip{$ip}{"count"} > min values %top10_hash) {

                    $top10_hash{$ip} = $hash_of_ip{$ip}{"count"};

                    if (scalar keys %top10_hash > 10) {
                        foreach (keys %top10_hash) {
                            delete $top10_hash{$_} if $top10_hash{$_} == $min_val;
                        }
                    } 

                }
        }
        else {
            $top10_hash{$ip} = $hash_of_ip{$ip}{"count"};
        }

    #######################################################

    }
    close $fd;

    # you can put your code here
    #######################################################

    foreach (sort {$a <=> $b} values %top10_hash) { #сортируем значения хэша топ 10 ip адресов 
        my $arg = $_;
        my @a = grep {$top10_hash{$_} == $arg} keys %top10_hash;
        unshift @top_10_ip, @a;
    }

    my $count_of_minutes = scalar keys %total_minutes;

    $result = {
        "hash_of_ip" => \%hash_of_ip,
        "top_ip" => \@top_10_ip,
        "Count" => $query_count,
        "Data" => $total_data,
        "Status" => \%data_of_status,
        "Minutes" => $count_of_minutes,
    }; 

    #######################################################

    return $result;
}

sub report {
    my $result = shift;

    # you can put your code here
    #######################################################

    printf "%-8s%-8s%-8s%-8s","IP","count","avg","data";
    my @sort_status = sort keys $result->{"Status"};
    foreach (@sort_status) {
        printf "%-8s", $_;
    }
    printf "\n";
    printf "%-8s%-8s%-8.2f%-8.0f","total",$result->{"Count"},$result->{"Count"}/$result->{"Minutes"},$result->{"Data"}/1024;
    foreach (@sort_status) {
        printf "%-8.0f", $result->{"Status"}{$_}/1024;
    }
    print "\n";

    foreach (@{$result->{"top_ip"}}) {
        printf "%-16s%-8s%-8.2f%-8.0f", $_, $result->{"hash_of_ip"}{$_}{"count"}, 
                        $result->{"hash_of_ip"}{$_}{"count"}/(scalar keys $result->{"hash_of_ip"}{$_}{"minutes"}),
                        $result->{"hash_of_ip"}{$_}{"data"}/1024;

        my $arg = $_;
        foreach (@sort_status) {
            printf "%-8.0f", $result->{"hash_of_ip"}{$arg}{$_} ? $result->{"hash_of_ip"}{$arg}{$_}/1024 : 0;
        }
        print "\n";
    }

    #######################################################

}
