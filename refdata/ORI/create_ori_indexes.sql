--
-- @brief SQL script creating the indexes for the ORI-related tables.
--        See also create_ori_tables.sql in the same directory.
-- @author Denis Arnaud <denis.arnaud_ori@m4x.org>
--


--
-- Index structure for table por (points of reference)
--

-- code, ref_name, ref_name2, full_name, city_code, is_airport, 
-- state_code, country_code, region_code, pricing_zone, tz_group,
-- latitude, longitude, numeric_code, is_commercial, location_type

ALTER TABLE por ADD PRIMARY KEY (`code`);

ALTER TABLE por ADD INDEX (`ref_name`);

-- ALTER TABLE por ADD UNIQUE INDEX (`full_name`);
ALTER TABLE por ADD INDEX (`full_name`);

ALTER TABLE por ADD INDEX (`city_code`);

ALTER TABLE por ADD INDEX (`state_code`);

ALTER TABLE por ADD INDEX (`country_code`);

ALTER TABLE por ADD INDEX (`region_code`);

ALTER TABLE por ADD INDEX (`pricing_zone`);

ALTER TABLE por ADD INDEX (`tz_group`);

ALTER TABLE por ADD INDEX (`latitude`);

ALTER TABLE por ADD INDEX (`longitude`);


--
-- Index structure for table airport popularity
--
-- region_code, country, city, airport, airport_code, atmsa, atmsb, atmsc, atmsd
-- tatm, paxa, paxb, paxc, paxd, tpax, frta, frtb, tfrt, mail, tcgo
-- latmsa, latmsb, latmsc, latmsd, ltatm, lpaxa, lpaxb, lpaxc, lpaxd
-- ltpax, lfrta, lfrtb, ltfrt, lmail, ltcgo

ALTER TABLE airport_popularity ADD PRIMARY KEY (`airport_code`);

