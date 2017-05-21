create table Relation
(
	id int auto_increment
		primary key,
	first_friend int not null,
	second_friend int not null
)
comment 'Friendship graph'
;

create index first_friend
	on Relation (first_friend)
;

create index second_friend
	on Relation (second_friend)
;

create index Relation_id_index
	on Relation (id)
;

create table User
(
	id int auto_increment
		primary key,
	first_name varchar(30) not null,
	last_name varchar(30) not null
)
comment 'Users of social network'
;

create index User_id_index
	on User (id)
;

