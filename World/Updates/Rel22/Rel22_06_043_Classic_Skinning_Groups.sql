-- Restore Classic skinning group semantics for three donation-material sources.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN RESIGNAL; END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='042' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_classic_skinning_group_rows`;
        CREATE TEMPORARY TABLE `aq_classic_skinning_group_rows` (
          `entry` MEDIUMINT UNSIGNED NOT NULL,
          `item` MEDIUMINT UNSIGNED NOT NULL,
          `old_chance` FLOAT NOT NULL,
          `old_groupid` TINYINT UNSIGNED NOT NULL,
          `final_chance` FLOAT NOT NULL,
          `final_groupid` TINYINT UNSIGNED NOT NULL,
          `mincount` MEDIUMINT NOT NULL,
          `maxcount` TINYINT UNSIGNED NOT NULL,
          `condition_id` MEDIUMINT UNSIGNED NOT NULL,
          PRIMARY KEY (`entry`,`item`)
        );
        INSERT INTO `aq_classic_skinning_group_rows` VALUES
          (2505,4304,77.1689,0,77,1,1,1,0),
          (2505,8167,49.5809,0,50,2,1,2,0),
          (2505,8169,3.0062,0,3,1,1,1,0),
          (2505,8170,19.7919,0,20,1,1,1,0),
          (4374,4304,7.759,0,11,1,1,1,0),
          (4374,8170,81.034,0,84,1,1,2,0),
          (4374,8171,4.31,0,5,1,1,1,0),
          (4397,4234,76.643,0,77,1,1,1,0),
          (4397,4235,2.613,0,3,1,1,1,0),
          (4397,4304,20.735,0,20,1,1,1,0),
          (4397,8167,24.478,0,25,2,1,1,0);

        IF (SELECT COUNT(*) FROM `creature_template`
              WHERE Entry=2505 AND Name='Saltwater Snapjaw' AND SkinningLootId=2505)<>1 OR
           (SELECT COUNT(*) FROM `creature_template`
              WHERE Entry=4374 AND Name='Strashaz Hydra' AND SkinningLootId=4374)<>1 OR
           (SELECT COUNT(*) FROM `creature_template`
              WHERE Entry=4397 AND Name='Mudrock Spikeshell' AND SkinningLootId=4397)<>1 OR
           EXISTS (SELECT 1 FROM `creature_template`
              WHERE SkinningLootId IN (2505,4374,4397) AND Entry NOT IN (2505,4374,4397)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic skinning group template conflict';
        END IF;
        IF (SELECT COUNT(*) FROM `skinning_loot_template` WHERE entry IN (2505,4374,4397))<>11 OR
           EXISTS (SELECT 1 FROM `skinning_loot_template` l
              LEFT JOIN `aq_classic_skinning_group_rows` s ON s.entry=l.entry AND s.item=l.item
              WHERE l.entry IN (2505,4374,4397) AND
                (s.entry IS NULL OR
                 NOT ((l.ChanceOrQuestChance=s.old_chance AND l.groupid=s.old_groupid) OR
                      (l.ChanceOrQuestChance=s.final_chance AND l.groupid=s.final_groupid)) OR
                 l.mincountOrRef<>s.mincount OR l.maxcount<>s.maxcount OR l.condition_id<>s.condition_id)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic skinning group loot conflict';
        END IF;

        UPDATE `skinning_loot_template` l
          JOIN `aq_classic_skinning_group_rows` s ON s.entry=l.entry AND s.item=l.item
          SET l.ChanceOrQuestChance=s.final_chance,l.groupid=s.final_groupid,
              l.mincountOrRef=s.mincount,l.maxcount=s.maxcount,l.condition_id=s.condition_id;
        INSERT INTO `db_version` VALUES ('22','06','043','Classic_Skinning_Groups','Correct pinned skinning group semantics');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='043' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic skinning group correction requires 22/06/042';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
