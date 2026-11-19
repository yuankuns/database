-- Align shared donation-material skinning rates with the pinned Classic data.
-- Keep Zero's explicit group-1 normalization for the 21 affected templates.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN RESIGNAL; END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='043' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_classic_skinning_rate_rows`;
        CREATE TEMPORARY TABLE `aq_classic_skinning_rate_rows` (
          `entry` MEDIUMINT UNSIGNED NOT NULL,
          `item` MEDIUMINT UNSIGNED NOT NULL,
          `old_chance` FLOAT NOT NULL,
          `final_chance` FLOAT NOT NULL,
          `groupid` TINYINT UNSIGNED NOT NULL,
          `mincount` MEDIUMINT NOT NULL,
          `maxcount` TINYINT UNSIGNED NOT NULL,
          `condition_id` MEDIUMINT UNSIGNED NOT NULL,
          PRIMARY KEY (`entry`,`item`)
        );
        INSERT INTO `aq_classic_skinning_rate_rows` VALUES
          (4323,4234,40.283,40,1,1,1,0),(4323,4304,50.021,50,1,1,1,0),
          (4324,4234,38.762,39,1,1,1,0),(4324,4304,51.018,51,1,1,1,0),
          (4328,4234,35.736,35,1,1,2,0),(4328,4304,49.566,50,1,1,2,0),
          (4329,4234,34.93,35,1,1,2,0),(4329,4304,50.854,50,1,1,2,0),
          (4331,4234,35.603,35,1,1,2,0),(4331,4304,49.804,50,1,1,2,0),
          (4334,4234,34.473,35,1,1,2,0),(4334,4304,50.343,50,1,1,2,0),
          (4341,2319,42.934,43,1,1,1,0),(4341,4234,50.851,51,1,1,1,0),
          (4343,4234,78.05,78,1,1,1,0),(4343,4304,19.217,19,1,1,1,0),
          (4344,4234,77.698,78,1,1,1,0),(4344,4304,19.87,20,1,1,1,0),
          (4345,4234,77.351,77,1,1,1,0),(4345,4304,20.747,21,1,1,1,0),
          (4346,2319,30.841,31,1,1,1,0),(4346,4234,62.617,62,1,1,1,0),
          (4347,4234,73.864,74,1,1,1,0),(4347,4304,21.591,21,1,1,1,0),
          (4348,4234,77.982,78,1,1,1,0),(4348,4304,19.266,19,1,1,1,0),
          (4351,2319,43.627,44,1,1,1,0),(4351,4234,49.618,50,1,1,1,0),
          (4352,4234,77.463,77,1,1,1,0),(4352,4304,19.557,20,1,1,1,0),
          (4356,4234,78.564,78,1,1,1,0),(4356,4304,18.864,19,1,1,1,0),
          (4357,4234,77.552,78,1,1,1,0),(4357,4304,19.94,20,1,1,1,0),
          (4388,4234,76.957,77,1,1,1,0),(4388,4304,19.928,20,1,1,1,0),
          (4389,4234,42.308,43,1,1,1,0),(4389,4304,50.577,50,1,1,1,0),
          (4390,4234,39.286,39,1,1,1,0),(4390,4304,53.571,54,1,1,1,0),
          (4841,4234,43.797,44,1,1,1,0),(4841,4304,50.38,50,1,1,1,0),
          (8497,4304,45.3586,48,1,1,2,0),(8497,8170,17.5105,15,1,1,2,0);

        IF (SELECT COUNT(*) FROM `creature_template`
              WHERE Entry IN (4323,4324,4328,4329,4331,4334,4341,4343,4344,4345,4346,4347,4348,4351,4352,4356,4357,4388,4389,4390,4841,8497)
                AND SkinningLootId=Entry)<>22 OR
           EXISTS (SELECT 1 FROM `creature_template`
              WHERE SkinningLootId IN (4323,4324,4328,4329,4331,4334,4341,4343,4344,4345,4346,4347,4348,4351,4352,4356,4357,4388,4389,4390,4841,8497)
                AND Entry NOT IN (4323,4324,4328,4329,4331,4334,4341,4343,4344,4345,4346,4347,4348,4351,4352,4356,4357,4388,4389,4390,4841,8497)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic skinning rate template conflict';
        END IF;
        SELECT COUNT(*),SUM(NOT ((l.ChanceOrQuestChance=s.old_chance OR l.ChanceOrQuestChance=s.final_chance) AND
                         l.groupid=s.groupid AND l.mincountOrRef=s.mincount AND
                         l.maxcount=s.maxcount AND l.condition_id=s.condition_id))
          INTO @aq_skinning_rate_rows,@aq_skinning_rate_conflicts
          FROM `skinning_loot_template` l
          JOIN `aq_classic_skinning_rate_rows` s ON s.entry=l.entry AND s.item=l.item;
        IF @aq_skinning_rate_rows<>44 OR @aq_skinning_rate_conflicts<>0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic skinning rate loot conflict';
        END IF;

        UPDATE `skinning_loot_template` l
          JOIN `aq_classic_skinning_rate_rows` s ON s.entry=l.entry AND s.item=l.item
          SET l.ChanceOrQuestChance=s.final_chance;
        INSERT INTO `db_version` VALUES ('22','06','044','Classic_Skinning_Rates','Align shared donation skinning rates');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='044' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic skinning rate correction requires 22/06/043';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
