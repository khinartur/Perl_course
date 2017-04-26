package mydb;

use strict;
use warnings;
use utf8;
use Dancer2;
use Dancer2::Plugin::Database;

sub ppr_insert_user {
	return database->prepare('INSERT INTO user (login, password) VALUES (?, ?)');
}

sub ppr_select_note {
	return database->prepare('SELECT user_id, title, content, create_time, can_read FROM note WHERE id = cast(? as signed)');
}

sub ppr_insert_note {
	return database->prepare('INSERT INTO note (id, user_id, title, content, create_time, can_read) VALUES (cast(? as signed), ?, ?, ?, from_unixtime(?), ?)');
}

sub select_my_notes {
	my $login = shift;
	return database->selectall_arrayref('SELECT cast(n.id as unsigned) as id, n.create_time, n.title FROM note n INNER JOIN user u ON n.user_id = u.id where u.login = ?', {Slice => {}}, $login);
}

sub select_my_friends {
	my $user_id = shift;
	return database->selectall_arrayref('SELECT u.login FROM friend f INNER JOIN user u ON u.id = f.second_login WHERE f.first_login = ?', {Slice => {}}, $user_id);
}

sub is_friend {
	my ($logged_id, $person_id) = @_;
	return database->do('SELECT * FROM friend f WHERE f.first_login = ? AND f.second_login = ?', {}, $logged_id, $person_id);
}

sub select_guest_notes {
	my ($login, $can_read) = @_;
	return database->selectall_arrayref("SELECT cast(n.id as unsigned) as id, n.create_time, n.title FROM note n INNER JOIN user u ON n.user_id = u.id WHERE u.login = ? AND (n.can_read = 'all' OR n.can_read = ?)", {Slice => {}}, $login, $can_read);
}

sub get_people_list {
	return database->selectall_arrayref('SELECT u.login FROM user u', {Slice => {}});
}

sub insert_friend {
	my ($first, $second) = @_;
	database->do('INSERT INTO friend (first_login, second_login) VALUES (?,?)', {}, $first, $second);
}

1;