package VFS;
use utf8;
use strict;
use warnings;
use 5.010;
use File::Basename;
use File::Spec::Functions qw{catdir};
use JSON::XS;
use Encode;
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
	my $total_result;

	my @levels;				#уровни вложенности
	my $temp_level = 0;

	my $position = 0;
	my $next_byte = substr $arg, $position++, 1;

	if ($next_byte eq "D") {			#формируем root и проверяем валидность входного буфера
				my $result = {};
				
				$result->{type} = 'directory';
	    		my $name_size = unpack 'n', substr $arg, $position, 2;
	    		$position += 2;
	       		$result->{name} = substr $arg, $position, $name_size;
	       		$position += $name_size;
	       		$result->{mode} = mode2s(unpack 'n', substr $arg, $position, 2);
	       		$position += 2;
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

	$next_byte = substr $arg, $position++, 1;

	while ($next_byte) {		#интерпретируем каждый байт буфера

		if ($next_byte eq "D") {
					my $result = {};
					
					$result->{type} = 'directory';
		    		my $name_size = unpack 'n', substr $arg, $position, 2;
		    		$position += 2;
		       		$result->{name} = decode_utf8(substr $arg, $position, $name_size);
		       		$position += $name_size;
		       		$result->{mode} = mode2s(unpack 'n', substr $arg, $position, 2);
		       		$position += 2;
		       		$result->{list} = [];
		       		push @{$levels[$temp_level]}, $result;
		       		$levels[$temp_level+1] = $result->{list};
		}
		elsif ($next_byte eq "F") {
					my $result = {};

					$result->{type} = 'file';
		    		my $name_size = unpack 'n', substr $arg, $position, 2;
		    		$position += 2;
		       		my $str = substr $arg, $position, $name_size;
		       		$result->{name} = decode_utf8($str);
		       		$position += $name_size;
		       		$result->{mode} = mode2s(unpack 'n', substr $arg, $position, 2);
		       		$position += 2;
		       		$result->{size} = unpack 'N', substr $arg, $position, 4;
		       		$position += 4;
		       		$result->{hash} = unpack 'H40', substr $arg, $position, 20;
		       		$position += 20;

		       		push @{$levels[$temp_level]}, $result;
		}
		elsif ($next_byte eq "I") {
			$temp_level++;
		}
		elsif ($next_byte eq "U") {
			$temp_level--;
		}
		elsif ($next_byte eq "Z") {
			die "Garbage ae the end of the buffer" if substr $arg, $position, 1;
		}
		$next_byte = substr $arg, $position++, 1;
	}

	return $total_result;
}

1;