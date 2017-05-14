package Crawler;

use 5.010;
use strict;
use warnings;

use AnyEvent::HTTP;
use Web::Query;
use URI;

=encoding UTF8

=head1 NAME

Crawler

=head1 SYNOPSIS

Web Crawler

=head1 run($start_page, $parallel_factor)

Сбор с сайта всех ссылок на уникальные страницы

Входные данные:

$start_page - Ссылка с которой надо начать обход сайта

$parallel_factor - Значение фактора паралельности

Выходные данные:

$total_size - суммарный размер собранных ссылок в байтах

@top10_list - top-10 страниц отсортированный по размеру.

=cut

use constant MAX_URI_COUNT => 1000; #максимальное количество собранных уникальных ссылок
my %uri_hash;						#хэш уникальных ссылок
my @uris;							#массив всех найденных ссылок
my $total_size;						#суммарный размер собранных ссылок в байтах

sub get_uris {
	my ($body, $base) = @_;
	my @result;

	wq($body)
	    ->find('a')					#найти все теги <a>
	    ->each(sub {				#для каждой найденной ссылки получить ее абсолютный адрес и убрать теги привязки и добавить в result
	        my $uri = URI->new_abs($_->attr('href'), $base);					#и uri_hash если она до этого не встречалась
	        if ($uri =~ m/^$base[^#]/ && !(exists $uri_hash{$uri}) && scalar keys %uri_hash < MAX_URI_COUNT) {
	        	$uri_hash{$uri} = 0;
				push @result, $uri;
	        }
	    });

	return @result;
}

sub load_page {
	my ($base, $page, $cb) = @_;
 	my $size;
 	my @links_found;

 	my $guard; $guard = http_request
	    HEAD => $page,
	    sub { 
	    	undef $guard;
	    	if ($_[1]->{'content-type'} =~ m/^text\/html/) {

	    		http_request
				    GET => $page,
				    timeout => 1,
				    sub {
				        my ($body, $hdr) = @_;
				        if ($hdr->{Status} == 200) {
				        	$size = length $body;
				        	$total_size += $size;
				        	$uri_hash{$page} = $size;
				        	push @uris, $_ foreach @links_found = get_uris($body, $base);
				        } else {
				            warn "Fail: @$hdr{qw(Status Reason)}";
				        }
				        $cb->();
					};
	    	}
	    };

	return;
}

sub run {
    my ($start_page, $parallel_factor) = @_;
    $start_page or die "You must setup url parameter";
    $parallel_factor or die "You must setup parallel factor > 0";

    my @top10_list;
    my $base = URI->new($start_page);
    my $startbody;

    @uris = ($start_page);

    my $cv = AE::cv();
    $cv->begin;

    my $processes = 0; 	#количество параллельных загрузок страниц
    my $next; $next = sub {
    	while ($processes <= $parallel_factor and @uris and scalar keys %uri_hash < MAX_URI_COUNT) {
    		my $page = shift @uris;
    		say "Loading page $page";
    		$processes++;
    		$cv->begin;
    		load_page ( $base, $page, sub { $processes--; $next->(); $cv->end;} );
    	}
    }; $next->();

    $cv->end;
    $cv->recv();

    @top10_list = sort { $uri_hash{$b} <=> $uri_hash{$a} } keys %uri_hash;
	@top10_list = splice @top10_list, 0, 10;

    return $total_size, @top10_list;
}

1;
