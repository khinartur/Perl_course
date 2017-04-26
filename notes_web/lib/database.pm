package mydb;

use strict;
use warnings;

sub ppr_insert_user {
	return database->prepare('INSERT INTO user (login, password) VALUES (?, ?)');
}



1;