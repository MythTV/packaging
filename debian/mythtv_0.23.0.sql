-- MySQL dump 10.13  Distrib 5.1.41, for debian-linux-gnu (i486)
--
-- Host: localhost    Database: mythconverg
-- ------------------------------------------------------
-- Server version	5.1.41-3ubuntu4

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archiveitems` (
  `intid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `type` set('Recording','Video','File') CHARACTER SET latin1 DEFAULT NULL,
  `title` varchar(128) DEFAULT NULL,
  `subtitle` varchar(128) DEFAULT NULL,
  `description` text,
  `startdate` varchar(30) DEFAULT NULL,
  `starttime` varchar(30) DEFAULT NULL,
  `size` bigint(20) unsigned NOT NULL,
  `filename` text NOT NULL,
  `hascutlist` tinyint(1) NOT NULL DEFAULT '0',
  `cutlist` text,
  `duration` int(10) unsigned NOT NULL DEFAULT '0',
  `cutduration` int(10) unsigned NOT NULL DEFAULT '0',
  `videowidth` int(10) unsigned NOT NULL DEFAULT '0',
  `videoheight` int(10) unsigned NOT NULL DEFAULT '0',
  `filecodec` varchar(50) NOT NULL DEFAULT '',
  `videocodec` varchar(50) NOT NULL DEFAULT '',
  `encoderprofile` varchar(50) NOT NULL DEFAULT 'NONE',
  PRIMARY KEY (`intid`),
  KEY `title` (`title`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `callsignnetworkmap` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `callsign` varchar(20) NOT NULL DEFAULT '',
  `network` varchar(20) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `callsign` (`callsign`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `capturecard` (
  `cardid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `videodevice` varchar(128) DEFAULT NULL,
  `audiodevice` varchar(128) DEFAULT NULL,
  `vbidevice` varchar(128) DEFAULT NULL,
  `cardtype` varchar(32) DEFAULT 'V4L',
  `defaultinput` varchar(32) DEFAULT 'Television',
  `audioratelimit` int(11) DEFAULT NULL,
  `hostname` varchar(64) DEFAULT NULL,
  `dvb_swfilter` int(11) DEFAULT '0',
  `dvb_sat_type` int(11) NOT NULL DEFAULT '0',
  `dvb_wait_for_seqstart` int(11) NOT NULL DEFAULT '1',
  `skipbtaudio` tinyint(1) DEFAULT '0',
  `dvb_on_demand` tinyint(4) NOT NULL DEFAULT '0',
  `dvb_diseqc_type` smallint(6) DEFAULT NULL,
  `firewire_speed` int(10) unsigned NOT NULL DEFAULT '0',
  `firewire_model` varchar(32) DEFAULT NULL,
  `firewire_connection` int(10) unsigned NOT NULL DEFAULT '0',
  `signal_timeout` int(11) NOT NULL DEFAULT '1000',
  `channel_timeout` int(11) NOT NULL DEFAULT '3000',
  `dvb_tuning_delay` int(10) unsigned NOT NULL DEFAULT '0',
  `contrast` int(11) NOT NULL DEFAULT '0',
  `brightness` int(11) NOT NULL DEFAULT '0',
  `colour` int(11) NOT NULL DEFAULT '0',
  `hue` int(11) NOT NULL DEFAULT '0',
  `diseqcid` int(10) unsigned DEFAULT NULL,
  `dvb_eitscan` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`cardid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cardinput` (
  `cardinputid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `cardid` int(10) unsigned NOT NULL DEFAULT '0',
  `sourceid` int(10) unsigned NOT NULL DEFAULT '0',
  `inputname` varchar(32) NOT NULL DEFAULT '',
  `externalcommand` varchar(128) DEFAULT NULL,
  `shareable` char(1) DEFAULT 'N',
  `tunechan` varchar(10) DEFAULT NULL,
  `startchan` varchar(10) DEFAULT NULL,
  `displayname` varchar(64) NOT NULL DEFAULT '',
  `dishnet_eit` tinyint(1) NOT NULL DEFAULT '0',
  `recpriority` int(11) NOT NULL DEFAULT '0',
  `quicktune` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cardinputid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `channel` (
  `chanid` int(10) unsigned NOT NULL DEFAULT '0',
  `channum` varchar(10) NOT NULL DEFAULT '',
  `freqid` varchar(10) DEFAULT NULL,
  `sourceid` int(10) unsigned DEFAULT NULL,
  `callsign` varchar(20) NOT NULL DEFAULT '',
  `name` varchar(64) NOT NULL DEFAULT '',
  `icon` varchar(255) NOT NULL DEFAULT 'none',
  `finetune` int(11) DEFAULT NULL,
  `videofilters` varchar(255) NOT NULL DEFAULT '',
  `xmltvid` varchar(64) NOT NULL DEFAULT '',
  `recpriority` int(10) NOT NULL DEFAULT '0',
  `contrast` int(11) DEFAULT '32768',
  `brightness` int(11) DEFAULT '32768',
  `colour` int(11) DEFAULT '32768',
  `hue` int(11) DEFAULT '32768',
  `tvformat` varchar(10) NOT NULL DEFAULT 'Default',
  `visible` tinyint(1) NOT NULL DEFAULT '1',
  `outputfilters` varchar(255) NOT NULL DEFAULT '',
  `useonairguide` tinyint(1) DEFAULT '0',
  `mplexid` smallint(6) DEFAULT NULL,
  `serviceid` mediumint(8) unsigned DEFAULT NULL,
  `tmoffset` int(11) NOT NULL DEFAULT '0',
  `atsc_major_chan` int(10) unsigned NOT NULL DEFAULT '0',
  `atsc_minor_chan` int(10) unsigned NOT NULL DEFAULT '0',
  `last_record` datetime NOT NULL,
  `default_authority` varchar(32) NOT NULL DEFAULT '',
  `commmethod` int(11) NOT NULL DEFAULT '-1',
  PRIMARY KEY (`chanid`),
  KEY `channel_src` (`channum`,`sourceid`),
  KEY `sourceid` (`sourceid`,`xmltvid`,`chanid`),
  KEY `visible` (`visible`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `channel`
--

LOCK TABLES `channel` WRITE;
/*!40000 ALTER TABLE `channel` DISABLE KEYS */;
/*!40000 ALTER TABLE `channel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `channelgroup`
--

DROP TABLE IF EXISTS `channelgroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `channelgroup` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `chanid` int(11) unsigned NOT NULL DEFAULT '0',
  `grpid` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `channelgroup`
--

LOCK TABLES `channelgroup` WRITE;
/*!40000 ALTER TABLE `channelgroup` DISABLE KEYS */;
/*!40000 ALTER TABLE `channelgroup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `channelgroupnames`
--

DROP TABLE IF EXISTS `channelgroupnames`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `channelgroupnames` (
  `grpid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL DEFAULT '0',
  PRIMARY KEY (`grpid`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `channelgroupnames`
--

LOCK TABLES `channelgroupnames` WRITE;
/*!40000 ALTER TABLE `channelgroupnames` DISABLE KEYS */;
INSERT INTO `channelgroupnames` VALUES (1,'Favorites');
/*!40000 ALTER TABLE `channelgroupnames` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `channelscan`
--

DROP TABLE IF EXISTS `channelscan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `channelscan` (
  `scanid` int(3) unsigned NOT NULL AUTO_INCREMENT,
  `cardid` int(3) unsigned NOT NULL,
  `sourceid` int(3) unsigned NOT NULL,
  `processed` tinyint(1) unsigned NOT NULL,
  `scandate` datetime NOT NULL,
  PRIMARY KEY (`scanid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `channelscan`
--

LOCK TABLES `channelscan` WRITE;
/*!40000 ALTER TABLE `channelscan` DISABLE KEYS */;
/*!40000 ALTER TABLE `channelscan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `channelscan_channel`
--

DROP TABLE IF EXISTS `channelscan_channel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `channelscan_channel` (
  `transportid` int(6) unsigned NOT NULL,
  `scanid` int(3) unsigned NOT NULL,
  `mplex_id` smallint(6) NOT NULL,
  `source_id` int(3) unsigned NOT NULL,
  `channel_id` int(3) unsigned NOT NULL DEFAULT '0',
  `callsign` varchar(20) NOT NULL DEFAULT '',
  `service_name` varchar(64) NOT NULL DEFAULT '',
  `chan_num` varchar(10) NOT NULL DEFAULT '',
  `service_id` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `atsc_major_channel` int(4) unsigned NOT NULL DEFAULT '0',
  `atsc_minor_channel` int(4) unsigned NOT NULL DEFAULT '0',
  `use_on_air_guide` tinyint(1) NOT NULL DEFAULT '0',
  `hidden` tinyint(1) NOT NULL DEFAULT '0',
  `hidden_in_guide` tinyint(1) NOT NULL DEFAULT '0',
  `freqid` varchar(10) NOT NULL DEFAULT '',
  `icon` varchar(255) NOT NULL DEFAULT '',
  `tvformat` varchar(10) NOT NULL DEFAULT 'Default',
  `xmltvid` varchar(64) NOT NULL DEFAULT '',
  `pat_tsid` int(5) unsigned NOT NULL DEFAULT '0',
  `vct_tsid` int(5) unsigned NOT NULL DEFAULT '0',
  `vct_chan_tsid` int(5) unsigned NOT NULL DEFAULT '0',
  `sdt_tsid` int(5) unsigned NOT NULL DEFAULT '0',
  `orig_netid` int(5) unsigned NOT NULL DEFAULT '0',
  `netid` int(5) unsigned NOT NULL DEFAULT '0',
  `si_standard` varchar(10) NOT NULL,
  `in_channels_conf` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `in_pat` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `in_pmt` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `in_vct` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `in_nit` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `in_sdt` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `is_encrypted` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `is_data_service` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `is_audio_service` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `is_opencable` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `could_be_opencable` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `decryption_status` smallint(2) unsigned NOT NULL DEFAULT '0',
  `default_authority` varchar(32) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `channelscan_channel`
--

LOCK TABLES `channelscan_channel` WRITE;
/*!40000 ALTER TABLE `channelscan_channel` DISABLE KEYS */;
/*!40000 ALTER TABLE `channelscan_channel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `channelscan_dtv_multiplex`
--

DROP TABLE IF EXISTS `channelscan_dtv_multiplex`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `channelscan_dtv_multiplex` (
  `transportid` int(6) unsigned NOT NULL AUTO_INCREMENT,
  `scanid` int(3) unsigned NOT NULL,
  `mplexid` smallint(6) unsigned NOT NULL,
  `frequency` bigint(12) unsigned NOT NULL,
  `inversion` char(1) NOT NULL DEFAULT 'a',
  `symbolrate` bigint(12) unsigned NOT NULL DEFAULT '0',
  `fec` varchar(10) NOT NULL DEFAULT 'auto',
  `polarity` char(1) NOT NULL DEFAULT '',
  `hp_code_rate` varchar(10) NOT NULL DEFAULT 'auto',
  `mod_sys` varchar(10) DEFAULT NULL,
  `rolloff` varchar(4) DEFAULT NULL,
  `lp_code_rate` varchar(10) NOT NULL DEFAULT 'auto',
  `modulation` varchar(10) NOT NULL DEFAULT 'auto',
  `transmission_mode` char(1) NOT NULL DEFAULT 'a',
  `guard_interval` varchar(10) NOT NULL DEFAULT 'auto',
  `hierarchy` varchar(10) NOT NULL DEFAULT 'auto',
  `bandwidth` char(1) NOT NULL DEFAULT 'a',
  `sistandard` varchar(10) NOT NULL,
  `tuner_type` smallint(2) unsigned NOT NULL,
  `default_authority` varchar(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`transportid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `channelscan_dtv_multiplex`
--

LOCK TABLES `channelscan_dtv_multiplex` WRITE;
/*!40000 ALTER TABLE `channelscan_dtv_multiplex` DISABLE KEYS */;
/*!40000 ALTER TABLE `channelscan_dtv_multiplex` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `codecparams`
--

DROP TABLE IF EXISTS `codecparams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `codecparams` (
  `profile` int(10) unsigned NOT NULL DEFAULT '0',
  `name` varchar(128) NOT NULL DEFAULT '',
  `value` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`profile`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `credits` (
  `person` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `chanid` int(10) unsigned NOT NULL DEFAULT '0',
  `starttime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `role` set('actor','director','producer','executive_producer','writer','guest_star','host','adapter','presenter','commentator','guest') CHARACTER SET latin1 NOT NULL DEFAULT '',
  UNIQUE KEY `chanid` (`chanid`,`starttime`,`person`,`role`),
  KEY `person` (`person`,`role`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `customexample` (
  `rulename` varchar(64) NOT NULL,
  `fromclause` text NOT NULL,
  `whereclause` text NOT NULL,
  `search` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`rulename`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customexample`
--

LOCK TABLES `customexample` WRITE;
/*!40000 ALTER TABLE `customexample` DISABLE KEYS */;
INSERT INTO `customexample` VALUES ('New Flix','','program.category_type = \'movie\' AND program.airdate >= \n     YEAR(DATE_SUB(NOW(), INTERVAL 1 YEAR)) \nAND program.stars > 0.5 ',1);
/*!40000 ALTER TABLE `customexample` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `diseqc_config`
--

DROP TABLE IF EXISTS `diseqc_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `diseqc_config` (
  `cardinputid` int(10) unsigned NOT NULL,
  `diseqcid` int(10) unsigned NOT NULL,
  `value` varchar(16) NOT NULL DEFAULT '',
  KEY `id` (`cardinputid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `diseqc_tree` (
  `diseqcid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `parentid` int(10) unsigned DEFAULT NULL,
  `ordinal` tinyint(3) unsigned NOT NULL,
  `type` varchar(16) NOT NULL DEFAULT '',
  `subtype` varchar(16) NOT NULL DEFAULT '',
  `description` varchar(32) NOT NULL DEFAULT '',
  `switch_ports` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `rotor_hi_speed` float NOT NULL DEFAULT '0',
  `rotor_lo_speed` float NOT NULL DEFAULT '0',
  `rotor_positions` varchar(255) NOT NULL DEFAULT '',
  `lnb_lof_switch` int(10) NOT NULL DEFAULT '0',
  `lnb_lof_hi` int(10) NOT NULL DEFAULT '0',
  `lnb_lof_lo` int(10) NOT NULL DEFAULT '0',
  `cmd_repeat` int(11) NOT NULL DEFAULT '1',
  `lnb_pol_inv` tinyint(4) NOT NULL DEFAULT '0',
  `address` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`diseqcid`),
  KEY `parentid` (`parentid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diseqc_tree`
--

LOCK TABLES `diseqc_tree` WRITE;
/*!40000 ALTER TABLE `diseqc_tree` DISABLE KEYS */;
/*!40000 ALTER TABLE `diseqc_tree` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `displayprofilegroups`
--

DROP TABLE IF EXISTS `displayprofilegroups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `displayprofilegroups` (
  `name` varchar(128) NOT NULL,
  `hostname` varchar(64) NOT NULL,
  `profilegroupid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`name`,`hostname`),
  UNIQUE KEY `profilegroupid` (`profilegroupid`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `displayprofilegroups`
--

LOCK TABLES `displayprofilegroups` WRITE;
/*!40000 ALTER TABLE `displayprofilegroups` DISABLE KEYS */;
INSERT INTO `displayprofilegroups` VALUES ('CPU++','OLDHOSTNAME',1),('CPU+','OLDHOSTNAME',2),('CPU--','OLDHOSTNAME',3),('High Quality','OLDHOSTNAME',4),('Normal','OLDHOSTNAME',5),('Slim','OLDHOSTNAME',6),('VDPAU High Quality','OLDHOSTNAME',7),('VDPAU Normal','OLDHOSTNAME',8),('VDPAU Slim','OLDHOSTNAME',9);
/*!40000 ALTER TABLE `displayprofilegroups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `displayprofiles`
--

DROP TABLE IF EXISTS `displayprofiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `displayprofiles` (
  `profilegroupid` int(10) unsigned NOT NULL,
  `profileid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `value` varchar(128) NOT NULL,
  `data` varchar(255) NOT NULL DEFAULT '',
  KEY `profilegroupid` (`profilegroupid`),
  KEY `profileid` (`profileid`,`value`),
  KEY `profileid_2` (`profileid`)
) ENGINE=MyISAM AUTO_INCREMENT=29 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `displayprofiles`
--

LOCK TABLES `displayprofiles` WRITE;
/*!40000 ALTER TABLE `displayprofiles` DISABLE KEYS */;
INSERT INTO `displayprofiles` VALUES (1,1,'pref_priority','1'),(1,1,'pref_cmp0','> 0 0'),(1,1,'pref_decoder','ffmpeg'),(1,1,'pref_max_cpus','1'),(1,1,'pref_videorenderer','xv-blit'),(1,1,'pref_osdrenderer','softblend'),(1,1,'pref_osdfade','1'),(1,1,'pref_deint0','bobdeint'),(1,1,'pref_deint1','linearblend'),(1,1,'pref_filters',''),(1,2,'pref_priority','2'),(1,2,'pref_cmp0','> 0 0'),(1,2,'pref_decoder','ffmpeg'),(1,2,'pref_max_cpus','1'),(1,2,'pref_videorenderer','quartz-blit'),(1,2,'pref_osdrenderer','softblend'),(1,2,'pref_osdfade','1'),(1,2,'pref_deint0','linearblend'),(1,2,'pref_deint1','linearblend'),(1,2,'pref_filters',''),(2,3,'pref_priority','1'),(2,3,'pref_cmp0','<= 720 576'),(2,3,'pref_cmp1','> 0 0'),(2,3,'pref_decoder','ffmpeg'),(2,3,'pref_max_cpus','1'),(2,3,'pref_videorenderer','xv-blit'),(2,3,'pref_osdrenderer','softblend'),(2,3,'pref_osdfade','1'),(2,3,'pref_deint0','bobdeint'),(2,3,'pref_deint1','linearblend'),(2,3,'pref_filters',''),(2,4,'pref_priority','2'),(2,4,'pref_cmp0','<= 1280 720'),(2,4,'pref_cmp1','> 720 576'),(2,4,'pref_decoder','xvmc'),(2,4,'pref_max_cpus','1'),(2,4,'pref_videorenderer','xvmc-blit'),(2,4,'pref_osdrenderer','opengl'),(2,4,'pref_osdfade','1'),(2,4,'pref_deint0','bobdeint'),(2,4,'pref_deint1','onefield'),(2,4,'pref_filters',''),(2,5,'pref_priority','3'),(2,5,'pref_cmp0','<= 1280 720'),(2,5,'pref_cmp1','> 720 576'),(2,5,'pref_decoder','libmpeg2'),(2,5,'pref_max_cpus','1'),(2,5,'pref_videorenderer','xv-blit'),(2,5,'pref_osdrenderer','softblend'),(2,5,'pref_osdfade','1'),(2,5,'pref_deint0','bobdeint'),(2,5,'pref_deint1','onefield'),(2,5,'pref_filters',''),(2,6,'pref_priority','4'),(2,6,'pref_cmp0','> 0 0'),(2,6,'pref_decoder','xvmc'),(2,6,'pref_max_cpus','1'),(2,6,'pref_videorenderer','xvmc-blit'),(2,6,'pref_osdrenderer','ia44blend'),(2,6,'pref_osdfade','0'),(2,6,'pref_deint0','bobdeint'),(2,6,'pref_deint1','onefield'),(2,6,'pref_filters',''),(2,7,'pref_priority','5'),(2,7,'pref_cmp0','> 0 0'),(2,7,'pref_decoder','libmpeg2'),(2,7,'pref_max_cpus','1'),(2,7,'pref_videorenderer','xv-blit'),(2,7,'pref_osdrenderer','chromakey'),(2,7,'pref_osdfade','0'),(2,7,'pref_deint0','bobdeint'),(2,7,'pref_deint1','onefield'),(2,7,'pref_filters',''),(3,8,'pref_priority','1'),(3,8,'pref_cmp0','<= 720 576'),(3,8,'pref_cmp1','> 0 0'),(3,8,'pref_decoder','ivtv'),(3,8,'pref_max_cpus','1'),(3,8,'pref_videorenderer','ivtv'),(3,8,'pref_osdrenderer','ivtv'),(3,8,'pref_osdfade','1'),(3,8,'pref_deint0','none'),(3,8,'pref_deint1','none'),(3,8,'pref_filters',''),(3,9,'pref_priority','2'),(3,9,'pref_cmp0','<= 720 576'),(3,9,'pref_cmp1','> 0 0'),(3,9,'pref_decoder','xvmc'),(3,9,'pref_max_cpus','1'),(3,9,'pref_videorenderer','xvmc-blit'),(3,9,'pref_osdrenderer','ia44blend'),(3,9,'pref_osdfade','0'),(3,9,'pref_deint0','bobdeint'),(3,9,'pref_deint1','onefield'),(3,9,'pref_filters',''),(3,10,'pref_priority','3'),(3,10,'pref_cmp0','<= 1280 720'),(3,10,'pref_cmp1','> 720 576'),(3,10,'pref_decoder','xvmc'),(3,10,'pref_max_cpus','1'),(3,10,'pref_videorenderer','xvmc-blit'),(3,10,'pref_osdrenderer','ia44blend'),(3,10,'pref_osdfade','0'),(3,10,'pref_deint0','bobdeint'),(3,10,'pref_deint1','onefield'),(3,10,'pref_filters',''),(3,11,'pref_priority','4'),(3,11,'pref_cmp0','> 0 0'),(3,11,'pref_decoder','xvmc'),(3,11,'pref_max_cpus','1'),(3,11,'pref_videorenderer','xvmc-blit'),(3,11,'pref_osdrenderer','ia44blend'),(3,11,'pref_osdfade','0'),(3,11,'pref_deint0','bobdeint'),(3,11,'pref_deint1','onefield'),(3,11,'pref_filters',''),(3,12,'pref_priority','5'),(3,12,'pref_cmp0','> 0 0'),(3,12,'pref_decoder','libmpeg2'),(3,12,'pref_max_cpus','1'),(3,12,'pref_videorenderer','xv-blit'),(3,12,'pref_osdrenderer','chromakey'),(3,12,'pref_osdfade','0'),(3,12,'pref_deint0','none'),(3,12,'pref_deint1','none'),(3,12,'pref_filters',''),(4,13,'pref_priority','1'),(4,13,'pref_cmp0','>= 1920 1080'),(4,13,'pref_decoder','ffmpeg'),(4,13,'pref_max_cpus','2'),(4,13,'pref_videorenderer','xv-blit'),(4,13,'pref_osdrenderer','softblend'),(4,13,'pref_osdfade','1'),(4,13,'pref_deint0','linearblend'),(4,13,'pref_deint1','linearblend'),(4,13,'pref_filters',''),(4,14,'pref_priority','2'),(4,14,'pref_cmp0','> 0 0'),(4,14,'pref_decoder','ffmpeg'),(4,14,'pref_max_cpus','1'),(4,14,'pref_videorenderer','xv-blit'),(4,14,'pref_osdrenderer','softblend'),(4,14,'pref_osdfade','1'),(4,14,'pref_deint0','yadifdoubleprocessdeint'),(4,14,'pref_deint1','yadifdeint'),(4,14,'pref_filters',''),(4,15,'pref_priority','3'),(4,15,'pref_cmp0','>= 1920 1080'),(4,15,'pref_decoder','ffmpeg'),(4,15,'pref_max_cpus','2'),(4,15,'pref_videorenderer','quartz-blit'),(4,15,'pref_osdrenderer','softblend'),(4,15,'pref_osdfade','1'),(4,15,'pref_deint0','linearblend'),(4,15,'pref_deint1','linearblend'),(4,15,'pref_filters',''),(4,16,'pref_priority','4'),(4,16,'pref_cmp0','> 0 0'),(4,16,'pref_decoder','ffmpeg'),(4,16,'pref_max_cpus','1'),(4,16,'pref_videorenderer','quartz-blit'),(4,16,'pref_osdrenderer','softblend'),(4,16,'pref_osdfade','1'),(4,16,'pref_deint0','yadifdoubleprocessdeint'),(4,16,'pref_deint1','yadifdeint'),(4,16,'pref_filters',''),(5,17,'pref_priority','1'),(5,17,'pref_cmp0','>= 1280 720'),(5,17,'pref_decoder','ffmpeg'),(5,17,'pref_max_cpus','1'),(5,17,'pref_videorenderer','xv-blit'),(5,17,'pref_osdrenderer','softblend'),(5,17,'pref_osdfade','0'),(5,17,'pref_deint0','linearblend'),(5,17,'pref_deint1','linearblend'),(5,17,'pref_filters',''),(5,18,'pref_priority','2'),(5,18,'pref_cmp0','> 0 0'),(5,18,'pref_decoder','ffmpeg'),(5,18,'pref_max_cpus','1'),(5,18,'pref_videorenderer','xv-blit'),(5,18,'pref_osdrenderer','softblend'),(5,18,'pref_osdfade','1'),(5,18,'pref_deint0','greedyhdoubleprocessdeint'),(5,18,'pref_deint1','kerneldeint'),(5,18,'pref_filters',''),(5,19,'pref_priority','3'),(5,19,'pref_cmp0','>= 1280 720'),(5,19,'pref_decoder','ffmpeg'),(5,19,'pref_max_cpus','1'),(5,19,'pref_videorenderer','quartz-blit'),(5,19,'pref_osdrenderer','softblend'),(5,19,'pref_osdfade','0'),(5,19,'pref_deint0','linearblend'),(5,19,'pref_deint1','linearblend'),(5,19,'pref_filters',''),(5,20,'pref_priority','4'),(5,20,'pref_cmp0','> 0 0'),(5,20,'pref_decoder','ffmpeg'),(5,20,'pref_max_cpus','1'),(5,20,'pref_videorenderer','quartz-blit'),(5,20,'pref_osdrenderer','softblend'),(5,20,'pref_osdfade','1'),(5,20,'pref_deint0','greedyhdoubleprocessdeint'),(5,20,'pref_deint1','kerneldeint'),(5,20,'pref_filters',''),(6,21,'pref_priority','1'),(6,21,'pref_cmp0','>= 1280 720'),(6,21,'pref_decoder','ffmpeg'),(6,21,'pref_max_cpus','1'),(6,21,'pref_videorenderer','xv-blit'),(6,21,'pref_osdrenderer','softblend'),(6,21,'pref_osdfade','0'),(6,21,'pref_deint0','onefield'),(6,21,'pref_deint1','onefield'),(6,21,'pref_filters',''),(6,22,'pref_priority','2'),(6,22,'pref_cmp0','> 0 0'),(6,22,'pref_decoder','ffmpeg'),(6,22,'pref_max_cpus','1'),(6,22,'pref_videorenderer','xv-blit'),(6,22,'pref_osdrenderer','softblend'),(6,22,'pref_osdfade','1'),(6,22,'pref_deint0','linearblend'),(6,22,'pref_deint1','linearblend'),(6,22,'pref_filters',''),(6,23,'pref_priority','3'),(6,23,'pref_cmp0','>= 1280 720'),(6,23,'pref_decoder','ffmpeg'),(6,23,'pref_max_cpus','1'),(6,23,'pref_videorenderer','quartz-blit'),(6,23,'pref_osdrenderer','softblend'),(6,23,'pref_osdfade','0'),(6,23,'pref_deint0','onefield'),(6,23,'pref_deint1','onefield'),(6,23,'pref_filters',''),(6,24,'pref_priority','4'),(6,24,'pref_cmp0','> 0 0'),(6,24,'pref_decoder','ffmpeg'),(6,24,'pref_max_cpus','1'),(6,24,'pref_videorenderer','quartz-blit'),(6,24,'pref_osdrenderer','softblend'),(6,24,'pref_osdfade','1'),(6,24,'pref_deint0','linearblend'),(6,24,'pref_deint1','linearblend'),(6,24,'pref_filters',''),(7,25,'pref_priority','1'),(7,25,'pref_cmp0','> 0 0'),(7,25,'pref_decoder','vdpau'),(7,25,'pref_max_cpus','1'),(7,25,'pref_videorenderer','vdpau'),(7,25,'pref_osdrenderer','vdpau'),(7,25,'pref_osdfade','1'),(7,25,'pref_deint0','vdpauadvanceddoublerate'),(7,25,'pref_deint1','vdpauadvanced'),(7,25,'pref_filters',''),(8,26,'pref_priority','1'),(8,26,'pref_cmp0','>= 0 720'),(8,26,'pref_decoder','vdpau'),(8,26,'pref_max_cpus','1'),(8,26,'pref_videorenderer','vdpau'),(8,26,'pref_osdrenderer','vdpau'),(8,26,'pref_osdfade','1'),(8,26,'pref_deint0','vdpaubasicdoublerate'),(8,26,'pref_deint1','vdpaubasic'),(8,26,'pref_filters',''),(8,27,'pref_priority','2'),(8,27,'pref_cmp0','> 0 0'),(8,27,'pref_decoder','vdpau'),(8,27,'pref_max_cpus','1'),(8,27,'pref_videorenderer','vdpau'),(8,27,'pref_osdrenderer','vdpau'),(8,27,'pref_osdfade','1'),(8,27,'pref_deint0','vdpauadvanceddoublerate'),(8,27,'pref_deint1','vdpauadvanced'),(8,27,'pref_filters',''),(9,28,'pref_priority','1'),(9,28,'pref_cmp0','> 0 0'),(9,28,'pref_decoder','vdpau'),(9,28,'pref_max_cpus','1'),(9,28,'pref_videorenderer','vdpau'),(9,28,'pref_osdrenderer','vdpau'),(9,28,'pref_osdfade','0'),(9,28,'pref_deint0','vdpaubobdeint'),(9,28,'pref_deint1','vdpauonefield'),(9,28,'pref_filters','vdpauskipchroma');
/*!40000 ALTER TABLE `displayprofiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dtv_multiplex`
--

DROP TABLE IF EXISTS `dtv_multiplex`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dtv_multiplex` (
  `mplexid` smallint(6) NOT NULL AUTO_INCREMENT,
  `sourceid` smallint(6) DEFAULT NULL,
  `transportid` int(11) DEFAULT NULL,
  `networkid` int(11) DEFAULT NULL,
  `frequency` int(11) DEFAULT NULL,
  `inversion` char(1) DEFAULT 'a',
  `symbolrate` int(11) DEFAULT NULL,
  `fec` varchar(10) DEFAULT 'auto',
  `polarity` char(1) DEFAULT NULL,
  `modulation` varchar(10) DEFAULT 'auto',
  `bandwidth` char(1) DEFAULT 'a',
  `lp_code_rate` varchar(10) DEFAULT 'auto',
  `transmission_mode` char(1) DEFAULT 'a',
  `guard_interval` varchar(10) DEFAULT 'auto',
  `visible` smallint(1) NOT NULL DEFAULT '0',
  `constellation` varchar(10) DEFAULT 'auto',
  `hierarchy` varchar(10) DEFAULT 'auto',
  `hp_code_rate` varchar(10) DEFAULT 'auto',
  `mod_sys` varchar(10) DEFAULT NULL,
  `rolloff` varchar(4) DEFAULT NULL,
  `sistandard` varchar(10) DEFAULT 'dvb',
  `serviceversion` smallint(6) DEFAULT '33',
  `updatetimestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `default_authority` varchar(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`mplexid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dtv_privatetypes` (
  `sitype` varchar(4) NOT NULL DEFAULT '',
  `networkid` int(11) NOT NULL DEFAULT '0',
  `private_type` varchar(20) NOT NULL DEFAULT '',
  `private_value` varchar(100) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dtv_privatetypes`
--

LOCK TABLES `dtv_privatetypes` WRITE;
/*!40000 ALTER TABLE `dtv_privatetypes` DISABLE KEYS */;
INSERT INTO `dtv_privatetypes` VALUES ('dvb',9018,'channel_numbers','131'),('dvb',9018,'guide_fixup','2'),('dvb',256,'guide_fixup','1'),('dvb',257,'guide_fixup','1'),('dvb',256,'tv_types','1,150,134,133'),('dvb',257,'tv_types','1,150,134,133'),('dvb',4100,'sdt_mapping','1'),('dvb',4101,'sdt_mapping','1'),('dvb',4102,'sdt_mapping','1'),('dvb',4103,'sdt_mapping','1'),('dvb',4104,'sdt_mapping','1'),('dvb',4105,'sdt_mapping','1'),('dvb',4106,'sdt_mapping','1'),('dvb',4107,'sdt_mapping','1'),('dvb',4097,'sdt_mapping','1'),('dvb',4098,'sdt_mapping','1'),('dvb',4100,'tv_types','1,145,154'),('dvb',4101,'tv_types','1,145,154'),('dvb',4102,'tv_types','1,145,154'),('dvb',4103,'tv_types','1,145,154'),('dvb',4104,'tv_types','1,145,154'),('dvb',4105,'tv_types','1,145,154'),('dvb',4106,'tv_types','1,145,154'),('dvb',4107,'tv_types','1,145,154'),('dvb',4097,'tv_types','1,145,154'),('dvb',4098,'tv_types','1,145,154'),('dvb',4100,'guide_fixup','1'),('dvb',4101,'guide_fixup','1'),('dvb',4102,'guide_fixup','1'),('dvb',4103,'guide_fixup','1'),('dvb',4104,'guide_fixup','1'),('dvb',4105,'guide_fixup','1'),('dvb',4106,'guide_fixup','1'),('dvb',4107,'guide_fixup','1'),('dvb',4096,'guide_fixup','5'),('dvb',4097,'guide_fixup','1'),('dvb',4098,'guide_fixup','1'),('dvb',94,'tv_types','1,128'),('atsc',1793,'guide_fixup','3'),('dvb',40999,'guide_fixup','4'),('dvb',70,'force_guide_present','yes'),('dvb',70,'guide_ranges','80,80,96,96'),('dvb',4112,'channel_numbers','131'),('dvb',4115,'channel_numbers','131'),('dvb',4116,'channel_numbers','131'),('dvb',12802,'channel_numbers','131'),('dvb',12803,'channel_numbers','131'),('dvb',12829,'channel_numbers','131'),('dvb',40999,'parse_subtitle_list','1070,1308,1041,1306,1307,1030,1016,1131,1068,1069'),('dvb',4096,'guide_fixup','5');
/*!40000 ALTER TABLE `dtv_privatetypes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dvdbookmark`
--

DROP TABLE IF EXISTS `dvdbookmark`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dvdbookmark` (
  `serialid` varchar(16) NOT NULL DEFAULT '',
  `name` varchar(32) DEFAULT NULL,
  `title` smallint(6) NOT NULL DEFAULT '0',
  `audionum` tinyint(4) NOT NULL DEFAULT '-1',
  `subtitlenum` tinyint(4) NOT NULL DEFAULT '-1',
  `framenum` bigint(20) NOT NULL DEFAULT '0',
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`serialid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dvdbookmark`
--

LOCK TABLES `dvdbookmark` WRITE;
/*!40000 ALTER TABLE `dvdbookmark` DISABLE KEYS */;
/*!40000 ALTER TABLE `dvdbookmark` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dvdinput`
--

DROP TABLE IF EXISTS `dvdinput`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dvdinput` (
  `intid` int(10) unsigned NOT NULL,
  `hsize` int(10) unsigned DEFAULT NULL,
  `vsize` int(10) unsigned DEFAULT NULL,
  `ar_num` int(10) unsigned DEFAULT NULL,
  `ar_denom` int(10) unsigned DEFAULT NULL,
  `fr_code` int(10) unsigned DEFAULT NULL,
  `letterbox` tinyint(1) DEFAULT NULL,
  `v_format` varchar(16) DEFAULT NULL,
  PRIMARY KEY (`intid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dvdtranscode` (
  `intid` int(11) NOT NULL AUTO_INCREMENT,
  `input` int(10) unsigned DEFAULT NULL,
  `name` varchar(128) NOT NULL,
  `sync_mode` int(10) unsigned DEFAULT NULL,
  `use_yv12` tinyint(1) DEFAULT NULL,
  `cliptop` int(11) DEFAULT NULL,
  `clipbottom` int(11) DEFAULT NULL,
  `clipleft` int(11) DEFAULT NULL,
  `clipright` int(11) DEFAULT NULL,
  `f_resize_h` int(11) DEFAULT NULL,
  `f_resize_w` int(11) DEFAULT NULL,
  `hq_resize_h` int(11) DEFAULT NULL,
  `hq_resize_w` int(11) DEFAULT NULL,
  `grow_h` int(11) DEFAULT NULL,
  `grow_w` int(11) DEFAULT NULL,
  `clip2top` int(11) DEFAULT NULL,
  `clip2bottom` int(11) DEFAULT NULL,
  `clip2left` int(11) DEFAULT NULL,
  `clip2right` int(11) DEFAULT NULL,
  `codec` varchar(128) NOT NULL,
  `codec_param` varchar(128) DEFAULT NULL,
  `bitrate` int(11) DEFAULT NULL,
  `a_sample_r` int(11) DEFAULT NULL,
  `a_bitrate` int(11) DEFAULT NULL,
  `two_pass` tinyint(1) DEFAULT NULL,
  `tc_param` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`intid`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `eit_cache` (
  `chanid` int(10) NOT NULL,
  `eventid` int(10) unsigned NOT NULL DEFAULT '0',
  `tableid` tinyint(3) unsigned NOT NULL,
  `version` tinyint(3) unsigned NOT NULL,
  `endtime` int(10) unsigned NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`chanid`,`eventid`,`status`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eit_cache`
--

LOCK TABLES `eit_cache` WRITE;
/*!40000 ALTER TABLE `eit_cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `eit_cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `filemarkup`
--

DROP TABLE IF EXISTS `filemarkup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `filemarkup` (
  `filename` text NOT NULL,
  `mark` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `offset` bigint(20) unsigned DEFAULT NULL,
  `type` tinyint(4) NOT NULL DEFAULT '0',
  KEY `filename` (`filename`(255))
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gallerymetadata` (
  `image` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `angle` int(11) NOT NULL,
  PRIMARY KEY (`image`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gamemetadata` (
  `system` varchar(128) NOT NULL DEFAULT '',
  `romname` varchar(128) NOT NULL DEFAULT '',
  `gamename` varchar(128) NOT NULL DEFAULT '',
  `genre` varchar(128) NOT NULL DEFAULT '',
  `year` varchar(10) NOT NULL DEFAULT '',
  `publisher` varchar(128) NOT NULL DEFAULT '',
  `favorite` tinyint(1) DEFAULT NULL,
  `rompath` varchar(255) NOT NULL DEFAULT '',
  `screenshot` varchar(255) NOT NULL,
  `fanart` varchar(255) NOT NULL,
  `plot` text NOT NULL,
  `boxart` varchar(255) NOT NULL,
  `gametype` varchar(64) NOT NULL DEFAULT '',
  `diskcount` tinyint(1) NOT NULL DEFAULT '1',
  `country` varchar(128) NOT NULL DEFAULT '',
  `crc_value` varchar(64) NOT NULL DEFAULT '',
  `display` tinyint(1) NOT NULL DEFAULT '1',
  `version` varchar(64) NOT NULL DEFAULT '',
  KEY `system` (`system`),
  KEY `year` (`year`),
  KEY `romname` (`romname`),
  KEY `gamename` (`gamename`),
  KEY `genre` (`genre`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gameplayers` (
  `gameplayerid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `playername` varchar(64) NOT NULL DEFAULT '',
  `workingpath` varchar(255) NOT NULL DEFAULT '',
  `rompath` varchar(255) NOT NULL DEFAULT '',
  `screenshots` varchar(255) NOT NULL DEFAULT '',
  `commandline` text NOT NULL,
  `gametype` varchar(64) NOT NULL DEFAULT '',
  `extensions` varchar(128) NOT NULL DEFAULT '',
  `spandisks` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`gameplayerid`),
  UNIQUE KEY `playername` (`playername`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `housekeeping` (
  `tag` varchar(64) NOT NULL DEFAULT '',
  `lastrun` datetime DEFAULT NULL,
  PRIMARY KEY (`tag`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `housekeeping`
--

LOCK TABLES `housekeeping` WRITE;
/*!40000 ALTER TABLE `housekeeping` DISABLE KEYS */;
INSERT INTO `housekeeping` VALUES ('DailyCleanup','2010-02-17 23:45:39'),('JobQueueRecover-OLDHOSTNAME','2010-02-17 23:45:39'),('BackupDB','2010-02-18 01:25:06'),('DBCleanup','2009-09-20 01:56:39');
/*!40000 ALTER TABLE `housekeeping` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inputgroup`
--

DROP TABLE IF EXISTS `inputgroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inputgroup` (
  `cardinputid` int(10) unsigned NOT NULL,
  `inputgroupid` int(10) unsigned NOT NULL,
  `inputgroupname` varchar(32) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inputgroup`
--

LOCK TABLES `inputgroup` WRITE;
/*!40000 ALTER TABLE `inputgroup` DISABLE KEYS */;
/*!40000 ALTER TABLE `inputgroup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inuseprograms`
--

DROP TABLE IF EXISTS `inuseprograms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inuseprograms` (
  `chanid` int(10) unsigned NOT NULL DEFAULT '0',
  `starttime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `recusage` varchar(128) NOT NULL DEFAULT '',
  `lastupdatetime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `hostname` varchar(64) NOT NULL DEFAULT '',
  `rechost` varchar(64) NOT NULL,
  `recdir` varchar(255) NOT NULL DEFAULT '',
  KEY `chanid` (`chanid`,`starttime`),
  KEY `recusage` (`recusage`,`lastupdatetime`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobqueue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chanid` int(10) NOT NULL DEFAULT '0',
  `starttime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `inserttime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `type` int(11) NOT NULL DEFAULT '0',
  `cmds` int(11) NOT NULL DEFAULT '0',
  `flags` int(11) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL DEFAULT '0',
  `statustime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `hostname` varchar(64) NOT NULL DEFAULT '',
  `args` blob NOT NULL,
  `comment` varchar(128) NOT NULL DEFAULT '',
  `schedruntime` datetime NOT NULL DEFAULT '2007-01-01 00:00:00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `chanid` (`chanid`,`starttime`,`type`,`inserttime`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jumppoints` (
  `destination` varchar(128) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT NULL,
  `keylist` varchar(128) DEFAULT NULL,
  `hostname` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`destination`,`hostname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jumppoints`
--

LOCK TABLES `jumppoints` WRITE;
/*!40000 ALTER TABLE `jumppoints` DISABLE KEYS */;
INSERT INTO `jumppoints` VALUES ('Reload Theme',NULL,'','OLDHOSTNAME'),('Main Menu',NULL,'','OLDHOSTNAME'),('Program Guide',NULL,'','OLDHOSTNAME'),('Program Finder',NULL,'','OLDHOSTNAME'),('Manage Recordings / Fix Conflicts',NULL,'','OLDHOSTNAME'),('Program Recording Priorities',NULL,'','OLDHOSTNAME'),('Channel Recording Priorities',NULL,'','OLDHOSTNAME'),('TV Recording Playback',NULL,'','OLDHOSTNAME'),('TV Recording Deletion',NULL,'','OLDHOSTNAME'),('Live TV',NULL,'','OLDHOSTNAME'),('Live TV In Guide',NULL,'','OLDHOSTNAME'),('Manual Record Scheduling',NULL,'','OLDHOSTNAME'),('Status Screen',NULL,'','OLDHOSTNAME'),('Previously Recorded',NULL,'','OLDHOSTNAME'),('Play DVD',NULL,'','OLDHOSTNAME'),('Play VCD',NULL,'','OLDHOSTNAME'),('Rip DVD',NULL,'','OLDHOSTNAME'),('Netflix Browser',NULL,'','OLDHOSTNAME'),('Netflix Queue',NULL,'','OLDHOSTNAME'),('Netflix History',NULL,'','OLDHOSTNAME'),('MythGallery',NULL,'','OLDHOSTNAME'),('MythGame',NULL,'','OLDHOSTNAME'),('Play music',NULL,'','OLDHOSTNAME'),('Select music playlists',NULL,'','OLDHOSTNAME'),('Rip CD',NULL,'','OLDHOSTNAME'),('Scan music',NULL,'','OLDHOSTNAME'),('MythNews',NULL,'','OLDHOSTNAME'),('MythVideo',NULL,'','OLDHOSTNAME'),('Video Manager',NULL,'','OLDHOSTNAME'),('Video Browser',NULL,'','OLDHOSTNAME'),('Video Listings',NULL,'','OLDHOSTNAME'),('Video Gallery',NULL,'','OLDHOSTNAME'),('MythWeather',NULL,'','OLDHOSTNAME'),('Manage Recording Rules','','','OLDHOSTNAME'),('ScreenShot','','','OLDHOSTNAME'),('Create DVD','','','OLDHOSTNAME'),('Create Archive','','','OLDHOSTNAME'),('Import Archive','','','OLDHOSTNAME'),('View Archive Log','','','OLDHOSTNAME'),('Play Created DVD','','','OLDHOSTNAME'),('Burn DVD','','','OLDHOSTNAME'),('Show Music Miniplayer','','','OLDHOSTNAME'),('MythNetSearch','Internet Television Client - Search','','OLDHOSTNAME'),('MythNetTree','Internet Television Client - Site/Tree View','','OLDHOSTNAME');
/*!40000 ALTER TABLE `jumppoints` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `keybindings`
--

DROP TABLE IF EXISTS `keybindings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `keybindings` (
  `context` varchar(32) NOT NULL DEFAULT '',
  `action` varchar(32) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT NULL,
  `keylist` varchar(128) DEFAULT NULL,
  `hostname` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`context`,`action`,`hostname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `keybindings`
--

LOCK TABLES `keybindings` WRITE;
/*!40000 ALTER TABLE `keybindings` DISABLE KEYS */;
INSERT INTO `keybindings` VALUES ('Global','UP','Up Arrow','Up','OLDHOSTNAME'),('Global','DOWN','Down Arrow','Down','OLDHOSTNAME'),('Global','LEFT','Left Arrow','Left','OLDHOSTNAME'),('Global','RIGHT','Right Arrow','Right','OLDHOSTNAME'),('Global','SELECT','Select','Return,Enter,Space','OLDHOSTNAME'),('Global','ESCAPE','Escape','Esc','OLDHOSTNAME'),('Global','MENU','Pop-up menu','M','OLDHOSTNAME'),('Global','INFO','More information','I','OLDHOSTNAME'),('Global','PAGEUP','Page Up','PgUp','OLDHOSTNAME'),('Global','PAGEDOWN','Page Down','PgDown','OLDHOSTNAME'),('Global','PREVVIEW','Previous View','Home','OLDHOSTNAME'),('Global','NEXTVIEW','Next View','End','OLDHOSTNAME'),('Global','HELP','Help','F1','OLDHOSTNAME'),('Global','EJECT','Eject Removable Media','','OLDHOSTNAME'),('Global','0','0','0','OLDHOSTNAME'),('Global','1','1','1','OLDHOSTNAME'),('Global','2','2','2','OLDHOSTNAME'),('Global','3','3','3','OLDHOSTNAME'),('Global','4','4','4','OLDHOSTNAME'),('Global','5','5','5','OLDHOSTNAME'),('Global','6','6','6','OLDHOSTNAME'),('Global','7','7','7','OLDHOSTNAME'),('Global','8','8','8','OLDHOSTNAME'),('Global','9','9','9','OLDHOSTNAME'),('TV Frontend','GUIDE','Show the Program Guide','S','OLDHOSTNAME'),('TV Frontend','PAGEUP','Page Up','3','OLDHOSTNAME'),('TV Frontend','PAGEDOWN','Page Down','9','OLDHOSTNAME'),('TV Frontend','FINDER','Show the Program Finder','#','OLDHOSTNAME'),('TV Frontend','PLAYBACK','Play Program','P','OLDHOSTNAME'),('TV Frontend','TOGGLERECORD','Toggle recording status of current program','R','OLDHOSTNAME'),('TV Frontend','DAYLEFT','Page the program guide back one day','Home,7','OLDHOSTNAME'),('TV Frontend','DAYRIGHT','Page the program guide forward one day','End,1','OLDHOSTNAME'),('TV Frontend','PAGELEFT','Page the program guide left',',,<','OLDHOSTNAME'),('TV Frontend','PAGERIGHT','Page the program guide right','>,.','OLDHOSTNAME'),('TV Frontend','TOGGLEFAV','Toggle the current channel as a favorite','?','OLDHOSTNAME'),('TV Frontend','NEXTFAV','Cycle through channel groups and all channels in the program guide.','/','OLDHOSTNAME'),('TV Frontend','CHANUPDATE','Switch channels without exiting guide in Live TV mode.','X','OLDHOSTNAME'),('TV Frontend','RANKINC','Increase program or channel rank','Right','OLDHOSTNAME'),('TV Frontend','RANKDEC','Decrease program or channel rank','Left','OLDHOSTNAME'),('TV Frontend','UPCOMING','List upcoming episodes','O','OLDHOSTNAME'),('TV Frontend','DETAILS','Show program details','U','OLDHOSTNAME'),('TV Frontend','VIEWCARD','Switch Capture Card view','Y','OLDHOSTNAME'),('Global','CUT','Cut text from textedit','Ctrl+X','OLDHOSTNAME'),('TV Playback','CLEAROSD','Clear OSD','Backspace','OLDHOSTNAME'),('TV Playback','PAUSE','Pause','P','OLDHOSTNAME'),('TV Playback','SEEKFFWD','Fast Forward','Right','OLDHOSTNAME'),('TV Playback','SEEKRWND','Rewind','Left','OLDHOSTNAME'),('TV Playback','ARBSEEK','Arbitrary Seek','*','OLDHOSTNAME'),('TV Playback','CHANNELUP','Channel up','Up','OLDHOSTNAME'),('TV Playback','CHANNELDOWN','Channel down','Down','OLDHOSTNAME'),('TV Playback','NEXTFAV','Switch to the next favorite channel','/','OLDHOSTNAME'),('TV Playback','PREVCHAN','Switch to the previous channel','H','OLDHOSTNAME'),('TV Playback','JUMPFFWD','Jump ahead','PgDown','OLDHOSTNAME'),('TV Playback','JUMPRWND','Jump back','PgUp','OLDHOSTNAME'),('TV Playback','JUMPBKMRK','Jump to bookmark','K','OLDHOSTNAME'),('TV Playback','FFWDSTICKY','Fast Forward (Sticky) or Forward one frame while paused','>,.','OLDHOSTNAME'),('TV Playback','RWNDSTICKY','Rewind (Sticky) or Rewind one frame while paused',',,<','OLDHOSTNAME'),('TV Playback','SKIPCOMMERCIAL','Skip Commercial','Z,End','OLDHOSTNAME'),('TV Playback','SKIPCOMMBACK','Skip Commercial (Reverse)','Q,Home','OLDHOSTNAME'),('TV Playback','JUMPSTART','Jump to the start of the recording.','Ctrl+B','OLDHOSTNAME'),('TV Playback','TOGGLEBROWSE','Toggle channel browse mode','O','OLDHOSTNAME'),('TV Playback','TOGGLERECORD','Toggle recording status of current program','R','OLDHOSTNAME'),('TV Playback','TOGGLEFAV','Toggle the current channel as a favorite','?','OLDHOSTNAME'),('TV Playback','VOLUMEDOWN','Volume down','[,{,F10,Volume Down','OLDHOSTNAME'),('TV Playback','VOLUMEUP','Volume up','],},F11,Volume Up','OLDHOSTNAME'),('TV Playback','MUTE','Mute','|,\\,F9,Volume Mute','OLDHOSTNAME'),('TV Playback','TOGGLEPIPMODE','Toggle Picture-in-Picture view','V','OLDHOSTNAME'),('TV Playback','TOGGLEPIPWINDOW','Toggle active PiP window','B','OLDHOSTNAME'),('TV Playback','SWAPPIP','Swap PBP/PIP Windows','N','OLDHOSTNAME'),('TV Playback','TOGGLECC','Toggle any captions','T','OLDHOSTNAME'),('TV Playback','TOGGLETTC','Toggle Teletext Captions','','OLDHOSTNAME'),('TV Playback','TOGGLESUBTITLE','Toggle Subtitles','','OLDHOSTNAME'),('TV Playback','TOGGLECC608','Toggle VBI CC','','OLDHOSTNAME'),('TV Playback','TOGGLECC708','Toggle ATSC CC','','OLDHOSTNAME'),('TV Playback','TOGGLETTM','Toggle Teletext Menu','','OLDHOSTNAME'),('TV Playback','SELECTAUDIO_0','Play audio track 1','','OLDHOSTNAME'),('TV Playback','SELECTAUDIO_1','Play audio track 2','','OLDHOSTNAME'),('TV Playback','SELECTSUBTITLE_0','Display subtitle 1','','OLDHOSTNAME'),('TV Playback','SELECTSUBTITLE_1','Display subtitle 2','','OLDHOSTNAME'),('TV Playback','SELECTCC608_0','Display VBI CC1','','OLDHOSTNAME'),('TV Playback','SELECTCC608_1','Display VBI CC2','','OLDHOSTNAME'),('TV Playback','SELECTCC608_2','Display VBI CC3','','OLDHOSTNAME'),('TV Playback','SELECTCC608_3','Display VBI CC4','','OLDHOSTNAME'),('TV Playback','SELECTCC708_0','Display ATSC CC1','','OLDHOSTNAME'),('TV Playback','SELECTCC708_1','Display ATSC CC2','','OLDHOSTNAME'),('TV Playback','SELECTCC708_2','Display ATSC CC3','','OLDHOSTNAME'),('TV Playback','SELECTCC708_3','Display ATSC CC4','','OLDHOSTNAME'),('TV Playback','NEXTAUDIO','Next audio track','+','OLDHOSTNAME'),('TV Playback','PREVAUDIO','Previous audio track','-','OLDHOSTNAME'),('TV Playback','NEXTSUBTITLE','Next subtitle track','','OLDHOSTNAME'),('TV Playback','PREVSUBTITLE','Previous subtitle track','','OLDHOSTNAME'),('TV Playback','NEXTCC608','Next VBI CC track','','OLDHOSTNAME'),('TV Playback','PREVCC608','Previous VBI CC track','','OLDHOSTNAME'),('TV Playback','NEXTCC708','Next ATSC CC track','','OLDHOSTNAME'),('TV Playback','PREVCC708','Previous ATSC CC track','','OLDHOSTNAME'),('TV Playback','NEXTCC','Next of any captions','','OLDHOSTNAME'),('TV Playback','NEXTSCAN','Next video scan overidemode','','OLDHOSTNAME'),('TV Playback','QUEUETRANSCODE','Queue the current recording for transcoding','X','OLDHOSTNAME'),('TV Playback','SPEEDINC','Increase the playback speed','U','OLDHOSTNAME'),('TV Playback','SPEEDDEC','Decrease the playback speed','J','OLDHOSTNAME'),('TV Playback','ADJUSTSTRETCH','Turn on time stretch control','A','OLDHOSTNAME'),('TV Playback','STRETCHINC','Increase time stretch speed','','OLDHOSTNAME'),('TV Playback','STRETCHDEC','Decrease time stretch speed','','OLDHOSTNAME'),('TV Playback','TOGGLESTRETCH','Toggle time stretch speed','','OLDHOSTNAME'),('TV Playback','TOGGLEAUDIOSYNC','Turn on audio sync adjustment controls','','OLDHOSTNAME'),('TV Playback','TOGGLEPICCONTROLS','Playback picture adjustments','F','OLDHOSTNAME'),('TV Playback','TOGGLECHANCONTROLS','Recording picture adjustments for this channel','Ctrl+G','OLDHOSTNAME'),('TV Playback','TOGGLERECCONTROLS','Recording picture adjustments for this recorder','G','OLDHOSTNAME'),('TV Frontend','TOGGLEEPGORDER','Reverse the channel order in the program guide','0','OLDHOSTNAME'),('TV Playback','CYCLECOMMSKIPMODE','Cycle Commercial Skip mode','','OLDHOSTNAME'),('TV Playback','GUIDE','Show the Program Guide','S','OLDHOSTNAME'),('TV Playback','FINDER','Show the Program Finder','#','OLDHOSTNAME'),('TV Playback','TOGGLESLEEP','Toggle the Sleep Timer','F8','OLDHOSTNAME'),('TV Playback','PLAY','Play','Ctrl+P','OLDHOSTNAME'),('TV Playback','JUMPPREV','Jump to previously played recording','','OLDHOSTNAME'),('TV Playback','JUMPREC','Display menu of recorded programs to jump to','','OLDHOSTNAME'),('TV Playback','JUMPTODVDROOTMENU','Jump to the DVD Root Menu','','OLDHOSTNAME'),('TV Editing','CLEARMAP','Clear editing cut points','C,Q,Home','OLDHOSTNAME'),('TV Editing','INVERTMAP','Invert Begin/End cut points','I','OLDHOSTNAME'),('TV Editing','LOADCOMMSKIP','Load cut list from commercial skips','Z,End','OLDHOSTNAME'),('TV Editing','NEXTCUT','Jump to the next cut point','PgDown','OLDHOSTNAME'),('TV Editing','PREVCUT','Jump to the previous cut point','PgUp','OLDHOSTNAME'),('TV Editing','BIGJUMPREW','Jump back 10x the normal amount',',,<','OLDHOSTNAME'),('TV Editing','BIGJUMPFWD','Jump forward 10x the normal amount','>,.','OLDHOSTNAME'),('Teletext Menu','NEXTPAGE','Next Page','Down','OLDHOSTNAME'),('Teletext Menu','PREVPAGE','Previous Page','Up','OLDHOSTNAME'),('Teletext Menu','NEXTSUBPAGE','Next Subpage','Right','OLDHOSTNAME'),('Teletext Menu','PREVSUBPAGE','Previous Subpage','Left','OLDHOSTNAME'),('Teletext Menu','TOGGLETT','Toggle Teletext','T','OLDHOSTNAME'),('Teletext Menu','MENURED','Menu Red','F2','OLDHOSTNAME'),('Teletext Menu','MENUGREEN','Menu Green','F3','OLDHOSTNAME'),('Teletext Menu','MENUYELLOW','Menu Yellow','F4','OLDHOSTNAME'),('Teletext Menu','MENUBLUE','Menu Blue','F5','OLDHOSTNAME'),('Teletext Menu','MENUWHITE','Menu White','F6','OLDHOSTNAME'),('Teletext Menu','TOGGLEBACKGROUND','Toggle Background','F7','OLDHOSTNAME'),('Teletext Menu','REVEAL','Reveal hidden Text','F8','OLDHOSTNAME'),('TV Playback','MENURED','Menu Red','F2','OLDHOSTNAME'),('TV Playback','MENUGREEN','Menu Green','F3','OLDHOSTNAME'),('TV Playback','MENUYELLOW','Menu Yellow','F4','OLDHOSTNAME'),('TV Playback','MENUBLUE','Menu Blue','F5','OLDHOSTNAME'),('TV Playback','TEXTEXIT','Menu Exit','F6','OLDHOSTNAME'),('TV Playback','MENUTEXT','Menu Text','F7','OLDHOSTNAME'),('TV Playback','MENUEPG','Menu EPG','F12','OLDHOSTNAME'),('Archive','TOGGLECUT','Toggle use cut list state for selected program','C','OLDHOSTNAME'),('NetFlix','MOVETOTOP','Moves movie to top of queue','1','OLDHOSTNAME'),('NetFlix','REMOVE','Removes movie from queue','D','OLDHOSTNAME'),('Gallery','PLAY','Start/Stop Slideshow','P','OLDHOSTNAME'),('Gallery','HOME','Go to the first image in thumbnail view','Home','OLDHOSTNAME'),('Gallery','END','Go to the last image in thumbnail view','End','OLDHOSTNAME'),('Gallery','MENU','Toggle activating menu in thumbnail view','M','OLDHOSTNAME'),('Gallery','SLIDESHOW','Start Slideshow in thumbnail view','S','OLDHOSTNAME'),('Gallery','RANDOMSHOW','Start Random Slideshow in thumbnail view','R','OLDHOSTNAME'),('Gallery','ROTRIGHT','Rotate image right 90 degrees','],3','OLDHOSTNAME'),('Gallery','ROTLEFT','Rotate image left 90 degrees','[,1','OLDHOSTNAME'),('Gallery','ZOOMOUT','Zoom image out','7','OLDHOSTNAME'),('Gallery','ZOOMIN','Zoom image in','9','OLDHOSTNAME'),('Gallery','SCROLLUP','Scroll image up','2','OLDHOSTNAME'),('Gallery','SCROLLLEFT','Scroll image left','4','OLDHOSTNAME'),('Gallery','SCROLLRIGHT','Scroll image right','6','OLDHOSTNAME'),('Gallery','SCROLLDOWN','Scroll image down','8','OLDHOSTNAME'),('Gallery','RECENTER','Recenter image','5','OLDHOSTNAME'),('Gallery','FULLSIZE','Full-size (un-zoom) image','0','OLDHOSTNAME'),('Gallery','UPLEFT','Go to the upper-left corner of the image','PgUp','OLDHOSTNAME'),('Gallery','LOWRIGHT','Go to the lower-right corner of the image','PgDown','OLDHOSTNAME'),('Gallery','INFO','Toggle Showing Information about Image','I','OLDHOSTNAME'),('Gallery','FULLSCREEN','Toggle scale to fullscreen/scale to fit','W','OLDHOSTNAME'),('Gallery','MARK','Mark image','T','OLDHOSTNAME'),('Game','TOGGLEFAV','Toggle the current game as a favorite','?,/','OLDHOSTNAME'),('Game','INCSEARCH','Show incremental search dialog','Ctrl+S','OLDHOSTNAME'),('Game','INCSEARCHNEXT','Incremental search find next match','Ctrl+N','OLDHOSTNAME'),('Music','PLAY','Start playback','','OLDHOSTNAME'),('Music','NEXTTRACK','Move to the next track','>,.,Z,End','OLDHOSTNAME'),('Music','PREVTRACK','Move to the previous track',',,<,Q,Home','OLDHOSTNAME'),('Music','FFWD','Fast forward','PgDown','OLDHOSTNAME'),('Music','RWND','Rewind','PgUp','OLDHOSTNAME'),('Music','PAUSE','Pause/Start playback','P','OLDHOSTNAME'),('Music','STOP','Stop playback','O','OLDHOSTNAME'),('Music','VOLUMEDOWN','Volume down','[,{,F10,Volume Down','OLDHOSTNAME'),('Music','VOLUMEUP','Volume up','],},F11,Volume Up','OLDHOSTNAME'),('Music','MUTE','Mute','|,\\,F9,Volume Mute','OLDHOSTNAME'),('Music','CYCLEVIS','Cycle visualizer mode','6','OLDHOSTNAME'),('Music','BLANKSCR','Blank screen','5','OLDHOSTNAME'),('Music','THMBUP','Increase rating','9','OLDHOSTNAME'),('Music','THMBDOWN','Decrease rating','7','OLDHOSTNAME'),('Music','REFRESH','Refresh music tree','8','OLDHOSTNAME'),('Music','FILTER','Filter All My Music','F','OLDHOSTNAME'),('Music','INCSEARCH','Show incremental search dialog','Ctrl+S','OLDHOSTNAME'),('Music','INCSEARCHNEXT','Incremental search find next match','Ctrl+N','OLDHOSTNAME'),('News','RETRIEVENEWS','Update news items','I','OLDHOSTNAME'),('News','FORCERETRIEVE','Force update news items','M','OLDHOSTNAME'),('News','CANCEL','Cancel news item updating','C','OLDHOSTNAME'),('Phone','0','0','0','OLDHOSTNAME'),('Phone','1','1','1','OLDHOSTNAME'),('Phone','2','2','2','OLDHOSTNAME'),('Phone','3','3','3','OLDHOSTNAME'),('Phone','4','4','4','OLDHOSTNAME'),('Phone','5','5','5','OLDHOSTNAME'),('Phone','6','6','6','OLDHOSTNAME'),('Phone','7','7','7','OLDHOSTNAME'),('Phone','8','8','8','OLDHOSTNAME'),('Phone','9','9','9','OLDHOSTNAME'),('Phone','HASH','HASH','#','OLDHOSTNAME'),('Phone','STAR','STAR','*','OLDHOSTNAME'),('Phone','Up','Up','Up','OLDHOSTNAME'),('Phone','Down','Down','Down','OLDHOSTNAME'),('Phone','Left','Left','Left','OLDHOSTNAME'),('Phone','Right','Right','Right','OLDHOSTNAME'),('Phone','VOLUMEDOWN','Volume down','[,{,F10,Volume Down','OLDHOSTNAME'),('Phone','VOLUMEUP','Volume up','],},F11,Volume Up','OLDHOSTNAME'),('Phone','ZOOMIN','Zoom the video window in','>,.,Z,End','OLDHOSTNAME'),('Phone','ZOOMOUT','Zoom the video window out',',,<,Q,Home','OLDHOSTNAME'),('Phone','FULLSCRN','Show received video full-screen','P','OLDHOSTNAME'),('Phone','HANGUP','Hangup an active call','O','OLDHOSTNAME'),('Phone','MUTE','Mute','|,\\,F9,Volume Mute','OLDHOSTNAME'),('Phone','LOOPBACK','Loopback Video','L','OLDHOSTNAME'),('Video','FILTER','Open video filter dialog','F','OLDHOSTNAME'),('Global','PAGETOP','Page to top of list','','OLDHOSTNAME'),('Video','BROWSE','Change browsable in video manager','B','OLDHOSTNAME'),('Video','INCPARENT','Increase Parental Level','],},F11','OLDHOSTNAME'),('Video','DECPARENT','Decrease Parental Level','[,{,F10','OLDHOSTNAME'),('Video','HOME','Go to the first video','Home','OLDHOSTNAME'),('Video','END','Go to the last video','End','OLDHOSTNAME'),('Weather','PAUSE','Pause current page','P','OLDHOSTNAME'),('Global','NEXT','Move to next widget','Tab','OLDHOSTNAME'),('Global','PREVIOUS','Move to preview widget','Backtab','OLDHOSTNAME'),('Global','BACKSPACE','Backspace','Backspace','OLDHOSTNAME'),('Global','DELETE','Delete','D','OLDHOSTNAME'),('Global','EDIT','Edit','E','OLDHOSTNAME'),('Browser','ZOOMIN','Zoom in on browser window','.,>','OLDHOSTNAME'),('Browser','ZOOMOUT','Zoom out on browser window',',,<','OLDHOSTNAME'),('Browser','TOGGLEINPUT','Toggle where keyboard input goes to','F1','OLDHOSTNAME'),('Browser','MOUSEUP','Move mouse pointer up','2','OLDHOSTNAME'),('Browser','MOUSEDOWN','Move mouse pointer down','8','OLDHOSTNAME'),('Browser','MOUSELEFT','Move mouse pointer left','4','OLDHOSTNAME'),('Browser','MOUSERIGHT','Move mouse pointer right','6','OLDHOSTNAME'),('Browser','MOUSELEFTBUTTON','Mouse Left button click','5','OLDHOSTNAME'),('Browser','PAGEDOWN','Scroll down half a page','9','OLDHOSTNAME'),('Browser','PAGEUP','Scroll up half a page','3','OLDHOSTNAME'),('Browser','PAGELEFT','Scroll left half a page','7','OLDHOSTNAME'),('Browser','PAGERIGHT','Scroll right half a page','1','OLDHOSTNAME'),('Browser','NEXTLINK','Move selection to next link','Z','OLDHOSTNAME'),('Browser','PREVIOUSLINK','Move selection to previous link','Q','OLDHOSTNAME'),('Browser','FOLLOWLINK','Follow selected link','Return,Space,Enter','OLDHOSTNAME'),('Browser','HISTORYBACK','Go back to previous page','R,Backspace','OLDHOSTNAME'),('Browser','HISTORYFORWARD','Go forward to previous page','F','OLDHOSTNAME'),('Global','PAGEMIDDLE','Page to middle of list','','OLDHOSTNAME'),('Global','PAGEBOTTOM','Page to bottom of list','','OLDHOSTNAME'),('TV Frontend','VOLUMEDOWN','Volume down','[,{,F10,Volume Down','OLDHOSTNAME'),('TV Frontend','VOLUMEUP','Volume up','],},F11,Volume Up','OLDHOSTNAME'),('TV Frontend','MUTE','Mute','|,\\,F9,Volume Mute','OLDHOSTNAME'),('TV Frontend','VIEWINPUT','Switch Capture Card view','C','OLDHOSTNAME'),('TV Frontend','CHANGERECGROUP','Change Recording Group','','OLDHOSTNAME'),('TV Frontend','CHANGEGROUPVIEW','Change Group View','','OLDHOSTNAME'),('TV Playback','NEXTSOURCE','Next Video Source','Y','OLDHOSTNAME'),('TV Playback','PREVSOURCE','Previous Video Source','Ctrl+Y','OLDHOSTNAME'),('TV Playback','NEXTINPUT','Next Input','C','OLDHOSTNAME'),('TV Playback','NEXTCARD','Next Card','','OLDHOSTNAME'),('TV Playback','TOGGLEPBPMODE','Toggle Picture-by-Picture view','Ctrl+V','OLDHOSTNAME'),('TV Playback','CREATEPIPVIEW','Create Picture-in-Picture view','','OLDHOSTNAME'),('TV Playback','CREATEPBPVIEW','Create Picture-by-Picture view','','OLDHOSTNAME'),('TV Playback','NEXTPIPWINDOW','Toggle active PIP/PBP window','B','OLDHOSTNAME'),('TV Playback','TOGGLEPIPSTATE','Change PxP view','','OLDHOSTNAME'),('TV Playback','TOGGLEASPECT','Toggle the video aspect ratio','Ctrl+W','OLDHOSTNAME'),('TV Playback','TOGGLEFILL','Next Preconfigured Zoom mode','W','OLDHOSTNAME'),('TV Playback','VIEWSCHEDULED','Display scheduled recording list','','OLDHOSTNAME'),('TV Playback','SIGNALMON','Monitor Signal Quality','Alt+F7','OLDHOSTNAME'),('TV Playback','EXITSHOWNOPROMPTS','Exit Show without any prompts','','OLDHOSTNAME'),('TV Playback','SCREENSHOT','Save screenshot of current video frame','','OLDHOSTNAME'),('Music','SPEEDUP','Increase Play Speed','W','OLDHOSTNAME'),('Music','SPEEDDOWN','Decrease Play Speed','X','OLDHOSTNAME'),('Video','PLAYALT','Play selected item in alternate player','ALT+P','OLDHOSTNAME'),('Video','INCSEARCH','Show Incremental Search Dialog','Ctrl+S','OLDHOSTNAME'),('Video','DOWNLOADDATA','Download metadata for current item','W','OLDHOSTNAME'),('Video','ITEMDETAIL','Display Item Detail Popup','','OLDHOSTNAME'),('Weather','SEARCH','Search List','/','OLDHOSTNAME'),('Weather','NEXTSEARCH','Search List','n','OLDHOSTNAME'),('Weather','UPDATE','Search List','u','OLDHOSTNAME'),('Global','COPY','Copy text from textedit','Ctrl+C','OLDHOSTNAME'),('Global','PASTE','Paste text into textedit','Ctrl+V','OLDHOSTNAME'),('Global','SYSEVENT01','Trigger System Key Event #1','','OLDHOSTNAME'),('Global','SYSEVENT02','Trigger System Key Event #2','','OLDHOSTNAME'),('Global','SYSEVENT03','Trigger System Key Event #3','','OLDHOSTNAME'),('Global','SYSEVENT04','Trigger System Key Event #4','','OLDHOSTNAME'),('Global','SYSEVENT05','Trigger System Key Event #5','','OLDHOSTNAME'),('Global','SYSEVENT06','Trigger System Key Event #6','','OLDHOSTNAME'),('Global','SYSEVENT07','Trigger System Key Event #7','','OLDHOSTNAME'),('Global','SYSEVENT08','Trigger System Key Event #8','','OLDHOSTNAME'),('Global','SYSEVENT09','Trigger System Key Event #9','','OLDHOSTNAME'),('Global','SYSEVENT10','Trigger System Key Event #10','','OLDHOSTNAME'),('TV Frontend','CUSTOMEDIT','Edit Custom Record Rule','','OLDHOSTNAME'),('TV Playback','TOGGLEUPMIX','Toggle audio upmixer','Ctrl+U','OLDHOSTNAME'),('Browser','NEXTTAB','Move to next browser tab','P','OLDHOSTNAME'),('Browser','PREVTAB','Move to previous browser tab','','OLDHOSTNAME'),('Music','TOGGLEUPMIX','Toggle audio upmixer','Ctrl+U','OLDHOSTNAME');
/*!40000 ALTER TABLE `keybindings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `keyword`
--

DROP TABLE IF EXISTS `keyword`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `keyword` (
  `phrase` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  `searchtype` int(10) unsigned NOT NULL DEFAULT '3',
  UNIQUE KEY `phrase` (`phrase`,`searchtype`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `keyword`
--

LOCK TABLES `keyword` WRITE;
/*!40000 ALTER TABLE `keyword` DISABLE KEYS */;
/*!40000 ALTER TABLE `keyword` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movies_movies`
--

DROP TABLE IF EXISTS `movies_movies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `movies_movies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `moviename` varchar(255) DEFAULT NULL,
  `rating` varchar(10) DEFAULT NULL,
  `runningtime` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movies_movies`
--

LOCK TABLES `movies_movies` WRITE;
/*!40000 ALTER TABLE `movies_movies` DISABLE KEYS */;
/*!40000 ALTER TABLE `movies_movies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movies_showtimes`
--

DROP TABLE IF EXISTS `movies_showtimes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `movies_showtimes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `theaterid` int(11) NOT NULL,
  `movieid` int(11) NOT NULL,
  `showtimes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movies_showtimes`
--

LOCK TABLES `movies_showtimes` WRITE;
/*!40000 ALTER TABLE `movies_showtimes` DISABLE KEYS */;
/*!40000 ALTER TABLE `movies_showtimes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `movies_theaters`
--

DROP TABLE IF EXISTS `movies_theaters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `movies_theaters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `theatername` varchar(100) DEFAULT NULL,
  `theateraddress` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `movies_theaters`
--

LOCK TABLES `movies_theaters` WRITE;
/*!40000 ALTER TABLE `movies_theaters` DISABLE KEYS */;
/*!40000 ALTER TABLE `movies_theaters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `music_albumart`
--

DROP TABLE IF EXISTS `music_albumart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `music_albumart` (
  `albumart_id` int(20) NOT NULL AUTO_INCREMENT,
  `filename` varchar(255) NOT NULL DEFAULT '',
  `directory_id` int(20) NOT NULL DEFAULT '0',
  `imagetype` tinyint(3) NOT NULL DEFAULT '0',
  `song_id` int(11) NOT NULL DEFAULT '0',
  `embedded` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`albumart_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `music_albumart`
--

LOCK TABLES `music_albumart` WRITE;
/*!40000 ALTER TABLE `music_albumart` DISABLE KEYS */;
/*!40000 ALTER TABLE `music_albumart` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `music_albums`
--

DROP TABLE IF EXISTS `music_albums`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `music_albums` (
  `album_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `artist_id` int(11) unsigned NOT NULL DEFAULT '0',
  `album_name` varchar(255) NOT NULL DEFAULT '',
  `year` smallint(6) NOT NULL DEFAULT '0',
  `compilation` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`album_id`),
  KEY `idx_album_name` (`album_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `music_artists` (
  `artist_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `artist_name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`artist_id`),
  KEY `idx_artist_name` (`artist_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `music_artists`
--

LOCK TABLES `music_artists` WRITE;
/*!40000 ALTER TABLE `music_artists` DISABLE KEYS */;
/*!40000 ALTER TABLE `music_artists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `music_directories`
--

DROP TABLE IF EXISTS `music_directories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `music_directories` (
  `directory_id` int(20) NOT NULL AUTO_INCREMENT,
  `path` text NOT NULL,
  `parent_id` int(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`directory_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `music_directories`
--

LOCK TABLES `music_directories` WRITE;
/*!40000 ALTER TABLE `music_directories` DISABLE KEYS */;
/*!40000 ALTER TABLE `music_directories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `music_genres`
--

DROP TABLE IF EXISTS `music_genres`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `music_genres` (
  `genre_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `genre` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`genre_id`),
  KEY `idx_genre` (`genre`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `music_playlists` (
  `playlist_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `playlist_name` varchar(255) NOT NULL DEFAULT '',
  `playlist_songs` text NOT NULL,
  `last_accessed` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `length` int(11) unsigned NOT NULL DEFAULT '0',
  `songcount` smallint(8) unsigned NOT NULL DEFAULT '0',
  `hostname` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`playlist_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `music_smartplaylist_categories` (
  `categoryid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`categoryid`),
  KEY `name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `music_smartplaylist_items` (
  `smartplaylistitemid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `smartplaylistid` int(10) unsigned NOT NULL,
  `field` varchar(50) NOT NULL,
  `operator` varchar(20) NOT NULL,
  `value1` varchar(255) NOT NULL,
  `value2` varchar(255) NOT NULL,
  PRIMARY KEY (`smartplaylistitemid`),
  KEY `smartplaylistid` (`smartplaylistid`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `music_smartplaylists` (
  `smartplaylistid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `categoryid` int(10) unsigned NOT NULL,
  `matchtype` set('All','Any') CHARACTER SET latin1 NOT NULL DEFAULT 'All',
  `orderby` varchar(128) NOT NULL DEFAULT '',
  `limitto` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`smartplaylistid`),
  KEY `name` (`name`),
  KEY `categoryid` (`categoryid`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `music_songs` (
  `song_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `filename` text NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `track` smallint(6) unsigned NOT NULL DEFAULT '0',
  `artist_id` int(11) unsigned NOT NULL DEFAULT '0',
  `album_id` int(11) unsigned NOT NULL DEFAULT '0',
  `genre_id` int(11) unsigned NOT NULL DEFAULT '0',
  `year` smallint(6) NOT NULL DEFAULT '0',
  `length` int(11) unsigned NOT NULL DEFAULT '0',
  `numplays` int(11) unsigned NOT NULL DEFAULT '0',
  `rating` tinyint(4) unsigned NOT NULL DEFAULT '0',
  `lastplay` datetime DEFAULT NULL,
  `date_entered` datetime DEFAULT NULL,
  `date_modified` datetime DEFAULT NULL,
  `format` varchar(4) NOT NULL DEFAULT '0',
  `mythdigest` varchar(255) DEFAULT NULL,
  `size` bigint(20) unsigned DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `disc_count` smallint(5) unsigned DEFAULT '0',
  `disc_number` smallint(5) unsigned DEFAULT '0',
  `track_count` smallint(5) unsigned DEFAULT '0',
  `start_time` int(10) unsigned DEFAULT '0',
  `stop_time` int(10) unsigned DEFAULT NULL,
  `eq_preset` varchar(255) DEFAULT NULL,
  `relative_volume` tinyint(4) DEFAULT '0',
  `sample_rate` int(10) unsigned DEFAULT '0',
  `bitrate` int(10) unsigned DEFAULT '0',
  `bpm` smallint(5) unsigned DEFAULT NULL,
  `directory_id` int(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`song_id`),
  KEY `idx_name` (`name`),
  KEY `idx_mythdigest` (`mythdigest`),
  KEY `directory_id` (`directory_id`),
  KEY `album_id` (`album_id`),
  KEY `genre_id` (`genre_id`),
  KEY `artist_id` (`artist_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `music_stats` (
  `num_artists` smallint(5) unsigned NOT NULL DEFAULT '0',
  `num_albums` smallint(5) unsigned NOT NULL DEFAULT '0',
  `num_songs` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `num_genres` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `total_time` varchar(12) NOT NULL DEFAULT '0',
  `total_size` varchar(10) NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `music_stats`
--

LOCK TABLES `music_stats` WRITE;
/*!40000 ALTER TABLE `music_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `music_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mythlog`
--

DROP TABLE IF EXISTS `mythlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mythlog` (
  `logid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `module` varchar(32) NOT NULL DEFAULT '',
  `priority` int(11) NOT NULL DEFAULT '0',
  `acknowledged` tinyint(1) DEFAULT '0',
  `logdate` datetime DEFAULT NULL,
  `host` varchar(128) DEFAULT NULL,
  `message` varchar(255) NOT NULL DEFAULT '',
  `details` text,
  PRIMARY KEY (`logid`),
  KEY `module` (`module`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mythlog`
--

LOCK TABLES `mythlog` WRITE;
/*!40000 ALTER TABLE `mythlog` DISABLE KEYS */;
/*!40000 ALTER TABLE `mythlog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `netvisionrssitems`
--

DROP TABLE IF EXISTS `netvisionrssitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `netvisionrssitems` (
  `feedtitle` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `url` text NOT NULL,
  `thumbnail` text NOT NULL,
  `mediaURL` text NOT NULL,
  `author` varchar(255) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `time` int(11) NOT NULL,
  `rating` varchar(255) NOT NULL,
  `filesize` bigint(20) NOT NULL,
  `player` varchar(255) NOT NULL,
  `playerargs` text NOT NULL,
  `download` varchar(255) NOT NULL,
  `downloadargs` text NOT NULL,
  `width` smallint(6) NOT NULL,
  `height` smallint(6) NOT NULL,
  `language` varchar(128) DEFAULT NULL,
  `downloadable` tinyint(1) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `netvisionrssitems`
--

LOCK TABLES `netvisionrssitems` WRITE;
/*!40000 ALTER TABLE `netvisionrssitems` DISABLE KEYS */;
/*!40000 ALTER TABLE `netvisionrssitems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `netvisionsearchgrabbers`
--

DROP TABLE IF EXISTS `netvisionsearchgrabbers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `netvisionsearchgrabbers` (
  `name` varchar(255) NOT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  `commandline` text NOT NULL,
  `host` varchar(128) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `netvisionsearchgrabbers`
--

LOCK TABLES `netvisionsearchgrabbers` WRITE;
/*!40000 ALTER TABLE `netvisionsearchgrabbers` DISABLE KEYS */;
/*!40000 ALTER TABLE `netvisionsearchgrabbers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `netvisionsites`
--

DROP TABLE IF EXISTS `netvisionsites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `netvisionsites` (
  `name` varchar(255) NOT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  `description` text,
  `url` text NOT NULL,
  `author` varchar(255) DEFAULT NULL,
  `download` tinyint(1) NOT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `netvisionsites`
--

LOCK TABLES `netvisionsites` WRITE;
/*!40000 ALTER TABLE `netvisionsites` DISABLE KEYS */;
/*!40000 ALTER TABLE `netvisionsites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `netvisiontreegrabbers`
--

DROP TABLE IF EXISTS `netvisiontreegrabbers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `netvisiontreegrabbers` (
  `name` varchar(255) NOT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  `commandline` text NOT NULL,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `host` varchar(128) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `netvisiontreegrabbers`
--

LOCK TABLES `netvisiontreegrabbers` WRITE;
/*!40000 ALTER TABLE `netvisiontreegrabbers` DISABLE KEYS */;
/*!40000 ALTER TABLE `netvisiontreegrabbers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `netvisiontreeitems`
--

DROP TABLE IF EXISTS `netvisiontreeitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `netvisiontreeitems` (
  `feedtitle` varchar(255) NOT NULL,
  `path` text NOT NULL,
  `paththumb` text NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `url` text NOT NULL,
  `thumbnail` text NOT NULL,
  `mediaURL` text NOT NULL,
  `author` varchar(255) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `time` int(11) NOT NULL,
  `rating` varchar(255) NOT NULL,
  `filesize` bigint(20) NOT NULL,
  `player` varchar(255) NOT NULL,
  `playerargs` text NOT NULL,
  `download` varchar(255) NOT NULL,
  `downloadargs` text NOT NULL,
  `width` smallint(6) NOT NULL,
  `height` smallint(6) NOT NULL,
  `language` varchar(128) NOT NULL,
  `downloadable` tinyint(1) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `netvisiontreeitems`
--

LOCK TABLES `netvisiontreeitems` WRITE;
/*!40000 ALTER TABLE `netvisiontreeitems` DISABLE KEYS */;
/*!40000 ALTER TABLE `netvisiontreeitems` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `networkiconmap`
--

DROP TABLE IF EXISTS `networkiconmap`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `networkiconmap` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `network` varchar(20) NOT NULL DEFAULT '',
  `url` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `network` (`network`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `networkiconmap`
--

LOCK TABLES `networkiconmap` WRITE;
/*!40000 ALTER TABLE `networkiconmap` DISABLE KEYS */;
/*!40000 ALTER TABLE `networkiconmap` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `newssites`
--

DROP TABLE IF EXISTS `newssites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `newssites` (
  `name` varchar(100) NOT NULL,
  `category` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `ico` varchar(255) DEFAULT NULL,
  `updated` int(10) unsigned DEFAULT NULL,
  `podcast` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `newssites`
--

LOCK TABLES `newssites` WRITE;
/*!40000 ALTER TABLE `newssites` DISABLE KEYS */;
/*!40000 ALTER TABLE `newssites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oldfind`
--

DROP TABLE IF EXISTS `oldfind`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oldfind` (
  `recordid` int(11) NOT NULL DEFAULT '0',
  `findid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`recordid`,`findid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oldprogram` (
  `oldtitle` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  `airdate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`oldtitle`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oldrecorded` (
  `chanid` int(10) unsigned NOT NULL DEFAULT '0',
  `starttime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `endtime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `title` varchar(128) NOT NULL DEFAULT '',
  `subtitle` varchar(128) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `category` varchar(64) NOT NULL DEFAULT '',
  `seriesid` varchar(40) NOT NULL DEFAULT '',
  `programid` varchar(40) NOT NULL DEFAULT '',
  `findid` int(11) NOT NULL DEFAULT '0',
  `recordid` int(11) NOT NULL DEFAULT '0',
  `station` varchar(20) NOT NULL DEFAULT '',
  `rectype` int(10) unsigned NOT NULL DEFAULT '0',
  `duplicate` tinyint(1) NOT NULL DEFAULT '0',
  `recstatus` int(11) NOT NULL DEFAULT '0',
  `reactivate` smallint(6) NOT NULL DEFAULT '0',
  `generic` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`station`,`starttime`,`title`),
  KEY `endtime` (`endtime`),
  KEY `title` (`title`),
  KEY `seriesid` (`seriesid`),
  KEY `programid` (`programid`),
  KEY `recordid` (`recordid`),
  KEY `recstatus` (`recstatus`,`programid`,`seriesid`),
  KEY `recstatus_2` (`recstatus`,`title`,`subtitle`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `people` (
  `person` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  PRIMARY KEY (`person`),
  UNIQUE KEY `name` (`name`(41))
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `phonecallhistory` (
  `recid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `displayname` text NOT NULL,
  `url` text NOT NULL,
  `timestamp` text NOT NULL,
  `duration` int(10) unsigned NOT NULL,
  `directionin` int(10) unsigned NOT NULL,
  `directoryref` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`recid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `phonedirectory` (
  `intid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nickname` text NOT NULL,
  `firstname` text,
  `surname` text,
  `url` text NOT NULL,
  `directory` text NOT NULL,
  `photofile` text,
  `speeddial` int(10) unsigned NOT NULL,
  `onhomelan` int(10) unsigned DEFAULT '0',
  PRIMARY KEY (`intid`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pidcache` (
  `chanid` smallint(6) NOT NULL DEFAULT '0',
  `pid` int(11) NOT NULL DEFAULT '-1',
  `tableid` int(11) NOT NULL DEFAULT '-1',
  KEY `chanid` (`chanid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `playgroup` (
  `name` varchar(32) NOT NULL DEFAULT '',
  `titlematch` varchar(255) NOT NULL DEFAULT '',
  `skipahead` int(11) NOT NULL DEFAULT '0',
  `skipback` int(11) NOT NULL DEFAULT '0',
  `timestretch` int(11) NOT NULL DEFAULT '0',
  `jump` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `playgroup`
--

LOCK TABLES `playgroup` WRITE;
/*!40000 ALTER TABLE `playgroup` DISABLE KEYS */;
INSERT INTO `playgroup` VALUES ('Default','',30,5,100,0);
/*!40000 ALTER TABLE `playgroup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `powerpriority`
--

DROP TABLE IF EXISTS `powerpriority`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `powerpriority` (
  `priorityname` varchar(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `recpriority` int(10) NOT NULL DEFAULT '0',
  `selectclause` text NOT NULL,
  PRIMARY KEY (`priorityname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `powerpriority`
--

LOCK TABLES `powerpriority` WRITE;
/*!40000 ALTER TABLE `powerpriority` DISABLE KEYS */;
/*!40000 ALTER TABLE `powerpriority` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `profilegroups`
--

DROP TABLE IF EXISTS `profilegroups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `profilegroups` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) DEFAULT NULL,
  `cardtype` varchar(32) NOT NULL DEFAULT 'V4L',
  `is_default` int(1) DEFAULT '0',
  `hostname` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`,`hostname`),
  KEY `cardtype` (`cardtype`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `profilegroups`
--

LOCK TABLES `profilegroups` WRITE;
/*!40000 ALTER TABLE `profilegroups` DISABLE KEYS */;
INSERT INTO `profilegroups` VALUES (1,'Software Encoders (v4l based)','V4L',1,NULL),(2,'MPEG-2 Encoders (PVR-x50, PVR-500)','MPEG',1,NULL),(3,'Hardware MJPEG Encoders (Matrox G200-TV, Miro DC10, etc)','MJPEG',1,NULL),(4,'Hardware HDTV','HDTV',1,NULL),(5,'Hardware DVB Encoders','DVB',1,NULL),(6,'Transcoders','TRANSCODE',1,NULL),(7,'FireWire Input','FIREWIRE',1,NULL),(8,'USB Mpeg-4 Encoder (Plextor ConvertX, etc)','GO7007',1,NULL),(14,'Import Recorder','IMPORT',1,NULL),(10,'Freebox Input','Freebox',1,NULL),(11,'HDHomeRun Recorders','HDHOMERUN',1,NULL),(12,'CRC IP Recorders','CRC_IP',1,NULL),(13,'HD-PVR Recorders','HDPVR',1,NULL);
/*!40000 ALTER TABLE `profilegroups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `program`
--

DROP TABLE IF EXISTS `program`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `program` (
  `chanid` int(10) unsigned NOT NULL DEFAULT '0',
  `starttime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `endtime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `title` varchar(128) NOT NULL DEFAULT '',
  `subtitle` varchar(128) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `category` varchar(64) NOT NULL DEFAULT '',
  `category_type` varchar(64) NOT NULL DEFAULT '',
  `airdate` year(4) NOT NULL DEFAULT '0000',
  `stars` float NOT NULL DEFAULT '0',
  `previouslyshown` tinyint(4) NOT NULL DEFAULT '0',
  `title_pronounce` varchar(128) NOT NULL DEFAULT '',
  `stereo` tinyint(1) NOT NULL DEFAULT '0',
  `subtitled` tinyint(1) NOT NULL DEFAULT '0',
  `hdtv` tinyint(1) NOT NULL DEFAULT '0',
  `closecaptioned` tinyint(1) NOT NULL DEFAULT '0',
  `partnumber` int(11) NOT NULL DEFAULT '0',
  `parttotal` int(11) NOT NULL DEFAULT '0',
  `seriesid` varchar(64) NOT NULL DEFAULT '',
  `originalairdate` date DEFAULT NULL,
  `showtype` varchar(30) NOT NULL DEFAULT '',
  `colorcode` varchar(20) NOT NULL DEFAULT '',
  `syndicatedepisodenumber` varchar(20) NOT NULL DEFAULT '',
  `programid` varchar(64) NOT NULL DEFAULT '',
  `manualid` int(10) unsigned NOT NULL DEFAULT '0',
  `generic` tinyint(1) DEFAULT '0',
  `listingsource` int(11) NOT NULL DEFAULT '0',
  `first` tinyint(1) NOT NULL DEFAULT '0',
  `last` tinyint(1) NOT NULL DEFAULT '0',
  `audioprop` set('STEREO','MONO','SURROUND','DOLBY','HARDHEAR','VISUALIMPAIR') CHARACTER SET latin1 NOT NULL,
  `subtitletypes` set('HARDHEAR','NORMAL','ONSCREEN','SIGNED') CHARACTER SET latin1 NOT NULL,
  `videoprop` set('HDTV','WIDESCREEN','AVC') CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`chanid`,`starttime`,`manualid`),
  KEY `endtime` (`endtime`),
  KEY `title` (`title`),
  KEY `title_pronounce` (`title_pronounce`),
  KEY `seriesid` (`seriesid`),
  KEY `id_start_end` (`chanid`,`starttime`,`endtime`),
  KEY `program_manualid` (`manualid`),
  KEY `previouslyshown` (`previouslyshown`),
  KEY `programid` (`programid`,`starttime`),
  KEY `starttime` (`starttime`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `programgenres` (
  `chanid` int(10) unsigned NOT NULL DEFAULT '0',
  `starttime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `relevance` char(1) NOT NULL DEFAULT '',
  `genre` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`chanid`,`starttime`,`relevance`),
  KEY `genre` (`genre`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `programrating` (
  `chanid` int(10) unsigned NOT NULL DEFAULT '0',
  `starttime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `system` varchar(8) DEFAULT NULL,
  `rating` varchar(16) DEFAULT NULL,
  UNIQUE KEY `chanid` (`chanid`,`starttime`,`system`,`rating`),
  KEY `starttime` (`starttime`,`system`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recgrouppassword` (
  `recgroup` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  `password` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`recgroup`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `record` (
  `recordid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `type` int(10) unsigned NOT NULL DEFAULT '0',
  `chanid` int(10) unsigned DEFAULT NULL,
  `starttime` time NOT NULL DEFAULT '00:00:00',
  `startdate` date NOT NULL DEFAULT '0000-00-00',
  `endtime` time NOT NULL DEFAULT '00:00:00',
  `enddate` date NOT NULL DEFAULT '0000-00-00',
  `title` varchar(128) NOT NULL DEFAULT '',
  `subtitle` varchar(128) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `category` varchar(64) NOT NULL DEFAULT '',
  `profile` varchar(128) NOT NULL DEFAULT 'Default',
  `recpriority` int(10) NOT NULL DEFAULT '0',
  `autoexpire` int(11) NOT NULL DEFAULT '0',
  `maxepisodes` int(11) NOT NULL DEFAULT '0',
  `maxnewest` int(11) NOT NULL DEFAULT '0',
  `startoffset` int(11) NOT NULL DEFAULT '0',
  `endoffset` int(11) NOT NULL DEFAULT '0',
  `recgroup` varchar(32) NOT NULL DEFAULT 'Default',
  `dupmethod` int(11) NOT NULL DEFAULT '6',
  `dupin` int(11) NOT NULL DEFAULT '15',
  `station` varchar(20) NOT NULL DEFAULT '',
  `seriesid` varchar(40) NOT NULL DEFAULT '',
  `programid` varchar(40) NOT NULL DEFAULT '',
  `search` int(10) unsigned NOT NULL DEFAULT '0',
  `autotranscode` tinyint(1) NOT NULL DEFAULT '0',
  `autocommflag` tinyint(1) NOT NULL DEFAULT '0',
  `autouserjob1` tinyint(1) NOT NULL DEFAULT '0',
  `autouserjob2` tinyint(1) NOT NULL DEFAULT '0',
  `autouserjob3` tinyint(1) NOT NULL DEFAULT '0',
  `autouserjob4` tinyint(1) NOT NULL DEFAULT '0',
  `findday` tinyint(4) NOT NULL DEFAULT '0',
  `findtime` time NOT NULL DEFAULT '00:00:00',
  `findid` int(11) NOT NULL DEFAULT '0',
  `inactive` tinyint(1) NOT NULL DEFAULT '0',
  `parentid` int(11) NOT NULL DEFAULT '0',
  `transcoder` int(11) NOT NULL DEFAULT '0',
  `tsdefault` float NOT NULL DEFAULT '1',
  `playgroup` varchar(32) NOT NULL DEFAULT 'Default',
  `prefinput` int(10) NOT NULL DEFAULT '0',
  `next_record` datetime NOT NULL,
  `last_record` datetime NOT NULL,
  `last_delete` datetime NOT NULL,
  `storagegroup` varchar(32) NOT NULL DEFAULT 'Default',
  `avg_delay` int(11) NOT NULL DEFAULT '100',
  PRIMARY KEY (`recordid`),
  KEY `chanid` (`chanid`,`starttime`),
  KEY `title` (`title`),
  KEY `seriesid` (`seriesid`),
  KEY `programid` (`programid`),
  KEY `maxepisodes` (`maxepisodes`),
  KEY `search` (`search`),
  KEY `type` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recorded` (
  `chanid` int(10) unsigned NOT NULL DEFAULT '0',
  `starttime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `endtime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `title` varchar(128) NOT NULL DEFAULT '',
  `subtitle` varchar(128) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `category` varchar(64) NOT NULL DEFAULT '',
  `hostname` varchar(64) NOT NULL DEFAULT '',
  `bookmark` tinyint(1) NOT NULL DEFAULT '0',
  `editing` int(10) unsigned NOT NULL DEFAULT '0',
  `cutlist` tinyint(1) NOT NULL DEFAULT '0',
  `autoexpire` int(11) NOT NULL DEFAULT '0',
  `commflagged` int(10) unsigned NOT NULL DEFAULT '0',
  `recgroup` varchar(32) NOT NULL DEFAULT 'Default',
  `recordid` int(11) DEFAULT NULL,
  `seriesid` varchar(40) NOT NULL DEFAULT '',
  `programid` varchar(40) NOT NULL DEFAULT '',
  `lastmodified` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `filesize` bigint(20) NOT NULL DEFAULT '0',
  `stars` float NOT NULL DEFAULT '0',
  `previouslyshown` tinyint(1) DEFAULT '0',
  `originalairdate` date DEFAULT NULL,
  `preserve` tinyint(1) NOT NULL DEFAULT '0',
  `findid` int(11) NOT NULL DEFAULT '0',
  `deletepending` tinyint(1) NOT NULL DEFAULT '0',
  `transcoder` int(11) NOT NULL DEFAULT '0',
  `timestretch` float NOT NULL DEFAULT '1',
  `recpriority` int(11) NOT NULL DEFAULT '0',
  `basename` varchar(255) NOT NULL,
  `progstart` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `progend` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `playgroup` varchar(32) NOT NULL DEFAULT 'Default',
  `profile` varchar(32) NOT NULL DEFAULT '',
  `duplicate` tinyint(1) NOT NULL DEFAULT '0',
  `transcoded` tinyint(1) NOT NULL DEFAULT '0',
  `watched` tinyint(4) NOT NULL DEFAULT '0',
  `storagegroup` varchar(32) NOT NULL DEFAULT 'Default',
  `bookmarkupdate` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`chanid`,`starttime`),
  KEY `endtime` (`endtime`),
  KEY `seriesid` (`seriesid`),
  KEY `programid` (`programid`),
  KEY `title` (`title`),
  KEY `recordid` (`recordid`),
  KEY `deletepending` (`deletepending`,`lastmodified`),
  KEY `recgroup` (`recgroup`,`endtime`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recordedcredits` (
  `person` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `chanid` int(10) unsigned NOT NULL DEFAULT '0',
  `starttime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `role` set('actor','director','producer','executive_producer','writer','guest_star','host','adapter','presenter','commentator','guest') CHARACTER SET latin1 NOT NULL DEFAULT '',
  UNIQUE KEY `chanid` (`chanid`,`starttime`,`person`,`role`),
  KEY `person` (`person`,`role`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recordedcredits`
--

LOCK TABLES `recordedcredits` WRITE;
/*!40000 ALTER TABLE `recordedcredits` DISABLE KEYS */;
/*!40000 ALTER TABLE `recordedcredits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recordedfile`
--

DROP TABLE IF EXISTS `recordedfile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recordedfile` (
  `chanid` int(10) unsigned NOT NULL DEFAULT '0',
  `starttime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `basename` varchar(128) NOT NULL DEFAULT '',
  `filesize` bigint(20) NOT NULL DEFAULT '0',
  `width` smallint(5) unsigned NOT NULL DEFAULT '0',
  `height` smallint(5) unsigned NOT NULL DEFAULT '0',
  `fps` float(6,3) NOT NULL DEFAULT '0.000',
  `aspect` float(8,6) NOT NULL DEFAULT '0.000000',
  `audio_sample_rate` smallint(5) unsigned NOT NULL DEFAULT '0',
  `audio_bits_per_sample` smallint(5) unsigned NOT NULL DEFAULT '0',
  `audio_channels` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `audio_type` varchar(255) NOT NULL DEFAULT '',
  `video_type` varchar(255) NOT NULL DEFAULT '',
  `comment` varchar(255) NOT NULL DEFAULT '',
  `hostname` varchar(64) NOT NULL,
  `storagegroup` varchar(32) NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chanid` (`chanid`,`starttime`,`basename`),
  KEY `basename` (`basename`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recordedfile`
--

LOCK TABLES `recordedfile` WRITE;
/*!40000 ALTER TABLE `recordedfile` DISABLE KEYS */;
/*!40000 ALTER TABLE `recordedfile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recordedmarkup`
--

DROP TABLE IF EXISTS `recordedmarkup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recordedmarkup` (
  `chanid` int(10) unsigned NOT NULL DEFAULT '0',
  `starttime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `mark` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `type` tinyint(4) NOT NULL DEFAULT '0',
  `data` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`chanid`,`starttime`,`type`,`mark`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recordedprogram` (
  `chanid` int(10) unsigned NOT NULL DEFAULT '0',
  `starttime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `endtime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `title` varchar(128) NOT NULL DEFAULT '',
  `subtitle` varchar(128) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `category` varchar(64) NOT NULL DEFAULT '',
  `category_type` varchar(64) NOT NULL DEFAULT '',
  `airdate` year(4) NOT NULL DEFAULT '0000',
  `stars` float unsigned NOT NULL DEFAULT '0',
  `previouslyshown` tinyint(4) NOT NULL DEFAULT '0',
  `title_pronounce` varchar(128) NOT NULL DEFAULT '',
  `stereo` tinyint(1) NOT NULL DEFAULT '0',
  `subtitled` tinyint(1) NOT NULL DEFAULT '0',
  `hdtv` tinyint(1) NOT NULL DEFAULT '0',
  `closecaptioned` tinyint(1) NOT NULL DEFAULT '0',
  `partnumber` int(11) NOT NULL DEFAULT '0',
  `parttotal` int(11) NOT NULL DEFAULT '0',
  `seriesid` varchar(40) NOT NULL DEFAULT '',
  `originalairdate` date DEFAULT NULL,
  `showtype` varchar(30) NOT NULL DEFAULT '',
  `colorcode` varchar(20) NOT NULL DEFAULT '',
  `syndicatedepisodenumber` varchar(20) NOT NULL DEFAULT '',
  `programid` varchar(40) NOT NULL DEFAULT '',
  `manualid` int(10) unsigned NOT NULL DEFAULT '0',
  `generic` tinyint(1) DEFAULT '0',
  `listingsource` int(11) NOT NULL DEFAULT '0',
  `first` tinyint(1) NOT NULL DEFAULT '0',
  `last` tinyint(1) NOT NULL DEFAULT '0',
  `audioprop` set('STEREO','MONO','SURROUND','DOLBY','HARDHEAR','VISUALIMPAIR') CHARACTER SET latin1 NOT NULL,
  `subtitletypes` set('HARDHEAR','NORMAL','ONSCREEN','SIGNED') CHARACTER SET latin1 NOT NULL,
  `videoprop` set('HDTV','WIDESCREEN','AVC','720','1080') NOT NULL,
  PRIMARY KEY (`chanid`,`starttime`,`manualid`),
  KEY `endtime` (`endtime`),
  KEY `title` (`title`),
  KEY `title_pronounce` (`title_pronounce`),
  KEY `seriesid` (`seriesid`),
  KEY `programid` (`programid`),
  KEY `id_start_end` (`chanid`,`starttime`,`endtime`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recordedrating` (
  `chanid` int(10) unsigned NOT NULL DEFAULT '0',
  `starttime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `system` varchar(8) DEFAULT NULL,
  `rating` varchar(16) DEFAULT NULL,
  UNIQUE KEY `chanid` (`chanid`,`starttime`,`system`,`rating`),
  KEY `starttime` (`starttime`,`system`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recordedseek` (
  `chanid` int(10) unsigned NOT NULL DEFAULT '0',
  `starttime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `mark` mediumint(8) unsigned NOT NULL DEFAULT '0',
  `offset` bigint(20) unsigned NOT NULL,
  `type` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`chanid`,`starttime`,`type`,`mark`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recordingprofiles` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) DEFAULT NULL,
  `videocodec` varchar(128) DEFAULT NULL,
  `audiocodec` varchar(128) DEFAULT NULL,
  `profilegroup` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `profilegroup` (`profilegroup`)
) ENGINE=MyISAM AUTO_INCREMENT=58 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recordingprofiles`
--

LOCK TABLES `recordingprofiles` WRITE;
/*!40000 ALTER TABLE `recordingprofiles` DISABLE KEYS */;
INSERT INTO `recordingprofiles` VALUES (1,'Default',NULL,NULL,1),(2,'Live TV',NULL,NULL,1),(3,'High Quality',NULL,NULL,1),(4,'Low Quality',NULL,NULL,1),(5,'Default',NULL,NULL,2),(6,'Live TV',NULL,NULL,2),(7,'High Quality',NULL,NULL,2),(8,'Low Quality',NULL,NULL,2),(9,'Default',NULL,NULL,3),(10,'Live TV',NULL,NULL,3),(11,'High Quality',NULL,NULL,3),(12,'Low Quality',NULL,NULL,3),(13,'Default',NULL,NULL,4),(14,'Live TV',NULL,NULL,4),(15,'High Quality',NULL,NULL,4),(16,'Low Quality',NULL,NULL,4),(17,'Default',NULL,NULL,5),(18,'Live TV',NULL,NULL,5),(19,'High Quality',NULL,NULL,5),(20,'Low Quality',NULL,NULL,5),(21,'RTjpeg/MPEG4',NULL,NULL,6),(22,'MPEG2',NULL,NULL,6),(23,'Default',NULL,NULL,8),(24,'Live TV',NULL,NULL,8),(25,'High Quality',NULL,NULL,8),(26,'Low Quality',NULL,NULL,8),(27,'High Quality',NULL,NULL,6),(28,'Medium Quality',NULL,NULL,6),(29,'Low Quality',NULL,NULL,6),(30,'Default',NULL,NULL,10),(31,'Live TV',NULL,NULL,10),(32,'High Quality',NULL,NULL,10),(33,'Low Quality',NULL,NULL,10),(34,'Default',NULL,NULL,11),(35,'Live TV',NULL,NULL,11),(36,'High Quality',NULL,NULL,11),(37,'Low Quality',NULL,NULL,11),(38,'Default',NULL,NULL,12),(39,'Live TV',NULL,NULL,12),(40,'High Quality',NULL,NULL,12),(41,'Low Quality',NULL,NULL,12),(42,'Default',NULL,NULL,7),(43,'Live TV',NULL,NULL,7),(44,'High Quality',NULL,NULL,7),(45,'Low Quality',NULL,NULL,7),(46,'Default',NULL,NULL,9),(47,'Live TV',NULL,NULL,9),(48,'High Quality',NULL,NULL,9),(49,'Low Quality',NULL,NULL,9),(50,'Default',NULL,NULL,13),(51,'Live TV',NULL,NULL,13),(52,'High Quality',NULL,NULL,13),(53,'Low Quality',NULL,NULL,13),(54,'Default',NULL,NULL,14),(55,'Live TV',NULL,NULL,14),(56,'High Quality',NULL,NULL,14),(57,'Low Quality',NULL,NULL,14);
/*!40000 ALTER TABLE `recordingprofiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recordmatch`
--

DROP TABLE IF EXISTS `recordmatch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recordmatch` (
  `recordid` int(10) unsigned DEFAULT NULL,
  `chanid` int(10) unsigned DEFAULT NULL,
  `starttime` datetime DEFAULT NULL,
  `manualid` int(10) unsigned DEFAULT NULL,
  `oldrecduplicate` tinyint(1) DEFAULT NULL,
  `recduplicate` tinyint(1) DEFAULT NULL,
  `findduplicate` tinyint(1) DEFAULT NULL,
  `oldrecstatus` int(11) DEFAULT NULL,
  KEY `recordid` (`recordid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `romdb` (
  `crc` varchar(64) NOT NULL DEFAULT '',
  `name` varchar(128) NOT NULL DEFAULT '',
  `description` varchar(128) NOT NULL DEFAULT '',
  `category` varchar(128) NOT NULL DEFAULT '',
  `year` varchar(10) NOT NULL DEFAULT '',
  `manufacturer` varchar(128) NOT NULL DEFAULT '',
  `country` varchar(128) NOT NULL DEFAULT '',
  `publisher` varchar(128) NOT NULL DEFAULT '',
  `platform` varchar(64) NOT NULL DEFAULT '',
  `filesize` int(12) DEFAULT NULL,
  `flags` varchar(64) NOT NULL DEFAULT '',
  `version` varchar(64) NOT NULL DEFAULT '',
  `binfile` varchar(64) NOT NULL DEFAULT '',
  KEY `crc` (`crc`),
  KEY `year` (`year`),
  KEY `category` (`category`),
  KEY `name` (`name`),
  KEY `description` (`description`),
  KEY `platform` (`platform`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schemalock` (
  `schemalock` int(1) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `settings` (
  `value` varchar(128) NOT NULL DEFAULT '',
  `data` text,
  `hostname` varchar(64) DEFAULT NULL,
  KEY `value` (`value`,`hostname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES ('mythfilldatabaseLastRunStart',NULL,NULL),('mythfilldatabaseLastRunEnd',NULL,NULL),('mythfilldatabaseLastRunStatus',NULL,NULL),('DataDirectMessage',NULL,NULL),('HaveRepeats','0',NULL),('DBSchemaVer','1254',NULL),('DefaultTranscoder','0',NULL),('MythFillSuggestedRunTime','1970-01-01T00:00:00',NULL),('MythFillGrabberSuggestsTime','1',NULL),('BackendServerIP','127.0.0.1','OLDHOSTNAME'),('BackendServerPort','6543','OLDHOSTNAME'),('BackendStatusPort','6544','OLDHOSTNAME'),('MasterServerIP','127.0.0.1',NULL),('MasterServerPort','6543',NULL),('RecordFilePrefix','/var/lib/mythtv/recordings','OLDHOSTNAME'),('TruncateDeletesSlowly','1','OLDHOSTNAME'),('TVFormat','NTSC',NULL),('VbiFormat','None',NULL),('FreqTable','us-bcast',NULL),('TimeOffset','None',NULL),('MasterBackendOverride','1',NULL),('DeletesFollowLinks','0',NULL),('EITTimeOffset','Auto',NULL),('EITTransportTimeout','5',NULL),('EITIgnoresSource','0',NULL),('EITCrawIdleStart','60',NULL),('startupCommand','',NULL),('blockSDWUwithoutClient','1',NULL),('idleTimeoutSecs','0',NULL),('idleWaitForRecordingTime','15',NULL),('StartupSecsBeforeRecording','120',NULL),('WakeupTimeFormat','hh:mm yyyy-MM-dd',NULL),('SetWakeuptimeCommand','',NULL),('ServerHaltCommand','sudo /sbin/halt -p',NULL),('preSDWUCheckCommand','',NULL),('WOLbackendReconnectWaitTime','0',NULL),('WOLbackendConnectRetry','5',NULL),('WOLbackendCommand','',NULL),('WOLslaveBackendsCommand','',NULL),('JobQueueMaxSimultaneousJobs','1','OLDHOSTNAME'),('JobQueueCheckFrequency','60','OLDHOSTNAME'),('JobQueueWindowStart','00:00','OLDHOSTNAME'),('JobQueueWindowEnd','23:59','OLDHOSTNAME'),('JobQueueCPU','0','OLDHOSTNAME'),('JobAllowCommFlag','1','OLDHOSTNAME'),('JobAllowTranscode','1','OLDHOSTNAME'),('JobAllowUserJob1','0','OLDHOSTNAME'),('JobAllowUserJob2','0','OLDHOSTNAME'),('JobAllowUserJob3','0','OLDHOSTNAME'),('JobAllowUserJob4','0','OLDHOSTNAME'),('JobsRunOnRecordHost','0',NULL),('AutoCommflagWhileRecording','0',NULL),('JobQueueCommFlagCommand','mythcommflag',NULL),('JobQueueTranscodeCommand','mythtranscode',NULL),('AutoTranscodeBeforeAutoCommflag','0',NULL),('SaveTranscoding','0',NULL),('UserJobDesc1','User Job #1',NULL),('UserJob1','',NULL),('UserJobDesc2','User Job #2',NULL),('UserJob2','',NULL),('UserJobDesc3','User Job #3',NULL),('UserJob3','',NULL),('UserJobDesc4','User Job #4',NULL),('UserJob4','',NULL),('upnp:UDN:urn:schemas-upnp-org:device:MediaServer:1','256a89b4-1266-49ca-9ac7-f0b4b4641e7f','OLDHOSTNAME'),('Deinterlace','0','OLDHOSTNAME'),('DeinterlaceFilter','linearblend','OLDHOSTNAME'),('CustomFilters','','OLDHOSTNAME'),('PreferredMPEG2Decoder','ffmpeg','OLDHOSTNAME'),('UseOpenGLVSync','0','OLDHOSTNAME'),('RealtimePriority','1','OLDHOSTNAME'),('UseVideoTimebase','0','OLDHOSTNAME'),('DecodeExtraAudio','1','OLDHOSTNAME'),('AspectOverride','0','OLDHOSTNAME'),('PIPLocation','0','OLDHOSTNAME'),('PlaybackExitPrompt','0','OLDHOSTNAME'),('EndOfRecordingExitPrompt','0','OLDHOSTNAME'),('ClearSavedPosition','1','OLDHOSTNAME'),('AltClearSavedPosition','1','OLDHOSTNAME'),('UseOutputPictureControls','0','OLDHOSTNAME'),('AudioNag','1','OLDHOSTNAME'),('UDPNotifyPort','6948','OLDHOSTNAME'),('PlayBoxOrdering','1','OLDHOSTNAME'),('PlayBoxEpisodeSort','Date','OLDHOSTNAME'),('GeneratePreviewPixmaps','0','OLDHOSTNAME'),('PreviewPixmapOffset','64',NULL),('PreviewFromBookmark','1','OLDHOSTNAME'),('PlaybackPreview','1','OLDHOSTNAME'),('PlaybackPreviewLowCPU','0','OLDHOSTNAME'),('PlaybackBoxStartInTitle','1','OLDHOSTNAME'),('ShowGroupInfo','0','OLDHOSTNAME'),('AllRecGroupPassword','',NULL),('DisplayRecGroup','All Programs','OLDHOSTNAME'),('QueryInitialFilter','0','OLDHOSTNAME'),('RememberRecGroup','1','OLDHOSTNAME'),('DispRecGroupAsAllProg','0','OLDHOSTNAME'),('LiveTVInAllPrograms','0','OLDHOSTNAME'),('DisplayGroupDefaultView','0','OLDHOSTNAME'),('DisplayGroupTitleSort','0','OLDHOSTNAME'),('PVR350OutputEnable','0','OLDHOSTNAME'),('PVR350VideoDev','/dev/video16','OLDHOSTNAME'),('PVR350EPGAlphaValue','164','OLDHOSTNAME'),('PVR350InternalAudioOnly','0','OLDHOSTNAME'),('SmartForward','0','OLDHOSTNAME'),('StickyKeys','0','OLDHOSTNAME'),('FFRewReposTime','100','OLDHOSTNAME'),('FFRewReverse','1','OLDHOSTNAME'),('ExactSeeking','0','OLDHOSTNAME'),('AutoCommercialSkip','0','OLDHOSTNAME'),('CommRewindAmount','0','OLDHOSTNAME'),('CommNotifyAmount','0','OLDHOSTNAME'),('MaximumCommercialSkip','3600',NULL),('CommSkipAllBlanks','1',NULL),('VertScanPercentage','0','OLDHOSTNAME'),('HorizScanPercentage','0','OLDHOSTNAME'),('XScanDisplacement','0','OLDHOSTNAME'),('YScanDisplacement','0','OLDHOSTNAME'),('OSDTheme','BlackCurves-OSD','OLDHOSTNAME'),('OSDGeneralTimeout','2','OLDHOSTNAME'),('OSDProgramInfoTimeout','3','OLDHOSTNAME'),('OSDNotifyTimeout','5','OLDHOSTNAME'),('OSDFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCCFont','FreeMono.ttf','OLDHOSTNAME'),('OSDThemeFontSizeType','default','OLDHOSTNAME'),('CCBackground','0','OLDHOSTNAME'),('DefaultCCMode','0','OLDHOSTNAME'),('PersistentBrowseMode','1','OLDHOSTNAME'),('EnableMHEG','0','OLDHOSTNAME'),('OSDCC708TextZoom','100','OLDHOSTNAME'),('OSDCC708DefaultFontType','MonoSerif','OLDHOSTNAME'),('OSDCC708MonoSerifFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708PropSerifFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708MonoSansSerifFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708PropSansSerifFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708CasualFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708CursiveFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708CapitalsFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708MonoSerifItalicFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708PropSerifItalicFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708MonoSansSerifItalicFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708PropSansSerifItalicFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708CasualItalicFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708CursiveItalicFont','FreeMono.ttf','OLDHOSTNAME'),('OSDCC708CapitalsItalicFont','FreeMono.ttf','OLDHOSTNAME'),('ChannelOrdering','channum','OLDHOSTNAME'),('ChannelFormat','<num> <sign>','OLDHOSTNAME'),('LongChannelFormat','<num> <name>','OLDHOSTNAME'),('SmartChannelChange','0','OLDHOSTNAME'),('LastFreeCard','0',NULL),('AutoExpireMethod','2',NULL),('AutoExpireDayPriority','3',NULL),('AutoExpireDefault','1',NULL),('AutoExpireLiveTVMaxAge','1',NULL),('AutoExpireExtraSpace','1',NULL),('AutoCommercialFlag','1',NULL),('CommercialSkipMethod','7',NULL),('AggressiveCommDetect','1',NULL),('AutoTranscode','0',NULL),('AutoRunUserJob1','0',NULL),('AutoRunUserJob2','0',NULL),('AutoRunUserJob3','0',NULL),('AutoRunUserJob4','0',NULL),('RecordPreRoll','0',NULL),('RecordOverTime','0',NULL),('OverTimeCategory','category name',NULL),('CategoryOverTime','30',NULL),('ATSCCheckSignalThreshold','65',NULL),('ATSCCheckSignalWait','5000',NULL),('HDRingbufferSize','9400',NULL),('EPGFillType','10','OLDHOSTNAME'),('EPGShowCategoryColors','1','OLDHOSTNAME'),('EPGShowCategoryText','1','OLDHOSTNAME'),('EPGScrollType','1','OLDHOSTNAME'),('EPGShowChannelIcon','1','OLDHOSTNAME'),('EPGShowFavorites','0','OLDHOSTNAME'),('WatchTVGuide','0','OLDHOSTNAME'),('chanPerPage','5','OLDHOSTNAME'),('timePerPage','4','OLDHOSTNAME'),('UnknownTitle','Unknown','OLDHOSTNAME'),('UnknownCategory','Unknown','OLDHOSTNAME'),('DefaultTVChannel','3','OLDHOSTNAME'),('SelectChangesChannel','0','OLDHOSTNAME'),('SelChangeRecThreshold','16','OLDHOSTNAME'),('EPGEnableJumpToChannel','0',NULL),('ThemePainter','qt','OLDHOSTNAME'),('Style','','OLDHOSTNAME'),('ThemeFontSizeType','default','OLDHOSTNAME'),('RandomTheme','0','OLDHOSTNAME'),('MenuTheme','default','OLDHOSTNAME'),('XineramaScreen','0','OLDHOSTNAME'),('XineramaMonitorAspectRatio','1.3333','OLDHOSTNAME'),('GuiWidth','0','OLDHOSTNAME'),('GuiHeight','0','OLDHOSTNAME'),('GuiOffsetX','0','OLDHOSTNAME'),('GuiOffsetY','0','OLDHOSTNAME'),('GuiSizeForTV','1','OLDHOSTNAME'),('HideMouseCursor','1','OLDHOSTNAME'),('RunFrontendInWindow','0','OLDHOSTNAME'),('UseVideoModes','0','OLDHOSTNAME'),('GuiVidModeResolution','640x480','OLDHOSTNAME'),('TVVidModeResolution','640x480','OLDHOSTNAME'),('TVVidModeForceAspect','0.0','OLDHOSTNAME'),('VidModeWidth0','0','OLDHOSTNAME'),('VidModeHeight0','0','OLDHOSTNAME'),('TVVidModeResolution0','640x480','OLDHOSTNAME'),('TVVidModeForceAspect0','0.0','OLDHOSTNAME'),('VidModeWidth1','0','OLDHOSTNAME'),('VidModeHeight1','0','OLDHOSTNAME'),('TVVidModeResolution1','640x480','OLDHOSTNAME'),('TVVidModeForceAspect1','0.0','OLDHOSTNAME'),('VidModeWidth2','0','OLDHOSTNAME'),('VidModeHeight2','0','OLDHOSTNAME'),('TVVidModeResolution2','640x480','OLDHOSTNAME'),('TVVidModeForceAspect2','0.0','OLDHOSTNAME'),('ISO639Language0','eng','OLDHOSTNAME'),('ISO639Language1','eng','OLDHOSTNAME'),('DateFormat','ddd MMM d','OLDHOSTNAME'),('ShortDateFormat','M/d','OLDHOSTNAME'),('TimeFormat','h:mm AP','OLDHOSTNAME'),('QtFontSmall','12','OLDHOSTNAME'),('QtFontMedium','16','OLDHOSTNAME'),('QtFontBig','25','OLDHOSTNAME'),('PlayBoxTransparency','1','OLDHOSTNAME'),('PlayBoxShading','0','OLDHOSTNAME'),('UseVirtualKeyboard','1','OLDHOSTNAME'),('LCDEnable','0','OLDHOSTNAME'),('LCDShowTime','1','OLDHOSTNAME'),('LCDShowMenu','1','OLDHOSTNAME'),('LCDShowMusic','1','OLDHOSTNAME'),('LCDShowMusicItems','ArtistTitle','OLDHOSTNAME'),('LCDShowChannel','1','OLDHOSTNAME'),('LCDShowRecStatus','0','OLDHOSTNAME'),('LCDShowVolume','1','OLDHOSTNAME'),('LCDShowGeneric','1','OLDHOSTNAME'),('LCDBacklightOn','1','OLDHOSTNAME'),('LCDHeartBeatOn','0','OLDHOSTNAME'),('LCDBigClock','0','OLDHOSTNAME'),('LCDKeyString','ABCDEF','OLDHOSTNAME'),('LCDPopupTime','5','OLDHOSTNAME'),('AudioOutputDevice','ALSA:default','OLDHOSTNAME'),('PassThruOutputDevice','Default','OLDHOSTNAME'),('AC3PassThru','0','OLDHOSTNAME'),('DTSPassThru','0','OLDHOSTNAME'),('AggressiveSoundcardBuffer','0','OLDHOSTNAME'),('MythControlsVolume','1','OLDHOSTNAME'),('MixerDevice','default','OLDHOSTNAME'),('MixerControl','PCM','OLDHOSTNAME'),('MasterMixerVolume','70','OLDHOSTNAME'),('PCMMixerVolume','70','OLDHOSTNAME'),('IndividualMuteControl','0','OLDHOSTNAME'),('AllowQuitShutdown','4','OLDHOSTNAME'),('NoPromptOnExit','1','OLDHOSTNAME'),('HaltCommand','','OLDHOSTNAME'),('LircKeyPressedApp','','OLDHOSTNAME'),('UseArrowAccels','1','OLDHOSTNAME'),('NetworkControlEnabled','0','OLDHOSTNAME'),('NetworkControlPort','6546','OLDHOSTNAME'),('SetupPinCodeRequired','0','OLDHOSTNAME'),('MonitorDrives','0','OLDHOSTNAME'),('EnableXbox','0','OLDHOSTNAME'),('LogEnabled','0',NULL),('LogPrintLevel','8','OLDHOSTNAME'),('LogCleanEnabled','0','OLDHOSTNAME'),('LogCleanPeriod','14','OLDHOSTNAME'),('LogCleanDays','14','OLDHOSTNAME'),('LogCleanMax','30','OLDHOSTNAME'),('LogMaxCount','100','OLDHOSTNAME'),('MythFillEnabled','0',NULL),('MythFillDatabasePath','/usr/bin/mythfilldatabase',NULL),('MythFillDatabaseArgs','',NULL),('MythFillDatabaseLog','',NULL),('MythFillPeriod','1',NULL),('MythFillMinHour','2',NULL),('MythFillMaxHour','5',NULL),('SchedMoveHigher','1',NULL),('DefaultStartOffset','0',NULL),('DefaultEndOffset','0',NULL),('ComplexPriority','0',NULL),('PrefInputPriority','2',NULL),('OnceRecPriority','0',NULL),('HDTVRecPriority','0',NULL),('CCRecPriority','0',NULL),('SingleRecordRecPriority','1',NULL),('OverrideRecordRecPriority','0',NULL),('FindOneRecordRecPriority','-1',NULL),('WeekslotRecordRecPriority','0',NULL),('TimeslotRecordRecPriority','0',NULL),('ChannelRecordRecPriority','0',NULL),('AllRecordRecPriority','0',NULL),('ArchiveDBSchemaVer','1005',NULL),('MythArchiveTempDir','/var/lib/mytharchive/temp','OLDHOSTNAME'),('MythArchiveShareDir','/usr/share/mythtv/mytharchive/','OLDHOSTNAME'),('MythArchiveVideoFormat','PAL','OLDHOSTNAME'),('MythArchiveFileFilter','*.mpg *.mov *.avi *.mpeg *.nuv','OLDHOSTNAME'),('MythArchiveDVDLocation','/dev/dvd','OLDHOSTNAME'),('MythArchiveEncodeToAc3','0','OLDHOSTNAME'),('MythArchiveCopyRemoteFiles','0','OLDHOSTNAME'),('MythArchiveAlwaysUseMythTranscode','1','OLDHOSTNAME'),('MythArchiveUseFIFO','1','OLDHOSTNAME'),('MythArchiveMainMenuAR','16:9','OLDHOSTNAME'),('MythArchiveChapterMenuAR','Video','OLDHOSTNAME'),('MythArchiveDateFormat','%a  %b  %d','OLDHOSTNAME'),('MythArchiveTimeFormat','%I:%M %p','OLDHOSTNAME'),('MythArchiveFfmpegCmd','ffmpeg','OLDHOSTNAME'),('MythArchiveMplexCmd','mplex','OLDHOSTNAME'),('MythArchiveDvdauthorCmd','dvdauthor','OLDHOSTNAME'),('MythArchiveSpumuxCmd','spumux','OLDHOSTNAME'),('MythArchiveMpeg2encCmd','mpeg2enc','OLDHOSTNAME'),('MythArchiveMkisofsCmd','mkisofs','OLDHOSTNAME'),('MythArchiveGrowisofsCmd','growisofs','OLDHOSTNAME'),('MythArchiveTcrequantCmd','tcrequant','OLDHOSTNAME'),('MythArchivePng2yuvCmd','png2yuv','OLDHOSTNAME'),('mythvideo.DBSchemaVer','1032',NULL),('DVDDeviceLocation','/dev/dvd','OLDHOSTNAME'),('VCDDeviceLocation','/dev/cdrom','OLDHOSTNAME'),('DVDOnInsertDVD','1','OLDHOSTNAME'),('mythdvd.DVDPlayerCommand','Internal','OLDHOSTNAME'),('VCDPlayerCommand','mplayer vcd:// -cdrom-device %d -fs -zoom -vo xv','OLDHOSTNAME'),('DVDRipLocation','/var/lib/mythdvd/temp','OLDHOSTNAME'),('TitlePlayCommand','Internal','OLDHOSTNAME'),('SubTitleCommand','-sid %s','OLDHOSTNAME'),('TranscodeCommand','transcode','OLDHOSTNAME'),('MTDPort','2442','OLDHOSTNAME'),('MTDNiceLevel','20','OLDHOSTNAME'),('MTDConcurrentTranscodes','1','OLDHOSTNAME'),('MTDRipSize','0','OLDHOSTNAME'),('MTDLogFlag','0','OLDHOSTNAME'),('MTDac3Flag','0','OLDHOSTNAME'),('MTDxvidFlag','1','OLDHOSTNAME'),('mythvideo.TrustTranscodeFRDetect','1','OLDHOSTNAME'),('GalleryDBSchemaVer','1003',NULL),('GalleryDir','/var/lib/mythtv/pictures','OLDHOSTNAME'),('GalleryThumbnailLocation','1','OLDHOSTNAME'),('GallerySortOrder','20','OLDHOSTNAME'),('GalleryImportDirs','/media/cdrom:/media/usbdisk','OLDHOSTNAME'),('GalleryMoviePlayerCmd','Internal','OLDHOSTNAME'),('SlideshowOpenGLTransition','none','OLDHOSTNAME'),('SlideshowOpenGLTransitionLength','2000','OLDHOSTNAME'),('GalleryOverlayCaption','0','OLDHOSTNAME'),('SlideshowTransition','none','OLDHOSTNAME'),('SlideshowBackground','','OLDHOSTNAME'),('SlideshowDelay','5','OLDHOSTNAME'),('GameDBSchemaVer','1016',NULL),('MusicDBSchemaVer','1017',NULL),('MusicLocation','/var/lib/mythtv/music/','OLDHOSTNAME'),('MusicAudioDevice','default','OLDHOSTNAME'),('CDDevice','/dev/cdrom','OLDHOSTNAME'),('TreeLevels','splitartist artist album title','OLDHOSTNAME'),('NonID3FileNameFormat','GENRE/ARTIST/ALBUM/TRACK_TITLE','OLDHOSTNAME'),('Ignore_ID3','0','OLDHOSTNAME'),('AutoLookupCD','1','OLDHOSTNAME'),('AutoPlayCD','0','OLDHOSTNAME'),('KeyboardAccelerators','1','OLDHOSTNAME'),('CDWriterEnabled','1','OLDHOSTNAME'),('CDDiskSize','1','OLDHOSTNAME'),('CDCreateDir','1','OLDHOSTNAME'),('CDWriteSpeed','0','OLDHOSTNAME'),('CDBlankType','fast','OLDHOSTNAME'),('PlayMode','Normal','OLDHOSTNAME'),('IntelliRatingWeight','35','OLDHOSTNAME'),('IntelliPlayCountWeight','25','OLDHOSTNAME'),('IntelliLastPlayWeight','25','OLDHOSTNAME'),('IntelliRandomWeight','15','OLDHOSTNAME'),('MusicShowRatings','0','OLDHOSTNAME'),('ShowWholeTree','0','OLDHOSTNAME'),('ListAsShuffled','0','OLDHOSTNAME'),('VisualMode','Random','OLDHOSTNAME'),('VisualCycleOnSongChange','0','OLDHOSTNAME'),('VisualModeDelay','0','OLDHOSTNAME'),('VisualScaleWidth','1','OLDHOSTNAME'),('VisualScaleHeight','1','OLDHOSTNAME'),('ParanoiaLevel','Full','OLDHOSTNAME'),('FilenameTemplate','ARTIST/ALBUM/TRACK-TITLE','OLDHOSTNAME'),('TagSeparator',' - ','OLDHOSTNAME'),('NoWhitespace','0','OLDHOSTNAME'),('PostCDRipScript','','OLDHOSTNAME'),('EjectCDAfterRipping','1','OLDHOSTNAME'),('OnlyImportNewMusic','0','OLDHOSTNAME'),('EncoderType','ogg','OLDHOSTNAME'),('DefaultRipQuality','0','OLDHOSTNAME'),('Mp3UseVBR','0','OLDHOSTNAME'),('PhoneDBSchemaVer','1001',NULL),('SipRegisterWithProxy','1','OLDHOSTNAME'),('SipProxyName','fwd.pulver.com','OLDHOSTNAME'),('SipProxyAuthName','','OLDHOSTNAME'),('SipProxyAuthPassword','','OLDHOSTNAME'),('MySipName','Me','OLDHOSTNAME'),('SipAutoanswer','0','OLDHOSTNAME'),('SipBindInterface','eth0','OLDHOSTNAME'),('SipLocalPort','5060','OLDHOSTNAME'),('NatTraversalMethod','None','OLDHOSTNAME'),('NatIpAddress','http://checkip.dyndns.org','OLDHOSTNAME'),('AudioLocalPort','21232','OLDHOSTNAME'),('VideoLocalPort','21234','OLDHOSTNAME'),('MicrophoneDevice','None','OLDHOSTNAME'),('CodecPriorityList','GSM;G.711u;G.711a','OLDHOSTNAME'),('PlayoutAudioCall','40','OLDHOSTNAME'),('PlayoutVideoCall','110','OLDHOSTNAME'),('TxResolution','176x144','OLDHOSTNAME'),('TransmitFPS','5','OLDHOSTNAME'),('TransmitBandwidth','256','OLDHOSTNAME'),('CaptureResolution','352x288','OLDHOSTNAME'),('TimeToAnswer','10','OLDHOSTNAME'),('DefaultVxmlUrl','http://127.0.0.1/vxml/index.vxml','OLDHOSTNAME'),('DefaultVoicemailPrompt','I am not at home, please leave a message after the tone','OLDHOSTNAME'),('VideoStartupDir','/var/lib/mythtv/videos','OLDHOSTNAME'),('VideoArtworkDir','/var/lib/mythtv/coverart','OLDHOSTNAME'),('VideoDefaultParentalLevel','4','OLDHOSTNAME'),('VideoAggressivePC','0','OLDHOSTNAME'),('Default MythVideo View','2','OLDHOSTNAME'),('VideoListUnknownFiletypes','1','OLDHOSTNAME'),('VideoBrowserNoDB','0','OLDHOSTNAME'),('VideoGalleryNoDB','0','OLDHOSTNAME'),('VideoTreeNoDB','0','OLDHOSTNAME'),('VideoTreeLoadMetaData','1','OLDHOSTNAME'),('VideoNewBrowsable','1','OLDHOSTNAME'),('mythvideo.sort_ignores_case','1','OLDHOSTNAME'),('mythvideo.db_folder_view','1','OLDHOSTNAME'),('mythvideo.ImageCacheSize','50','OLDHOSTNAME'),('AutomaticSetWatched','0','OLDHOSTNAME'),('AlwaysStreamFiles','0','OLDHOSTNAME'),('DefaultVideoPlaybackProfile','CPU+','OLDHOSTNAME'),('JumpToProgramOSD','1','OLDHOSTNAME'),('ContinueEmbeddedTVPlay','0','OLDHOSTNAME'),('VideoGalleryColsPerPage','4','OLDHOSTNAME'),('VideoGalleryRowsPerPage','3','OLDHOSTNAME'),('VideoGallerySubtitle','1','OLDHOSTNAME'),('VideoGalleryAspectRatio','1','OLDHOSTNAME'),('VideoDefaultPlayer','Internal','OLDHOSTNAME'),('MythFillFixProgramIDsHasRunOnce','1','OLDHOSTNAME'),('DisplayGroupDefaultViewMask','32777','OLDHOSTNAME'),('SecurityPin','0000','OLDHOSTNAME'),('MiscStatusScript','','OLDHOSTNAME'),('DisableFirewireReset','0','OLDHOSTNAME'),('Theme','Mythbuntu','localhost'),('Theme','Mythbuntu','OLDHOSTNAME'),('MythFillFixProgramIDsHasRunOnce','1','OLDHOSTNAME'),('BackupDBLastRunStart','2010-02-18 01:25:04',NULL),('BackupDBLastRunEnd','2010-02-18 01:25:06',NULL),('Language','EN_US','OLDHOSTNAME'),('BackendServerIP','127.0.0.1','OLDHOSTNAME'),('BackendServerPort','6543','OLDHOSTNAME'),('BackendStatusPort','6544','OLDHOSTNAME'),('SecurityPin','','OLDHOSTNAME'),('TruncateDeletesSlowly','0','OLDHOSTNAME'),('MiscStatusScript','','OLDHOSTNAME'),('DisableFirewireReset','0','OLDHOSTNAME'),('JobQueueMaxSimultaneousJobs','1','OLDHOSTNAME'),('JobQueueCheckFrequency','60','OLDHOSTNAME'),('JobQueueWindowStart','00:00','OLDHOSTNAME'),('JobQueueWindowEnd','23:59','OLDHOSTNAME'),('JobQueueCPU','0','OLDHOSTNAME'),('JobAllowCommFlag','1','OLDHOSTNAME'),('JobAllowTranscode','1','OLDHOSTNAME'),('JobAllowUserJob1','0','OLDHOSTNAME'),('JobAllowUserJob2','0','OLDHOSTNAME'),('JobAllowUserJob3','0','OLDHOSTNAME'),('JobAllowUserJob4','0','OLDHOSTNAME'),('StorageScheduler','Combination',NULL),('AdjustFill','6','OLDHOSTNAME'),('LetterboxColour','0','OLDHOSTNAME'),('GeneratePreviewRemotely','0','OLDHOSTNAME'),('HWAccelPlaybackPreview','0','OLDHOSTNAME'),('PlaybackWatchList','1','OLDHOSTNAME'),('PlaybackWLStart','0','OLDHOSTNAME'),('PlaybackWLAutoExpire','0','OLDHOSTNAME'),('PlaybackWLMaxAge','60','OLDHOSTNAME'),('PlaybackWLBlackOut','2','OLDHOSTNAME'),('BrowseAllTuners','0','OLDHOSTNAME'),('Prefer708Captions','1','OLDHOSTNAME'),('SubtitleCodec','UTF-8','OLDHOSTNAME'),('LiveTVPriority','0',NULL),('RerecordWatched','1',NULL),('AutoExpireWatchedPriority','0',NULL),('AutoExpireInsteadOfDelete','0',NULL),('DeletedFifoOrder','0',NULL),('ChannelGroupRememberLast','0','OLDHOSTNAME'),('ChannelGroupDefault','-1','OLDHOSTNAME'),('BrowseChannelGroup','0','OLDHOSTNAME'),('ThemeCacheSize','1','OLDHOSTNAME'),('UseFixedWindowSize','1','OLDHOSTNAME'),('TVVidModeRefreshRate','60.000','OLDHOSTNAME'),('TVVidModeRefreshRate0','60.000','OLDHOSTNAME'),('TVVidModeRefreshRate1','60.000','OLDHOSTNAME'),('TVVidModeRefreshRate2','60.000','OLDHOSTNAME'),('MaxChannels','2','OLDHOSTNAME'),('AudioUpmixType','0','OLDHOSTNAME'),('ScreenShotPath','/tmp/','OLDHOSTNAME'),('MediaChangeEvents','0','OLDHOSTNAME'),('OverrideExitMenu','0','OLDHOSTNAME'),('RebootCommand','','OLDHOSTNAME'),('LircSocket','/dev/lircd','OLDHOSTNAME'),('SchedOpenEnd','0',NULL),('MythArchiveDVDPlayerCmd','Internal','OLDHOSTNAME'),('MythArchiveUseProjectX','0','OLDHOSTNAME'),('MythArchiveAddSubtitles','0','OLDHOSTNAME'),('MythArchiveDefaultEncProfile','SP','OLDHOSTNAME'),('MythArchiveJpeg2yuvCmd','jpeg2yuv','OLDHOSTNAME'),('MythArchiveProjectXCmd','projectx','OLDHOSTNAME'),('SlideshowUseOpenGL','0','OLDHOSTNAME'),('MythMovies.LastGrabDate','','OLDHOSTNAME'),('MythMovies.DatabaseVersion','4','OLDHOSTNAME'),('ArtistTreeGroups','0','OLDHOSTNAME'),('MusicTagEncoding','utf16','OLDHOSTNAME'),('CDWriterDevice','default','OLDHOSTNAME'),('ResumeMode','off','OLDHOSTNAME'),('MusicExitAction','prompt','OLDHOSTNAME'),('MaxSearchResults','300','OLDHOSTNAME'),('VisualAlbumArtOnSongChange','0','OLDHOSTNAME'),('VisualRandomize','0','OLDHOSTNAME'),('mythvideo.screenshotDir','/var/lib/mythtv/screenshots','OLDHOSTNAME'),('mythvideo.bannerDir','/var/lib/mythtv/banners','OLDHOSTNAME'),('mythvideo.fanartDir','/var/lib/mythtv/fanart','OLDHOSTNAME'),('mythvideo.db_group_view','1','OLDHOSTNAME'),('mythvideo.VideoTreeRemember','0','OLDHOSTNAME'),('mythvideo.db_group_type','0','OLDHOSTNAME'),('DVDDriveSpeed','12','OLDHOSTNAME'),('EnableDVDBookmark','0','OLDHOSTNAME'),('DVDBookmarkPrompt','0','OLDHOSTNAME'),('DVDBookmarkDays','10','OLDHOSTNAME'),('MovieListCommandLine','/usr/share/mythtv/mythvideo/scripts/tmdb.pl -M','OLDHOSTNAME'),('MoviePosterCommandLine','/usr/share/mythtv/mythvideo/scripts/tmdb.pl -P','OLDHOSTNAME'),('MovieFanartCommandLine','/usr/share/mythtv/mythvideo/scripts/tmdb.pl -B','OLDHOSTNAME'),('MovieDataCommandLine','/usr/share/mythtv/mythvideo/scripts/tmdb.pl -D','OLDHOSTNAME'),('mythvideo.ParentalLevelFromRating','0','OLDHOSTNAME'),('mythvideo.AutoR2PL1','G','OLDHOSTNAME'),('mythvideo.AutoR2PL2','PG','OLDHOSTNAME'),('mythvideo.AutoR2PL3','PG-13','OLDHOSTNAME'),('mythvideo.AutoR2PL4','R:NC-17','OLDHOSTNAME'),('mythvideo.TrailersDir','/home/test/.mythtv/MythVideo/Trailers','OLDHOSTNAME'),('mythvideo.TrailersRandomEnabled','0','OLDHOSTNAME'),('mythvideo.TrailersRandomCount','3','OLDHOSTNAME'),('mythvideo.TVListCommandLine','/usr/share/mythtv/mythvideo/scripts/ttvdb.py -M','OLDHOSTNAME'),('mythvideo.TVPosterCommandLine','/usr/share/mythtv/mythvideo/scripts/ttvdb.py -mP','OLDHOSTNAME'),('mythvideo.TVFanartCommandLine','/usr/share/mythtv/mythvideo/scripts/ttvdb.py -tF','OLDHOSTNAME'),('mythvideo.TVBannerCommandLine','/usr/share/mythtv/mythvideo/scripts/ttvdb.py -tB','OLDHOSTNAME'),('mythvideo.TVDataCommandLine','/usr/share/mythtv/mythvideo/scripts/ttvdb.py -D','OLDHOSTNAME'),('mythvideo.TVTitleSubCommandLine','/usr/share/mythtv/mythvideo/scripts/ttvdb.py -N','OLDHOSTNAME'),('mythvideo.TVScreenshotCommandLine','/usr/share/mythtv/mythvideo/scripts/ttvdb.py -S','OLDHOSTNAME'),('mythvideo.EnableAlternatePlayer','0','OLDHOSTNAME'),('mythvideo.VideoAlternatePlayer','Internal','OLDHOSTNAME'),('WeatherDBSchemaVer','1004',NULL),('DisableAutomaticBackup','0',NULL),('BackendStopCommand','killall mythbackend',NULL),('BackendStartCommand','mythbackend',NULL),('UPnP/WMPSource','0',NULL),('UPnP/RebuildDelay','30','OLDHOSTNAME'),('AudioDefaultUpmix','1','OLDHOSTNAME'),('AdvancedAudioSettings','0','OLDHOSTNAME'),('SRCQualityOverride','0','OLDHOSTNAME'),('SRCQuality','1','OLDHOSTNAME'),('BrowserDBSchemaVer','1002',NULL),('WebBrowserCommand','Internal','OLDHOSTNAME'),('WebBrowserZoomLevel','1.4','OLDHOSTNAME'),('NetvisionDBSchemaVer','1004',NULL),('NewsDBSchemaVer','1001',NULL),('MusicDefaultUpmix','0','OLDHOSTNAME');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `storagegroup`
--

DROP TABLE IF EXISTS `storagegroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `storagegroup` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `groupname` varchar(32) NOT NULL,
  `hostname` varchar(64) NOT NULL DEFAULT '',
  `dirname` varchar(235) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `grouphostdir` (`groupname`,`hostname`,`dirname`),
  KEY `hostname` (`hostname`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `storagegroup`
--

LOCK TABLES `storagegroup` WRITE;
/*!40000 ALTER TABLE `storagegroup` DISABLE KEYS */;
INSERT INTO `storagegroup` VALUES (1,'Default','OLDHOSTNAME','/var/lib/mythtv/recordings'),(2,'Videos','OLDHOSTNAME','/var/lib/mythtv/videos/'),(3,'Fanart','OLDHOSTNAME','/var/lib/mythtv/fanart/'),(4,'Trailers','OLDHOSTNAME','/var/lib/mythtv/trailers/'),(5,'Coverart','OLDHOSTNAME','/var/lib/mythtv/coverart/'),(7,'Screenshots','OLDHOSTNAME','/var/lib/mythtv/screenshots/'),(8,'Banners','OLDHOSTNAME','/var/lib/mythtv/banners/'),(9,'DB Backups','OLDHOSTNAME','/var/lib/mythtv/db_backups/'),(10,'LiveTV','OLDHOSTNAME','/var/lib/mythtv/livetv/');
/*!40000 ALTER TABLE `storagegroup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tvchain`
--

DROP TABLE IF EXISTS `tvchain`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tvchain` (
  `chanid` int(10) unsigned NOT NULL DEFAULT '0',
  `starttime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `chainid` varchar(128) NOT NULL DEFAULT '',
  `chainpos` int(10) NOT NULL DEFAULT '0',
  `discontinuity` tinyint(1) NOT NULL DEFAULT '0',
  `watching` int(10) NOT NULL DEFAULT '0',
  `hostprefix` varchar(128) NOT NULL DEFAULT '',
  `cardtype` varchar(32) NOT NULL DEFAULT 'V4L',
  `input` varchar(32) NOT NULL DEFAULT '',
  `channame` varchar(32) NOT NULL DEFAULT '',
  `endtime` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`chanid`,`starttime`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tvchain`
--

LOCK TABLES `tvchain` WRITE;
/*!40000 ALTER TABLE `tvchain` DISABLE KEYS */;
/*!40000 ALTER TABLE `tvchain` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tvosdmenu`
--

DROP TABLE IF EXISTS `tvosdmenu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tvosdmenu` (
  `osdcategory` varchar(32) NOT NULL,
  `livetv` tinyint(4) NOT NULL DEFAULT '0',
  `recorded` tinyint(4) NOT NULL DEFAULT '0',
  `video` tinyint(4) NOT NULL DEFAULT '0',
  `dvd` tinyint(4) NOT NULL DEFAULT '0',
  `description` varchar(32) NOT NULL,
  PRIMARY KEY (`osdcategory`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tvosdmenu`
--

LOCK TABLES `tvosdmenu` WRITE;
/*!40000 ALTER TABLE `tvosdmenu` DISABLE KEYS */;
/*!40000 ALTER TABLE `tvosdmenu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `upnpmedia`
--

DROP TABLE IF EXISTS `upnpmedia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `upnpmedia` (
  `intid` int(10) unsigned NOT NULL DEFAULT '0',
  `class` varchar(64) NOT NULL DEFAULT '',
  `itemtype` varchar(128) NOT NULL DEFAULT '',
  `parentid` int(10) unsigned NOT NULL DEFAULT '0',
  `itemproperties` varchar(255) NOT NULL DEFAULT '',
  `filepath` varchar(512) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL DEFAULT '',
  `filename` varchar(512) NOT NULL DEFAULT '',
  `coverart` varchar(512) NOT NULL DEFAULT '',
  PRIMARY KEY (`intid`),
  KEY `class` (`class`),
  KEY `filepath` (`filepath`(333)),
  KEY `parentid` (`parentid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `upnpmedia`
--

LOCK TABLES `upnpmedia` WRITE;
/*!40000 ALTER TABLE `upnpmedia` DISABLE KEYS */;
/*!40000 ALTER TABLE `upnpmedia` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `videocast`
--

DROP TABLE IF EXISTS `videocast`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `videocast` (
  `intid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `cast` varchar(128) NOT NULL,
  PRIMARY KEY (`intid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `videocast`
--

LOCK TABLES `videocast` WRITE;
/*!40000 ALTER TABLE `videocast` DISABLE KEYS */;
/*!40000 ALTER TABLE `videocast` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `videocategory`
--

DROP TABLE IF EXISTS `videocategory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `videocategory` (
  `intid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `category` varchar(128) NOT NULL,
  PRIMARY KEY (`intid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `videocountry` (
  `intid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `country` varchar(128) NOT NULL,
  PRIMARY KEY (`intid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `videogenre` (
  `intid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `genre` varchar(128) NOT NULL,
  PRIMARY KEY (`intid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `videometadata` (
  `intid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL,
  `subtitle` text NOT NULL,
  `director` varchar(128) NOT NULL,
  `plot` text,
  `rating` varchar(128) NOT NULL,
  `inetref` varchar(255) NOT NULL,
  `homepage` text NOT NULL,
  `year` int(10) unsigned NOT NULL,
  `releasedate` date NOT NULL,
  `userrating` float NOT NULL,
  `length` int(10) unsigned NOT NULL,
  `season` smallint(5) unsigned NOT NULL DEFAULT '0',
  `episode` smallint(5) unsigned NOT NULL DEFAULT '0',
  `showlevel` int(10) unsigned NOT NULL,
  `filename` text NOT NULL,
  `hash` varchar(128) NOT NULL,
  `coverfile` text NOT NULL,
  `childid` int(11) NOT NULL DEFAULT '-1',
  `browse` tinyint(1) NOT NULL DEFAULT '1',
  `watched` tinyint(1) NOT NULL DEFAULT '0',
  `playcommand` varchar(255) DEFAULT NULL,
  `category` int(10) unsigned NOT NULL DEFAULT '0',
  `trailer` text,
  `host` text NOT NULL,
  `screenshot` text,
  `banner` text,
  `fanart` text,
  `insertdate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`intid`),
  KEY `director` (`director`),
  KEY `title` (`title`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `videometadata`
--

LOCK TABLES `videometadata` WRITE;
/*!40000 ALTER TABLE `videometadata` DISABLE KEYS */;
/*!40000 ALTER TABLE `videometadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `videometadatacast`
--

DROP TABLE IF EXISTS `videometadatacast`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `videometadatacast` (
  `idvideo` int(10) unsigned NOT NULL,
  `idcast` int(10) unsigned NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `videometadatacast`
--

LOCK TABLES `videometadatacast` WRITE;
/*!40000 ALTER TABLE `videometadatacast` DISABLE KEYS */;
/*!40000 ALTER TABLE `videometadatacast` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `videometadatacountry`
--

DROP TABLE IF EXISTS `videometadatacountry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `videometadatacountry` (
  `idvideo` int(10) unsigned NOT NULL,
  `idcountry` int(10) unsigned NOT NULL,
  KEY `idvideo` (`idvideo`),
  KEY `idcountry` (`idcountry`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `videometadatagenre` (
  `idvideo` int(10) unsigned NOT NULL,
  `idgenre` int(10) unsigned NOT NULL,
  KEY `idvideo` (`idvideo`),
  KEY `idgenre` (`idgenre`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `videosource` (
  `sourceid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL DEFAULT '',
  `xmltvgrabber` varchar(128) DEFAULT NULL,
  `userid` varchar(128) NOT NULL DEFAULT '',
  `freqtable` varchar(16) NOT NULL DEFAULT 'default',
  `lineupid` varchar(64) DEFAULT NULL,
  `password` varchar(64) DEFAULT NULL,
  `useeit` smallint(6) NOT NULL DEFAULT '0',
  `configpath` varchar(4096) DEFAULT NULL,
  `dvb_nit_id` int(6) DEFAULT '-1',
  PRIMARY KEY (`sourceid`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

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
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `videotypes` (
  `intid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `extension` varchar(128) NOT NULL,
  `playcommand` varchar(255) NOT NULL,
  `f_ignore` tinyint(1) DEFAULT NULL,
  `use_default` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`intid`)
) ENGINE=MyISAM AUTO_INCREMENT=23 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `videotypes`
--

LOCK TABLES `videotypes` WRITE;
/*!40000 ALTER TABLE `videotypes` DISABLE KEYS */;
INSERT INTO `videotypes` VALUES (1,'txt','',1,0),(2,'log','',1,0),(3,'mpg','Internal',0,0),(4,'avi','',0,1),(5,'vob','Internal',0,0),(6,'mpeg','Internal',0,0),(7,'VIDEO_TS','Internal',0,0),(8,'iso','Internal',0,0),(9,'img','Internal',0,0),(10,'mkv','Internal',0,0),(11,'mp4','Internal',0,0),(12,'m2ts','Internal',0,0),(13,'evo','Internal',0,0),(14,'divx','Internal',0,0),(15,'mov','Internal',0,0),(16,'qt','Internal',0,0),(17,'wmv','Internal',0,0),(18,'3gp','Internal',0,0),(19,'asf','Internal',0,0),(20,'ogg','Internal',0,0),(21,'ogm','Internal',0,0),(22,'flv','Internal',0,0);
/*!40000 ALTER TABLE `videotypes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `weatherdatalayout`
--

DROP TABLE IF EXISTS `weatherdatalayout`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `weatherdatalayout` (
  `location` varchar(64) NOT NULL,
  `dataitem` varchar(64) NOT NULL,
  `weatherscreens_screen_id` int(10) unsigned NOT NULL,
  `weathersourcesettings_sourceid` int(10) unsigned NOT NULL,
  PRIMARY KEY (`location`,`dataitem`,`weatherscreens_screen_id`,`weathersourcesettings_sourceid`),
  KEY `weatherdatalayout_FKIndex1` (`weatherscreens_screen_id`),
  KEY `weatherdatalayout_FKIndex2` (`weathersourcesettings_sourceid`),
  CONSTRAINT `weatherdatalayout_ibfk_1` FOREIGN KEY (`weatherscreens_screen_id`) REFERENCES `weatherscreens` (`screen_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `weatherdatalayout_ibfk_2` FOREIGN KEY (`weathersourcesettings_sourceid`) REFERENCES `weathersourcesettings` (`sourceid`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `weatherdatalayout`
--

LOCK TABLES `weatherdatalayout` WRITE;
/*!40000 ALTER TABLE `weatherdatalayout` DISABLE KEYS */;
/*!40000 ALTER TABLE `weatherdatalayout` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `weatherscreens`
--

DROP TABLE IF EXISTS `weatherscreens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `weatherscreens` (
  `screen_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `draworder` int(10) unsigned NOT NULL,
  `container` varchar(64) NOT NULL,
  `hostname` varchar(64) DEFAULT NULL,
  `units` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`screen_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `weatherscreens`
--

LOCK TABLES `weatherscreens` WRITE;
/*!40000 ALTER TABLE `weatherscreens` DISABLE KEYS */;
/*!40000 ALTER TABLE `weatherscreens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `weathersourcesettings`
--

DROP TABLE IF EXISTS `weathersourcesettings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `weathersourcesettings` (
  `sourceid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `source_name` varchar(64) NOT NULL,
  `update_timeout` int(10) unsigned NOT NULL DEFAULT '600',
  `retrieve_timeout` int(10) unsigned NOT NULL DEFAULT '60',
  `hostname` varchar(64) DEFAULT NULL,
  `path` varchar(255) DEFAULT NULL,
  `author` varchar(128) DEFAULT NULL,
  `version` varchar(32) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `types` mediumtext,
  `updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`sourceid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `weathersourcesettings`
--

LOCK TABLES `weathersourcesettings` WRITE;
/*!40000 ALTER TABLE `weathersourcesettings` DISABLE KEYS */;
/*!40000 ALTER TABLE `weathersourcesettings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `websites`
--

DROP TABLE IF EXISTS `websites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `websites` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `category` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `url` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `websites`
--

LOCK TABLES `websites` WRITE;
/*!40000 ALTER TABLE `websites` DISABLE KEYS */;
/*!40000 ALTER TABLE `websites` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2010-02-18  1:32:39
