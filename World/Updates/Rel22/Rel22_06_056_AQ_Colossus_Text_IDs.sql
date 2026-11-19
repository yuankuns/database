-- Move AQ-specific colossus arrival texts away from IDs used by Classic's
-- registered ScriptDev examples, and restore those source example rows.
DROP PROCEDURE IF EXISTS `update_mangos`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN RESIGNAL; END;
    SET @v := (SELECT `version` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @s := (SELECT `structure` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    SET @c := (SELECT `content` FROM `db_version` ORDER BY version DESC,structure DESC,content DESC LIMIT 1);
    IF @v='22' AND @s='06' AND @c='055' THEN
        IF (SELECT COUNT(*) FROM `script_texts` WHERE `entry` IN (-1999923,-1999924,-1999925) AND (
             (`entry`=-1999923 AND `type`=2 AND `language`=0 AND `sound`=0 AND `emote`=0
              AND `comment`='AQ colossus arrival'
              AND `content_default`='%s casts its massive shadow upon the whole of Silithus.') OR
             (`entry`=-1999924 AND `type`=2 AND `language`=0 AND `sound`=0 AND `emote`=0
              AND `comment`='AQ colossus arrival'
              AND `content_default`='%s hears the call to battle and rises to serve its master.') OR
             (`entry`=-1999925 AND `type`=2 AND `language`=0 AND `sound`=0 AND `emote`=0
              AND `comment`='AQ colossus arrival'
              AND `content_default`='%s breaks free of its cocoon beneath Hive\'Ashi.') OR
             (`entry`=-1999923 AND `type`=0 AND `language`=0 AND `sound`=0 AND `emote`=0
              AND `comment`='example_gossip_codebox SAY_WRONG' AND `content_default`='Wrong!') OR
             (`entry`=-1999924 AND `type`=0 AND `language`=0 AND `sound`=0 AND `emote`=0
              AND `comment`='example_gossip_codebox SAY_CORRECT'
              AND `content_default`='You\'re right, you are allowed to see my inner secrets.') OR
             (`entry`=-1999925 AND `type`=0 AND `language`=0 AND `sound`=0 AND `emote`=0
              AND `comment`='example_areatrigger SAY_HI' AND `content_default`='Hi!')
            ))<>3 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ colossus text ID source conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `script_texts` WHERE `entry`=-1999922 AND NOT
             (`type`=0 AND `language`=0 AND `sound`=0 AND `emote`=0
              AND `comment`='example_gossip_codebox SAY_NOT_INTERESTED'
              AND `content_default`='Normal select, guess you\'re not interested.')) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Classic example dialogue ID conflict';
        END IF;
        IF EXISTS (SELECT 1 FROM `script_texts` WHERE `entry` BETWEEN -1999802 AND -1999800 AND NOT (
             (`entry`=-1999800 AND `type`=2 AND `language`=0 AND `sound`=0 AND `emote`=0
              AND `comment`='AQ colossus arrival'
              AND `content_default`='%s casts its massive shadow upon the whole of Silithus.') OR
             (`entry`=-1999801 AND `type`=2 AND `language`=0 AND `sound`=0 AND `emote`=0
              AND `comment`='AQ colossus arrival'
              AND `content_default`='%s hears the call to battle and rises to serve its master.') OR
             (`entry`=-1999802 AND `type`=2 AND `language`=0 AND `sound`=0 AND `emote`=0
              AND `comment`='AQ colossus arrival'
              AND `content_default`='%s breaks free of its cocoon beneath Hive\'Ashi.'))) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ colossus text destination conflict';
        END IF;

        INSERT IGNORE INTO `script_texts`
          (`entry`,`content_default`,`type`,`language`,`sound`,`emote`,`comment`) VALUES
          (-1999800,'%s casts its massive shadow upon the whole of Silithus.',2,0,0,0,'AQ colossus arrival'),
          (-1999801,'%s hears the call to battle and rises to serve its master.',2,0,0,0,'AQ colossus arrival'),
          (-1999802,'%s breaks free of its cocoon beneath Hive\'Ashi.',2,0,0,0,'AQ colossus arrival');
        UPDATE `script_texts` SET
          `content_default`=CASE `entry`
            WHEN -1999923 THEN 'Wrong!'
            WHEN -1999924 THEN 'You\'re right, you are allowed to see my inner secrets.'
            ELSE 'Hi!' END,
          `type`=0,`language`=0,`sound`=0,`emote`=0,
          `comment`=CASE `entry`
            WHEN -1999923 THEN 'example_gossip_codebox SAY_WRONG'
            WHEN -1999924 THEN 'example_gossip_codebox SAY_CORRECT'
            ELSE 'example_areatrigger SAY_HI' END
          WHERE `entry` IN (-1999923,-1999924,-1999925);
        INSERT IGNORE INTO `script_texts`
          (`entry`,`content_default`,`type`,`language`,`sound`,`emote`,`comment`) VALUES
          (-1999922,'Normal select, guess you\'re not interested.',0,0,0,0,'example_gossip_codebox SAY_NOT_INTERESTED');
        INSERT INTO `db_version` VALUES ('22','06','056','AQ_Colossus_Text_IDs',
          'Move AQ texts away from Classic example IDs');
        SELECT '* UPDATE COMPLETE *' AS status;
    ELSEIF @v='22' AND @s='06' AND @c='056' THEN
        SELECT '* UPDATE SKIPPED *' AS status;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='AQ colossus text ID migration requires 22/06/055';
    END IF;
END$$
DELIMITER ;
CALL `update_mangos`();
DROP PROCEDURE `update_mangos`;
