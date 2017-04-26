-- ---
-- Globals
-- ---

-- SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
-- SET FOREIGN_KEY_CHECKS=0;

-- ---
-- Table 'User'
-- 
-- ---

DROP TABLE IF EXISTS `User`;
		
CREATE TABLE `User` (
  `id` INTEGER NOT NULL AUTO_INCREMENT,
  `login` VARCHAR(255) NOT NULL,
  `password` CHAR(32) NOT NULL,
  PRIMARY KEY (`id`),
  KEY login_idx (`login`)
);

-- ---
-- Table 'Friend'
-- 
-- ---

DROP TABLE IF EXISTS `Friend`;
		
CREATE TABLE `Friend` (
  `id` INTEGER NOT NULL AUTO_INCREMENT,
  `first_login` INTEGER NOT NULL,
  `second_login` INTEGER NOT NULL,
  PRIMARY KEY (`id`)
);

-- ---
-- Table 'Note'
-- 
-- ---

DROP TABLE IF EXISTS `Note`;
		
CREATE TABLE `Note` (
  `id` BIGINT(20) NOT NULL,
  `user_id` INTEGER NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `content` LONGTEXT NOT NULL,
  `create_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `can_read` ENUM ('all', 'friends') NOT NULL,
  PRIMARY KEY (`id`)
);

-- ---
-- Foreign Keys 
-- ---

ALTER TABLE Friend ADD FOREIGN KEY (first_login) REFERENCES User (`id`);
ALTER TABLE Friend ADD FOREIGN KEY (second_login) REFERENCES User (`id`);
ALTER TABLE Note ADD FOREIGN KEY (user_id) REFERENCES User (`id`);

-- ---
-- Table Properties
-- ---

-- ALTER TABLE `User` ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
-- ALTER TABLE `Friend` ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
-- ALTER TABLE `Note` ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- ---
-- Test Data
-- ---

-- INSERT INTO `User` (`id`,`login`,`password`) VALUES
-- ('','','');
-- INSERT INTO `Friend` (`id`,`first_login`,`second_login`) VALUES
-- ('','','');
-- INSERT INTO `Note` (`id`,`user_id`,`create_time`,`can_read`) VALUES
-- ('','','','');