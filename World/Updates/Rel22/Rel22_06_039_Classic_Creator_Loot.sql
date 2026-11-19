-- Port pinned Classic update 4876's crafted-creature loot tables.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN RESIGNAL; END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='038' THEN
        IF (SELECT COUNT(*) FROM `creature_template` WHERE `entry` IN (2673,2674,2676,12426))<>4 OR
           EXISTS (SELECT 1 FROM `creature_template` WHERE
             (`entry`=2673 AND (`Name`<>'Target Dummy' OR `LootId` NOT IN (0,2673))) OR
             (`entry`=2674 AND (`Name`<>'Advanced Target Dummy' OR `LootId` NOT IN (0,2674))) OR
             (`entry`=2676 AND (`Name`<>'Compact Harvest Reaper' OR `LootId`<>2676)) OR
             (`entry`=12426 AND (`Name`<>'Masterwork Target Dummy' OR `LootId` NOT IN (0,12426)))) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic creator-loot template binding conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `creature_template` WHERE `LootId` IN (2673,2674,2676,12426)
                   AND `entry` NOT IN (2673,2674,2676,12426)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic creator-loot table has an unexpected template reference';
        END IF;

        DROP TEMPORARY TABLE IF EXISTS `aq_creator_loot_old`;
        CREATE TEMPORARY TABLE `aq_creator_loot_old` (
          `entry` MEDIUMINT UNSIGNED NOT NULL, `item` MEDIUMINT UNSIGNED NOT NULL,
          `chance` FLOAT NOT NULL, `groupid` TINYINT UNSIGNED NOT NULL,
          `mincount` SMALLINT NOT NULL, `maxcount` TINYINT UNSIGNED NOT NULL,
          `condition_id` MEDIUMINT UNSIGNED NOT NULL, PRIMARY KEY (`entry`,`item`)
        );
        INSERT INTO `aq_creator_loot_old` VALUES
          (2676,414,2.4,0,1,1,0),(2676,858,7.22,0,1,1,0),(2676,1179,4.17,0,1,1,0),
          (2676,1645,9.64,0,1,1,0),(2676,1710,4.82,0,1,1,0),(2676,2287,1.04,0,1,1,0),
          (2676,2447,1.04,0,1,1,0),(2676,2450,2.4,0,1,1,0),(2676,2455,4.82,0,1,1,0),
          (2676,2589,1.04,0,1,1,0),(2676,2592,1.04,0,1,1,0),(2676,2770,2.4,0,1,1,0),
          (2676,2771,2.4,0,1,1,0),(2676,2772,4.82,0,1,1,0),(2676,2835,1.04,0,1,1,0),
          (2676,2838,2.4,0,1,1,0),(2676,3355,2.08,0,1,1,0),(2676,3358,2.4,0,1,1,0),
          (2676,3827,2.4,0,1,1,0),(2676,4382,2.4,0,1,1,0),(2676,4387,4,0,1,1,0),
          (2676,4389,0.8,0,1,1,0),(2676,4537,4.82,0,1,1,0),(2676,4541,4.82,0,1,1,0),
          (2676,4601,4.82,0,1,1,0),(2676,4605,1.04,0,1,1,0),(2676,7191,2.4,0,1,1,0),
          (2676,7910,2.4,0,1,1,0),(2676,24070,5,1,-24070,1,0),(2676,24078,1,1,-24078,1,0);

        DROP TEMPORARY TABLE IF EXISTS `aq_creator_loot_final`;
        CREATE TEMPORARY TABLE `aq_creator_loot_final` LIKE `aq_creator_loot_old`;
        INSERT INTO `aq_creator_loot_final` VALUES
          (2673,4363,50,0,1,1,0),(2673,4359,80,0,1,1,0),(2673,2841,70,0,1,1,0),
          (2673,2592,5,0,1,1,0),(2673,2589,75,0,1,1,0),(2673,7191,10,0,1,1,0),
          (2674,4387,60,0,1,1,0),(2674,4382,60,0,1,1,0),(2674,4389,60,0,1,1,0),
          (2674,4234,75,0,1,3,0),(2674,7191,25,0,1,1,0),
          (2676,4387,75,0,1,2,0),(2676,4382,50,0,1,1,0),(2676,4389,75,0,1,2,0),
          (2676,4234,75,4,1,3,0),(2676,7191,20,0,1,1,0),
          (12426,16000,40,0,1,1,0),(12426,6037,40,0,1,1,0),(12426,10561,40,0,1,1,0),
          (12426,15994,75,0,1,2,0),(12426,8170,100,0,1,2,0),(12426,7191,40,0,1,1,0);

        IF EXISTS (SELECT 1 FROM `creature_loot_template` l
          LEFT JOIN `aq_creator_loot_old` o ON o.entry=l.entry AND o.item=l.item
          LEFT JOIN `aq_creator_loot_final` f ON f.entry=l.entry AND f.item=l.item
          WHERE l.entry IN (2673,2674,2676,12426) AND
            (o.entry IS NULL OR l.ChanceOrQuestChance<>o.chance OR l.groupid<>o.groupid OR
               l.mincountOrRef<>o.mincount OR l.maxcount<>o.maxcount OR l.condition_id<>o.condition_id) AND
            (f.entry IS NULL OR l.ChanceOrQuestChance<>f.chance OR l.groupid<>f.groupid OR
               l.mincountOrRef<>f.mincount OR l.maxcount<>f.maxcount OR l.condition_id<>f.condition_id)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic creator-loot rows conflict with source or migration';
        END IF;

        UPDATE `creature_template` SET `LootId`=`entry` WHERE `entry` IN (2673,2674,2676,12426) AND `LootId`<>`entry`;
        DELETE FROM `creature_loot_template` WHERE `entry` IN (2673,2674,2676,12426);
        INSERT INTO `creature_loot_template` (`entry`,`item`,`ChanceOrQuestChance`,`groupid`,`mincountOrRef`,`maxcount`,`condition_id`)
          SELECT `entry`,`item`,`chance`,`groupid`,`mincount`,`maxcount`,`condition_id` FROM `aq_creator_loot_final`;
        INSERT INTO `db_version` VALUES ('22','06','039','Classic_Creator_Loot','Port pinned Classic update 4876 creator loot');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='039' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic creator-loot migration requires 22/06/038';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
