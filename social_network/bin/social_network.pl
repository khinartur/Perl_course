#!/usr/bin/perl

use strict;
use warnings;

use utf8;
use FindBin;
use lib "$FindBin::Bin/../lib";
use YAML;
use Getopt::Long;
use JSON;
use DBI;
no warnings 'experimental::smartmatch';
use feature 'switch';

my $command = shift;
my @users;

GetOptions ("user=i", \@users)  
or die("Error in command line arguments\n");

my $config = YAML::LoadFile("$FindBin::Bin/../etc/config.yaml");

my ($database, $host, $port, $user, $pass) = 
			(
				$config->{database},
				$config->{host},
				$config->{port},
				$config->{user},
				$config->{pass}
			);

		
my $dbh = DBI->connect(
	"DBI:mysql:database=$database;" .
	"host=$host;port=$port",
	$user, 
	$pass,
	{ RaiseError => 1, AutoCommit => 1 },
);

given ($command) {
  	when ('friends') {
  		die "Input id of both users!" unless $users[0] && $users[1]; 
  		my ($user1, $user2) = ($users[0], $users[1]);

		my $sth = $dbh->prepare(
				'SELECT friends1.first_friend, friends1.second_friend
				FROM
				(SELECT r.first_friend, r.second_friend FROM Relation r WHERE r.first_friend = ? OR r.second_friend = ?) friends1
				INNER JOIN
				(SELECT r.first_friend, r.second_friend FROM Relation r WHERE r.first_friend = ? OR r.second_friend = ?) friends2
				ON 
				friends1.first_friend = friends2.first_friend
				OR
				friends1.first_friend = friends2.second_friend
				OR 
				friends1.second_friend = friends2.first_friend
				OR 
				friends1.second_friend = friends2.second_friend'
			);

		$sth->execute($user1, $user1, $user2, $user2);
		my $array_ref = $sth->fetchall_arrayref({});
		
		foreach my $relation (@$array_ref) {
			my ($first, $second) = ($relation->{first_friend}, $relation->{second_friend});
			
			my $common = ( $first == $user1 or $first == $user2 ) ? $second : $first;	#нужен не совпадающий с введенными пользователь 
			$user = $dbh->selectrow_hashref('SELECT id, first_name, last_name FROM User WHERE id = ?', {}, $common);	
			print to_json($user);
		}		
  	}
  	when ('nofriends') {

		my $array_ref = $dbh->selectall_arrayref(
			'SELECT q.id, q.first_name, q.last_name FROM 
			( SELECT uuu.id, uuu.first_name, uuu.last_name FROM User uuu
			LEFT JOIN Relation rrr
			ON uuu.id = rrr.first_friend 
			WHERE rrr.first_friend IS NULL ) q 
			LEFT JOIN Relation r 
			ON q.id = r.second_friend 
			WHERE r.second_friend IS NULL', { slice => {} }
			);

		my @params_array = ('id', 0, 'first_name', 0, 'last_name', 0);
		foreach my $user (@$array_ref) {
			$params_array[1] = $user->[0];
			$params_array[3] = $user->[1];
			$params_array[5] = $user->[2];
			my %result = @params_array;
			print to_json(\%result);
			print "\n";
		}
		
  	}
  	when ('num_handshakes') {
  		die "Input id of both users!" unless $users[0] && $users[1]; 
  		my ($user1, $user2) = ($users[0], $users[1]);

  		my @friends = ($user1);		#ищем пользователя user2 естественно сначала среди друзей user1
  		my $num_handshakes = 1;
  		my $found = 0;

  		while (@friends && !$found) {		#пока есть среди чьих друзей проверять и мы еще не нашли нужного нам пользователя user2
  			
  			my @array_of_friends;
  			my @level_friends = ();			#вспомогательный массив - друзья на уровне $num_handshakes рукопожатий

  			while (@friends) {
  				my $friend = shift @friends;

  				@array_of_friends = $dbh->selectall_array(
  					'SELECT first_friend FROM Relation WHERE second_friend = ? 
  					UNION ALL
    				SELECT second_friend FROM Relation WHERE first_friend = ?', {}, ($friend, $friend)
  				);
  				my $count = grep { @{$_}[0] == $user2 } @array_of_friends;
				if ($count) { $found++; last; }
				for (@level_friends) { push @friends, @$_; }
  			}

  			last if $found;
  			$num_handshakes++;
  			for (@level_friends) { push @friends, @$_; }
  			@level_friends = ();
  		}

  		print $num_handshakes;
  	}
  	default {
  		print "Supported commands: 'friends' 'nofriends' 'num_handshakes'\n";
  	}
}