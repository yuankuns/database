-- Alliance donation quest 8520 has no predecessor in the pinned Classic DB.
-- Zero's baseline incorrectly gates it behind the unrelated Wild Leather
-- Armor quest 2847.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN RESIGNAL; END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='052' THEN
        IF (SELECT COUNT(*) FROM `quest_template` WHERE entry=8520
              AND Title='The Alliance Needs Silk Bandages!'
              AND PrevQuestId IN (0,2847))<>1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ donation quest prerequisite conflict';
        END IF;
        UPDATE `quest_template` SET PrevQuestId=0
          WHERE entry=8520 AND Title='The Alliance Needs Silk Bandages!' AND PrevQuestId=2847;
        INSERT INTO `db_version` VALUES ('22','06','053','AQ_Quest_Prerequisite_Parity','Remove unrelated AQ donation quest prerequisite');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='053' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ quest prerequisite parity requires 22/06/052';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
