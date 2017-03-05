package SecretSanta;

use 5.010;
use strict;
use warnings;
use DDP;

sub calculate {
	my @members = @_;
	my @res;
	# ...
	#	push @res,[ "fromname", "toname" ];
	# ...
	my (@values, %pairs_done, %family); #@values - массив из всех имен без ссылок, %pairs_done - хэш пар, составленных случайным образом,
										#%family - хэш супружеских пар, которые по условию запрещены в качестве результата

	foreach my $val (@members) {		#формирование массива @values и хэша %family	
		unless (ref $val) {
			push @values, $val;
		} else {
			my @pair = ($val->[0], $val->[1]);
			$family{$val->[0]} = $val->[1];
			$family{$val->[1]} = $val->[0];
			push @values, @pair;
		}
	}

	my %unused_tonames;					#%unused_tonames - имена, которые еще не получили подарки
	@unused_tonames{@values} = (); 
	%pairs_done = map {$_ => @values[rand @values]} @values;

	while (my ($fromname, $toname) = each %pairs_done) {	 #проверка правильности подбора пар случайным образом

    	while ($fromname eq $toname || $pairs_done{$toname} eq $fromname || 
    		exists $family{$fromname} && $toname eq $family{$fromname} || !(exists $unused_tonames{$toname})) {
    		
    		$toname = @values[rand @values];	#если случайно подобранная пара не удовлетворяет условиям, то подобрать дарителя снова
    	}
    	
    	push @res, [$fromname, $toname];		#поместить сслыку на полученную пару в результирующий массив
    	delete $unused_tonames{$toname};		#$toname больше не может быть использован в качестве дарителя
	}

	
	return @res;
}

1;