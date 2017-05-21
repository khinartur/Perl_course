LOAD DATA INFILE '/private/tmp/user_relation'
INTO TABLE Relation
CHARACTER SET utf8
FIELDS TERMINATED BY ' ' LINES TERMINATED BY '\n'
(first_friend, second_friend);

LOAD DATA INFILE '/private/tmp/user'
INTO TABLE User
CHARACTER SET utf8
FIELDS TERMINATED BY ' ' LINES TERMINATED BY '\n'
(id, first_name, last_name);