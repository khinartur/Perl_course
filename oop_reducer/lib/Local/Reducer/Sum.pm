package Local::Reducer::Sum;

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
	my $class = shift;
    my %params = @_; 
    my ($field, $source, $row_class, $initial_value) = ($params{field}, $params{source}, $params{row_class}, $params{initial_value});

	my $self = Local::Reducer->new($source, $row_class, $initial_value);
	$self->{field} = $field;

	bless $self, $class;

	return $self;
}

sub reduce_n {
	my $self = shift;

	for (1..shift) {
		my $next_str = $self->{source}->next;	#получение строки лога

		return $self->{initial_value} unless $next_str;		#если строки кончились - вернуть текущий результат
		next unless $self->{row_class}->new($next_str);		#если строка не по формату - не обрабатывать

		$self->{initial_value} += $self->{row_class}->new($next_str)->get($self->{field}); #приращение результирующей суммы
	}
	return $self->{initial_value};
}

sub reduce_all {
	my $self = shift;

	my $next_str = $self->{source}->next;
	
	while ($next_str) {
		unless ($self->{row_class}->new($next_str)) {	#если строка не по формату - не обрабатывать
			$next_str = $self->{source}->next;	
			next;
		}
		$self->{initial_value} += $self->{row_class}->new($next_str)->get($self->{field});
		$next_str = $self->{source}->next;					
	}

	return $self->{initial_value};
}

1;