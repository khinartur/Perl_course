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

    my %hash_of_ip = (total => {"ip" => "total"});     #хэш всех ip, с которых происходили запросы. Включает необходимые для вывода данные    
    my ($ip, $minute, $status, $compressed_data, $indices);     #информация из строки лога
    my @top_10_ip;     #топ десять ip адресов для вывода в результат

    #######################################################

    my $fd;
    if ($file =~ /\.bz2$/) {
        open $fd, "-|", "bunzip2 < $file" or die "Can't open '$file' via bunzip2: $!";
    } else {
        open $fd, "<", $file or die "Can't open '$file': $!";
    }

    my @result;
    while (my $log_line = <$fd>) {

        # you can put your code here
        # $log_line contains line from log file
    #######################################################

        next unless ($ip, $minute, $status, $compressed_data, $indices) = $log_line =~ 
                /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) \[(\d{1,2}\/[JFMASOND][a-z]{2}\/\d{4}:\d{2}:\d{2}):\d{2} \+\d{4}\] "[A-Z]+ [^"]+" (\d{3}) (\d{1,}) "[^"]+" "[^"]+" "(.+)"$/;

        $indices = 1 if $indices eq "-";

        my $uncompressed_data = $status eq "200" ? int ($compressed_data * $indices) : 0;    #количество несжатых данных
        
        foreach ('total', $ip) {
            $hash_of_ip{$_}{ip} = $_;
            $hash_of_ip{$_}{count}++;                                      #количество запросов от данного ip адреса
            $hash_of_ip{$_}{minutes}{$minute} = 1;                         #минуты, в которых происходили запросы от данного ip адреса
            $hash_of_ip{$_}{data} += $uncompressed_data;                   #количество несжатых данных от данного ip
            $hash_of_ip{$_}{data_of_status}{$status} += $compressed_data;  #количество сжатых данных по каждому статусу ответа для данного ip
        }

    #######################################################

    }

    close $fd;

    # you can put your code here
    #######################################################

    @top_10_ip = sort {$hash_of_ip{$b}{count} <=> $hash_of_ip{$a}{count}} keys %hash_of_ip;
    @top_10_ip = splice @top_10_ip, 0, 11;

    foreach (@top_10_ip) {
        push @result, $hash_of_ip{$_};
    }

    #######################################################

    return \@result;
}

sub report {
    my $result = shift;

    # you can put your code here
    #######################################################
    my $kb = 1024;  #для вывода в килобайтах

    my @sort_status = sort keys %{@{$result}[0]->{data_of_status}};
    local $" = "\t";
    print "IP\tcount\tavg\tdata\t@sort_status\n";

    my $format = "%s\t%d\t%.2f\t%d\t".join("\t", map { "%d" } @sort_status)."\n";
    
    foreach my $s (@$result) {
        printf $format, $s->{ip}, $s->{count}, $s->{count} / scalar keys %{$s->{minutes}}, $s->{data} / $kb,
            map {($s->{data_of_status}{$_} || 0) / $kb} @sort_status; 
    }

    #######################################################
}
