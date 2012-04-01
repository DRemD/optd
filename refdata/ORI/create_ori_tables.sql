--
-- ORI-maintained list of POR (points of reference, i.e., airports, cities,
-- places, etc.)
-- See https://github.com/opentraveldata/optd/tree/trunk/refdata/ORI
--

set @saved_cs_client     = @@character_set_client;
set character_set_client = utf8;

--
-- Note: the index is created in a separate file, namely create_ori_indexes.sql
--
--
-- ORI-related part:
-- -----------------
-- is_geonames       : Whether that POR is known by Geonames; varchar(1)
-- is_airport        : Whether that POR is an airport; varchar(1)
-- is_commercial     : Whether that POR is open to commerce; varchar(1)
-- city_code         : Code of the city related to the POR; varchar(3)
-- state_code        : Code of the state related to the POR; varchar(3)
-- region_code       : Code of the region related to the POR; varchar(5)
-- location_type     : Type of the POR; varchar(4)
--
--
-- Geonames-related part:
-- ----------------------
-- iata_code         : IATA code; varchar(3)
-- icao_code         : ICAO code; varchar(4)
-- geonameid         : Integer ID of record in geonames database
-- name              : Name of geographical point
--                     (UTF8) varchar(200)
-- asciiname         : Name of geographical point in plain ascii characters
--                     (ASCII) varchar(200)
-- alternatenames    : Alternate names, comma separated
--                     varchar(5000)
-- latitude          : Latitude in decimal degrees (wgs84)
-- longitude         : Longitude in decimal degrees (wgs84)
-- feature class     : See http://www.geonames.org/export/codes.html
--                     char(1)
-- feature code      : See http://www.geonames.org/export/codes.html
--                     varchar(10)
-- country code      : ISO-3166 2-letter country code, 2 characters
-- cc2               : Alternate country codes, comma separated, ISO-3166
--                     2-letter country code, 60 characters
-- admin1 code       : FIPS code (subject to change to ISO code), see exceptions
--                     below. See file admin1Codes.txt for display names of
--                     this code; varchar(20)
-- admin2 code       : Code for the second administrative division, a county
--                     in the US. See file admin2Codes.txt; varchar(80)
-- admin3 code       : Code for third level administrative division
--                     varchar(20)
-- admin4 code       : Code for fourth level administrative division
--                     varchar(20)
-- population        : bigint (8 byte int) 
-- elevation         : In meters, integer
-- dem               : Digital elevation model, srtm3 or gtopo30, average
--                     elevation of 3''x3'' (ca 90mx90m) or 30''x30''
--                     (ca 900mx900m) area in meters, integer.
--                     srtm processed by cgiar/ciat.
-- timezone          : The time-zone ID (see file timeZone.txt)
-- gmt offset        : GMT offset on 1st of January
-- dst offset        : DST offset to GMT on 1st of July (of the current year)
-- raw offset        : Raw Offset without DST
-- modification date : Date of last modification in yyyy-MM-dd format
--
-- ORI-related part:
-- -----------------
--
-- is airport        : Whether or not that POR is an airport
-- is commercial     : Whether or not that POR hosts commercial activities
-- city code         : The IATA code of the related city, when knwon
-- state code        : The ISO code of the related state
-- region code       : The code of the related region (see below)
-- continent code    : The code of the related continent (ITC1, ITC2 or ITC3)
-- location type     : A/APT airport; B/BUS bus/coach station; C/CITY City;
--                     G/GRD ground transport (this code is used for SK in
--                     Sweden only); H/HELI Heliport;
--                     O/OFF-PT off-line point, i.e. a city without an airport;
--                     R/RAIL railway Station; S/ASSOC a location without its
--                     own IATA code, but attached to an IATA location.
--
-- Regions:
-- --------
-- AFRIC / AF        : Africa (geonameId=6255146)
-- ASIA  / AS        : Asia (geonameId=6255147)
-- ATLAN             : Atlantic
-- AUSTL             : Australia
-- CAMER             : Central America
-- CARIB             : Carribean
-- EEURO             : Eastern Europe
-- EURAS             : Euras
-- EUROP / EU        : Europe (geonameId=6255148)
-- IOCEA             :
-- MEAST             : Middle-East
-- NAMER / NA        : North America (geonameId=6255149)
-- NONE              : Non real POR
-- PACIF             : Pacific
-- SAMER / SA        : South America (geonameId=6255150)
-- SEASI             : South East
--       / OC        : Oceania (geonameId=6255151)
--       / AN        : Antarctica (geonameId=6255152)
--
-- Samples:
-- CDG^LFPG^6269554^Paris - Charles-de-Gaulle^Paris - Charles-de-Gaulle^49.0127800^2.5500000^FR^AIRP^0^Europe/Paris^1.0^2.0^1.0^CDG,LFPG,Paris - Charles de Gaulle,París - Charles de Gaulle,Roissy Charles de Gaulle
-- PAR^ZZZZ^2988507^Paris^Paris^48.8534100^2.3488000^FR^PPLC^2138551^Europe/Paris^1.0^2.0^1.0^Lungsod ng Paris,Lutece,Lutetia Parisorum,PAR,Pa-ri,Paarys,Paname,Pantruche,Paraeis,Paras,Pari,Paries,Pariggi,Parigi,Pariis,Pariisi,Parijs,Paris,Paris - Paris,Parisi,Pariz,Parize,Parizh,Parizo,Parizs,Parys,Paryz,Paryzh,Paryzius,Paryż,Paryžius,Paräis,París,París - Paris,Paríž,Parîs,Parīze,Paříž,Páras,Párizs,Ville-Lumiere,Ville-Lumière,ba li,barys,pali si,pari,paris,parys,paryzh,perisa,prys,pryz,pyaris,pyrs,Παρίσι,Париж,Париз,Парыж,Փարիզ,פריז,باريس,پارىژ,پاریس,پیرس,ܦܪܝܣ,पॅरिस,பாரிஸ்,ಪ್ಯಾರಿಸ್,ปารีส,პარიზი,ፓሪስ,パリ,巴黎,파리 시
--

