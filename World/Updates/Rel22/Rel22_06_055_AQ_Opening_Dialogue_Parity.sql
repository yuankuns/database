-- Restore the pinned Classic script_texts for the AQ opening sequence.
-- The 31 rows -1000740..-1000770 have matching keys and non-text fields;
-- these 17 content_default values differed in Zero's Full_DB baseline.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN RESIGNAL; END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='054' THEN
        DROP TEMPORARY TABLE IF EXISTS `aq_dialogue_stage`;
        CREATE TEMPORARY TABLE `aq_dialogue_stage` (
          `entry` MEDIUMINT PRIMARY KEY, `zero_text` VARCHAR(600) NOT NULL,
          `classic_text` VARCHAR(600) NOT NULL
        ) ENGINE=MEMORY;
        INSERT INTO `aq_dialogue_stage` VALUES
          (-1000770,'And now you know all that there is to know, mortal','And now you know all that there is to know, mortal... '),
          (-1000767,'My son\'s soul will find no comfort in this hollow victory, dragon! I will have him back. Though it takes a millenia. I WILL have my son back!','My son\'s soul will find no comfort in this hollow victory, dragon. I will have him back. Though it takes a millennia, I WILL have my son back!  '),
          (-1000764,'I want nothing to do with Silithus, the Qiraji and least of all, any damed dragons!','I want nothing to do with Silithus, the Qiraji and least of all, any damned dragons!'),
          (-1000761,'Before I leave this place, I make one final offering for you, Lord Staghelm. Should a time arise in which you must gain entry to this accursed fortress, use the scepter of the shifting sands on the sacred gong. The magic holding the barrier together will dissipate an the horrors of the Ahn\'Qiraj will be unleashed upon the world once more.','Before I leave this place, I make one final offering for you, Lord Staghelm. Should a time arise in which you must gain entry to this accursed fortress, use the Scepter of the Shifting Sands on the sacred gong. The magic holding the barrier together will dissipate and the horrors of Ahn\'Qiraj will be unleashed upon the world once more.'),
          (-1000760,'There is but one duty that remains','There is but one duty that remains...'),
          (-1000754,'Stay close.','Stay close...'),
          (-1000753,'It is done, dragon. Lead the way!','It is done, dragon. Lead the way.'),
          (-1000752,'NOW,STAGHELM! WE GO NOW! Prepare your magic!','NOW, STAGHELM! WE GO NOW! Prepare your magic!'),
          (-1000751,'Alexstrasza, give me the resolve to drive your enemies back.','Alexstrasza grant me the resolve to drive our enemies back!'),
          (-1000750,'Do not forget sacrifices made on this day, night elf. We have all suffered immensely at the hands of these beasts.','Do not forget the sacrifices made on this day, night elf. We have all suffered immensely at the hands of these beasts.'),
          (-1000749,'Let them feelt the wrath of the blue flight! May Malygos protect me!','Let them feel the wrath of the Blue Flight! May Malygos protect me!'),
          (-1000748,'Anachronos, the diversion will give you an the young druid time enough to seal the gate. Do not falter. Now, let us see how they deal with chaotic magic.','Anachronos, this diversion will give you and the young druid time enough to seal the gate. Do not falter. Now, let us see how they deal with chaotic magic.'),
          (-1000747,'Succumb to the endless dream, little ones. Let it comsume you!','Succumb to the endless dream, little ones. Let it consume you!'),
          (-1000746,'We will push him back, Anachronos. This is wow. Uphold your end of this task. Let not your hands falter as you seal our fates behind the barrier.','We will push him back, Anachronos. This I vow. Uphold your end of this task. Let not your hands falter as you seal our fates behind the barrier.'),
          (-1000744,'Aye, Fandral, remember these words: Let not your grief guide your faith. These thoughts you hold... dark places you go, night elf.Absolution cannot be had through misguided vengeance.','Aye, Fandral, remember these words: Let not your grief guide your faith. These thoughts you hold... dark places you go, night elf. Absolution cannot be had through misguided vengeance.'),
          (-1000741,'My forces cannot overcome the Qiraji defenses. We will not be able to get close enough to place our precious barrier, dragon.','My forces cannot overcome the Qiraji defenses. We will not be able to get close enough to place your precious barrier, dragon.'),
          (-1000740,'We must act quickly or shall be lost!','We must act quickly or all shall be lost!');

        IF EXISTS (SELECT 1 FROM `aq_dialogue_stage` s LEFT JOIN `script_texts` t USING (`entry`)
                   WHERE t.entry IS NULL OR t.content_default NOT IN (s.zero_text,s.classic_text)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ opening dialogue text conflict';
        END IF;
        UPDATE `script_texts` t JOIN `aq_dialogue_stage` s USING (`entry`)
          SET t.content_default=s.classic_text
          WHERE t.content_default=s.zero_text;
        DROP TEMPORARY TABLE `aq_dialogue_stage`;
        INSERT INTO `db_version` VALUES ('22','06','055','AQ_Opening_Dialogue_Parity',
          'Align AQ opening dialogue with Classic');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='055' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ dialogue parity requires 22/06/054';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
