-- Dump of Mythconverg database - 
-- Dumped via MythTV 0.20.1+fixes13716
-- by Mario Limonciello <superm1@ubuntu.com>
-- using MySQL dump 10.11
--
-- Currently this file has all instances of
-- the hostname set as OLDHOSTNAME
--
-- All instances of the ip address are set
-- as 127.0.0.1
--
-- The language setting has been removed
--
--
-- Host: OLDHOSTNAME    Database: mythconverg
-- ------------------------------------------------------
-- Server version    5.0.41-Debian_1-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `archiveitems`
--

DROP TABLE IF EXISTS `archiveitems`;
CREATE TABLE `archiveitems` (
  `intid` int(10) unsigned NOT NULL auto_increment,
  `type` set('Recording','Video','File') default NULL,
  `title` varchar(128) default NULL,
  `subtitle` varchar(128) default NULL,
  `description` text,
  `startdate` varchar(30) default NULL,
  `starttime` varchar(30) default NULL,
  `size` int(10) unsigned NOT NULL,
  `filename` text NOT NULL,
  `hascutlist` tinyint(1) NOT NULL default '0',
  `cutlist` text,
  PRIMARY KEY  (`intid`),
  KEY `title` (`title`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `archiveitems`
--

LOCK TABLES `archiveitems` WRITE;
/*!40000 ALTER TABLE `archiveitems` DISABLE KEYS */;
/*!40000 ALTER TABLE `archiveitems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `callsignnetworkmap`
--

DROP TABLE IF EXISTS `callsignnetworkmap`;
CREATE TABLE `callsignnetworkmap` (
  `id` int(11) NOT NULL auto_increment,
  `callsign` varchar(20) NOT NULL default '',
  `network` varchar(20) NOT NULL default '',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `callsign` (`callsign`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `callsignnetworkmap`
--

LOCK TABLES `callsignnetworkmap` WRITE;
/*!40000 ALTER TABLE `callsignnetworkmap` DISABLE KEYS */;
/*!40000 ALTER TABLE `callsignnetworkmap` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `capturecard`
--

DROP TABLE IF EXISTS `capturecard`;
CREATE TABLE `capturecard` (
  `cardid` int(10) unsigned NOT NULL auto_increment,
  `videodevice` varchar(128) default NULL,
  `audiodevice` varchar(128) default NULL,
  `vbidevice` varchar(128) default NULL,
  `cardtype` varchar(32) default 'V4L',
  `defaultinput` varchar(32) default 'Television',
  `audioratelimit` int(11) default NULL,
  `hostname` varchar(255) default NULL,
  `dvb_swfilter` int(11) default '0',
  `dvb_recordts` int(11) default '1',
  `dvb_sat_type` int(11) NOT NULL default '0',
  `dvb_wait_for_seqstart` int(11) NOT NULL default '1',
  `skipbtaudio` tinyint(1) default '0',
  `dvb_on_demand` tinyint(4) NOT NULL default '0',
  `dvb_diseqc_type` smallint(6) default NULL,
  `firewire_port` int(10) unsigned NOT NULL default '0',
  `firewire_node` int(10) unsigned NOT NULL default '2',
  `firewire_speed` int(10) unsigned NOT NULL default '0',
  `firewire_model` varchar(32) default NULL,
  `firewire_connection` int(10) unsigned NOT NULL default '0',
  `dvb_hw_decoder` int(11) default '0',
  `dbox2_port` int(10) unsigned NOT NULL default '31338',
  `dbox2_httpport` int(10) unsigned NOT NULL default '80',
  `dbox2_host` varchar(32) default NULL,
  `signal_timeout` int(11) NOT NULL default '1000',
  `channel_timeout` int(11) NOT NULL default '3000',
  `parentid` int(10) NOT NULL default '0',
  `dvb_tuning_delay` int(10) unsigned NOT NULL default '0',
  `contrast` int(11) NOT NULL default '0',
  `brightness` int(11) NOT NULL default '0',
  `colour` int(11) NOT NULL default '0',
  `hue` int(11) NOT NULL default '0',
  `diseqcid` int(10) unsigned default NULL,
  PRIMARY KEY  (`cardid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `capturecard`
--

LOCK TABLES `capturecard` WRITE;
/*!40000 ALTER TABLE `capturecard` DISABLE KEYS */;
/*!40000 ALTER TABLE `capturecard` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cardinput`
--

DROP TABLE IF EXISTS `cardinput`;
CREATE TABLE `cardinput` (
  `cardinputid` int(10) unsigned NOT NULL auto_increment,
  `cardid` int(10) unsigned NOT NULL default '0',
  `sourceid` int(10) unsigned NOT NULL default '0',
  `inputname` varchar(32) NOT NULL default '',
  `externalcommand` varchar(128) default NULL,
  `preference` int(11) NOT NULL default '0',
  `shareable` char(1) default 'N',
  `tunechan` varchar(10) default NULL,
  `startchan` varchar(10) default NULL,
  `freetoaironly` tinyint(1) default '1',
  `diseqc_port` smallint(6) default NULL,
  `diseqc_pos` float default NULL,
  `lnb_lof_switch` int(11) default '11700000',
  `lnb_lof_hi` int(11) default '10600000',
  `lnb_lof_lo` int(11) default '9750000',
  `displayname` varchar(64) NOT NULL default '',
  `radioservices` tinyint(1) default '1',
  `childcardid` int(10) NOT NULL default '0',
  `dishnet_eit` tinyint(1) NOT NULL default '0',
  `recpriority` int(11) NOT NULL default '0',
  PRIMARY KEY  (`cardinputid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `cardinput`
--

LOCK TABLES `cardinput` WRITE;
/*!40000 ALTER TABLE `cardinput` DISABLE KEYS */;
/*!40000 ALTER TABLE `cardinput` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `channel`
--

DROP TABLE IF EXISTS `channel`;
CREATE TABLE `channel` (
  `chanid` int(10) unsigned NOT NULL default '0',
  `channum` varchar(10) NOT NULL default '',
  `freqid` varchar(10) default NULL,
  `sourceid` int(10) unsigned default NULL,
  `callsign` varchar(20) NOT NULL default '',
  `name` varchar(64) NOT NULL default '',
  `icon` varchar(255) NOT NULL default 'none',
  `finetune` int(11) default NULL,
  `videofilters` varchar(255) NOT NULL default '',
  `xmltvid` varchar(64) NOT NULL default '',
  `recpriority` int(10) NOT NULL default '0',
  `contrast` int(11) default '32768',
  `brightness` int(11) default '32768',
  `colour` int(11) default '32768',
  `hue` int(11) default '32768',
  `tvformat` varchar(10) NOT NULL default 'Default',
  `commfree` tinyint(4) NOT NULL default '0',
  `visible` tinyint(1) NOT NULL default '1',
  `outputfilters` varchar(255) NOT NULL default '',
  `useonairguide` tinyint(1) default '0',
  `mplexid` smallint(6) default NULL,
  `serviceid` mediumint(8) unsigned default NULL,
  `atscsrcid` int(11) default NULL,
  `tmoffset` int(11) NOT NULL default '0',
  `atsc_major_chan` int(10) unsigned NOT NULL default '0',
  `atsc_minor_chan` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`chanid`),
  KEY `channel_src` (`channum`,`sourceid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `channel`
--

LOCK TABLES `channel` WRITE;
/*!40000 ALTER TABLE `channel` DISABLE KEYS */;
/*!40000 ALTER TABLE `channel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `codecparams`
--

DROP TABLE IF EXISTS `codecparams`;
CREATE TABLE `codecparams` (
  `profile` int(10) unsigned NOT NULL default '0',
  `name` varchar(128) NOT NULL default '',
  `value` varchar(128) default NULL,
  PRIMARY KEY  (`profile`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `codecparams`
--

LOCK TABLES `codecparams` WRITE;
/*!40000 ALTER TABLE `codecparams` DISABLE KEYS */;
/*!40000 ALTER TABLE `codecparams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `credits`
--

DROP TABLE IF EXISTS `credits`;
CREATE TABLE `credits` (
  `person` mediumint(8) unsigned NOT NULL default '0',
  `chanid` int(10) unsigned NOT NULL default '0',
  `starttime` datetime NOT NULL default '0000-00-00 00:00:00',
  `role` set('actor','director','producer','executive_producer','writer','guest_star','host','adapter','presenter','commentator','guest') NOT NULL default '',
  UNIQUE KEY `chanid` (`chanid`,`starttime`,`person`,`role`),
  KEY `person` (`person`,`role`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `credits`
--

LOCK TABLES `credits` WRITE;
/*!40000 ALTER TABLE `credits` DISABLE KEYS */;
/*!40000 ALTER TABLE `credits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customexample`
--

DROP TABLE IF EXISTS `customexample`;
CREATE TABLE `customexample` (
  `rulename` varchar(64) NOT NULL,
  `fromclause` text NOT NULL,
  `whereclause` text NOT NULL,
  PRIMARY KEY  (`rulename`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `customexample`
--

LOCK TABLES `customexample` WRITE;
/*!40000 ALTER TABLE `customexample` DISABLE KEYS */;
/*!40000 ALTER TABLE `customexample` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `diseqc_config`
--

DROP TABLE IF EXISTS `diseqc_config`;
CREATE TABLE `diseqc_config` (
  `cardinputid` int(10) unsigned NOT NULL,
  `diseqcid` int(10) unsigned NOT NULL,
  `value` varchar(16) NOT NULL default '',
  KEY `id` (`cardinputid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `diseqc_config`
--

LOCK TABLES `diseqc_config` WRITE;
/*!40000 ALTER TABLE `diseqc_config` DISABLE KEYS */;
/*!40000 ALTER TABLE `diseqc_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `diseqc_tree`
--

DROP TABLE IF EXISTS `diseqc_tree`;
CREATE TABLE `diseqc_tree` (
  `diseqcid` int(10) unsigned NOT NULL auto_increment,
  `parentid` int(10) unsigned default NULL,
  `ordinal` tinyint(3) unsigned NOT NULL,
  `type` varchar(16) NOT NULL default '',
  `subtype` varchar(16) NOT NULL default '',
  `description` varchar(32) NOT NULL default '',
  `switch_ports` tinyint(3) unsigned NOT NULL default '0',
  `rotor_hi_speed` float NOT NULL default '0',
  `rotor_lo_speed` float NOT NULL default '0',
  `rotor_positions` varchar(255) NOT NULL default '',
  `lnb_lof_switch` int(10) NOT NULL default '0',
  `lnb_lof_hi` int(10) NOT NULL default '0',
  `lnb_lof_lo` int(10) NOT NULL default '0',
  `cmd_repeat` int(11) NOT NULL default '1',
  PRIMARY KEY  (`diseqcid`),
  KEY `parentid` (`parentid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `diseqc_tree`
--

LOCK TABLES `diseqc_tree` WRITE;
/*!40000 ALTER TABLE `diseqc_tree` DISABLE KEYS */;
/*!40000 ALTER TABLE `diseqc_tree` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dtv_multiplex`
--

DROP TABLE IF EXISTS `dtv_multiplex`;
CREATE TABLE `dtv_multiplex` (
  `mplexid` smallint(6) NOT NULL auto_increment,
  `sourceid` smallint(6) default NULL,
  `transportid` int(11) default NULL,
  `networkid` int(11) default NULL,
  `frequency` int(11) default NULL,
  `inversion` char(1) default 'a',
  `symbolrate` int(11) default NULL,
  `fec` varchar(10) default 'auto',
  `polarity` char(1) default NULL,
  `modulation` varchar(10) default 'auto',
  `bandwidth` char(1) default 'a',
  `lp_code_rate` varchar(10) default 'auto',
  `transmission_mode` char(1) default 'a',
  `guard_interval` varchar(10) default 'auto',
  `visible` smallint(1) NOT NULL default '0',
  `constellation` varchar(10) default 'auto',
  `hierarchy` varchar(10) default 'auto',
  `hp_code_rate` varchar(10) default 'auto',
  `sistandard` varchar(10) default 'dvb',
  `serviceversion` smallint(6) default '33',
  `updatetimestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`mplexid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `dtv_multiplex`
--

LOCK TABLES `dtv_multiplex` WRITE;
/*!40000 ALTER TABLE `dtv_multiplex` DISABLE KEYS */;
/*!40000 ALTER TABLE `dtv_multiplex` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dtv_privatetypes`
--

DROP TABLE IF EXISTS `dtv_privatetypes`;
CREATE TABLE `dtv_privatetypes` (
  `sitype` varchar(4) NOT NULL default '',
  `networkid` int(11) NOT NULL default '0',
  `private_type` varchar(20) NOT NULL default '',
  `private_value` varchar(100) NOT NULL default ''
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `dtv_privatetypes`
--

LOCK TABLES `dtv_privatetypes` WRITE;
/*!40000 ALTER TABLE `dtv_privatetypes` DISABLE KEYS */;
INSERT INTO `dtv_privatetypes` VALUES ('dvb',9018,'channel_numbers','131'),('dvb',9018,'guide_fixup','2'),('dvb',256,'guide_fixup','1'),('dvb',257,'guide_fixup','1'),('dvb',256,'tv_types','1,150,134,133'),('dvb',257,'tv_types','1,150,134,133'),('dvb',4100,'sdt_mapping','1'),('dvb',4101,'sdt_mapping','1'),('dvb',4102,'sdt_mapping','1'),('dvb',4103,'sdt_mapping','1'),('dvb',4104,'sdt_mapping','1'),('dvb',4105,'sdt_mapping','1'),('dvb',4106,'sdt_mapping','1'),('dvb',4107,'sdt_mapping','1'),('dvb',4097,'sdt_mapping','1'),('dvb',4098,'sdt_mapping','1'),('dvb',4100,'tv_types','1,145,154'),('dvb',4101,'tv_types','1,145,154'),('dvb',4102,'tv_types','1,145,154'),('dvb',4103,'tv_types','1,145,154'),('dvb',4104,'tv_types','1,145,154'),('dvb',4105,'tv_types','1,145,154'),('dvb',4106,'tv_types','1,145,154'),('dvb',4107,'tv_types','1,145,154'),('dvb',4097,'tv_types','1,145,154'),('dvb',4098,'tv_types','1,145,154'),('dvb',4100,'guide_fixup','1'),('dvb',4101,'guide_fixup','1'),('dvb',4102,'guide_fixup','1'),('dvb',4103,'guide_fixup','1'),('dvb',4104,'guide_fixup','1'),('dvb',4105,'guide_fixup','1'),('dvb',4106,'guide_fixup','1'),('dvb',4107,'guide_fixup','1'),('dvb',4096,'guide_fixup','5'),('dvb',4097,'guide_fixup','1'),('dvb',4098,'guide_fixup','1'),('dvb',94,'tv_types','1,128'),('atsc',1793,'guide_fixup','3'),('dvb',40999,'guide_fixup','4'),('dvb',70,'force_guide_present','yes'),('dvb',70,'guide_ranges','80,80,96,96'),('dvb',4112,'channel_numbers','131'),('dvb',4115,'channel_numbers','131'),('dvb',4116,'channel_numbers','131'),('dvb',12802,'channel_numbers','131'),('dvb',12803,'channel_numbers','131'),('dvb',12829,'channel_numbers','131'),('dvb',40999,'parse_subtitle_list','1070,1308,1041,1306,1307,1030,1016,1131,1068,1069'),('dvb',4096,'guide_fixup','5');
/*!40000 ALTER TABLE `dtv_privatetypes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dvdinput`
--

DROP TABLE IF EXISTS `dvdinput`;
CREATE TABLE `dvdinput` (
  `intid` int(10) unsigned NOT NULL,
  `hsize` int(10) unsigned default NULL,
  `vsize` int(10) unsigned default NULL,
  `ar_num` int(10) unsigned default NULL,
  `ar_denom` int(10) unsigned default NULL,
  `fr_code` int(10) unsigned default NULL,
  `letterbox` tinyint(1) default NULL,
  `v_format` varchar(16) default NULL,
  PRIMARY KEY  (`intid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `dvdinput`
--

LOCK TABLES `dvdinput` WRITE;
/*!40000 ALTER TABLE `dvdinput` DISABLE KEYS */;
INSERT INTO `dvdinput` VALUES (1,720,480,16,9,1,1,'ntsc'),(2,720,480,16,9,1,0,'ntsc'),(3,720,480,4,3,1,1,'ntsc'),(4,720,480,4,3,1,0,'ntsc'),(5,720,576,16,9,3,1,'pal'),(6,720,576,16,9,3,0,'pal'),(7,720,576,4,3,3,1,'pal'),(8,720,576,4,3,3,0,'pal');
/*!40000 ALTER TABLE `dvdinput` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dvdtranscode`
--

DROP TABLE IF EXISTS `dvdtranscode`;
CREATE TABLE `dvdtranscode` (
  `intid` int(11) NOT NULL auto_increment,
  `input` int(10) unsigned default NULL,
  `name` varchar(128) NOT NULL,
  `sync_mode` int(10) unsigned default NULL,
  `use_yv12` tinyint(1) default NULL,
  `cliptop` int(11) default NULL,
  `clipbottom` int(11) default NULL,
  `clipleft` int(11) default NULL,
  `clipright` int(11) default NULL,
  `f_resize_h` int(11) default NULL,
  `f_resize_w` int(11) default NULL,
  `hq_resize_h` int(11) default NULL,
  `hq_resize_w` int(11) default NULL,
  `grow_h` int(11) default NULL,
  `grow_w` int(11) default NULL,
  `clip2top` int(11) default NULL,
  `clip2bottom` int(11) default NULL,
  `clip2left` int(11) default NULL,
  `clip2right` int(11) default NULL,
  `codec` varchar(128) NOT NULL,
  `codec_param` varchar(128) default NULL,
  `bitrate` int(11) default NULL,
  `a_sample_r` int(11) default NULL,
  `a_bitrate` int(11) default NULL,
  `two_pass` tinyint(1) default NULL,
  `tc_param` varchar(128) default NULL,
  PRIMARY KEY  (`intid`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `dvdtranscode`
--

LOCK TABLES `dvdtranscode` WRITE;
/*!40000 ALTER TABLE `dvdtranscode` DISABLE KEYS */;
INSERT INTO `dvdtranscode` VALUES (1,1,'Good',2,1,16,16,0,0,2,0,0,0,0,0,32,32,8,8,'divx5',NULL,1618,NULL,NULL,0,NULL),(2,2,'Excellent',2,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'divx5',NULL,0,NULL,NULL,1,NULL),(3,2,'Good',2,1,0,0,8,8,0,0,0,0,0,0,0,0,0,0,'divx5',NULL,1618,NULL,NULL,0,NULL),(4,2,'Medium',2,1,0,0,8,8,5,5,0,0,0,0,0,0,0,0,'divx5',NULL,1200,NULL,NULL,0,NULL),(5,3,'Good',2,1,0,0,0,0,0,0,0,0,2,0,80,80,8,8,'divx5',NULL,0,NULL,NULL,0,NULL),(6,4,'Excellent',2,1,0,0,0,0,0,0,0,0,2,0,0,0,0,0,'divx5',NULL,0,NULL,NULL,1,NULL),(7,4,'Good',2,1,0,0,8,8,0,2,0,0,0,0,0,0,0,0,'divx5',NULL,1618,NULL,NULL,0,NULL),(8,5,'Good',1,1,16,16,0,0,5,0,0,0,0,0,40,40,8,8,'divx5',NULL,1618,NULL,NULL,0,NULL),(9,6,'Good',1,1,0,0,16,16,5,0,0,0,0,0,0,0,0,0,'divx5',NULL,1618,NULL,NULL,0,NULL),(10,7,'Good',1,1,0,0,0,0,1,0,0,0,0,0,76,76,8,8,'divx5',NULL,1618,NULL,NULL,0,NULL),(11,8,'Good',1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,'divx5',NULL,1618,NULL,NULL,0,NULL);
/*!40000 ALTER TABLE `dvdtranscode` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eit_cache`
--

DROP TABLE IF EXISTS `eit_cache`;
CREATE TABLE `eit_cache` (
  `chanid` int(10) NOT NULL,
  `eventid` smallint(5) unsigned NOT NULL,
  `tableid` tinyint(3) unsigned NOT NULL,
  `version` tinyint(3) unsigned NOT NULL,
  `endtime` int(10) unsigned NOT NULL,
  PRIMARY KEY  (`chanid`,`eventid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `eit_cache`
--

LOCK TABLES `eit_cache` WRITE;
/*!40000 ALTER TABLE `eit_cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `eit_cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `favorites`
--

DROP TABLE IF EXISTS `favorites`;
CREATE TABLE `favorites` (
  `favid` int(11) unsigned NOT NULL auto_increment,
  `userid` int(11) unsigned NOT NULL default '0',
  `chanid` int(11) unsigned NOT NULL default '0',
  PRIMARY KEY  (`favid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `favorites`
--

LOCK TABLES `favorites` WRITE;
/*!40000 ALTER TABLE `favorites` DISABLE KEYS */;
/*!40000 ALTER TABLE `favorites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `filemarkup`
--

DROP TABLE IF EXISTS `filemarkup`;
CREATE TABLE `filemarkup` (
  `filename` text NOT NULL,
  `mark` bigint(20) NOT NULL,
  `offset` varchar(32) default NULL,
  `type` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `filemarkup`
--

LOCK TABLES `filemarkup` WRITE;
/*!40000 ALTER TABLE `filemarkup` DISABLE KEYS */;
/*!40000 ALTER TABLE `filemarkup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gallerymetadata`
--

DROP TABLE IF EXISTS `gallerymetadata`;
CREATE TABLE `gallerymetadata` (
  `image` varchar(255) NOT NULL,
  `angle` int(11) NOT NULL,
  PRIMARY KEY  (`image`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `gallerymetadata`
--

LOCK TABLES `gallerymetadata` WRITE;
/*!40000 ALTER TABLE `gallerymetadata` DISABLE KEYS */;
/*!40000 ALTER TABLE `gallerymetadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gamemetadata`
--

DROP TABLE IF EXISTS `gamemetadata`;
CREATE TABLE `gamemetadata` (
  `system` varchar(128) NOT NULL default '',
  `romname` varchar(128) NOT NULL default '',
  `gamename` varchar(128) NOT NULL default '',
  `genre` varchar(128) NOT NULL default '',
  `year` varchar(10) NOT NULL default '',
  `publisher` varchar(128) NOT NULL default '',
  `favorite` tinyint(1) default NULL,
  `rompath` varchar(255) NOT NULL default '',
  `gametype` varchar(64) NOT NULL default '',
  `diskcount` tinyint(1) NOT NULL default '1',
  `country` varchar(128) NOT NULL default '',
  `crc_value` varchar(64) NOT NULL default '',
  `display` tinyint(1) NOT NULL default '1',
  `version` varchar(64) NOT NULL default '',
  KEY `system` (`system`),
  KEY `year` (`year`),
  KEY `romname` (`romname`),
  KEY `gamename` (`gamename`),
  KEY `genre` (`genre`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `gamemetadata`
--

LOCK TABLES `gamemetadata` WRITE;
/*!40000 ALTER TABLE `gamemetadata` DISABLE KEYS */;
/*!40000 ALTER TABLE `gamemetadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gameplayers`
--

DROP TABLE IF EXISTS `gameplayers`;
CREATE TABLE `gameplayers` (
  `gameplayerid` int(10) unsigned NOT NULL auto_increment,
  `playername` varchar(64) NOT NULL default '',
  `workingpath` varchar(255) NOT NULL default '',
  `rompath` varchar(255) NOT NULL default '',
  `screenshots` varchar(255) NOT NULL default '',
  `commandline` text NOT NULL,
  `gametype` varchar(64) NOT NULL default '',
  `extensions` varchar(128) NOT NULL default '',
  `spandisks` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`gameplayerid`),
  UNIQUE KEY `playername` (`playername`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `gameplayers`
--

LOCK TABLES `gameplayers` WRITE;
/*!40000 ALTER TABLE `gameplayers` DISABLE KEYS */;
/*!40000 ALTER TABLE `gameplayers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `housekeeping`
--

DROP TABLE IF EXISTS `housekeeping`;
CREATE TABLE `housekeeping` (
  `tag` varchar(64) NOT NULL default '',
  `lastrun` datetime default NULL,
  PRIMARY KEY  (`tag`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `housekeeping`
--

LOCK TABLES `housekeeping` WRITE;
/*!40000 ALTER TABLE `housekeeping` DISABLE KEYS */;
INSERT INTO `housekeeping` VALUES ('DailyCleanup','2007-06-27 20:33:37'),('JobQueueRecover-OLDHOSTNAME','2007-06-27 20:33:37');
/*!40000 ALTER TABLE `housekeeping` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inuseprograms`
--

DROP TABLE IF EXISTS `inuseprograms`;
CREATE TABLE `inuseprograms` (
  `chanid` int(10) unsigned NOT NULL default '0',
  `starttime` datetime NOT NULL default '0000-00-00 00:00:00',
  `recusage` varchar(128) NOT NULL default '',
  `lastupdatetime` datetime NOT NULL default '0000-00-00 00:00:00',
  `hostname` varchar(255) NOT NULL default '',
  KEY `chanid` (`chanid`,`starttime`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `inuseprograms`
--

LOCK TABLES `inuseprograms` WRITE;
/*!40000 ALTER TABLE `inuseprograms` DISABLE KEYS */;
/*!40000 ALTER TABLE `inuseprograms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobqueue`
--

DROP TABLE IF EXISTS `jobqueue`;
CREATE TABLE `jobqueue` (
  `id` int(11) NOT NULL auto_increment,
  `chanid` int(10) NOT NULL default '0',
  `starttime` datetime NOT NULL default '0000-00-00 00:00:00',
  `inserttime` datetime NOT NULL default '0000-00-00 00:00:00',
  `type` int(11) NOT NULL default '0',
  `cmds` int(11) NOT NULL default '0',
  `flags` int(11) NOT NULL default '0',
  `status` int(11) NOT NULL default '0',
  `statustime` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `hostname` varchar(255) NOT NULL default '',
  `args` blob NOT NULL,
  `comment` varchar(128) NOT NULL default '',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `chanid` (`chanid`,`starttime`,`type`,`inserttime`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `jobqueue`
--

LOCK TABLES `jobqueue` WRITE;
/*!40000 ALTER TABLE `jobqueue` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobqueue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jumppoints`
--

DROP TABLE IF EXISTS `jumppoints`;
CREATE TABLE `jumppoints` (
  `destination` varchar(128) NOT NULL default '',
  `description` varchar(255) default NULL,
  `keylist` varchar(128) default NULL,
  `hostname` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`destination`,`hostname`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `jumppoints`
--

LOCK TABLES `jumppoints` WRITE;
/*!40000 ALTER TABLE `jumppoints` DISABLE KEYS */;
INSERT INTO `jumppoints` VALUES ('Reload Theme',NULL,'','OLDHOSTNAME'),('Main Menu',NULL,'','OLDHOSTNAME'),('Program Guide',NULL,'','OLDHOSTNAME'),('Program Finder',NULL,'','OLDHOSTNAME'),('Manage Recordings / Fix Conflicts',NULL,'','OLDHOSTNAME'),('Program Recording Priorities',NULL,'','OLDHOSTNAME'),('Channel Recording Priorities',NULL,'','OLDHOSTNAME'),('TV Recording Playback',NULL,'','OLDHOSTNAME'),('TV Recording Deletion',NULL,'','OLDHOSTNAME'),('Live TV',NULL,'','OLDHOSTNAME'),('Live TV In Guide',NULL,'','OLDHOSTNAME'),('Manual Record Scheduling',NULL,'','OLDHOSTNAME'),('Status Screen',NULL,'','OLDHOSTNAME'),('Previously Recorded',NULL,'','OLDHOSTNAME'),('Play DVD',NULL,'','OLDHOSTNAME'),('Play VCD',NULL,'','OLDHOSTNAME'),('Rip DVD',NULL,'','OLDHOSTNAME'),('Netflix Browser',NULL,'','OLDHOSTNAME'),('Netflix Queue',NULL,'','OLDHOSTNAME'),('Netflix History',NULL,'','OLDHOSTNAME'),('MythGallery',NULL,'','OLDHOSTNAME'),('MythGame',NULL,'','OLDHOSTNAME'),('Play music',NULL,'','OLDHOSTNAME'),('Select music playlists',NULL,'','OLDHOSTNAME'),('Rip CD',NULL,'','OLDHOSTNAME'),('Scan music',NULL,'','OLDHOSTNAME'),('MythNews',NULL,'','OLDHOSTNAME'),('MythVideo',NULL,'','OLDHOSTNAME'),('Video Manager',NULL,'','OLDHOSTNAME'),('Video Browser',NULL,'','OLDHOSTNAME'),('Video Listings',NULL,'','OLDHOSTNAME'),('Video Gallery',NULL,'','OLDHOSTNAME'),('MythWeather',NULL,'','OLDHOSTNAME');
/*!40000 ALTER TABLE `jumppoints` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `keybindings`
--

DROP TABLE IF EXISTS `keybindings`;
CREATE TABLE `keybindings` (
  `context` varchar(32) NOT NULL default '',
  `action` varchar(32) NOT NULL default '',
  `description` varchar(255) default NULL,
  `keylist` varchar(128) default NULL,
  `hostname` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`context`,`action`,`hostname`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `keybindings`
--

LOCK TABLES `keybindings` WRITE;
/*!40000 ALTER TABLE `keybindings` DISABLE KEYS */;
INSERT INTO `keybindings` VALUES ('Global','UP','Up Arrow','Up','OLDHOSTNAME'),('Global','DOWN','Down Arrow','Down','OLDHOSTNAME'),('Global','LEFT','Left Arrow','Left','OLDHOSTNAME'),('Global','RIGHT','Right Arrow','Right','OLDHOSTNAME'),('Global','SELECT','Select','Return,Enter,Space','OLDHOSTNAME'),('Global','ESCAPE','Escape','Esc','OLDHOSTNAME'),('Global','MENU','Pop-up menu','M','OLDHOSTNAME'),('Global','INFO','More information','I','OLDHOSTNAME'),('Global','PAGEUP','Page Up','PgUp','OLDHOSTNAME'),('Global','PAGEDOWN','Page Down','PgDown','OLDHOSTNAME'),('Global','PREVVIEW','Previous View','Home','OLDHOSTNAME'),('Global','NEXTVIEW','Next View','End','OLDHOSTNAME'),('Global','HELP','Help','F1','OLDHOSTNAME'),('Global','EJECT','Eject Removable Media','','OLDHOSTNAME'),('Global','0','0','0','OLDHOSTNAME'),('Global','1','1','1','OLDHOSTNAME'),('Global','2','2','2','OLDHOSTNAME'),('Global','3','3','3','OLDHOSTNAME'),('Global','4','4','4','OLDHOSTNAME'),('Global','5','5','5','OLDHOSTNAME'),('Global','6','6','6','OLDHOSTNAME'),('Global','7','7','7','OLDHOSTNAME'),('Global','8','8','8','OLDHOSTNAME'),('Global','9','9','9','OLDHOSTNAME'),('qt','DELETE','Delete','D','OLDHOSTNAME'),('qt','EDIT','Edit','E','OLDHOSTNAME'),('TV Frontend','PAGEUP','Page Up','3','OLDHOSTNAME'),('TV Frontend','PAGEDOWN','Page Down','9','OLDHOSTNAME'),('TV Frontend','DELETE','Delete Program','D','OLDHOSTNAME'),('TV Frontend','PLAYBACK','Play Program','P','OLDHOSTNAME'),('TV Frontend','TOGGLERECORD','Toggle recording status of current program','R','OLDHOSTNAME'),('TV Frontend','DAYLEFT','Page the program guide back one day','Home,7','OLDHOSTNAME'),('TV Frontend','DAYRIGHT','Page the program guide forward one day','End,1','OLDHOSTNAME'),('TV Frontend','PAGELEFT','Page the program guide left',',,<','OLDHOSTNAME'),('TV Frontend','PAGERIGHT','Page the program guide right','>,.','OLDHOSTNAME'),('TV Frontend','TOGGLEFAV','Toggle the current channel as a favorite','?','OLDHOSTNAME'),('TV Frontend','NEXTFAV','Toggle showing all channels or just favorites in the program guide.','/','OLDHOSTNAME'),('TV Frontend','CHANUPDATE','Switch channels without exiting guide in Live TV mode.','X','OLDHOSTNAME'),('TV Frontend','RANKINC','Increase program or channel rank','Right','OLDHOSTNAME'),('TV Frontend','RANKDEC','Decrease program or channel rank','Left','OLDHOSTNAME'),('TV Frontend','UPCOMING','List upcoming episodes','O','OLDHOSTNAME'),('TV Frontend','DETAILS','Show program details','U','OLDHOSTNAME'),('TV Frontend','VIEWCARD','Switch Capture Card view','Y','OLDHOSTNAME'),('TV Frontend','CUSTOMEDIT','Edit Custom Record Rule','E','OLDHOSTNAME'),('TV Playback','CLEAROSD','Clear OSD','Backspace','OLDHOSTNAME'),('TV Playback','PAUSE','Pause','P','OLDHOSTNAME'),('TV Playback','DELETE','Delete Program','D','OLDHOSTNAME'),('TV Playback','SEEKFFWD','Fast Forward','Right','OLDHOSTNAME'),('TV Playback','SEEKRWND','Rewind','Left','OLDHOSTNAME'),('TV Playback','ARBSEEK','Arbitrary Seek','*','OLDHOSTNAME'),('TV Playback','CHANNELUP','Channel up','Up','OLDHOSTNAME'),('TV Playback','CHANNELDOWN','Channel down','Down','OLDHOSTNAME'),('TV Playback','NEXTFAV','Switch to the next favorite channel','/','OLDHOSTNAME'),('TV Playback','PREVCHAN','Switch to the previous channel','H','OLDHOSTNAME'),('TV Playback','JUMPFFWD','Jump ahead','PgDown','OLDHOSTNAME'),('TV Playback','JUMPRWND','Jump back','PgUp','OLDHOSTNAME'),('TV Playback','JUMPBKMRK','Jump to bookmark','K','OLDHOSTNAME'),('TV Playback','FFWDSTICKY','Fast Forward (Sticky) or Forward one frame while paused','>,.','OLDHOSTNAME'),('TV Playback','RWNDSTICKY','Rewind (Sticky) or Rewind one frame while paused',',,<','OLDHOSTNAME'),('TV Playback','TOGGLEINPUTS','Toggle Inputs','C','OLDHOSTNAME'),('TV Playback','SWITCHCARDS','Switch Capture Cards','Y','OLDHOSTNAME'),('TV Playback','SKIPCOMMERCIAL','Skip Commercial','Z,End','OLDHOSTNAME'),('TV Playback','SKIPCOMMBACK','Skip Commercial (Reverse)','Q,Home','OLDHOSTNAME'),('TV Playback','JUMPSTART','Jump to the start of the recording.','Ctrl+B','OLDHOSTNAME'),('TV Playback','TOGGLEBROWSE','Toggle channel browse mode','O','OLDHOSTNAME'),('TV Playback','TOGGLERECORD','Toggle recording status of current program','R','OLDHOSTNAME'),('TV Playback','TOGGLEFAV','Toggle the current channel as a favorite','?','OLDHOSTNAME'),('TV Playback','VOLUMEDOWN','Volume down','[,{,F10','OLDHOSTNAME'),('TV Playback','VOLUMEUP','Volume up','],},F11','OLDHOSTNAME'),('TV Playback','MUTE','Mute','|,\\,F9','OLDHOSTNAME'),('TV Playback','TOGGLEPIPMODE','Toggle Picture-in-Picture mode','V','OLDHOSTNAME'),('TV Playback','TOGGLEPIPWINDOW','Toggle active PiP window','B','OLDHOSTNAME'),('TV Playback','SWAPPIP','Swap PiP/Main','N','OLDHOSTNAME'),('TV Playback','TOGGLEASPECT','Toggle the display aspect ratio','W','OLDHOSTNAME'),('TV Playback','TOGGLECC','Toggle any captions','T','OLDHOSTNAME'),('TV Playback','TOGGLETTC','Toggle Teletext Captions','','OLDHOSTNAME'),('TV Playback','TOGGLESUBTITLE','Toggle Subtitles','','OLDHOSTNAME'),('TV Playback','TOGGLECC608','Toggle VBI CC','','OLDHOSTNAME'),('TV Playback','TOGGLECC708','Toggle ATSC CC','','OLDHOSTNAME'),('TV Playback','TOGGLETTM','Toggle Teletext Menu','','OLDHOSTNAME'),('TV Playback','SELECTAUDIO_0','Play audio track 1','','OLDHOSTNAME'),('TV Playback','SELECTAUDIO_1','Play audio track 2','','OLDHOSTNAME'),('TV Playback','SELECTSUBTITLE_0','Display subtitle 1','','OLDHOSTNAME'),('TV Playback','SELECTSUBTITLE_1','Display subtitle 2','','OLDHOSTNAME'),('TV Playback','SELECTCC608_0','Display VBI CC1','','OLDHOSTNAME'),('TV Playback','SELECTCC608_1','Display VBI CC2','','OLDHOSTNAME'),('TV Playback','SELECTCC608_2','Display VBI CC3','','OLDHOSTNAME'),('TV Playback','SELECTCC608_3','Display VBI CC4','','OLDHOSTNAME'),('TV Playback','SELECTCC708_0','Display ATSC CC1','','OLDHOSTNAME'),('TV Playback','SELECTCC708_1','Display ATSC CC2','','OLDHOSTNAME'),('TV Playback','SELECTCC708_2','Display ATSC CC3','','OLDHOSTNAME'),('TV Playback','SELECTCC708_3','Display ATSC CC4','','OLDHOSTNAME'),('TV Playback','NEXTAUDIO','Next audio track','+','OLDHOSTNAME'),('TV Playback','PREVAUDIO','Previous audio track','-','OLDHOSTNAME'),('TV Playback','NEXTSUBTITLE','Next subtitle track','','OLDHOSTNAME'),('TV Playback','PREVSUBTITLE','Previous subtitle track','','OLDHOSTNAME'),('TV Playback','NEXTCC608','Next VBI CC track','','OLDHOSTNAME'),('TV Playback','PREVCC608','Previous VBI CC track','','OLDHOSTNAME'),('TV Playback','NEXTCC708','Next ATSC CC track','','OLDHOSTNAME'),('TV Playback','PREVCC708','Previous ATSC CC track','','OLDHOSTNAME'),('TV Playback','NEXTCC','Next of any captions','','OLDHOSTNAME'),('TV Playback','NEXTSCAN','Next video scan overidemode','','OLDHOSTNAME'),('TV Playback','QUEUETRANSCODE','Queue the current recording for transcoding','X','OLDHOSTNAME'),('TV Playback','SPEEDINC','Increase the playback speed','U','OLDHOSTNAME'),('TV Playback','SPEEDDEC','Decrease the playback speed','J','OLDHOSTNAME'),('TV Playback','ADJUSTSTRETCH','Turn on time stretch control','A','OLDHOSTNAME'),('TV Playback','STRETCHINC','Increase time stretch speed','','OLDHOSTNAME'),('TV Playback','STRETCHDEC','Decrease time stretch speed','','OLDHOSTNAME'),('TV Playback','TOGGLESTRETCH','Toggle time stretch speed','','OLDHOSTNAME'),('TV Playback','TOGGLEAUDIOSYNC','Turn on audio sync adjustment controls','','OLDHOSTNAME'),('TV Playback','TOGGLEPICCONTROLS','Playback picture adjustments','F','OLDHOSTNAME'),('TV Playback','TOGGLECHANCONTROLS','Recording picture adjustments for this channel','Ctrl+G','OLDHOSTNAME'),('TV Playback','TOGGLERECCONTROLS','Recording picture adjustments for this recorder','G','OLDHOSTNAME'),('TV Playback','TOGGLEEDIT','Start Edit Mode','E','OLDHOSTNAME'),('TV Playback','CYCLECOMMSKIPMODE','Cycle Commercial Skip mode','','OLDHOSTNAME'),('TV Playback','GUIDE','Show the Program Guide','S','OLDHOSTNAME'),('TV Playback','FINDER','Show the Program Finder','#','OLDHOSTNAME'),('TV Playback','TOGGLESLEEP','Toggle the Sleep Timer','F8','OLDHOSTNAME'),('TV Playback','PLAY','Play','Ctrl+P','OLDHOSTNAME'),('TV Playback','JUMPPREV','Jump to previously played recording','','OLDHOSTNAME'),('TV Playback','JUMPREC','Display menu of recorded programs to jump to','','OLDHOSTNAME'),('TV Playback','SIGNALMON','Monitor Signal Quality','F7','OLDHOSTNAME'),('TV Playback','JUMPTODVDROOTMENU','Jump to the DVD Root Menu','','OLDHOSTNAME'),('TV Editing','CLEARMAP','Clear editing cut points','C,Q,Home','OLDHOSTNAME'),('TV Editing','INVERTMAP','Invert Begin/End cut points','I','OLDHOSTNAME'),('TV Editing','LOADCOMMSKIP','Load cut list from commercial skips','Z,End','OLDHOSTNAME'),('TV Editing','NEXTCUT','Jump to the next cut point','PgDown','OLDHOSTNAME'),('TV Editing','PREVCUT','Jump to the previous cut point','PgUp','OLDHOSTNAME'),('TV Editing','BIGJUMPREW','Jump back 10x the normal amount',',,<','OLDHOSTNAME'),('TV Editing','BIGJUMPFWD','Jump forward 10x the normal amount','>,.','OLDHOSTNAME'),('TV Editing','TOGGLEEDIT','Exit out of Edit Mode','E','OLDHOSTNAME'),('Teletext Menu','NEXTPAGE','Next Page','Down','OLDHOSTNAME'),('Teletext Menu','PREVPAGE','Previous Page','Up','OLDHOSTNAME'),('Teletext Menu','NEXTSUBPAGE','Next Subpage','Right','OLDHOSTNAME'),('Teletext Menu','PREVSUBPAGE','Previous Subpage','Left','OLDHOSTNAME'),('Teletext Menu','TOGGLETT','Toggle Teletext','T','OLDHOSTNAME'),('Teletext Menu','MENURED','Menu Red','F2','OLDHOSTNAME'),('Teletext Menu','MENUGREEN','Menu Green','F3','OLDHOSTNAME'),('Teletext Menu','MENUYELLOW','Menu Yellow','F4','OLDHOSTNAME'),('Teletext Menu','MENUBLUE','Menu Blue','F5','OLDHOSTNAME'),('Teletext Menu','MENUWHITE','Menu White','F6','OLDHOSTNAME'),('Teletext Menu','TOGGLEBACKGROUND','Toggle Background','F7','OLDHOSTNAME'),('Teletext Menu','REVEAL','Reveal hidden Text','F8','OLDHOSTNAME'),('ITV Menu','MENURED','Menu Red','F2','OLDHOSTNAME'),('ITV Menu','MENUGREEN','Menu Green','F3','OLDHOSTNAME'),('ITV Menu','MENUYELLOW','Menu Yellow','F4','OLDHOSTNAME'),('ITV Menu','MENUBLUE','Menu Blue','F5','OLDHOSTNAME'),('ITV Menu','TEXTEXIT','Menu Exit','F6','OLDHOSTNAME'),('ITV Menu','MENUTEXT','Menu Text','F7','OLDHOSTNAME'),('ITV Menu','MENUEPG','Menu EPG','F12','OLDHOSTNAME'),('Archive','TOGGLECUT','Toggle use cut list state for selected program','C','OLDHOSTNAME'),('NetFlix','MOVETOTOP','Moves movie to top of queue','1','OLDHOSTNAME'),('NetFlix','REMOVE','Removes movie from queue','D','OLDHOSTNAME'),('Gallery','PLAY','Start/Stop Slideshow','P','OLDHOSTNAME'),('Gallery','HOME','Go to the first image in thumbnail view','Home','OLDHOSTNAME'),('Gallery','END','Go to the last image in thumbnail view','End','OLDHOSTNAME'),('Gallery','MENU','Toggle activating menu in thumbnail view','M','OLDHOSTNAME'),('Gallery','SLIDESHOW','Start Slideshow in thumbnail view','S','OLDHOSTNAME'),('Gallery','RANDOMSHOW','Start Random Slideshow in thumbnail view','R','OLDHOSTNAME'),('Gallery','ROTRIGHT','Rotate image right 90 degrees','],3','OLDHOSTNAME'),('Gallery','ROTLEFT','Rotate image left 90 degrees','[,1','OLDHOSTNAME'),('Gallery','ZOOMOUT','Zoom image out','7','OLDHOSTNAME'),('Gallery','ZOOMIN','Zoom image in','9','OLDHOSTNAME'),('Gallery','SCROLLUP','Scroll image up','2','OLDHOSTNAME'),('Gallery','SCROLLLEFT','Scroll image left','4','OLDHOSTNAME'),('Gallery','SCROLLRIGHT','Scroll image right','6','OLDHOSTNAME'),('Gallery','SCROLLDOWN','Scroll image down','8','OLDHOSTNAME'),('Gallery','RECENTER','Recenter image','5','OLDHOSTNAME'),('Gallery','FULLSIZE','Full-size (un-zoom) image','0','OLDHOSTNAME'),('Gallery','UPLEFT','Go to the upper-left corner of the image','PgUp','OLDHOSTNAME'),('Gallery','LOWRIGHT','Go to the lower-right corner of the image','PgDown','OLDHOSTNAME'),('Gallery','INFO','Toggle Showing Information about Image','I','OLDHOSTNAME'),('Gallery','DELETE','Delete marked images or current image if none are marked','D','OLDHOSTNAME'),('Gallery','MARK','Mark image','T','OLDHOSTNAME'),('Game','TOGGLEFAV','Toggle the current game as a favorite','?,/','OLDHOSTNAME'),('Game','INCSEARCH','Show incremental search dialog','Ctrl+S','OLDHOSTNAME'),('Game','INCSEARCHNEXT','Incremental search find next match','Ctrl+N','OLDHOSTNAME'),('Music','DELETE','Delete track from playlist','D','OLDHOSTNAME'),('Music','NEXTTRACK','Move to the next track','>,.,Z,End','OLDHOSTNAME'),('Music','PREVTRACK','Move to the previous track',',,<,Q,Home','OLDHOSTNAME'),('Music','FFWD','Fast forward','PgDown','OLDHOSTNAME'),('Music','RWND','Rewind','PgUp','OLDHOSTNAME'),('Music','PAUSE','Pause/Start playback','P','OLDHOSTNAME'),('Music','STOP','Stop playback','O','OLDHOSTNAME'),('Music','VOLUMEDOWN','Volume down','[,{,F10','OLDHOSTNAME'),('Music','VOLUMEUP','Volume up','],},F11','OLDHOSTNAME'),('Music','MUTE','Mute','|,\\,F9','OLDHOSTNAME'),('Music','CYCLEVIS','Cycle visualizer mode','6','OLDHOSTNAME'),('Music','BLANKSCR','Blank screen','5','OLDHOSTNAME'),('Music','THMBUP','Increase rating','9','OLDHOSTNAME'),('Music','THMBDOWN','Decrease rating','7','OLDHOSTNAME'),('Music','REFRESH','Refresh music tree','8','OLDHOSTNAME'),('Music','FILTER','Filter All My Music','F','OLDHOSTNAME'),('Music','INCSEARCH','Show incremental search dialog','Ctrl+S','OLDHOSTNAME'),('Music','INCSEARCHNEXT','Incremental search find next match','Ctrl+N','OLDHOSTNAME'),('News','RETRIEVENEWS','Update news items','I','OLDHOSTNAME'),('News','FORCERETRIEVE','Force update news items','M','OLDHOSTNAME'),('News','CANCEL','Cancel news item updating','C','OLDHOSTNAME'),('Phone','0','0','0','OLDHOSTNAME'),('Phone','1','1','1','OLDHOSTNAME'),('Phone','2','2','2','OLDHOSTNAME'),('Phone','3','3','3','OLDHOSTNAME'),('Phone','4','4','4','OLDHOSTNAME'),('Phone','5','5','5','OLDHOSTNAME'),('Phone','6','6','6','OLDHOSTNAME'),('Phone','7','7','7','OLDHOSTNAME'),('Phone','8','8','8','OLDHOSTNAME'),('Phone','9','9','9','OLDHOSTNAME'),('Phone','HASH','HASH','#','OLDHOSTNAME'),('Phone','STAR','STAR','*','OLDHOSTNAME'),('Phone','Up','Up','Up','OLDHOSTNAME'),('Phone','Down','Down','Down','OLDHOSTNAME'),('Phone','Left','Left','Left','OLDHOSTNAME'),('Phone','Right','Right','Right','OLDHOSTNAME'),('Phone','VOLUMEDOWN','Volume down','[,{,F10','OLDHOSTNAME'),('Phone','VOLUMEUP','Volume up','],},F11','OLDHOSTNAME'),('Phone','ZOOMIN','Zoom the video window in','>,.,Z,End','OLDHOSTNAME'),('Phone','ZOOMOUT','Zoom the video window out',',,<,Q,Home','OLDHOSTNAME'),('Phone','FULLSCRN','Show received video full-screen','P','OLDHOSTNAME'),('Phone','HANGUP','Hangup an active call','O','OLDHOSTNAME'),('Phone','MUTE','Mute','|,\\,F9','OLDHOSTNAME'),('Phone','LOOPBACK','Loopback Video','L','OLDHOSTNAME'),('Video','FILTER','Open video filter dialog','F','OLDHOSTNAME'),('Video','DELETE','Delete video','D','OLDHOSTNAME'),('Video','BROWSE','Change browsable in video manager','B','OLDHOSTNAME'),('Video','INCPARENT','Increase Parental Level','],},F11','OLDHOSTNAME'),('Video','DECPARENT','Decrease Parental Level','[,{,F10','OLDHOSTNAME'),('Video','HOME','Go to the first video','Home','OLDHOSTNAME'),('Video','END','Go to the last video','End','OLDHOSTNAME'),('Weather','PAUSE','Pause current page','P','OLDHOSTNAME');
/*!40000 ALTER TABLE `keybindings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `keyword`
--

DROP TABLE IF EXISTS `keyword`;
CREATE TABLE `keyword` (
  `phrase` varchar(128) NOT NULL default '',
  `searchtype` int(10) unsigned NOT NULL default '3',
  UNIQUE KEY `phrase` (`phrase`,`searchtype`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `keyword`
--

LOCK TABLES `keyword` WRITE;
/*!40000 ALTER TABLE `keyword` DISABLE KEYS */;
/*!40000 ALTER TABLE `keyword` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `music_albums`
--

DROP TABLE IF EXISTS `music_albums`;
CREATE TABLE `music_albums` (
  `album_id` int(11) unsigned NOT NULL auto_increment,
  `artist_id` int(11) unsigned NOT NULL default '0',
  `album_name` varchar(255) NOT NULL default '',
  `year` smallint(6) NOT NULL default '0',
  `compilation` tinyint(1) unsigned NOT NULL default '0',
  PRIMARY KEY  (`album_id`),
  KEY `idx_album_name` (`album_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `music_albums`
--

LOCK TABLES `music_albums` WRITE;
/*!40000 ALTER TABLE `music_albums` DISABLE KEYS */;
/*!40000 ALTER TABLE `music_albums` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `music_artists`
--

DROP TABLE IF EXISTS `music_artists`;
CREATE TABLE `music_artists` (
  `artist_id` int(11) unsigned NOT NULL auto_increment,
  `artist_name` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`artist_id`),
  KEY `idx_artist_name` (`artist_name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `music_artists`
--

LOCK TABLES `music_artists` WRITE;
/*!40000 ALTER TABLE `music_artists` DISABLE KEYS */;
/*!40000 ALTER TABLE `music_artists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `music_genres`
--

DROP TABLE IF EXISTS `music_genres`;
CREATE TABLE `music_genres` (
  `genre_id` int(11) unsigned NOT NULL auto_increment,
  `genre` varchar(25) NOT NULL default '',
  PRIMARY KEY  (`genre_id`),
  KEY `idx_genre` (`genre`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `music_genres`
--

LOCK TABLES `music_genres` WRITE;
/*!40000 ALTER TABLE `music_genres` DISABLE KEYS */;
/*!40000 ALTER TABLE `music_genres` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `music_playlists`
--

DROP TABLE IF EXISTS `music_playlists`;
CREATE TABLE `music_playlists` (
  `playlist_id` int(11) unsigned NOT NULL auto_increment,
  `playlist_name` varchar(255) NOT NULL default '',
  `playlist_songs` text NOT NULL,
  `last_accessed` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `length` int(11) unsigned NOT NULL default '0',
  `songcount` smallint(8) unsigned NOT NULL default '0',
  `hostname` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`playlist_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `music_playlists`
--

LOCK TABLES `music_playlists` WRITE;
/*!40000 ALTER TABLE `music_playlists` DISABLE KEYS */;
/*!40000 ALTER TABLE `music_playlists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `music_smartplaylist_categories`
--

DROP TABLE IF EXISTS `music_smartplaylist_categories`;
CREATE TABLE `music_smartplaylist_categories` (
  `categoryid` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(128) NOT NULL,
  PRIMARY KEY  (`categoryid`),
  KEY `name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `music_smartplaylist_categories`
--

LOCK TABLES `music_smartplaylist_categories` WRITE;
/*!40000 ALTER TABLE `music_smartplaylist_categories` DISABLE KEYS */;
INSERT INTO `music_smartplaylist_categories` VALUES (1,'Decades'),(2,'Favourite Tracks'),(3,'New Tracks');
/*!40000 ALTER TABLE `music_smartplaylist_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `music_smartplaylist_items`
--

DROP TABLE IF EXISTS `music_smartplaylist_items`;
CREATE TABLE `music_smartplaylist_items` (
  `smartplaylistitemid` int(10) unsigned NOT NULL auto_increment,
  `smartplaylistid` int(10) unsigned NOT NULL,
  `field` varchar(50) NOT NULL,
  `operator` varchar(20) NOT NULL,
  `value1` varchar(255) NOT NULL,
  `value2` varchar(255) NOT NULL,
  PRIMARY KEY  (`smartplaylistitemid`),
  KEY `smartplaylistid` (`smartplaylistid`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `music_smartplaylist_items`
--

LOCK TABLES `music_smartplaylist_items` WRITE;
/*!40000 ALTER TABLE `music_smartplaylist_items` DISABLE KEYS */;
INSERT INTO `music_smartplaylist_items` VALUES (1,1,'Year','is between','1960','1969'),(2,2,'Year','is between','1970','1979'),(3,3,'Year','is between','1980','1989'),(4,4,'Year','is between','1990','1999'),(5,5,'Year','is between','2000','2009'),(6,6,'Rating','is greater than','7','0'),(7,7,'Play Count','is greater than','0','0'),(8,8,'Play Count','is equal to','0','0');
/*!40000 ALTER TABLE `music_smartplaylist_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `music_smartplaylists`
--

DROP TABLE IF EXISTS `music_smartplaylists`;
CREATE TABLE `music_smartplaylists` (
  `smartplaylistid` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(128) NOT NULL,
  `categoryid` int(10) unsigned NOT NULL,
  `matchtype` set('All','Any') NOT NULL default 'All',
  `orderby` varchar(128) NOT NULL default '',
  `limitto` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`smartplaylistid`),
  KEY `name` (`name`),
  KEY `categoryid` (`categoryid`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `music_smartplaylists`
--

LOCK TABLES `music_smartplaylists` WRITE;
/*!40000 ALTER TABLE `music_smartplaylists` DISABLE KEYS */;
INSERT INTO `music_smartplaylists` VALUES (1,'1960\'s',1,'All','Artist (A)',0),(2,'1970\'s',1,'All','Artist (A)',0),(3,'1980\'s',1,'All','Artist (A)',0),(4,'1990\'s',1,'All','Artist (A)',0),(5,'2000\'s',1,'All','Artist (A)',0),(6,'Favorite Tracks',2,'All','Artist (A), Album (A)',0),(7,'100 Most Played Tracks',2,'All','Play Count (D)',100),(8,'Never Played Tracks',3,'All','Artist (A), Album (A)',0);
/*!40000 ALTER TABLE `music_smartplaylists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `music_songs`
--

DROP TABLE IF EXISTS `music_songs`;
CREATE TABLE `music_songs` (
  `song_id` int(11) unsigned NOT NULL auto_increment,
  `filename` text NOT NULL,
  `name` varchar(255) NOT NULL default '',
  `track` smallint(6) unsigned NOT NULL default '0',
  `artist_id` int(11) unsigned NOT NULL default '0',
  `album_id` int(11) unsigned NOT NULL default '0',
  `genre_id` int(11) unsigned NOT NULL default '0',
  `year` smallint(6) NOT NULL default '0',
  `length` int(11) unsigned NOT NULL default '0',
  `numplays` int(11) unsigned NOT NULL default '0',
  `rating` tinyint(4) unsigned NOT NULL default '0',
  `lastplay` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `date_entered` datetime default NULL,
  `date_modified` datetime default NULL,
  `format` varchar(4) NOT NULL default '0',
  `mythdigest` varchar(255) default NULL,
  `size` bigint(20) unsigned default NULL,
  `description` varchar(255) default NULL,
  `comment` varchar(255) default NULL,
  `disc_count` smallint(5) unsigned default '0',
  `disc_number` smallint(5) unsigned default '0',
  `track_count` smallint(5) unsigned default '0',
  `start_time` int(10) unsigned default '0',
  `stop_time` int(10) unsigned default NULL,
  `eq_preset` varchar(255) default NULL,
  `relative_volume` tinyint(4) default '0',
  `sample_rate` int(10) unsigned default '0',
  `bitrate` int(10) unsigned default '0',
  `bpm` smallint(5) unsigned default NULL,
  PRIMARY KEY  (`song_id`),
  KEY `idx_name` (`name`),
  KEY `idx_mythdigest` (`mythdigest`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `music_songs`
--

LOCK TABLES `music_songs` WRITE;
/*!40000 ALTER TABLE `music_songs` DISABLE KEYS */;
/*!40000 ALTER TABLE `music_songs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `music_stats`
--

DROP TABLE IF EXISTS `music_stats`;
CREATE TABLE `music_stats` (
  `num_artists` smallint(5) unsigned NOT NULL default '0',
  `num_albums` smallint(5) unsigned NOT NULL default '0',
  `num_songs` mediumint(8) unsigned NOT NULL default '0',
  `num_genres` tinyint(3) unsigned NOT NULL default '0',
  `total_time` varchar(12) NOT NULL default '0',
  `total_size` varchar(10) NOT NULL default '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `music_stats`
--

LOCK TABLES `music_stats` WRITE;
/*!40000 ALTER TABLE `music_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `music_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `musicmetadata`
--

DROP TABLE IF EXISTS `musicmetadata`;
CREATE TABLE `musicmetadata` (
  `intid` int(10) unsigned NOT NULL auto_increment,
  `artist` varchar(128) NOT NULL,
  `compilation_artist` varchar(128) NOT NULL,
  `album` varchar(128) NOT NULL,
  `title` varchar(128) NOT NULL,
  `genre` varchar(128) NOT NULL,
  `year` int(10) unsigned NOT NULL,
  `tracknum` int(10) unsigned NOT NULL,
  `length` int(10) unsigned NOT NULL,
  `filename` text NOT NULL,
  `rating` int(10) unsigned NOT NULL default '5',
  `lastplay` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `playcount` int(10) unsigned NOT NULL default '0',
  `mythdigest` varchar(255) default NULL,
  `size` bigint(20) unsigned default NULL,
  `date_added` datetime default NULL,
  `date_modified` datetime default NULL,
  `format` varchar(4) default NULL,
  `description` varchar(255) default NULL,
  `comment` varchar(255) default NULL,
  `compilation` tinyint(4) default '0',
  `composer` varchar(255) default NULL,
  `disc_count` smallint(5) unsigned default '0',
  `disc_number` smallint(5) unsigned default '0',
  `track_count` smallint(5) unsigned default '0',
  `start_time` int(10) unsigned default '0',
  `stop_time` int(10) unsigned default NULL,
  `eq_preset` varchar(255) default NULL,
  `relative_volume` tinyint(4) default '0',
  `sample_rate` int(10) unsigned default NULL,
  `bpm` smallint(5) unsigned default NULL,
  PRIMARY KEY  (`intid`),
  KEY `artist` (`artist`),
  KEY `album` (`album`),
  KEY `title` (`title`),
  KEY `genre` (`genre`),
  KEY `mythdigest` (`mythdigest`),
  KEY `compilation_artist` (`compilation_artist`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `musicmetadata`
--

LOCK TABLES `musicmetadata` WRITE;
/*!40000 ALTER TABLE `musicmetadata` DISABLE KEYS */;
/*!40000 ALTER TABLE `musicmetadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `musicplaylist`
--

DROP TABLE IF EXISTS `musicplaylist`;
CREATE TABLE `musicplaylist` (
  `playlistid` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(128) NOT NULL,
  `hostname` varchar(255) default NULL,
  `songlist` text NOT NULL,
  PRIMARY KEY  (`playlistid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `musicplaylist`
--

LOCK TABLES `musicplaylist` WRITE;
/*!40000 ALTER TABLE `musicplaylist` DISABLE KEYS */;
/*!40000 ALTER TABLE `musicplaylist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mythlog`
--

DROP TABLE IF EXISTS `mythlog`;
CREATE TABLE `mythlog` (
  `logid` int(10) unsigned NOT NULL auto_increment,
  `module` varchar(32) NOT NULL default '',
  `priority` int(11) NOT NULL default '0',
  `acknowledged` tinyint(1) default '0',
  `logdate` datetime default NULL,
  `host` varchar(128) default NULL,
  `message` varchar(255) NOT NULL default '',
  `details` text,
  PRIMARY KEY  (`logid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `mythlog`
--

LOCK TABLES `mythlog` WRITE;
/*!40000 ALTER TABLE `mythlog` DISABLE KEYS */;
/*!40000 ALTER TABLE `mythlog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `networkiconmap`
--

DROP TABLE IF EXISTS `networkiconmap`;
CREATE TABLE `networkiconmap` (
  `id` int(11) NOT NULL auto_increment,
  `network` varchar(20) NOT NULL default '',
  `url` varchar(255) NOT NULL default '',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `network` (`network`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `networkiconmap`
--

LOCK TABLES `networkiconmap` WRITE;
/*!40000 ALTER TABLE `networkiconmap` DISABLE KEYS */;
/*!40000 ALTER TABLE `networkiconmap` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oldfind`
--

DROP TABLE IF EXISTS `oldfind`;
CREATE TABLE `oldfind` (
  `recordid` int(11) NOT NULL default '0',
  `findid` int(11) NOT NULL default '0',
  PRIMARY KEY  (`recordid`,`findid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `oldfind`
--

LOCK TABLES `oldfind` WRITE;
/*!40000 ALTER TABLE `oldfind` DISABLE KEYS */;
/*!40000 ALTER TABLE `oldfind` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oldprogram`
--

DROP TABLE IF EXISTS `oldprogram`;
CREATE TABLE `oldprogram` (
  `oldtitle` varchar(128) NOT NULL default '',
  `airdate` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`oldtitle`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `oldprogram`
--

LOCK TABLES `oldprogram` WRITE;
/*!40000 ALTER TABLE `oldprogram` DISABLE KEYS */;
/*!40000 ALTER TABLE `oldprogram` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oldrecorded`
--

DROP TABLE IF EXISTS `oldrecorded`;
CREATE TABLE `oldrecorded` (
  `chanid` int(10) unsigned NOT NULL default '0',
  `starttime` datetime NOT NULL default '0000-00-00 00:00:00',
  `endtime` datetime NOT NULL default '0000-00-00 00:00:00',
  `title` varchar(128) NOT NULL default '',
  `subtitle` varchar(128) NOT NULL default '',
  `description` text NOT NULL,
  `category` varchar(64) NOT NULL default '',
  `seriesid` varchar(12) NOT NULL default '',
  `programid` varchar(20) NOT NULL default '',
  `findid` int(11) NOT NULL default '0',
  `recordid` int(11) NOT NULL default '0',
  `station` varchar(20) NOT NULL default '',
  `rectype` int(10) unsigned NOT NULL default '0',
  `duplicate` tinyint(1) NOT NULL default '0',
  `recstatus` int(11) NOT NULL default '0',
  `reactivate` smallint(6) NOT NULL default '0',
  `generic` tinyint(1) default '0',
  PRIMARY KEY  (`station`,`starttime`,`title`),
  KEY `endtime` (`endtime`),
  KEY `title` (`title`),
  KEY `seriesid` (`seriesid`),
  KEY `programid` (`programid`),
  KEY `recordid` (`recordid`),
  KEY `recstatus` (`recstatus`,`programid`,`seriesid`),
  KEY `recstatus_2` (`recstatus`,`title`,`subtitle`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `oldrecorded`
--

LOCK TABLES `oldrecorded` WRITE;
/*!40000 ALTER TABLE `oldrecorded` DISABLE KEYS */;
/*!40000 ALTER TABLE `oldrecorded` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `people`
--

DROP TABLE IF EXISTS `people`;
CREATE TABLE `people` (
  `person` mediumint(8) unsigned NOT NULL auto_increment,
  `name` char(128) NOT NULL default '',
  PRIMARY KEY  (`person`),
  UNIQUE KEY `name` (`name`(41))
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `people`
--

LOCK TABLES `people` WRITE;
/*!40000 ALTER TABLE `people` DISABLE KEYS */;
/*!40000 ALTER TABLE `people` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `phonecallhistory`
--

DROP TABLE IF EXISTS `phonecallhistory`;
CREATE TABLE `phonecallhistory` (
  `recid` int(10) unsigned NOT NULL auto_increment,
  `displayname` text NOT NULL,
  `url` text NOT NULL,
  `timestamp` text NOT NULL,
  `duration` int(10) unsigned NOT NULL,
  `directionin` int(10) unsigned NOT NULL,
  `directoryref` int(10) unsigned default NULL,
  PRIMARY KEY  (`recid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `phonecallhistory`
--

LOCK TABLES `phonecallhistory` WRITE;
/*!40000 ALTER TABLE `phonecallhistory` DISABLE KEYS */;
/*!40000 ALTER TABLE `phonecallhistory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `phonedirectory`
--

DROP TABLE IF EXISTS `phonedirectory`;
CREATE TABLE `phonedirectory` (
  `intid` int(10) unsigned NOT NULL auto_increment,
  `nickname` text NOT NULL,
  `firstname` text,
  `surname` text,
  `url` text NOT NULL,
  `directory` text NOT NULL,
  `photofile` text,
  `speeddial` int(10) unsigned NOT NULL,
  `onhomelan` int(10) unsigned default '0',
  PRIMARY KEY  (`intid`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `phonedirectory`
--

LOCK TABLES `phonedirectory` WRITE;
/*!40000 ALTER TABLE `phonedirectory` DISABLE KEYS */;
INSERT INTO `phonedirectory` VALUES (1,'Me(OLDHOSTNAME)','Local Myth Host','OLDHOSTNAME','','My MythTVs','',1,1);
/*!40000 ALTER TABLE `phonedirectory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pidcache`
--

DROP TABLE IF EXISTS `pidcache`;
CREATE TABLE `pidcache` (
  `chanid` smallint(6) NOT NULL default '0',
  `pid` int(11) NOT NULL default '-1',
  `tableid` int(11) NOT NULL default '-1',
  KEY `chanid` (`chanid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pidcache`
--

LOCK TABLES `pidcache` WRITE;
/*!40000 ALTER TABLE `pidcache` DISABLE KEYS */;
/*!40000 ALTER TABLE `pidcache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `playgroup`
--

DROP TABLE IF EXISTS `playgroup`;
CREATE TABLE `playgroup` (
  `name` varchar(32) NOT NULL default '',
  `titlematch` varchar(255) NOT NULL default '',
  `skipahead` int(11) NOT NULL default '0',
  `skipback` int(11) NOT NULL default '0',
  `timestretch` int(11) NOT NULL default '0',
  `jump` int(11) NOT NULL default '0',
  PRIMARY KEY  (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `playgroup`
--

LOCK TABLES `playgroup` WRITE;
/*!40000 ALTER TABLE `playgroup` DISABLE KEYS */;
INSERT INTO `playgroup` VALUES ('Default','',30,5,100,0);
/*!40000 ALTER TABLE `playgroup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profilegroups`
--

DROP TABLE IF EXISTS `profilegroups`;
CREATE TABLE `profilegroups` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(128) default NULL,
  `cardtype` varchar(32) NOT NULL default 'V4L',
  `is_default` int(1) default '0',
  `hostname` varchar(255) default NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `name` (`name`,`hostname`)
) ENGINE=MyISAM AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `profilegroups`
--

LOCK TABLES `profilegroups` WRITE;
/*!40000 ALTER TABLE `profilegroups` DISABLE KEYS */;
INSERT INTO `profilegroups` VALUES (1,'Software Encoders (v4l based)','V4L',1,NULL),(2,'MPEG-2 Encoders (PVR-x50, PVR-500)','MPEG',1,NULL),(3,'Hardware MJPEG Encoders (Matrox G200-TV, Miro DC10, etc)','MJPEG',1,NULL),(4,'Hardware HDTV','HDTV',1,NULL),(5,'Hardware DVB Encoders','DVB',1,NULL),(6,'Transcoders','TRANSCODE',1,NULL),(7,'FireWire Input','FIREWIRE',1,NULL),(8,'USB Mpeg-4 Encoder (Plextor ConvertX, etc)','GO7007',1,NULL),(9,'DBOX2 Input','DBOX2',1,NULL),(10,'Freebox Input','Freebox',1,NULL),(11,'HDHomeRun Recorders','HDHOMERUN',1,NULL),(12,'CRC IP Recorders','CRC_IP',1,NULL);
/*!40000 ALTER TABLE `profilegroups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `program`
--

DROP TABLE IF EXISTS `program`;
CREATE TABLE `program` (
  `chanid` int(10) unsigned NOT NULL default '0',
  `starttime` datetime NOT NULL default '0000-00-00 00:00:00',
  `endtime` datetime NOT NULL default '0000-00-00 00:00:00',
  `title` varchar(128) NOT NULL default '',
  `subtitle` varchar(128) NOT NULL default '',
  `description` text NOT NULL,
  `category` varchar(64) NOT NULL default '',
  `category_type` varchar(64) NOT NULL default '',
  `airdate` year(4) NOT NULL default '0000',
  `stars` float NOT NULL default '0',
  `previouslyshown` tinyint(4) NOT NULL default '0',
  `title_pronounce` varchar(128) NOT NULL default '',
  `stereo` tinyint(1) NOT NULL default '0',
  `subtitled` tinyint(1) NOT NULL default '0',
  `hdtv` tinyint(1) NOT NULL default '0',
  `closecaptioned` tinyint(1) NOT NULL default '0',
  `partnumber` int(11) NOT NULL default '0',
  `parttotal` int(11) NOT NULL default '0',
  `seriesid` varchar(12) NOT NULL default '',
  `originalairdate` date default NULL,
  `showtype` varchar(30) NOT NULL default '',
  `colorcode` varchar(20) NOT NULL default '',
  `syndicatedepisodenumber` varchar(20) NOT NULL default '',
  `programid` varchar(20) NOT NULL default '',
  `manualid` int(10) unsigned NOT NULL default '0',
  `generic` tinyint(1) default '0',
  `listingsource` int(11) NOT NULL default '0',
  `first` tinyint(1) NOT NULL default '0',
  `last` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`chanid`,`starttime`,`manualid`),
  KEY `endtime` (`endtime`),
  KEY `title` (`title`),
  KEY `title_pronounce` (`title_pronounce`),
  KEY `seriesid` (`seriesid`),
  KEY `programid` (`programid`),
  KEY `id_start_end` (`chanid`,`starttime`,`endtime`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `program`
--

LOCK TABLES `program` WRITE;
/*!40000 ALTER TABLE `program` DISABLE KEYS */;
/*!40000 ALTER TABLE `program` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `programgenres`
--

DROP TABLE IF EXISTS `programgenres`;
CREATE TABLE `programgenres` (
  `chanid` int(10) unsigned NOT NULL default '0',
  `starttime` datetime NOT NULL default '0000-00-00 00:00:00',
  `relevance` char(1) NOT NULL default '',
  `genre` char(30) default NULL,
  PRIMARY KEY  (`chanid`,`starttime`,`relevance`),
  KEY `genre` (`genre`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `programgenres`
--

LOCK TABLES `programgenres` WRITE;
/*!40000 ALTER TABLE `programgenres` DISABLE KEYS */;
/*!40000 ALTER TABLE `programgenres` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `programrating`
--

DROP TABLE IF EXISTS `programrating`;
CREATE TABLE `programrating` (
  `chanid` int(10) unsigned NOT NULL default '0',
  `starttime` datetime NOT NULL default '0000-00-00 00:00:00',
  `system` char(8) NOT NULL default '',
  `rating` char(8) NOT NULL default '',
  UNIQUE KEY `chanid` (`chanid`,`starttime`,`system`,`rating`),
  KEY `starttime` (`starttime`,`system`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `programrating`
--

LOCK TABLES `programrating` WRITE;
/*!40000 ALTER TABLE `programrating` DISABLE KEYS */;
/*!40000 ALTER TABLE `programrating` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recgrouppassword`
--

DROP TABLE IF EXISTS `recgrouppassword`;
CREATE TABLE `recgrouppassword` (
  `recgroup` varchar(32) NOT NULL default '',
  `password` varchar(10) NOT NULL default '',
  PRIMARY KEY  (`recgroup`),
  UNIQUE KEY `recgroup` (`recgroup`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `recgrouppassword`
--

LOCK TABLES `recgrouppassword` WRITE;
/*!40000 ALTER TABLE `recgrouppassword` DISABLE KEYS */;
/*!40000 ALTER TABLE `recgrouppassword` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `record`
--

DROP TABLE IF EXISTS `record`;
CREATE TABLE `record` (
  `recordid` int(10) unsigned NOT NULL auto_increment,
  `type` int(10) unsigned NOT NULL default '0',
  `chanid` int(10) unsigned default NULL,
  `starttime` time NOT NULL default '00:00:00',
  `startdate` date NOT NULL default '0000-00-00',
  `endtime` time NOT NULL default '00:00:00',
  `enddate` date NOT NULL default '0000-00-00',
  `title` varchar(128) NOT NULL default '',
  `subtitle` varchar(128) NOT NULL default '',
  `description` text NOT NULL,
  `category` varchar(64) NOT NULL default '',
  `profile` varchar(128) NOT NULL default 'Default',
  `recpriority` int(10) NOT NULL default '0',
  `autoexpire` int(11) NOT NULL default '0',
  `maxepisodes` int(11) NOT NULL default '0',
  `maxnewest` int(11) NOT NULL default '0',
  `startoffset` int(11) NOT NULL default '0',
  `endoffset` int(11) NOT NULL default '0',
  `recgroup` varchar(32) NOT NULL default 'Default',
  `dupmethod` int(11) NOT NULL default '6',
  `dupin` int(11) NOT NULL default '15',
  `station` varchar(20) NOT NULL default '',
  `seriesid` varchar(12) NOT NULL default '',
  `programid` varchar(20) NOT NULL default '',
  `search` int(10) unsigned NOT NULL default '0',
  `autotranscode` tinyint(1) NOT NULL default '0',
  `autocommflag` tinyint(1) NOT NULL default '0',
  `autouserjob1` tinyint(1) NOT NULL default '0',
  `autouserjob2` tinyint(1) NOT NULL default '0',
  `autouserjob3` tinyint(1) NOT NULL default '0',
  `autouserjob4` tinyint(1) NOT NULL default '0',
  `findday` tinyint(4) NOT NULL default '0',
  `findtime` time NOT NULL default '00:00:00',
  `findid` int(11) NOT NULL default '0',
  `inactive` tinyint(1) NOT NULL default '0',
  `parentid` int(11) NOT NULL default '0',
  `transcoder` int(11) NOT NULL default '0',
  `tsdefault` float NOT NULL default '1',
  `playgroup` varchar(32) NOT NULL default 'Default',
  `prefinput` int(10) NOT NULL default '0',
  `next_record` datetime NOT NULL,
  `last_record` datetime NOT NULL,
  `last_delete` datetime NOT NULL,
  PRIMARY KEY  (`recordid`),
  KEY `chanid` (`chanid`,`starttime`),
  KEY `title` (`title`),
  KEY `seriesid` (`seriesid`),
  KEY `programid` (`programid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `record`
--

LOCK TABLES `record` WRITE;
/*!40000 ALTER TABLE `record` DISABLE KEYS */;
/*!40000 ALTER TABLE `record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recorded`
--

DROP TABLE IF EXISTS `recorded`;
CREATE TABLE `recorded` (
  `chanid` int(10) unsigned NOT NULL default '0',
  `starttime` datetime NOT NULL default '0000-00-00 00:00:00',
  `endtime` datetime NOT NULL default '0000-00-00 00:00:00',
  `title` varchar(128) NOT NULL default '',
  `subtitle` varchar(128) NOT NULL default '',
  `description` text NOT NULL,
  `category` varchar(64) NOT NULL default '',
  `hostname` varchar(255) NOT NULL default '',
  `bookmark` tinyint(1) NOT NULL default '0',
  `editing` int(10) unsigned NOT NULL default '0',
  `cutlist` tinyint(1) NOT NULL default '0',
  `autoexpire` int(11) NOT NULL default '0',
  `commflagged` int(10) unsigned NOT NULL default '0',
  `recgroup` varchar(32) NOT NULL default 'Default',
  `recordid` int(11) default NULL,
  `seriesid` varchar(12) NOT NULL default '',
  `programid` varchar(20) NOT NULL default '',
  `lastmodified` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `filesize` bigint(20) NOT NULL default '0',
  `stars` float NOT NULL default '0',
  `previouslyshown` tinyint(1) default '0',
  `originalairdate` date default NULL,
  `preserve` tinyint(1) NOT NULL default '0',
  `findid` int(11) NOT NULL default '0',
  `deletepending` tinyint(1) NOT NULL default '0',
  `transcoder` int(11) NOT NULL default '0',
  `timestretch` float NOT NULL default '1',
  `recpriority` int(11) NOT NULL default '0',
  `basename` varchar(128) NOT NULL default '',
  `progstart` datetime NOT NULL default '0000-00-00 00:00:00',
  `progend` datetime NOT NULL default '0000-00-00 00:00:00',
  `playgroup` varchar(32) NOT NULL default 'Default',
  `profile` varchar(32) NOT NULL default '',
  `duplicate` tinyint(1) NOT NULL default '0',
  `transcoded` tinyint(1) NOT NULL default '0',
  `watched` tinyint(4) NOT NULL default '0',
  PRIMARY KEY  (`chanid`,`starttime`),
  KEY `endtime` (`endtime`),
  KEY `seriesid` (`seriesid`),
  KEY `programid` (`programid`),
  KEY `title` (`title`),
  KEY `recordid` (`recordid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `recorded`
--

LOCK TABLES `recorded` WRITE;
/*!40000 ALTER TABLE `recorded` DISABLE KEYS */;
/*!40000 ALTER TABLE `recorded` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recordedcredits`
--

DROP TABLE IF EXISTS `recordedcredits`;
CREATE TABLE `recordedcredits` (
  `person` mediumint(8) unsigned NOT NULL default '0',
  `chanid` int(10) unsigned NOT NULL default '0',
  `starttime` datetime NOT NULL default '0000-00-00 00:00:00',
  `role` set('actor','director','producer','executive_producer','writer','guest_star','host','adapter','presenter','commentator','guest') NOT NULL default '',
  UNIQUE KEY `chanid` (`chanid`,`starttime`,`person`,`role`),
  KEY `person` (`person`,`role`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `recordedcredits`
--

LOCK TABLES `recordedcredits` WRITE;
/*!40000 ALTER TABLE `recordedcredits` DISABLE KEYS */;
/*!40000 ALTER TABLE `recordedcredits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recordedmarkup`
--

DROP TABLE IF EXISTS `recordedmarkup`;
CREATE TABLE `recordedmarkup` (
  `chanid` int(10) unsigned NOT NULL default '0',
  `starttime` datetime NOT NULL default '0000-00-00 00:00:00',
  `mark` bigint(20) NOT NULL default '0',
  `offset` varchar(32) default NULL,
  `type` int(11) NOT NULL default '0',
  PRIMARY KEY  (`chanid`,`starttime`,`type`,`mark`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `recordedmarkup`
--

LOCK TABLES `recordedmarkup` WRITE;
/*!40000 ALTER TABLE `recordedmarkup` DISABLE KEYS */;
/*!40000 ALTER TABLE `recordedmarkup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recordedprogram`
--

DROP TABLE IF EXISTS `recordedprogram`;
CREATE TABLE `recordedprogram` (
  `chanid` int(10) unsigned NOT NULL default '0',
  `starttime` datetime NOT NULL default '0000-00-00 00:00:00',
  `endtime` datetime NOT NULL default '0000-00-00 00:00:00',
  `title` varchar(128) NOT NULL default '',
  `subtitle` varchar(128) NOT NULL default '',
  `description` text NOT NULL,
  `category` varchar(64) NOT NULL default '',
  `category_type` varchar(64) NOT NULL default '',
  `airdate` year(4) NOT NULL default '0000',
  `stars` float unsigned NOT NULL default '0',
  `previouslyshown` tinyint(4) NOT NULL default '0',
  `title_pronounce` varchar(128) NOT NULL default '',
  `stereo` tinyint(1) NOT NULL default '0',
  `subtitled` tinyint(1) NOT NULL default '0',
  `hdtv` tinyint(1) NOT NULL default '0',
  `closecaptioned` tinyint(1) NOT NULL default '0',
  `partnumber` int(11) NOT NULL default '0',
  `parttotal` int(11) NOT NULL default '0',
  `seriesid` varchar(12) NOT NULL default '',
  `originalairdate` date default NULL,
  `showtype` varchar(30) NOT NULL default '',
  `colorcode` varchar(20) NOT NULL default '',
  `syndicatedepisodenumber` varchar(20) NOT NULL default '',
  `programid` varchar(20) NOT NULL default '',
  `manualid` int(10) unsigned NOT NULL default '0',
  `generic` tinyint(1) default '0',
  `listingsource` int(11) NOT NULL default '0',
  `first` tinyint(1) NOT NULL default '0',
  `last` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`chanid`,`starttime`,`manualid`),
  KEY `endtime` (`endtime`),
  KEY `title` (`title`),
  KEY `title_pronounce` (`title_pronounce`),
  KEY `seriesid` (`seriesid`),
  KEY `programid` (`programid`),
  KEY `id_start_end` (`chanid`,`starttime`,`endtime`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `recordedprogram`
--

LOCK TABLES `recordedprogram` WRITE;
/*!40000 ALTER TABLE `recordedprogram` DISABLE KEYS */;
/*!40000 ALTER TABLE `recordedprogram` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recordedrating`
--

DROP TABLE IF EXISTS `recordedrating`;
CREATE TABLE `recordedrating` (
  `chanid` int(10) unsigned NOT NULL default '0',
  `starttime` datetime NOT NULL default '0000-00-00 00:00:00',
  `system` char(8) NOT NULL default '',
  `rating` char(8) NOT NULL default '',
  UNIQUE KEY `chanid` (`chanid`,`starttime`,`system`,`rating`),
  KEY `starttime` (`starttime`,`system`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `recordedrating`
--

LOCK TABLES `recordedrating` WRITE;
/*!40000 ALTER TABLE `recordedrating` DISABLE KEYS */;
/*!40000 ALTER TABLE `recordedrating` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recordedseek`
--

DROP TABLE IF EXISTS `recordedseek`;
CREATE TABLE `recordedseek` (
  `chanid` int(10) unsigned NOT NULL default '0',
  `starttime` datetime NOT NULL default '0000-00-00 00:00:00',
  `mark` bigint(20) NOT NULL default '0',
  `offset` varchar(32) default NULL,
  `type` int(11) NOT NULL default '0',
  PRIMARY KEY  (`chanid`,`starttime`,`type`,`mark`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `recordedseek`
--

LOCK TABLES `recordedseek` WRITE;
/*!40000 ALTER TABLE `recordedseek` DISABLE KEYS */;
/*!40000 ALTER TABLE `recordedseek` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recordingprofiles`
--

DROP TABLE IF EXISTS `recordingprofiles`;
CREATE TABLE `recordingprofiles` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(128) default NULL,
  `videocodec` varchar(128) default NULL,
  `audiocodec` varchar(128) default NULL,
  `profilegroup` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=42 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `recordingprofiles`
--

LOCK TABLES `recordingprofiles` WRITE;
/*!40000 ALTER TABLE `recordingprofiles` DISABLE KEYS */;
INSERT INTO `recordingprofiles` VALUES (1,'Default',NULL,NULL,1),(2,'Live TV',NULL,NULL,1),(3,'High Quality',NULL,NULL,1),(4,'Low Quality',NULL,NULL,1),(5,'Default',NULL,NULL,2),(6,'Live TV',NULL,NULL,2),(7,'High Quality',NULL,NULL,2),(8,'Low Quality',NULL,NULL,2),(9,'Default',NULL,NULL,3),(10,'Live TV',NULL,NULL,3),(11,'High Quality',NULL,NULL,3),(12,'Low Quality',NULL,NULL,3),(13,'Default',NULL,NULL,4),(14,'Live TV',NULL,NULL,4),(15,'High Quality',NULL,NULL,4),(16,'Low Quality',NULL,NULL,4),(17,'Default',NULL,NULL,5),(18,'Live TV',NULL,NULL,5),(19,'High Quality',NULL,NULL,5),(20,'Low Quality',NULL,NULL,5),(21,'RTjpeg/MPEG4',NULL,NULL,6),(22,'MPEG2',NULL,NULL,6),(23,'Default',NULL,NULL,8),(24,'Live TV',NULL,NULL,8),(25,'High Quality',NULL,NULL,8),(26,'Low Quality',NULL,NULL,8),(27,'High Quality',NULL,NULL,6),(28,'Medium Quality',NULL,NULL,6),(29,'Low Quality',NULL,NULL,6),(30,'Default',NULL,NULL,10),(31,'Live TV',NULL,NULL,10),(32,'High Quality',NULL,NULL,10),(33,'Low Quality',NULL,NULL,10),(34,'Default',NULL,NULL,11),(35,'Live TV',NULL,NULL,11),(36,'High Quality',NULL,NULL,11),(37,'Low Quality',NULL,NULL,11),(38,'Default',NULL,NULL,12),(39,'Live TV',NULL,NULL,12),(40,'High Quality',NULL,NULL,12),(41,'Low Quality',NULL,NULL,12);
/*!40000 ALTER TABLE `recordingprofiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recordmatch`
--

DROP TABLE IF EXISTS `recordmatch`;
CREATE TABLE `recordmatch` (
  `recordid` int(10) unsigned default NULL,
  `chanid` int(10) unsigned default NULL,
  `starttime` datetime default NULL,
  `manualid` int(10) unsigned default NULL,
  KEY `recordid` (`recordid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `recordmatch`
--

LOCK TABLES `recordmatch` WRITE;
/*!40000 ALTER TABLE `recordmatch` DISABLE KEYS */;
/*!40000 ALTER TABLE `recordmatch` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `romdb`
--

DROP TABLE IF EXISTS `romdb`;
CREATE TABLE `romdb` (
  `crc` varchar(64) NOT NULL default '',
  `name` varchar(128) NOT NULL default '',
  `description` varchar(128) NOT NULL default '',
  `category` varchar(128) NOT NULL default '',
  `year` varchar(10) NOT NULL default '',
  `manufacturer` varchar(128) NOT NULL default '',
  `country` varchar(128) NOT NULL default '',
  `publisher` varchar(128) NOT NULL default '',
  `platform` varchar(64) NOT NULL default '',
  `filesize` int(12) default NULL,
  `flags` varchar(64) NOT NULL default '',
  `version` varchar(64) NOT NULL default '',
  `binfile` varchar(64) NOT NULL default '',
  KEY `crc` (`crc`),
  KEY `year` (`year`),
  KEY `category` (`category`),
  KEY `name` (`name`),
  KEY `description` (`description`),
  KEY `platform` (`platform`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `romdb`
--

LOCK TABLES `romdb` WRITE;
/*!40000 ALTER TABLE `romdb` DISABLE KEYS */;
/*!40000 ALTER TABLE `romdb` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schemalock`
--

DROP TABLE IF EXISTS `schemalock`;
CREATE TABLE `schemalock` (
  `schemalock` int(1) default NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `schemalock`
--

LOCK TABLES `schemalock` WRITE;
/*!40000 ALTER TABLE `schemalock` DISABLE KEYS */;
/*!40000 ALTER TABLE `schemalock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
CREATE TABLE `settings` (
  `value` varchar(128) NOT NULL default '',
  `data` text,
  `hostname` varchar(255) default NULL,
  KEY `value` (`value`,`hostname`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES ('mythfilldatabaseLastRunStart',NULL,NULL),('mythfilldatabaseLastRunEnd',NULL,NULL),('mythfilldatabaseLastRunStatus',NULL,NULL),('DataDirectMessage',NULL,NULL),('HaveRepeats','0',NULL),('DBSchemaVer','1160',NULL),('DefaultTranscoder','0',NULL),('MythFillSuggestedRunTime','1970-01-01T00:00:00',NULL),('MythFillGrabberSuggestsTime','1',NULL),('BackendServerIP','127.0.0.1','OLDHOSTNAME'),('BackendServerPort','6543','OLDHOSTNAME'),('BackendStatusPort','6544','OLDHOSTNAME'),('MasterServerIP','127.0.0.1',NULL),('MasterServerPort','6543',NULL),('RecordFilePrefix','/var/lib/mythtv/recordings','OLDHOSTNAME'),('TruncateDeletesSlowly','0','OLDHOSTNAME'),('TVFormat','NTSC',NULL),('VbiFormat','None',NULL),('FreqTable','us-bcast',NULL),('TimeOffset','None',NULL),('MasterBackendOverride','1',NULL),('DeletesFollowLinks','0',NULL),('EITTimeOffset','Auto',NULL),('EITTransportTimeout','5',NULL),('EITIgnoresSource','0',NULL),('EITCrawIdleStart','60',NULL),('startupCommand','',NULL),('blockSDWUwithoutClient','1',NULL),('idleTimeoutSecs','0',NULL),('idleWaitForRecordingTime','15',NULL),('StartupSecsBeforeRecording','120',NULL),('WakeupTimeFormat','hh:mm yyyy-MM-dd',NULL),('SetWakeuptimeCommand','',NULL),('ServerHaltCommand','sudo /sbin/halt -p',NULL),('preSDWUCheckCommand','',NULL),('WOLbackendReconnectWaitTime','0',NULL),('WOLbackendConnectRetry','5',NULL),('WOLbackendCommand','',NULL),('WOLslaveBackendsCommand','',NULL),('JobQueueMaxSimultaneousJobs','1','OLDHOSTNAME'),('JobQueueCheckFrequency','60','OLDHOSTNAME'),('JobQueueWindowStart','00:00','OLDHOSTNAME'),('JobQueueWindowEnd','23:59','OLDHOSTNAME'),('JobQueueCPU','0','OLDHOSTNAME'),('JobAllowCommFlag','1','OLDHOSTNAME'),('JobAllowTranscode','1','OLDHOSTNAME'),('JobAllowUserJob1','0','OLDHOSTNAME'),('JobAllowUserJob2','0','OLDHOSTNAME'),('JobAllowUserJob3','0','OLDHOSTNAME'),('JobAllowUserJob4','0','OLDHOSTNAME'),('JobsRunOnRecordHost','0',NULL),('AutoCommflagWhileRecording','0',NULL),('JobQueueCommFlagCommand','mythcommflag',NULL),('JobQueueTranscodeCommand','mythtranscode',NULL),('AutoTranscodeBeforeAutoCommflag','0',NULL),('SaveTranscoding','0',NULL),('UserJobDesc1','User Job #1',NULL),('UserJob1','',NULL),('UserJobDesc2','User Job #2',NULL),('UserJob2','',NULL),('UserJobDesc3','User Job #3',NULL),('UserJob3','',NULL),('UserJobDesc4','User Job #4',NULL),('UserJob4','',NULL),('upnp:UDN:urn:schemas-upnp-org:device:MediaServer:1','256a89b4-1266-49ca-9ac7-f0b4b4641e7f','OLDHOSTNAME'),('Deinterlace','0','OLDHOSTNAME'),('DeinterlaceFilter','linearblend','OLDHOSTNAME'),('CustomFilters','','OLDHOSTNAME'),('PreferredMPEG2Decoder','ffmpeg','OLDHOSTNAME'),('UseOpenGLVSync','0','OLDHOSTNAME'),('RealtimePriority','1','OLDHOSTNAME'),('UseVideoTimebase','0','OLDHOSTNAME'),('DecodeExtraAudio','1','OLDHOSTNAME'),('AspectOverride','0','OLDHOSTNAME'),('PIPLocation','0','OLDHOSTNAME'),('PlaybackExitPrompt','0','OLDHOSTNAME'),('EndOfRecordingExitPrompt','0','OLDHOSTNAME'),('ClearSavedPosition','1','OLDHOSTNAME'),('AltClearSavedPosition','1','OLDHOSTNAME'),('UseOutputPictureControls','0','OLDHOSTNAME'),('AudioNag','1','OLDHOSTNAME'),('UDPNotifyPort','6948','OLDHOSTNAME'),('PlayBoxOrdering','1','OLDHOSTNAME'),('PlayBoxEpisodeSort','Date','OLDHOSTNAME'),('GeneratePreviewPixmaps','0','OLDHOSTNAME'),('PreviewPixmapOffset','64',NULL),('PreviewFromBookmark','1','OLDHOSTNAME'),('PlaybackPreview','1','OLDHOSTNAME'),('PlaybackPreviewLowCPU','0','OLDHOSTNAME'),('PlaybackBoxStartInTitle','1','OLDHOSTNAME'),('ShowGroupInfo','0','OLDHOSTNAME'),('AllRecGroupPassword','',NULL),('DisplayRecGroup','All Programs','OLDHOSTNAME'),('QueryInitialFilter','0','OLDHOSTNAME'),('RememberRecGroup','1','OLDHOSTNAME'),('DispRecGroupAsAllProg','0','OLDHOSTNAME'),('LiveTVInAllPrograms','0','OLDHOSTNAME'),('DisplayGroupDefaultView','0','OLDHOSTNAME'),('DisplayGroupTitleSort','0','OLDHOSTNAME'),('PVR350OutputEnable','0','OLDHOSTNAME'),('PVR350VideoDev','/dev/video16','OLDHOSTNAME'),('PVR350EPGAlphaValue','164','OLDHOSTNAME'),('PVR350InternalAudioOnly','0','OLDHOSTNAME'),('SmartForward','0','OLDHOSTNAME'),('StickyKeys','0','OLDHOSTNAME'),('FFRewReposTime','100','OLDHOSTNAME'),('FFRewReverse','1','OLDHOSTNAME'),('ExactSeeking','0','OLDHOSTNAME'),('AutoCommercialSkip','0','OLDHOSTNAME'),('CommRewindAmount','0','OLDHOSTNAME'),('CommNotifyAmount','0','OLDHOSTNAME'),('MaximumCommercialSkip','3600',NULL),('CommSkipAllBlanks','1',NULL),('VertScanPercentage','0','OLDHOSTNAME'),('HorizScanPercentage','0','OLDHOSTNAME'),('XScanDisplacement','0','OLDHOSTNAME'),('YScanDisplacement','0','OLDHOSTNAME'),('OSDTheme','blueosd','OLDHOSTNAME'),('OSDGeneralTimeout','2','OLDHOSTNAME'),('OSDProgramInfoTimeout','3','OLDHOSTNAME'),('OSDNotifyTimeout','5','OLDHOSTNAME'),('OSDFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCCFont','FreeMono.ttf','OLDHOSTNAME'),('OSDThemeFontSizeType','default','OLDHOSTNAME'),('CCBackground','0','OLDHOSTNAME'),('DefaultCCMode','0','OLDHOSTNAME'),('PersistentBrowseMode','1','OLDHOSTNAME'),('EnableMHEG','0','OLDHOSTNAME'),('OSDCC708TextZoom','100','OLDHOSTNAME'),('OSDCC708DefaultFontType','MonoSerif','OLDHOSTNAME'),('OSDCC708MonoSerifFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708PropSerifFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708MonoSansSerifFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708PropSansSerifFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708CasualFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708CursiveFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708CapitalsFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708MonoSerifItalicFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708PropSerifItalicFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708MonoSansSerifItalicFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708PropSansSerifItalicFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708CasualItalicFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708CursiveItalicFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708CapitalsItalicFont','FreeMono.ttf','OLDHOSTNAME'),('ChannelOrdering','channum','OLDHOSTNAME'),('ChannelFormat','<num> <sign>','OLDHOSTNAME'),('LongChannelFormat','<num> <name>','OLDHOSTNAME'),('SmartChannelChange','0','OLDHOSTNAME'),('LastFreeCard','0',NULL),('AutoExpireMethod','2',NULL),('AutoExpireDayPriority','3',NULL),('AutoExpireDefault','1',NULL),('AutoExpireLiveTVMaxAge','1',NULL),('AutoExpireExtraSpace','1',NULL),('AutoCommercialFlag','1',NULL),('CommercialSkipMethod','255',NULL),('AggressiveCommDetect','1',NULL),('AutoTranscode','0',NULL),('AutoRunUserJob1','0',NULL),('AutoRunUserJob2','0',NULL),('AutoRunUserJob3','0',NULL),('AutoRunUserJob4','0',NULL),('RecordPreRoll','0',NULL),('RecordOverTime','0',NULL),('OverTimeCategory','category name',NULL),('CategoryOverTime','30',NULL),('ATSCCheckSignalThreshold','65',NULL),('ATSCCheckSignalWait','5000',NULL),('HDRingbufferSize','9400',NULL),('EPGFillType','10','OLDHOSTNAME'),('EPGShowCategoryColors','1','OLDHOSTNAME'),('EPGShowCategoryText','1','OLDHOSTNAME'),('EPGScrollType','1','OLDHOSTNAME'),('EPGShowChannelIcon','1','OLDHOSTNAME'),('EPGShowFavorites','0','OLDHOSTNAME'),('WatchTVGuide','0','OLDHOSTNAME'),('chanPerPage','5','OLDHOSTNAME'),('timePerPage','4','OLDHOSTNAME'),('UnknownTitle','Unknown','OLDHOSTNAME'),('UnknownCategory','Unknown','OLDHOSTNAME'),('DefaultTVChannel','3','OLDHOSTNAME'),('SelectChangesChannel','0','OLDHOSTNAME'),('SelChangeRecThreshold','16','OLDHOSTNAME'),('EPGEnableJumpToChannel','0',NULL),('Theme','G.A.N.T.','OLDHOSTNAME'),('ThemePainter','qt','OLDHOSTNAME'),('Style','','OLDHOSTNAME'),('ThemeFontSizeType','default','OLDHOSTNAME'),('RandomTheme','0','OLDHOSTNAME'),('MenuTheme','Default','OLDHOSTNAME'),('XineramaScreen','0','OLDHOSTNAME'),('XineramaMonitorAspectRatio','1.3333','OLDHOSTNAME'),('GuiWidth','0','OLDHOSTNAME'),('GuiHeight','0','OLDHOSTNAME'),('GuiOffsetX','0','OLDHOSTNAME'),('GuiOffsetY','0','OLDHOSTNAME'),('GuiSizeForTV','1','OLDHOSTNAME'),('HideMouseCursor','1','OLDHOSTNAME'),('RunFrontendInWindow','0','OLDHOSTNAME'),('UseVideoModes','0','OLDHOSTNAME'),('GuiVidModeResolution','640x480','OLDHOSTNAME'),('TVVidModeResolution','640x480','OLDHOSTNAME'),('TVVidModeForceAspect','0.0','OLDHOSTNAME'),('VidModeWidth0','0','OLDHOSTNAME'),('VidModeHeight0','0','OLDHOSTNAME'),('TVVidModeResolution0','640x480','OLDHOSTNAME'),('TVVidModeForceAspect0','0.0','OLDHOSTNAME'),('VidModeWidth1','0','OLDHOSTNAME'),('VidModeHeight1','0','OLDHOSTNAME'),('TVVidModeResolution1','640x480','OLDHOSTNAME'),('TVVidModeForceAspect1','0.0','OLDHOSTNAME'),('VidModeWidth2','0','OLDHOSTNAME'),('VidModeHeight2','0','OLDHOSTNAME'),('TVVidModeResolution2','640x480','OLDHOSTNAME'),('TVVidModeForceAspect2','0.0','OLDHOSTNAME'),('ISO639Language0','eng','OLDHOSTNAME'),('ISO639Language1','eng','OLDHOSTNAME'),('DateFormat','ddd MMM d','OLDHOSTNAME'),('ShortDateFormat','M/d','OLDHOSTNAME'),('TimeFormat','h:mm AP','OLDHOSTNAME'),('QtFontSmall','12','OLDHOSTNAME'),('QtFontMedium','16','OLDHOSTNAME'),('QtFontBig','25','OLDHOSTNAME'),('PlayBoxTransparency','1','OLDHOSTNAME'),('PlayBoxShading','0','OLDHOSTNAME'),('UseVirtualKeyboard','1','OLDHOSTNAME'),('LCDEnable','0','OLDHOSTNAME'),('LCDShowTime','1','OLDHOSTNAME'),('LCDShowMenu','1','OLDHOSTNAME'),('LCDShowMusic','1','OLDHOSTNAME'),('LCDShowMusicItems','ArtistTitle','OLDHOSTNAME'),('LCDShowChannel','1','OLDHOSTNAME'),('LCDShowRecStatus','0','OLDHOSTNAME'),('LCDShowVolume','1','OLDHOSTNAME'),('LCDShowGeneric','1','OLDHOSTNAME'),('LCDBacklightOn','1','OLDHOSTNAME'),('LCDHeartBeatOn','0','OLDHOSTNAME'),('LCDBigClock','0','OLDHOSTNAME'),('LCDKeyString','ABCDEF','OLDHOSTNAME'),('LCDPopupTime','5','OLDHOSTNAME'),('AudioOutputDevice','ALSA:default','OLDHOSTNAME'),('PassThruOutputDevice','Default','OLDHOSTNAME'),('AC3PassThru','0','OLDHOSTNAME'),('DTSPassThru','0','OLDHOSTNAME'),('AggressiveSoundcardBuffer','0','OLDHOSTNAME'),('MythControlsVolume','1','OLDHOSTNAME'),('MixerDevice','default','OLDHOSTNAME'),('MixerControl','PCM','OLDHOSTNAME'),('MasterMixerVolume','70','OLDHOSTNAME'),('PCMMixerVolume','70','OLDHOSTNAME'),('IndividualMuteControl','0','OLDHOSTNAME'),('AllowQuitShutdown','4','OLDHOSTNAME'),('NoPromptOnExit','1','OLDHOSTNAME'),('HaltCommand','halt','OLDHOSTNAME'),('LircKeyPressedApp','','OLDHOSTNAME'),('UseArrowAccels','1','OLDHOSTNAME'),('NetworkControlEnabled','0','OLDHOSTNAME'),('NetworkControlPort','6546','OLDHOSTNAME'),('SetupPinCodeRequired','0','OLDHOSTNAME'),('MonitorDrives','0','OLDHOSTNAME'),('EnableXbox','0','OLDHOSTNAME'),('LogEnabled','0',NULL),('LogPrintLevel','8','OLDHOSTNAME'),('LogCleanEnabled','0','OLDHOSTNAME'),('LogCleanPeriod','14','OLDHOSTNAME'),('LogCleanDays','14','OLDHOSTNAME'),('LogCleanMax','30','OLDHOSTNAME'),('LogMaxCount','100','OLDHOSTNAME'),('MythFillEnabled','0',NULL),('MythFillDatabasePath','/usr/bin/mythfilldatabase',NULL),('MythFillDatabaseArgs','',NULL),('MythFillDatabaseLog','',NULL),('MythFillPeriod','1',NULL),('MythFillMinHour','2',NULL),('MythFillMaxHour','5',NULL),('SchedMoveHigher','1',NULL),('DefaultStartOffset','0',NULL),('DefaultEndOffset','0',NULL),('ComplexPriority','0',NULL),('PrefInputPriority','2',NULL),('OnceRecPriority','0',NULL),('HDTVRecPriority','0',NULL),('CCRecPriority','0',NULL),('SingleRecordRecPriority','1',NULL),('OverrideRecordRecPriority','0',NULL),('FindOneRecordRecPriority','-1',NULL),('WeekslotRecordRecPriority','0',NULL),('TimeslotRecordRecPriority','0',NULL),('ChannelRecordRecPriority','0',NULL),('AllRecordRecPriority','0',NULL),('ArchiveDBSchemaVer','1000',NULL),('MythArchiveTempDir','','OLDHOSTNAME'),('MythArchiveShareDir','/usr/share/mythtv/mytharchive/','OLDHOSTNAME'),('MythArchiveVideoFormat','PAL','OLDHOSTNAME'),('MythArchiveFileFilter','*.mpg *.mov *.avi *.mpeg *.nuv','OLDHOSTNAME'),('MythArchiveDVDLocation','/dev/dvd','OLDHOSTNAME'),('MythArchiveEncodeToAc3','0','OLDHOSTNAME'),('MythArchiveCopyRemoteFiles','0','OLDHOSTNAME'),('MythArchiveAlwaysUseMythTranscode','1','OLDHOSTNAME'),('MythArchiveUseFIFO','1','OLDHOSTNAME'),('MythArchiveMainMenuAR','16:9','OLDHOSTNAME'),('MythArchiveChapterMenuAR','Video','OLDHOSTNAME'),('MythArchiveDateFormat','%a  %b  %d','OLDHOSTNAME'),('MythArchiveTimeFormat','%I:%M %p','OLDHOSTNAME'),('MythArchiveFfmpegCmd','ffmpeg','OLDHOSTNAME'),('MythArchiveMplexCmd','mplex','OLDHOSTNAME'),('MythArchiveDvdauthorCmd','dvdauthor','OLDHOSTNAME'),('MythArchiveSpumuxCmd','spumux','OLDHOSTNAME'),('MythArchiveMpeg2encCmd','mpeg2enc','OLDHOSTNAME'),('MythArchiveMkisofsCmd','mkisofs','OLDHOSTNAME'),('MythArchiveGrowisofsCmd','growisofs','OLDHOSTNAME'),('MythArchiveTcrequantCmd','tcrequant','OLDHOSTNAME'),('MythArchivePng2yuvCmd','png2yuv','OLDHOSTNAME'),('DVDDBSchemaVer','1002',NULL),('DVDDeviceLocation','/dev/dvd','OLDHOSTNAME'),('VCDDeviceLocation','/dev/cdrom','OLDHOSTNAME'),('DVDOnInsertDVD','1','OLDHOSTNAME'),('mythdvd.DVDPlayerCommand','Internal','OLDHOSTNAME'),('VCDPlayerCommand','mplayer vcd:// -cdrom-device %d -fs -zoom -vo xv','OLDHOSTNAME'),('DVDRipLocation','/var/lib/mythdvd/temp','OLDHOSTNAME'),('TitlePlayCommand','mplayer dvd://%t -dvd-device %d -fs -zoom -vo xv -aid %a -channels %c','OLDHOSTNAME'),('SubTitleCommand','-sid %s','OLDHOSTNAME'),('TranscodeCommand','transcode','OLDHOSTNAME'),('MTDPort','2442','OLDHOSTNAME'),('MTDNiceLevel','20','OLDHOSTNAME'),('MTDConcurrentTranscodes','1','OLDHOSTNAME'),('MTDRipSize','0','OLDHOSTNAME'),('MTDLogFlag','0','OLDHOSTNAME'),('MTDac3Flag','0','OLDHOSTNAME'),('MTDxvidFlag','1','OLDHOSTNAME'),('mythvideo.TrustTranscodeFRDetect','1','OLDHOSTNAME'),('GalleryDBSchemaVer','1000',NULL),('GalleryDir','/var/lib/mythtv/pictures','OLDHOSTNAME'),('GalleryThumbnailLocation','1','OLDHOSTNAME'),('GallerySortOrder','20','OLDHOSTNAME'),('GalleryImportDirs','/media/cdrom:/media/usbdisk','OLDHOSTNAME'),('GalleryMoviePlayerCmd','mplayer -fs %s','OLDHOSTNAME'),('SlideshowOpenGLTransition','none','OLDHOSTNAME'),('SlideshowOpenGLTransitionLength','2000','OLDHOSTNAME'),('GalleryOverlayCaption','0','OLDHOSTNAME'),('SlideshowTransition','none','OLDHOSTNAME'),('SlideshowBackground','','OLDHOSTNAME'),('SlideshowDelay','5','OLDHOSTNAME'),('GameDBSchemaVer','1012',NULL),('MusicDBSchemaVer','1006',NULL),('MusicLocation','/var/lib/mythtv/music/','OLDHOSTNAME'),('MusicAudioDevice','default','OLDHOSTNAME'),('CDDevice','/dev/cdrom','OLDHOSTNAME'),('TreeLevels','splitartist artist album title','OLDHOSTNAME'),('NonID3FileNameFormat','GENRE/ARTIST/ALBUM/TRACK_TITLE','OLDHOSTNAME'),('Ignore_ID3','0','OLDHOSTNAME'),('AutoLookupCD','1','OLDHOSTNAME'),('AutoPlayCD','0','OLDHOSTNAME'),('KeyboardAccelerators','1','OLDHOSTNAME'),('CDWriterEnabled','1','OLDHOSTNAME'),('CDDiskSize','1','OLDHOSTNAME'),('CDCreateDir','1','OLDHOSTNAME'),('CDWriteSpeed','0','OLDHOSTNAME'),('CDBlankType','fast','OLDHOSTNAME'),('PlayMode','Normal','OLDHOSTNAME'),('IntelliRatingWeight','35','OLDHOSTNAME'),('IntelliPlayCountWeight','25','OLDHOSTNAME'),('IntelliLastPlayWeight','25','OLDHOSTNAME'),('IntelliRandomWeight','15','OLDHOSTNAME'),('MusicShowRatings','0','OLDHOSTNAME'),('ShowWholeTree','0','OLDHOSTNAME'),('ListAsShuffled','0','OLDHOSTNAME'),('VisualMode','Random','OLDHOSTNAME'),('VisualCycleOnSongChange','0','OLDHOSTNAME'),('VisualModeDelay','0','OLDHOSTNAME'),('VisualScaleWidth','1','OLDHOSTNAME'),('VisualScaleHeight','1','OLDHOSTNAME'),('ParanoiaLevel','Full','OLDHOSTNAME'),('FilenameTemplate','ARTIST/ALBUM/TRACK-TITLE','OLDHOSTNAME'),('TagSeparator',' - ','OLDHOSTNAME'),('NoWhitespace','0','OLDHOSTNAME'),('PostCDRipScript','','OLDHOSTNAME'),('EjectCDAfterRipping','1','OLDHOSTNAME'),('OnlyImportNewMusic','0','OLDHOSTNAME'),('EncoderType','ogg','OLDHOSTNAME'),('DefaultRipQuality','0','OLDHOSTNAME'),('Mp3UseVBR','0','OLDHOSTNAME'),('PhoneDBSchemaVer','1001',NULL),('SipRegisterWithProxy','1','OLDHOSTNAME'),('SipProxyName','fwd.pulver.com','OLDHOSTNAME'),('SipProxyAuthName','','OLDHOSTNAME'),('SipProxyAuthPassword','','OLDHOSTNAME'),('MySipName','Me','OLDHOSTNAME'),('SipAutoanswer','0','OLDHOSTNAME'),('SipBindInterface','eth0','OLDHOSTNAME'),('SipLocalPort','5060','OLDHOSTNAME'),('NatTraversalMethod','None','OLDHOSTNAME'),('NatIpAddress','http://checkip.dyndns.org','OLDHOSTNAME'),('AudioLocalPort','21232','OLDHOSTNAME'),('VideoLocalPort','21234','OLDHOSTNAME'),('MicrophoneDevice','None','OLDHOSTNAME'),('CodecPriorityList','GSM;G.711u;G.711a','OLDHOSTNAME'),('PlayoutAudioCall','40','OLDHOSTNAME'),('PlayoutVideoCall','110','OLDHOSTNAME'),('TxResolution','176x144','OLDHOSTNAME'),('TransmitFPS','5','OLDHOSTNAME'),('TransmitBandwidth','256','OLDHOSTNAME'),('CaptureResolution','352x288','OLDHOSTNAME'),('TimeToAnswer','10','OLDHOSTNAME'),('DefaultVxmlUrl','http://127.0.0.1/vxml/index.vxml','OLDHOSTNAME'),('DefaultVoicemailPrompt','I am not at home, please leave a message after the tone','OLDHOSTNAME'),('VideoDBSchemaVer','1010',NULL),('VideoStartupDir','/var/lib/mythtv/videos','OLDHOSTNAME'),('VideoArtworkDir','/home/mythtv/.mythtv/MythVideo','OLDHOSTNAME'),('VideoDefaultParentalLevel','4','OLDHOSTNAME'),('VideoAggressivePC','0','OLDHOSTNAME'),('Default MythVideo View','1','OLDHOSTNAME'),('VideoListUnknownFiletypes','1','OLDHOSTNAME'),('VideoBrowserNoDB','0','OLDHOSTNAME'),('VideoGalleryNoDB','0','OLDHOSTNAME'),('VideoTreeNoDB','0','OLDHOSTNAME'),('VideoTreeLoadMetaData','1','OLDHOSTNAME'),('VideoNewBrowsable','1','OLDHOSTNAME'),('mythvideo.sort_ignores_case','1','OLDHOSTNAME'),('mythvideo.db_folder_view','1','OLDHOSTNAME'),('mythvideo.ImageCacheSize','50','OLDHOSTNAME'),('MovieListCommandLine','/usr/share/mythtv/mythvideo/scripts/imdb.pl -M tv=no;video=no','OLDHOSTNAME'),('MoviePosterCommandLine','/usr/share/mythtv/mythvideo/scripts/imdb.pl -P','OLDHOSTNAME'),('MovieDataCommandLine','/usr/share/mythtv/mythvideo/scripts/imdb.pl -D','OLDHOSTNAME'),('VideoGalleryColsPerPage','4','OLDHOSTNAME'),('VideoGalleryRowsPerPage','3','OLDHOSTNAME'),('VideoGallerySubtitle','1','OLDHOSTNAME'),('VideoGalleryAspectRatio','1','OLDHOSTNAME'),('VideoDefaultPlayer','mplayer -fs -zoom -quiet -vo xv %s','OLDHOSTNAME');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tvchain`
--

DROP TABLE IF EXISTS `tvchain`;
CREATE TABLE `tvchain` (
  `chanid` int(10) unsigned NOT NULL default '0',
  `starttime` datetime NOT NULL default '0000-00-00 00:00:00',
  `chainid` varchar(128) NOT NULL default '',
  `chainpos` int(10) NOT NULL default '0',
  `discontinuity` tinyint(1) NOT NULL default '0',
  `watching` int(10) NOT NULL default '0',
  `hostprefix` varchar(128) NOT NULL default '',
  `cardtype` varchar(32) NOT NULL default 'V4L',
  `input` varchar(32) NOT NULL default '',
  `channame` varchar(32) NOT NULL default '',
  `endtime` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`chanid`,`starttime`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tvchain`
--

LOCK TABLES `tvchain` WRITE;
/*!40000 ALTER TABLE `tvchain` DISABLE KEYS */;
/*!40000 ALTER TABLE `tvchain` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `videocategory`
--

DROP TABLE IF EXISTS `videocategory`;
CREATE TABLE `videocategory` (
  `intid` int(10) unsigned NOT NULL auto_increment,
  `category` varchar(128) NOT NULL,
  PRIMARY KEY  (`intid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `videocategory`
--

LOCK TABLES `videocategory` WRITE;
/*!40000 ALTER TABLE `videocategory` DISABLE KEYS */;
/*!40000 ALTER TABLE `videocategory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `videocountry`
--

DROP TABLE IF EXISTS `videocountry`;
CREATE TABLE `videocountry` (
  `intid` int(10) unsigned NOT NULL auto_increment,
  `country` varchar(128) NOT NULL,
  PRIMARY KEY  (`intid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `videocountry`
--

LOCK TABLES `videocountry` WRITE;
/*!40000 ALTER TABLE `videocountry` DISABLE KEYS */;
/*!40000 ALTER TABLE `videocountry` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `videogenre`
--

DROP TABLE IF EXISTS `videogenre`;
CREATE TABLE `videogenre` (
  `intid` int(10) unsigned NOT NULL auto_increment,
  `genre` varchar(128) NOT NULL,
  PRIMARY KEY  (`intid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `videogenre`
--

LOCK TABLES `videogenre` WRITE;
/*!40000 ALTER TABLE `videogenre` DISABLE KEYS */;
/*!40000 ALTER TABLE `videogenre` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `videometadata`
--

DROP TABLE IF EXISTS `videometadata`;
CREATE TABLE `videometadata` (
  `intid` int(10) unsigned NOT NULL auto_increment,
  `title` varchar(128) NOT NULL,
  `director` varchar(128) NOT NULL,
  `plot` text,
  `rating` varchar(128) NOT NULL,
  `inetref` varchar(32) NOT NULL,
  `year` int(10) unsigned NOT NULL,
  `userrating` float NOT NULL,
  `length` int(10) unsigned NOT NULL,
  `showlevel` int(10) unsigned NOT NULL,
  `filename` text NOT NULL,
  `coverfile` text NOT NULL,
  `childid` int(11) NOT NULL default '-1',
  `browse` tinyint(1) NOT NULL default '1',
  `playcommand` varchar(255) default NULL,
  `category` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`intid`),
  KEY `director` (`director`),
  KEY `title` (`title`),
  KEY `title_2` (`title`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `videometadata`
--

LOCK TABLES `videometadata` WRITE;
/*!40000 ALTER TABLE `videometadata` DISABLE KEYS */;
/*!40000 ALTER TABLE `videometadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `videometadatacountry`
--

DROP TABLE IF EXISTS `videometadatacountry`;
CREATE TABLE `videometadatacountry` (
  `idvideo` int(10) unsigned NOT NULL,
  `idcountry` int(10) unsigned NOT NULL,
  KEY `idvideo` (`idvideo`),
  KEY `idcountry` (`idcountry`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `videometadatacountry`
--

LOCK TABLES `videometadatacountry` WRITE;
/*!40000 ALTER TABLE `videometadatacountry` DISABLE KEYS */;
/*!40000 ALTER TABLE `videometadatacountry` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `videometadatagenre`
--

DROP TABLE IF EXISTS `videometadatagenre`;
CREATE TABLE `videometadatagenre` (
  `idvideo` int(10) unsigned NOT NULL,
  `idgenre` int(10) unsigned NOT NULL,
  KEY `idvideo` (`idvideo`),
  KEY `idgenre` (`idgenre`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `videometadatagenre`
--

LOCK TABLES `videometadatagenre` WRITE;
/*!40000 ALTER TABLE `videometadatagenre` DISABLE KEYS */;
/*!40000 ALTER TABLE `videometadatagenre` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `videosource`
--

DROP TABLE IF EXISTS `videosource`;
CREATE TABLE `videosource` (
  `sourceid` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(128) NOT NULL default '',
  `xmltvgrabber` varchar(128) default NULL,
  `userid` varchar(128) NOT NULL default '',
  `freqtable` varchar(16) NOT NULL default 'default',
  `lineupid` varchar(64) default NULL,
  `password` varchar(64) default NULL,
  `useeit` smallint(6) NOT NULL default '0',
  PRIMARY KEY  (`sourceid`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `videosource`
--

LOCK TABLES `videosource` WRITE;
/*!40000 ALTER TABLE `videosource` DISABLE KEYS */;
/*!40000 ALTER TABLE `videosource` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `videotypes`
--

DROP TABLE IF EXISTS `videotypes`;
CREATE TABLE `videotypes` (
  `intid` int(10) unsigned NOT NULL auto_increment,
  `extension` varchar(128) NOT NULL,
  `playcommand` varchar(255) NOT NULL,
  `f_ignore` tinyint(1) default NULL,
  `use_default` tinyint(1) default NULL,
  PRIMARY KEY  (`intid`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;

--
-- Dumping data for table `videotypes`
--

LOCK TABLES `videotypes` WRITE;
/*!40000 ALTER TABLE `videotypes` DISABLE KEYS */;
INSERT INTO `videotypes` VALUES (1,'txt','',1,0),(2,'log','',1,0),(3,'mpg','Internal',0,0),(4,'avi','',0,1),(5,'vob','Internal',0,0),(6,'mpeg','Internal',0,0),(7,'VIDEO_TS','Internal',0,0),(8,'iso','Internal',0,0),(9,'img','Internal',0,0);
/*!40000 ALTER TABLE `videotypes` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2007-06-28  0:33:46
