package Local::Reducer::MaxDiff;

use strict;
use warnings;

our $VERSION = '1.00';

our @ISA = qw(Local::Reducer);

use Local::Reducer;
use Local::Source::Array;
use Local::Source::Text;
use Local::Row::Simple;
use Local::Row::JSON;

sub new {
	my $class = $_[0];
	my ($top, $bottom, $source, $row_class, $initial_value) = ($_[2], $_[4], $_[6], $_[8], $_[10]);
	my $self = Local::Reducer->new($source, $row_class, $initial_value);
	$self->{top} = $top;
	$self->{bottom} = $bottom;

	bless $self, $class;

	return $self;
}

sub reduce_n {
	my $self = shift;
	my $res;		#результат итерации цикла

	for (1..shift) {
		my $next_str = $self->{source}->next;	#следующая обрабатываемая строка
		
		return $self->{initial_value} unless $next_str;	#если строки кончились - вернуть полученное значение
		next unless $self->{row_class}->new($next_str); #если строка не подходит по формату - не обрабатывать
		
		$res = $self->{row_class}->new($next_str)->get($self->{top}) - #res - разница между top и bottom
										$self->{row_class}->new($next_str)->get($self->{bottom});
		$self->{initial_value} = $res if $res > $self->{initial_value}; #если res больше текущей максимальной разницы, то заменить
	}
	return $self->{initial_value};
}

sub reduce_all {
	my $self = shift;
	my $res;

	my $next_str = $self->{source}->next;

	while ($next_str) {
		unless ($self->{row_class}->new($next_str)) {	#если строка не по формату - не обрабатывать
			$next_str = $self->{source}->next;	
			next;
		}
		$res = $self->{row_class}->new($next_str)->get($self->{top}) - 
										$self->{row_class}->new($next_str)->get($self->{bottom});
		$self->{initial_value} = $res if $res > $self->{initial_value};
		$next_str = $self->{source}->next;					
	}

	return $self->{initial_value};
}

1;