package Local::MatrixMultiplier;

use strict;
use warnings;
use Parallel::ForkManager;

sub mult {
    my ($mat_a, $mat_b, $max_child) = @_;

    my $res = [];               #результирующая матрица

	my $matrix_size = scalar @{$mat_a} - 1;   #размерность квадратной матрицы

	if ((scalar @{@$mat_a[0]} -1 != $matrix_size) || (scalar @{$mat_b} -1 != $matrix_size) || (scalar @{@$mat_b[0]} -1 != $matrix_size)) {
		die "Wrong matrix";       #проверка на корректность матрицы
	}

	my $pm = Parallel::ForkManager->new($max_child, '/tmp/');

	$pm->run_on_finish (
		sub {
			my ($pid, $exit_code, $ident, $exit_signal, $core_dump, $data_structure_reference) = @_;

			# достаем перемноженную строку из дочернего процесса
			if (defined($data_structure_reference)) {  # если дочерний процесс успешно вернул данные
				my $child_result = $data_structure_reference;  # дочерний процесс прислал ссылку на хэш
				  
				$res->[$child_result->{index}] = $child_result->{line};
			}
			else {  # если дочерний процесс ничего не вернул
				die 'Error occurs!';
			}
		}
	);

	# запустить параллельные процессы
	STRINGS:
	foreach my $index (0..$matrix_size) {
		$pm->start() and next STRINGS;

				my $line = [];

		        for my $i (0..$matrix_size) {
			        my $string_element;

			        for my $j (0..$matrix_size) {
			            $string_element += $mat_a->[$index][$j] * $mat_b->[$j][$i];
			        }
			        $line->[$i] = $string_element;
		        }
		      
		my $to_return = {index => $index, line => $line};

		$pm->finish(0, $to_return);  #вернуть готовую строку в мастер процесс
	}

	$pm->wait_all_children;

	return $res;
}

1;