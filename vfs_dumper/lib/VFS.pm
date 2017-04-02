package VFS;
use utf8;
use strict;
use warnings;
use 5.010;
use File::Basename;
use File::Spec::Functions qw{catdir};
use JSON::XS;
no warnings 'experimental::smartmatch';

sub mode2s {
	my $rights = shift;

	return my $result = {
		other => {
			execute => $rights & 1 ? JSON::XS::true : JSON::XS::false, 
			write => ($rights >>= 1) & 1 ? JSON::XS::true : JSON::XS::false,
			read => ($rights >>= 1) & 1 ? JSON::XS::true : JSON::XS::false,
			},
		group => {
			execute => ($rights >>= 1) & 1 ? JSON::XS::true : JSON::XS::false, 
			write => ($rights >>= 1) & 1 ? JSON::XS::true : JSON::XS::false,
			read => ($rights >>= 1) & 1 ? JSON::XS::true : JSON::XS::false,
			},
		user => {
			execute => ($rights >>= 1) & 1 ? JSON::XS::true : JSON::XS::false,
			write => ($rights >>= 1) & 1 ? JSON::XS::true : JSON::XS::false,
			read => ($rights >>= 1) & 1 ? JSON::XS::true : JSON::XS::false,
			}
	};
}

sub parse { 

	my $arg = shift;
	my @arr = split //, $arg;
	my $total_result;

	my @levels;				#уровни вложенности
	my $temp_level = 0;

	my $next_byte = shift @arr;

	if ($next_byte eq "D") {			#формируем root и проверяем валидность входного буфера
				my $result = {};
				
				$result->{type} = 'directory';
	    		my $name_size = unpack 'n', join '', splice(@arr, 0, 2);
	       		$result->{name} = join '', splice(@arr, 0, $name_size);
	       		$result->{mode} = mode2s(unpack 'n', join '', splice(@arr, 0, 2));
	       		$result->{list} = [];
	       		$total_result = $result;
	       		$levels[$temp_level+1] = $result->{list};
	}
	elsif ($next_byte eq "Z") {
		return {};
	}
	else {
		die "The blob should start from 'D' or 'Z'";
	}

	$next_byte = shift @arr;

	while ($next_byte) {		#интерпретируем каждый байт буфера

		if ($next_byte eq "D") {
					my $result = {};

					$result->{type} = 'directory';
		    		my $name_size = unpack 'n', join '', splice(@arr, 0, 2);
		       		$result->{name} = join '', splice(@arr, 0, $name_size);
		       		$result->{mode} = mode2s(unpack 'n', join '', splice(@arr, 0, 2));
		       		$result->{list} = [];
		       		push @{$levels[$temp_level]}, $result;
		       		$levels[$temp_level+1] = $result->{list};
		}
		elsif ($next_byte eq "F") {
					my $result = {};

					$result->{type} = 'file';
		    		my $name_size = unpack 'n', join '', splice(@arr, 0, 2);
		       		$result->{name} = join '', splice(@arr, 0, $name_size);
		       		$result->{mode} = mode2s(unpack 'n', join '', splice(@arr, 0, 2));
		       		$result->{size} = unpack 'N', join '', splice(@arr, 0, 4);
		       		$result->{hash} = unpack 'H40', join '', splice(@arr, 0, 20);

		       		push @{$levels[$temp_level]}, $result;
		}
		elsif ($next_byte eq "I") {
			$temp_level++;
		}
		elsif ($next_byte eq "U") {
			$temp_level--;
		}
		elsif ($next_byte eq "Z") {
			die "Garbage ae the end of the buffer" if scalar @arr;
		}

		$next_byte = shift @arr;
	}

	return $total_result;
}

1;
