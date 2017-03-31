#!/usr/bin/perl

use strict;
use warnings;
our $VERSION = 1.0;

use POSIX;
use List::Util qw/min/;

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

    my $query_count;    #количество запросов в общем
    my %total_minutes;      #все минуты, в которых происходят запросы
    my $total_data;     #количество несжатых данных всего
    my %data_of_status;     #статусы запросов и сжатые данные которые были переданы при них
    my %hash_of_ip;     #хэш всех ip, с которых происходили запросы. Включает необходимые для вывода данные    
    my ($ip, $minute, $status, $compressed_data, $indices);     #информация из строки лога
    my @top_10_ip;     #топ десять ip адресов для вывода в результат
    my %top10_hash;    #вспомогательный массив для формирования @top_10_ip

    #######################################################

     my $fd;
    if ($file =~ /\.bz2$/) {
        open $fd, "-|", "bunzip2 < $file" or die "Can't open '$file' via bunzip2: $!";
    } else {
        open $fd, "<", $file or die "Can't open '$file': $!";
    }

    my $result;
    while (my $log_line = <$fd>) {

        # you can put your code here
        # $log_line contains line from log file
    #######################################################

        next unless ($ip, $minute, $status, $compressed_data, $indices) = $log_line =~ 
                /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) \[(\d{1,2}\/[JFMASOND][a-z]{2}\/\d{4}:\d{2}:\d{2}):\d{2} \+\d{4}\] "[A-Z]+ [^"]+" (\d{3}) (\d{1,}) "[^"]+" "[^"]+" "(.+)"$/;
        $query_count++;

        $indices = 1 if $indices eq "-";

        my $uncompressed_data = $status eq "200" ? floor ($compressed_data * $indices) : 0;    #количество несжатых данных

        $total_data += $uncompressed_data;           #добавляем к счетчику несжатых данных
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
    my $kb = 1024;  #для вывода в килобайтах

    print "IP\tcount\tavg\tdata";
    my @sort_status = sort keys %{$result->{"Status"}};
    foreach (@sort_status) {
        print "\t$_";
    }
    printf "\n";
    printf "%s\t%s\t%.2f\t%.0f","total",$result->{"Count"},$result->{"Count"}/$result->{"Minutes"}, floor $result->{"Data"}/1024;
    foreach (@sort_status) {
        printf "\t%d", floor $result->{"Status"}{$_}/$kb;
    }
    print "\n";

    foreach (@{$result->{'top_ip'}}) {
        print("$_\t");
        print("$result->{'hash_of_ip'}{$_}{'count'}\t");
        printf("%.2f\t%d", $result->{"hash_of_ip"}{$_}{"count"}/(scalar keys %{$result->{"hash_of_ip"}{$_}{"minutes"}}),
                        floor $result->{"hash_of_ip"}{$_}{"data"}/$kb);

        foreach my $status (@sort_status) {
            printf "\t%d", $result->{"hash_of_ip"}{$_}{$status} ? floor $result->{"hash_of_ip"}{$_}{$status}/$kb : 0;
        }
        print "\n";
    }

    #######################################################


}
