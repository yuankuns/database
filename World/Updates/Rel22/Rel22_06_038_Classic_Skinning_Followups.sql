-- Port remaining pinned Classic 4645/4853 donation-source corrections.
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
    IF @v='22' AND @s='06' AND @c='037' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_skinning_followup_stage`;
        CREATE TEMPORARY TABLE `aq_skinning_followup_stage` (
          `entry` MEDIUMINT UNSIGNED NOT NULL,
          `item` MEDIUMINT UNSIGNED NOT NULL,
          `chance` FLOAT NOT NULL,
          `groupid` TINYINT UNSIGNED NOT NULL,
          `mincountOrRef` MEDIUMINT NOT NULL,
          `maxcount` TINYINT UNSIGNED NOT NULL,
          `condition_id` MEDIUMINT UNSIGNED NOT NULL,
          PRIMARY KEY (`entry`,`item`)
        );
        INSERT INTO `aq_skinning_followup_stage` VALUES
          (14223,4234,75,1,1,1,0),(14223,4304,20,1,1,1,0),(14223,4235,5,1,1,1,0),(14223,8167,20,2,1,1,0),
          (5935,4234,65,1,1,2,0),(5935,4304,30,1,1,2,0),(5935,4235,5,1,1,1,0),
          (8208,4234,45,1,1,1,0),(8208,4304,50,1,1,1,0),(8208,4235,5,1,1,1,0),
          (1559,8170,50,1,1,2,0),(1559,4304,40,1,1,2,0),(1559,8171,5,1,1,1,0),(1559,8169,5,1,1,1,0);

        DROP TEMPORARY TABLE IF EXISTS `aq_skinning_followup_templates`;
        CREATE TEMPORARY TABLE `aq_skinning_followup_templates` (
          `entry` MEDIUMINT UNSIGNED NOT NULL PRIMARY KEY,
          `name` VARCHAR(100) NOT NULL,
          `old_loot_id` MEDIUMINT UNSIGNED NOT NULL
        );
        INSERT INTO `aq_skinning_followup_templates` VALUES
          (14223,'Cranky Benj',100002),(5935,'Ironeye the Invincible',100004),
          (8208,'Murderous Blisterpaw',100004),(1559,'King Mukla',1559);
        SELECT COUNT(*),COALESCE(SUM(t.Entry IS NULL),0),COALESCE(SUM(t.Entry IS NOT NULL AND
            (t.Name<>s.name OR t.SkinningLootId NOT IN (s.old_loot_id,s.entry))),0)
          INTO @template_count,@missing_templates,@template_conflicts
          FROM `aq_skinning_followup_templates` s LEFT JOIN `creature_template` t ON t.Entry=s.entry;
        IF @template_count<>4 OR @missing_templates<>0 OR @template_conflicts<>0 OR
           (SELECT COUNT(*) FROM `creature_template` WHERE SkinningLootId=100002 AND Entry<>14223)<>0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic skinning follow-up template conflict';
        END IF;

        SELECT COALESCE(SUM(CASE
            WHEN l.entry IS NULL THEN 0
            WHEN s.entry IS NULL THEN 1
            WHEN ABS(l.ChanceOrQuestChance-s.chance)<0.0001 AND l.groupid=s.groupid AND
              l.mincountOrRef=s.mincountOrRef AND l.maxcount=s.maxcount AND l.condition_id=s.condition_id THEN 0
            WHEN l.entry=1559 AND (
              (l.item=4304 AND ABS(l.ChanceOrQuestChance-39.2713)<0.0001 AND l.groupid=1 AND l.mincountOrRef=1 AND l.maxcount=2 AND l.condition_id=0) OR
              (l.item=8169 AND ABS(l.ChanceOrQuestChance-4.4534)<0.0001 AND l.groupid=1 AND l.mincountOrRef=1 AND l.maxcount=1 AND l.condition_id=0) OR
              (l.item=8170 AND ABS(l.ChanceOrQuestChance-50.6073)<0.0001 AND l.groupid=1 AND l.mincountOrRef=1 AND l.maxcount=2 AND l.condition_id=0) OR
              (l.item=8171 AND ABS(l.ChanceOrQuestChance-5.668)<0.0001 AND l.groupid=1 AND l.mincountOrRef=1 AND l.maxcount=1 AND l.condition_id=0)) THEN 0
            ELSE 1 END),0)
          INTO @bad_followup_rows
          FROM `skinning_loot_template` l LEFT JOIN `aq_skinning_followup_stage` s
            ON s.entry=l.entry AND s.item=l.item
          WHERE l.entry IN (14223,5935,8208,1559);
        IF @bad_followup_rows<>0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic skinning follow-up loot row conflict';
        END IF;
        IF (SELECT COUNT(*) FROM `skinning_loot_template` WHERE entry=100002)>1 OR
           EXISTS (SELECT 1 FROM `skinning_loot_template` WHERE entry=100002 AND
             NOT (item=8167 AND ChanceOrQuestChance=100 AND groupid=1 AND mincountOrRef=1 AND maxcount=1 AND condition_id=0)) OR
           EXISTS (SELECT 1 FROM `creature_loot_template` WHERE entry=2565 AND item=4234 AND
             (ChanceOrQuestChance<>100 OR groupid<>1 OR mincountOrRef<>1 OR maxcount<>1 OR condition_id<>0)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic skinning cleanup row conflict';
        END IF;

        UPDATE `creature_template` t JOIN `aq_skinning_followup_templates` s ON s.entry=t.Entry
          SET t.SkinningLootId=t.Entry WHERE t.SkinningLootId=s.old_loot_id AND t.SkinningLootId<>t.Entry;
        DELETE FROM `skinning_loot_template` WHERE entry IN (14223,5935,8208,1559,100002);
        INSERT INTO `skinning_loot_template`
          (`entry`,`item`,`ChanceOrQuestChance`,`groupid`,`mincountOrRef`,`maxcount`,`condition_id`)
          SELECT `entry`,`item`,`chance`,`groupid`,`mincountOrRef`,`maxcount`,`condition_id`
          FROM `aq_skinning_followup_stage`;
        DELETE FROM `creature_loot_template` WHERE entry=2565 AND item=4234;
        INSERT INTO `db_version` VALUES ('22','06','038','Classic_Skinning_Followups',
          'Apply pinned Classic skinning-source follow-ups');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='038' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic skinning follow-up requires 22/06/037';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
