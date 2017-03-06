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
	my (@values, %family); 	#@values - массив из всех имен без ссылок, 
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

	unless (scalar @values <= 2 || scalar keys %family == 2 && scalar @values == 3) {

		until (scalar @values == scalar @res) {		#выполнять подбор, пока не будет столько правильных пар, сколько уникальных имен

			@res = ();
			my %forbiden_pairs;						#%forbiden_pairs - хэш из пар, которые на данный момент подбора запрещены в качестве результата
			my %helper = map {$_ => $_} @values;
			my %pairs_done;							#%pairs_done - хэш-результат случайного подбора пар

			foreach my $fromname (@values) {		#формирование %forbiden_pairs и %pairs_done
				my @harr = values %helper;
				my $i = @harr[rand @harr];
				$pairs_done{$fromname} = $i;
				$forbiden_pairs{$i} = $fromname;
				delete $helper{$i}; 
			}

			while (my ($fromname, $toname) = each %pairs_done) {	#проверка правильности случайного подбора
				
				if ($fromname eq $toname ||
					exists $family{$fromname} && $family{$fromname} eq $toname ||
					exists $forbiden_pairs{$fromname} && $forbiden_pairs{$fromname} eq $toname) {

					@res = ();
					last;
				}
				push @res, [$fromname, $toname];

			}

		}
	} else {
		@res = ();
	}
	
	return @res;
}

1;