drop table if exists por;
create table por (
 iata_code varchar(3) NOT NULL,
 icao_code varchar(4) default NULL,
 is_geonames varchar(1) NOT NULL,
 geonameid int(11) default NULL,
 name varchar(200) default NULL,
 asciiname varchar(200) default NULL,
 alternatenames varchar(4000) default NULL,
 latitude decimal(10,7) default NULL,
 longitude decimal(10,7) default NULL,
 fclass varchar(1) default NULL,
 fcode varchar(10) default NULL,
 country_code varchar(2) default NULL,
 cc2 varchar(60) default NULL,
 admin1 varchar(20) default NULL,
 admin2 varchar(80) default NULL,
 admin3 varchar(20) default NULL,
 admin4 varchar(20) default NULL,
 population int(11) default NULL,
 elevation int(11) default NULL,
 gtopo30 int(11) default NULL,
 timezone varchar(40) default NULL,
 gmt_offset decimal(3,1) default NULL,
 dst_offset decimal(3,1) default NULL,
 raw_offset decimal(3,1) default NULL,
 moddate date default NULL,
 is_airport varchar(1) default NULL,
 is_commercial varchar(1) default NULL,
 city_code varchar(3) default NULL,
 state_code varchar(3) default NULL,
 region_code varchar(5) default NULL,
 continent_code varchar(4) default NULL,
 location_type varchar(4) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


--
-- Table structure for the table storing airport popularity details
--
drop table if exists airport_popularity;
create table airport_popularity (
  region_code char(3) NOT NULL,
  country varchar(20) NOT NULL,
  city varchar(40) NOT NULL,
  airport varchar(40) NOT NULL,
  airport_code char(3) NOT NULL,
  atmsa int(8) NULL,
  atmsb int(8) NULL,
  atmsc int(8) NULL,
  atmsd int(8) NULL,
  tatm int(8) NULL,
  paxa int(8) NULL,
  paxb int(8) NULL,
  paxc int(8) NULL,
  paxd int(8) NULL,
  tpax int(8) NULL,
  frta int(8) NULL,
  frtb int(8) NULL,
  tfrt int(8) NULL,
  mail int(8) NULL,
  tcgo int(8) NULL,
  latmsa int(8) NULL,
  latmsb int(8) NULL,
  latmsc int(8) NULL,
  latmsd int(8) NULL,
  ltatm int(8) NULL,
  lpaxa int(8) NULL,
  lpaxb int(8) NULL,
  lpaxc int(8) NULL,
  lpaxd int(8) NULL,
  ltpax int(8) NULL,
  lfrta int(8) NULL,
  lfrtb int(8) NULL,
  ltfrt int(8) NULL,
  lmail int(8) NULL,
  ltcgo int(8) NULL
) engine=InnoDB default charset=utf8 collate=utf8_unicode_ci;


--
-- Table structure for tableairports_pageranked
--

drop table if exists airports_pageranked;
create table airports_pageranked (
 localid int(6) NOT NULL,
 iata_code char(3) NOT NULL,
 page_rank decimal(15,12) NOT NULL
) engine=InnoDB default charset=utf8;


--
--
--
set character_set_client = @saved_cs_client;


