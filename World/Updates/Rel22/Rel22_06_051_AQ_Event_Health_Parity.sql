-- Align runtime AQ health/mana with Classic's creature template multipliers.
-- For entry 15744, adjust the target multiplier for its different class-2
-- BaseHealth/BaseMana rows instead of changing those shared level tables.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN RESIGNAL; END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='050' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_health_stage`;
        CREATE TEMPORARY TABLE `aq_health_stage` (
          `entry` MEDIUMINT UNSIGNED NOT NULL PRIMARY KEY,
          `name` VARCHAR(100) NOT NULL,
          `old_health` FLOAT NOT NULL, `new_health` FLOAT NOT NULL,
          `old_power` FLOAT NOT NULL, `new_power` FLOAT NOT NULL
        ) ENGINE=MEMORY;
        INSERT INTO `aq_health_stage` VALUES
          (15702,'Senior Sergeant Taiga',1.34993,5,0,1),
          (15703,'Senior Sergeant Grimsford',0.557012,5,0,1),
          (15704,'Senior Sergeant Kai\'jin',2.26081,5,0,1),
          (15707,'Master Sergeant Fizzlebolt',0.360419,5,0,1),
          (15708,'Master Sergeant Maclure',2.26081,5,0,1),
          (15709,'Master Sergeant Moonshadow',0.288663,5,0,1),
          (15740,'Colossus of Zora',71.9604,1000,0,1),
          (15741,'Colossus of Regal',271.075,1000,0,1),
          (15742,'Colossus of Ashi',736.581,1000,0,1),
          (15743,'Colossal Anubisath Warbringer',98.335,110,0,1),
          (15744,'Imperial Qiraji Destroyer',37.4489,85.72375,2.50818,8.538653),
          (15748,'Lesser Anubisath Warbringer',0.383784,5,0,1),
          (15749,'Lesser Silithid Flayer',0.398953,2,0,1),
          (15751,'Anubisath Warbringer',8,8,0,1),
          (15752,'Silithid Flayer',2,2,0,1),
          (15754,'Greater Anubisath Warbringer',10,10,0,1),
          (15756,'Greater Silithid Flayer',3.94789,4,0,1),
          (15758,'Supreme Anubisath Warbringer',18.5357,20,0,1),
          (15759,'Supreme Silithid Flayer',5.24246,5,0,1),
          (15769,'Resonating Crystal',0.190476,3,0,1),
          (15770,'Greater Resonating Crystal',0.190476,3,0,1),
          (15771,'Major Resonating Crystal',0.190476,3,0,1),
          (15797,'Colossus Researcher Sophia',0.288663,1,0,1),
          (15798,'Colossus Researcher Nestor',0.288663,1,0,1),
          (15799,'Colossus Researcher Eazel',0.288663,1,0,1),
          (15804,'Lesser Resonating Crystal',0.190476,3,0,1),
          (15805,'Minor Resonating Crystal',0.190476,3,0,1),
          (15807,'Minor Anubisath Warbringer',4.86409,5,0,1),
          (15808,'Minor Silithid Flayer',1.78503,1.8,0,1),
          (15810,'Eroded Anubisath Warbringer',4.49438,4,0,1),
          (15811,'Faltering Silithid Flayer',0.558559,1.8,0,1),
          (15853,'Orgrimmar Elite Infantryman',3.04653,25,0,1),
          (15861,'Ironforge Infantryman',0.291118,25,0,1),
          (15878,'Warcaller Finster',0.190476,1,0,1);
        IF (SELECT COUNT(*) FROM `aq_health_stage`)<>34 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ health staging count mismatch';
        END IF;
        IF (SELECT COUNT(*) FROM `creature_template` t JOIN `aq_health_stage` s ON s.entry=t.Entry)<>34 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ health template count mismatch';
        END IF;
        IF EXISTS (SELECT 1 FROM `aq_health_stage` s LEFT JOIN `creature_template` t ON t.Entry=s.entry
             WHERE t.Entry IS NULL OR t.Name<>s.name OR
               (ABS(t.HealthMultiplier-s.old_health)>0.0001 AND ABS(t.HealthMultiplier-s.new_health)>0.0001) OR
               (ABS(t.PowerMultiplier-s.old_power)>0.0001 AND ABS(t.PowerMultiplier-s.new_power)>0.0001)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ health/mana source/target conflict';
        END IF;
        UPDATE `creature_template` t JOIN `aq_health_stage` s ON s.entry=t.Entry
          SET t.HealthMultiplier=s.new_health,t.PowerMultiplier=s.new_power;
        INSERT INTO `db_version` VALUES ('22','06','051','AQ_Event_Health_Parity','Align AQ combat health and mana');
        SELECT '* UPDATE COMPLETE *' AS status;
        DROP TEMPORARY TABLE `aq_health_stage`;
    ELSEIF @v='22' AND @s='06' AND @c='051' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ health parity requires 22/06/050';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
