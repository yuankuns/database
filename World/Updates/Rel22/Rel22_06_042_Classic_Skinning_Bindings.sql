-- Apply pinned Classic 4642/4645/4647/4853 skinning bindings and table corrections.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN RESIGNAL; END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='041' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_classic_skinning_templates`;
        CREATE TEMPORARY TABLE `aq_classic_skinning_templates` (
          `entry` MEDIUMINT UNSIGNED NOT NULL PRIMARY KEY,
          `name` VARCHAR(100) NOT NULL,
          `old_loot_id` MEDIUMINT UNSIGNED NOT NULL,
          `final_loot_id` MEDIUMINT UNSIGNED NOT NULL
        );
        INSERT INTO `aq_classic_skinning_templates` VALUES
          (2831,'Giant Buzzard',2831,0),
          (5982,'Black Slayer',5982,0),
          (5983,'Bonepicker',5982,0),
          (14750,'Gurubashi Bat Rider',14750,0),
          (15316,'Qiraji Scarab',100003,0),
          (11787,'Rock Borer',100004,0),
          (11788,'Rock Worm',100004,0),
          (15718,'Ouro Scarab',100003,0),
          (756,'Skullsplitter Panther',10240,0),
          (3475,'Echeyakee',10116,3475),
          (7997,'Captured Sprite Darter',100001,7997),
          (10116,'Slave',0,0),
          (6728,'Narnie',100008,0),
          (7269,'Scarab',100004,0),
          (10376,'Crystal Fang',100003,0),
          (10596,'Mother Smolderweb',100003,0),
          (14490,'Rippa',100004,0);

        DROP TEMPORARY TABLE IF EXISTS `aq_classic_skinning_deleted_rows`;
        CREATE TEMPORARY TABLE `aq_classic_skinning_deleted_rows` (
          `entry` MEDIUMINT UNSIGNED NOT NULL,
          `item` MEDIUMINT UNSIGNED NOT NULL,
          `chance` FLOAT NOT NULL,
          `groupid` TINYINT UNSIGNED NOT NULL,
          `mincount` MEDIUMINT NOT NULL,
          `maxcount` TINYINT UNSIGNED NOT NULL,
          `condition_id` MEDIUMINT UNSIGNED NOT NULL,
          PRIMARY KEY (`entry`,`item`)
        );
        INSERT INTO `aq_classic_skinning_deleted_rows` VALUES
          (2831,4234,100,1,1,1,0),
          (5982,4304,100,1,1,1,0),
          (14750,8170,100,1,1,1,0),
          (10116,783,7,1,1,1,0),(10116,2318,70,1,1,2,0),
          (10116,2319,21,1,1,2,0),(10116,4232,2,1,1,1,0),
          (10240,4234,40,1,1,1,0),(10240,4235,4,1,1,1,0),
          (10240,4304,52,1,1,1,0),(10240,8169,4,1,1,1,0);

        DROP TEMPORARY TABLE IF EXISTS `aq_classic_skinning_final_rows`;
        CREATE TEMPORARY TABLE `aq_classic_skinning_final_rows` (
          `entry` MEDIUMINT UNSIGNED NOT NULL,
          `item` MEDIUMINT UNSIGNED NOT NULL,
          `chance` FLOAT NOT NULL,
          `groupid` TINYINT UNSIGNED NOT NULL,
          `mincount` MEDIUMINT NOT NULL,
          `maxcount` TINYINT UNSIGNED NOT NULL,
          `condition_id` MEDIUMINT UNSIGNED NOT NULL,
          PRIMARY KEY (`entry`,`item`)
        );
        INSERT INTO `aq_classic_skinning_final_rows` VALUES
          (3475,783,5.6075,1,1,1,0),(3475,2318,73.8318,1,1,2,0),
          (3475,2319,18.6916,1,1,1,0),(3475,4232,1.8692,1,1,1,0),
          (7997,4234,44,1,1,1,0),(7997,4235,3,1,1,1,0),
          (7997,4304,44,1,1,1,0),(7997,8165,3,1,1,1,0),
          (7997,8169,6,1,1,1,0),
          (4339,4234,30,1,1,1,0),(4339,4235,5,1,1,1,0),
          (4339,4304,65,1,1,1,0),(4339,8165,2,0,1,1,0);

        IF (SELECT COUNT(*) FROM `creature_template` t
              JOIN `aq_classic_skinning_templates` s ON s.entry=t.Entry AND s.name=t.Name
              WHERE t.SkinningLootId IN (s.old_loot_id,s.final_loot_id))<>17 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic skinning template conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `creature_template` t
              JOIN `aq_classic_skinning_templates` s ON s.entry=t.Entry
              WHERE t.Name<>s.name OR t.SkinningLootId NOT IN (s.old_loot_id,s.final_loot_id)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic skinning binding conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `creature_template` t
              JOIN `aq_classic_skinning_deleted_rows` s ON s.entry=t.SkinningLootId
              WHERE t.Entry NOT IN (2831,5982,5983,14750,3475,10116,756)) OR
           EXISTS (SELECT 1 FROM `creature_template`
              WHERE SkinningLootId IN (3475,7997) AND Entry NOT IN (3475,7997)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic skinning external binding conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `skinning_loot_template` l
              LEFT JOIN `aq_classic_skinning_deleted_rows` s ON s.entry=l.entry AND s.item=l.item
              WHERE l.entry IN (2831,5982,14750,10116,10240)
                AND (s.entry IS NULL OR l.ChanceOrQuestChance<>s.chance OR l.groupid<>s.groupid OR
                  l.mincountOrRef<>s.mincount OR l.maxcount<>s.maxcount OR l.condition_id<>s.condition_id)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic deleted skinning row conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `skinning_loot_template` l
              LEFT JOIN `aq_classic_skinning_final_rows` s ON s.entry=l.entry AND s.item=l.item
              WHERE l.entry IN (3475,7997)
                AND (s.entry IS NULL OR l.ChanceOrQuestChance<>s.chance OR l.groupid<>s.groupid OR
                  l.mincountOrRef<>s.mincount OR l.maxcount<>s.maxcount OR l.condition_id<>s.condition_id)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic inserted skinning row conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `skinning_loot_template` WHERE entry=4339 AND NOT (
             (item=4234 AND ChanceOrQuestChance=30 AND groupid IN (0,1) AND mincountOrRef=1 AND maxcount=1 AND condition_id=0) OR
             (item=4235 AND ChanceOrQuestChance=5 AND groupid=1 AND mincountOrRef=1 AND maxcount=1 AND condition_id=0) OR
             (item=4304 AND ChanceOrQuestChance=65 AND groupid IN (0,1) AND mincountOrRef=1 AND maxcount=1 AND condition_id=0) OR
             (item=8165 AND ChanceOrQuestChance IN (2,6.25) AND groupid=0 AND mincountOrRef=1 AND maxcount=1 AND condition_id=0) OR
             (item=8169 AND ChanceOrQuestChance=9.375 AND groupid=0 AND mincountOrRef=1 AND maxcount=1 AND condition_id=0))) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic Brimgore skinning row conflict';
        END IF;
        IF (SELECT COUNT(*) FROM `creature_template` WHERE Entry=4339 AND Name='Brimgore' AND SkinningLootId=4339)<>1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic Brimgore binding conflict';
        END IF;

        UPDATE `creature_template` t
          JOIN `aq_classic_skinning_templates` s ON s.entry=t.Entry
          SET t.SkinningLootId=s.final_loot_id WHERE t.SkinningLootId=s.old_loot_id;
        DELETE FROM `skinning_loot_template` WHERE entry IN (2831,5982,14750,10116,10240,3475,7997,4339);
        INSERT INTO `skinning_loot_template`
          (`entry`,`item`,`ChanceOrQuestChance`,`groupid`,`mincountOrRef`,`maxcount`,`condition_id`)
          SELECT entry,item,chance,groupid,mincount,maxcount,condition_id
          FROM `aq_classic_skinning_final_rows`;
        INSERT INTO `db_version` VALUES ('22','06','042','Classic_Skinning_Bindings','Apply pinned skinning bindings and loot corrections');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='042' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic skinning correction requires 22/06/041';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
