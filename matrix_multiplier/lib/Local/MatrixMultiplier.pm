package Local::MatrixMultiplier;

use strict;
use warnings;
use AnyEvent;

sub mult {
    my ($mat_a, $mat_b, $max_child) = @_;
    my $res = [];								#результирующая матрица

    my $matrix_size = scalar @{$mat_a} - 1;		#размерность квадратной матрицы
  
    if ((scalar @{@$mat_a[0]} -1 != $matrix_size) || (scalar @{$mat_b} -1 != $matrix_size) || (scalar @{@$mat_b[0]} -1 != $matrix_size)) {
    	die "Wrong matrix";				#проверка на корректность матрицы
    }

    my @for_processes = ();				#каждая строка в этой матрице - строки для обработки конкретным синхронным процессом

    if ($max_child >= $matrix_size) {
    	push @for_processes, [$_] for 0..$matrix_size;	#если $max_child больше или равно количеству строк, то по строке каждому процессу
    }
    else {

    	my $odd = ($matrix_size+1) % 2;					#иначе или каждому процессу по две строки если $max_child больше или равно половине строк
    	my $even = int ($matrix_size+1) / 2;			#или один процесс обрабатывает все в противном случае

    	if ($max_child >= $even + $odd) {				
    		for (0..$even-1) {
    			push @for_processes, [$_*2, $_*2+1]; 
    		}
    		push @for_processes, [$matrix_size] if $odd;
    	}
    	else {
    		push @for_processes, [0..$matrix_size];
    	}

    }

    sub async {											#асинхронная фукнция перемножения переданных строк
		my ($strings, $mat_a, $mat_b, $matrix_size, $res, $cb) = @_;
	    my $w;
	    $w = AE::timer 0, 0, sub {
	        undef $w;
	        foreach my $index (@$strings) {
	        	$res->[$index] = [];
	        	for my $i (0..$matrix_size) {
	        		my $string_element;
	        		for my $j (0..$matrix_size) {
	        			$string_element += $mat_a->[$index][$j] * $mat_b->[$j][$i];
	        		}
	        		$res->[$index][$i] = $string_element;
	        	}
	        }
			$cb->(); 
		};
		return; 
	}

	my $cv = AE::cv;
	for my $strings (@for_processes) {
		$cv->begin;
		async $strings, $mat_a, $mat_b, $matrix_size, $res, 
			sub {
				$cv->end; 
			}; 
	}

	$cv->recv;
    

    return $res;
}

1;