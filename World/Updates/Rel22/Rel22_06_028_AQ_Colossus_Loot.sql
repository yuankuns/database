-- Restore the canonical grouped loot for the three AQ world colossi.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        RESIGNAL;
    END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='027' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_colossus_loot_items`;
        CREATE TEMPORARY TABLE `aq_colossus_loot_items` (
            `item` MEDIUMINT UNSIGNED NOT NULL,
            `ChanceOrQuestChance` FLOAT NOT NULL,
            `groupid` TINYINT UNSIGNED NOT NULL,
            `mincountOrRef` MEDIUMINT NOT NULL,
            `maxcount` TINYINT UNSIGNED NOT NULL,
            `condition_id` MEDIUMINT UNSIGNED NOT NULL,
            PRIMARY KEY (`item`)
        );
        INSERT INTO `aq_colossus_loot_items` VALUES
          (1203,0,1,1,1,0),
          (1973,0,1,1,1,0),
          (2564,0,1,1,1,0),
          (4696,0,1,1,1,0),
          (5266,0,1,1,1,0),
          (6622,0,1,1,1,0),
          (7734,0,1,1,1,0),
          (9402,0,1,1,1,0),
          (11302,0,1,1,1,0),
          (13000,0,1,1,1,0),
          (13001,0,2,1,1,0),
          (13002,0,2,1,1,0),
          (13003,0,2,1,1,0),
          (13004,0,2,1,1,0),
          (13006,0,2,1,1,0),
          (13007,0,2,1,1,0),
          (13008,0,2,1,1,0),
          (13009,0,2,1,1,0),
          (13013,0,2,1,1,0),
          (13015,0,2,1,1,0),
          (13030,0,3,1,1,0),
          (13036,0,3,1,1,0),
          (13040,0,3,1,1,0),
          (13047,0,3,1,1,0),
          (13053,0,3,1,1,0),
          (13060,0,3,1,1,0),
          (13066,0,3,1,1,0),
          (13067,0,3,1,1,0),
          (13070,0,3,1,1,0),
          (13072,0,3,1,1,0),
          (13073,0,4,1,1,0),
          (13075,0,4,1,1,0),
          (13077,0,4,1,1,0),
          (13083,0,4,1,1,0),
          (13085,0,4,1,1,0),
          (13091,0,4,1,1,0),
          (13096,0,4,1,1,0),
          (13107,0,4,1,1,0),
          (13111,0,4,1,1,0),
          (13116,0,4,1,1,0),
          (13118,0,5,1,1,0),
          (13120,0,5,1,1,0),
          (13123,0,5,1,1,0),
          (13125,0,5,1,1,0),
          (13126,0,5,1,1,0),
          (13130,0,5,1,1,0),
          (13133,0,5,1,1,0),
          (13135,0,5,1,1,0),
          (13144,0,5,1,1,0),
          (13146,0,5,1,1,0),
          (647,0,6,1,1,0),
          (811,0,6,1,1,0),
          (1168,0,6,1,1,0),
          (1263,0,6,1,1,0),
          (1728,0,6,1,1,0),
          (2099,0,6,1,1,0),
          (2244,0,6,1,1,0),
          (2801,0,6,1,1,0),
          (14555,0,6,1,1,0),
          (833,0,7,1,1,0),
          (944,0,7,1,1,0),
          (1443,0,7,1,1,0),
          (2243,0,7,1,1,0),
          (2245,0,7,1,1,0),
          (2246,0,7,1,1,0),
          (3475,0,7,1,1,0),
          (14553,0,7,1,1,0),
          (14554,0,7,1,1,0),
          (14558,0,7,1,1,0);
        DROP TEMPORARY TABLE IF EXISTS `aq_colossus_loot_stage`;
        CREATE TEMPORARY TABLE `aq_colossus_loot_stage` LIKE `creature_loot_template`;
        INSERT INTO `aq_colossus_loot_stage`
          (`entry`,`item`,`ChanceOrQuestChance`,`groupid`,`mincountOrRef`,`maxcount`,`condition_id`)
          SELECT e.entry,i.item,i.ChanceOrQuestChance,i.groupid,i.mincountOrRef,i.maxcount,i.condition_id
          FROM (SELECT 15740 AS entry UNION ALL SELECT 15741 UNION ALL SELECT 15742) e
          CROSS JOIN `aq_colossus_loot_items` i;

        IF (SELECT COUNT(*) FROM `creature_template` WHERE `entry` IN (15740,15741,15742))<>3 OR
           EXISTS (SELECT 1 FROM `creature_template` WHERE `entry` IN (15740,15741,15742)
                    AND `LootId` NOT IN (0,`entry`)) OR
           (SELECT COUNT(*) FROM `aq_colossus_loot_stage`)<>207 OR
           (SELECT COUNT(*) FROM `item_template` WHERE `entry` IN (SELECT `item` FROM `aq_colossus_loot_items`))<>69 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ colossus loot template or item conflict';
        END IF;
        IF EXISTS (
          SELECT 1 FROM `creature_loot_template` a
          LEFT JOIN `aq_colossus_loot_stage` s ON s.entry=a.entry AND s.item=a.item
          WHERE a.entry IN (15740,15741,15742) AND
            (s.entry IS NULL OR NOT (a.ChanceOrQuestChance <=> s.ChanceOrQuestChance AND
             a.groupid <=> s.groupid AND a.mincountOrRef <=> s.mincountOrRef AND
             a.maxcount <=> s.maxcount AND a.condition_id <=> s.condition_id))
        ) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ colossus existing loot row conflict';
        END IF;

        INSERT IGNORE INTO `creature_loot_template`
          (`entry`,`item`,`ChanceOrQuestChance`,`groupid`,`mincountOrRef`,`maxcount`,`condition_id`)
          SELECT `entry`,`item`,`ChanceOrQuestChance`,`groupid`,`mincountOrRef`,`maxcount`,`condition_id`
          FROM `aq_colossus_loot_stage`;
        UPDATE `creature_template` SET `LootId`=`entry` WHERE `entry` IN (15740,15741,15742) AND `LootId`=0;
        INSERT INTO `db_version` VALUES ('22','06','028','AQ_Colossus_Loot',
          'Restore AQ colossus loot');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='028' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ colossus loot migration requires 22/06/027';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;

