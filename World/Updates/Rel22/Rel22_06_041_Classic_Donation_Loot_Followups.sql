-- Correct residual Classic 4562/4645 loot and binding mismatches found by the
-- final-state row audit, including the table typo in migration 038.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN RESIGNAL; END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='040' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_classic_donation_skinning`;
        CREATE TEMPORARY TABLE `aq_classic_donation_skinning` (
          `entry` MEDIUMINT UNSIGNED NOT NULL, `item` MEDIUMINT UNSIGNED NOT NULL,
          `chance` FLOAT NOT NULL, `groupid` TINYINT UNSIGNED NOT NULL,
          `mincount` MEDIUMINT NOT NULL, `maxcount` TINYINT UNSIGNED NOT NULL,
          `condition_id` MEDIUMINT UNSIGNED NOT NULL, PRIMARY KEY (`entry`,`item`)
        );
        INSERT INTO `aq_classic_donation_skinning` VALUES
          (1892,2318,60.3333,1,1,1,0),(1893,2318,63.6364,1,1,1,0),
          (1896,2318,65.9574,1,1,1,0),(1933,2318,10.8339,1,1,1,0),
          (2098,2318,9.5133,1,1,1,0),(3529,2318,50,1,1,1,0),
          (3531,2318,56.25,1,1,1,0),(3854,2318,65,1,1,2,0),(3854,2319,25,1,1,2,0),
          (5720,8170,96.875,0,2,3,0),(5721,8170,97.093,0,2,3,0),
          (8437,4234,20,1,1,1,0),(8437,4304,70,1,1,1,0),
          (8438,4304,70,1,1,2,0),(8438,8170,25,1,1,2,0),
          (8976,4304,3,1,2,2,0),(8976,8170,55,1,1,2,0);

        DROP TEMPORARY TABLE IF EXISTS `aq_classic_donation_skinning_templates`;
        CREATE TEMPORARY TABLE `aq_classic_donation_skinning_templates` (
          `entry` MEDIUMINT UNSIGNED NOT NULL PRIMARY KEY, `name` VARCHAR(100) NOT NULL
        );
        INSERT INTO `aq_classic_donation_skinning_templates` VALUES
          (1892,'Moonrage Watcher'),(1893,'Moonrage Sentry'),(1896,'Moonrage Elder'),
          (1933,'Sheep'),(2098,'Ram'),(3529,'Moonrage Armorer'),(3531,'Moonrage Tailor'),
          (3854,'Shadowfang Wolfguard'),(5720,'Weaver'),(5721,'Dreamscythe'),
          (8437,'Hakkari Minion'),(8438,'Hakkari Bloodkeeper'),(8976,'Hematos');
        IF (SELECT COUNT(*) FROM `creature_template` t JOIN `aq_classic_donation_skinning_templates` s
              ON s.entry=t.Entry AND s.name=t.Name AND t.SkinningLootId IN (0,s.entry))<>13 OR
           EXISTS (SELECT 1 FROM `creature_template` WHERE SkinningLootId IN
             (1892,1893,1896,1933,2098,3529,3531,3854,5720,5721,8437,8438,8976)
             AND Entry NOT IN (1892,1893,1896,1933,2098,3529,3531,3854,5720,5721,8437,8438,8976)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic donation skinning binding conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `skinning_loot_template` l
          LEFT JOIN `aq_classic_donation_skinning` s ON s.entry=l.entry AND s.item=l.item
          WHERE l.entry IN (1892,1893,1896,1933,2098,3529,3531,3854,5720,5721,8437,8438,8976)
            AND (s.entry IS NULL OR l.ChanceOrQuestChance<>s.chance OR l.groupid<>s.groupid OR
              l.mincountOrRef<>s.mincount OR l.maxcount<>s.maxcount OR l.condition_id<>s.condition_id)) OR
           EXISTS (SELECT 1 FROM `creature_loot_template` WHERE entry=3733 AND item<>2447) OR
           EXISTS (SELECT 1 FROM `creature_loot_template` WHERE entry=3733 AND item=2447
             AND (ABS(ChanceOrQuestChance-2.96)>0.0001 OR groupid<>0 OR mincountOrRef<>1 OR
               maxcount<>1 OR condition_id<>0)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic donation loot row conflict';
        END IF;
        IF (SELECT COUNT(*) FROM `creature_template` WHERE Entry=3733 AND Name='Forsaken Herbalist' AND LootId IN (0,3733))<>1 OR
           EXISTS (SELECT 1 FROM `creature_template` WHERE LootId=3733 AND Entry<>3733) OR
           EXISTS (SELECT 1 FROM `creature_template` WHERE Entry=8384 AND Name<>'Deep Lurker') OR
           (SELECT COUNT(*) FROM `creature_loot_template` WHERE entry=8384 AND item IN (2447,3820,4625,8831,8836))<>5 OR
           EXISTS (SELECT 1 FROM `creature_loot_template` WHERE entry=8384 AND item IN (2447,3820,4625,8831,8836)
             AND (groupid NOT IN (0,1) OR mincountOrRef<>1 OR maxcount<>1 OR condition_id<>0 OR
               (item=2447 AND ABS(ChanceOrQuestChance-1.32)>0.0001) OR
               (item=3820 AND ABS(ChanceOrQuestChance-0.9)>0.0001) OR
               (item=4625 AND ABS(ChanceOrQuestChance-0.98)>0.0001) OR
               (item=8831 AND ABS(ChanceOrQuestChance-1.04)>0.0001) OR
               (item=8836 AND ABS(ChanceOrQuestChance-0.92)>0.0001))) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic herb or herbalist loot conflict';
        END IF;
        IF (SELECT COUNT(*) FROM `creature_template` WHERE Entry=2565 AND Name='Giant Plains Creeper'
              AND SkinningLootId IN (0,2565))<>1 OR
           EXISTS (SELECT 1 FROM `creature_template` WHERE SkinningLootId=2565 AND Entry<>2565) OR
           EXISTS (SELECT 1 FROM `skinning_loot_template` WHERE entry=2565 AND item=4234
             AND (ChanceOrQuestChance<>100 OR groupid<>1 OR mincountOrRef<>1 OR maxcount<>1 OR condition_id<>0)) OR
           EXISTS (SELECT 1 FROM `creature_template` WHERE Entry=10151) OR
           (SELECT COUNT(*) FROM `creature_template` WHERE Entry=11614 AND Name='Bloodshot'
              AND SkinningLootId IN (0,10151))<>1 OR
           EXISTS (SELECT 1 FROM `creature_template` WHERE SkinningLootId=10151
              AND NOT (Entry=11614 AND Name='Bloodshot')) OR
           EXISTS (SELECT 1 FROM `skinning_loot_template` WHERE entry=10151 AND NOT (
             (item=4304 AND ChanceOrQuestChance=40 AND groupid=0 AND mincountOrRef=1 AND maxcount=2 AND condition_id=0) OR
             (item=8154 AND ChanceOrQuestChance=60 AND groupid=0 AND mincountOrRef=1 AND maxcount=1 AND condition_id=0) OR
             (item=8169 AND ChanceOrQuestChance=3 AND groupid=0 AND mincountOrRef=1 AND maxcount=1 AND condition_id=0) OR
             (item=8170 AND ChanceOrQuestChance=48 AND groupid=0 AND mincountOrRef=1 AND maxcount=2 AND condition_id=0) OR
             (item=8171 AND ChanceOrQuestChance=4 AND groupid=0 AND mincountOrRef=1 AND maxcount=1 AND condition_id=0) OR
             (item=8368 AND ChanceOrQuestChance=5 AND groupid=0 AND mincountOrRef=1 AND maxcount=1 AND condition_id=0))) OR
           EXISTS (SELECT 1 FROM `creature_template` WHERE Entry=11497 AND Name='The Razza' AND LootId<>11497) OR
           EXISTS (SELECT 1 FROM `creature_loot_template` WHERE entry=11497 AND item IN (4304,8170) AND NOT (
             (item=4304 AND ABS(ChanceOrQuestChance-0.73)<0.0001 AND groupid=0 AND mincountOrRef=1 AND maxcount=1 AND condition_id=0) OR
             (item=8170 AND ABS(ChanceOrQuestChance-5.03)<0.0001 AND groupid=0 AND mincountOrRef=1 AND maxcount=1 AND condition_id=0))) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic loot cleanup conflict';
        END IF;

        UPDATE `creature_template` t JOIN `aq_classic_donation_skinning_templates` s ON s.entry=t.Entry
          SET t.SkinningLootId=t.Entry WHERE t.SkinningLootId=0;
        UPDATE `creature_template` SET LootId=3733 WHERE Entry=3733 AND LootId=0;
        UPDATE `creature_template` SET SkinningLootId=0 WHERE Entry=2565 AND SkinningLootId=2565;
        UPDATE `creature_template` SET SkinningLootId=0 WHERE Entry=11614 AND SkinningLootId=10151;
        DELETE FROM `creature_loot_template` WHERE entry=11497 AND item IN (4304,8170);
        DELETE FROM `creature_loot_template` WHERE entry=3733 AND item=2447;
        INSERT INTO `creature_loot_template` VALUES (3733,2447,2.96,0,1,1,0);
        UPDATE `creature_loot_template` SET groupid=1 WHERE entry=8384 AND item IN (2447,3820,4625,8831,8836) AND groupid=0;
        DELETE FROM `skinning_loot_template` WHERE entry=2565 AND item=4234;
        DELETE FROM `skinning_loot_template` WHERE entry=10151;
        INSERT INTO `skinning_loot_template`
          (`entry`,`item`,`ChanceOrQuestChance`,`groupid`,`mincountOrRef`,`maxcount`,`condition_id`)
          SELECT s.`entry`,s.`item`,s.`chance`,s.`groupid`,s.`mincount`,s.`maxcount`,s.`condition_id`
          FROM `aq_classic_donation_skinning` s
          LEFT JOIN `skinning_loot_template` l ON l.entry=s.entry AND l.item=s.item
          WHERE l.entry IS NULL;
        INSERT INTO `db_version` VALUES ('22','06','041','Classic_Loot_Followups','Correct pinned donation loot and bindings');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='041' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic donation loot follow-up migration requires 22/06/040';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
