####
##
##
##
# 0. Reference
# See http://download.geonames.org/export/dump/readme.txt
#
# 1. Sample input lines:
#
# 1.1. allCountries.txt
# ---------------------
# geonameid name asciiname alternatenames latitude longitude fclass fcode country cc2 admin1 admin2 admin3 admin4 population elevation gtopo30 timezone moddate
# 6299418 Nice Côte d'Azur International Airport Nice Cote d'Azur International Airport Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Flughafen Nizza,LFMN,NCE,Nice Airport,Nice Cote d'Azur International Airport,Nice Côte d'Azur International Airport,Niza Aeropuerto 43.66272 7.20787 S AIRP FR  B8 06 062 06088 0 3 -9999 Europe/Paris 2012-06-30
# 2990440 Nice Nice NCE,Nica,Nicaea,Nicca,Nice,Nicea,Nico,Nisa,Niza,Nizza,Niça,ni si,nisa,nisu,nitsa,nys,Ница,Ницца,ניס,نيس,नीस,ნიცა,ニース,尼斯 43.70313 7.26608 P PPLA2 FR B8 06 062 06088 338620 25 18 Europe/Paris 2011-11-02
#
# 1.2. alternateNames.txt
# -----------------------
# alternatenameid geonameid isoLanguage alternateName isPreferredName isShortName isColloquial isHistoric
# 1886047 6299418 icao LFMN    
# 1888981 6299418 iata NCE    
# 1969714 6299418 de Flughafen Nizza    
# 1969715 6299418 en Nice Côte d'Azur International Airport    
# 2187822 6299418 es Niza Aeropuerto 1 1  
# 3032536 6299418 link http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport    
# 5713800 6299418 fr Aéroport de Nice Côte d'Azur    
# 7717894 6299418 en Nice Airport  1 
# 1628019 2990440 en Nice
# 1628030 2990440 fr Nice
# 1628021 2990440 es Niza 1 1  
# 1628023 2990440 ar نيس    
# 1628031 2990440 he ניס    
# 1628034 2990440 ja ニース
# 1628046 2990440 ru Ницца
# 1633915 2990440 zh-CN 尼斯
# 2964254 2990440 link http://en.wikipedia.org/wiki/Nice    
# 3054759 2990440 link http://ru.wikipedia.org/wiki/%D0%9D%D0%B8%D1%86%D1%86%D0%B0
#
# 1.3. admin1CodesASCII.txt
# -------------------------
# concatenated_codes name asciiname geonameId
# DE.01 Baden-Württemberg Baden-Wuerttemberg 2953481
# FR.B8 Provence-Alpes-Côte d'Azur Provence-Alpes-Cote d'Azur 2985244
# GB.ENG England England 6269131
# RU.84 Volgograd Volgograd 472755
# US.TX Texas Texas 4736286
#
# 1.4. admin2Codes.txt
# --------------------
# concatenated_codes name asciiname geonameId
# DE.01.084 Regierungsbezirk Tübingen Regierungsbezirk Tubingen 3214106
# FR.B8.06 Département des Alpes-Maritimes Departement des Alpes-Maritimes 3038049
# GB.ENG.GLA Greater London Greater London 2648110
# RU.84.462981 Zhirnovskiy Rayon Zhirnovskiy Rayon 462981
# US.TX.113 Dallas County Dallas County 4684904
#
# 1.5. countryInfo.txt
# --------------------
# ISO ISO3 ISO-Numeric fips CountryName Capital Area(in sq km) Population Continent tld CurrencyCode CurrencyName Phone Postal Code Format Postal Code Regex Languages geonameid neighbours EquivalentFipsCode
# DE DEU 276 GM Germany Berlin 357021 81802257 EU .de EUR Euro 49 ##### ^(\d{5})$ de 2921044 CH,PL,NL,DK,BE,CZ,LU,FR,AT
# FR FRA 250 FR France Paris 547030 64768389 EU .fr EUR Euro 33 ##### ^(\d{5})$ fr-FR,frp,br,co,ca,eu,oc 3017382 CH,DE,BE,LU,IT,AD,MC,ES 
# GB GBR 826 UK United Kingdom London 244820 62348447 EU .uk GBP Pound 44 @# #@@|@## #@@|@@# #@@|@@## #@@|@#@ #@@|@@#@ #@@|GIR0AA ^(([A-Z]\d{2}[A-Z]{2})|([A-Z]\d{3}[A-Z]{2})|([A-Z]{2}\d{2}[A-Z]{2})|([A-Z]{2}\d{3}[A-Z]{2})|([A-Z]\d[A-Z]\d[A-Z]{2})|([A-Z]{2}\d[A-Z]\d[A-Z]{2})|(GIR0AA))$ en-GB,cy-GB,gd 2635167 IE
# RU RUS 643 RS Russia Moscow 1.71E+007 140702000 EU .ru RUB Ruble 7 ###### ^(\d{6})$ ru,tt,xal,cau,ady,kv,ce,tyv,cv,udm,tut,mns,bua,myv,mdf,chm,ba,inh,tut,kbd,krc,ava,sah,nog 2017370 GE,CN,BY,UA,KZ,LV,PL,EE,LT,FI,MN,NO,AZ,KP 
# US USA 840 US United States Washington 9629091 310232863 NA .us USD Dollar 1 #####-#### ^(\d{9})$ en-US,es-US,haw,fr 6252001 CA,MX,CU
#
# 1.6. continentCodes.txt
# -----------------------
# AF Africa 6255146
# AS Asia 6255147
# EU Europe 6255148
# NA North America 6255149
# OC Oceania 6255151
# SA South America 6255150
# AN Antarctica 6255152
#
# 1.7. timeZones.txt
# ------------------
# CountryCode TimeZoneId GMT offset 1. Jan 2012 DST offset 1. Jul 2012 rawOffset (independant of DST)
# US America/Anchorage -9.0 -8.0 -9.0
# US America/Los_Angeles -8.0 -7.0 -8.0
# US America/Indiana/Indianapolis -5.0 -4.0 -5.0
# US America/New_York -5.0 -4.0 -5.0
# GB Europe/London 0.0 1.0 0.0
# FR Europe/Paris 1.0 2.0 1.0
# RU Europe/Volgograd 4.0 4.0 4.0
# CN Asia/Shanghai 8.0 8.0 8.0
# AU Australia/Sydney 11.0 10.0 10.0
# RU Asia/Vladivostok 11.0 11.0 11.0
#
#
# 2. Sample output lines:
# -----------------------
# iata_code^icao_code^faac_code^geonameid^name^asciiname^latitude^longitude^country^cc2^ctry_name^fclass^fcode^adm1^adm1_name_utf^adm1_name_ascii^adm2^adm2_name_utf^adm2_name_ascii^adm3^adm4^population^elevation^gtopo30^timezone^GMT_offset^DST_offset^raw_offset^moddate^alternatenames^wiki_link^altname_iso^altname_text
# NCE^LFMN^^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.66272^7.20787^FR^^Europe^S^AIRP^B8^06^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Flughafen Nizza,LFMN,NCE,Nice Airport,Nice Cote d'Azur International Airport,Nice Côte d'Azur International Airport,Niza Aeropuerto^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de|Flughafen Nizza||en|Nice Côte d'Azur International Airport||es|Niza Aeropuerto|ps|fr|Aéroport de Nice Côte d'Azur||en|Nice Airport|s
# NCE^^^2990440^Nice^Nice^43.70313^7.26608^FR^^Europe^P^PPLA2^B8^06^062^06088^338620^25^18^Europe/Paris^1.0^2.0^1.0^2011-11-02^NCE,Nica,Nicaea,Nicca,Nice,Nicea,Nico,Nisa,Niza,Nizza,Niça,ni si,nisa,nisu,nitsa,nys,Ница,Ницца,ניס,نيس,नीस,ნიცა,ニース,尼斯^http://en.wikipedia.org/wiki/Nice^en|Nice||de|Nizza||es|Niza|ps|af|Nice||ar|نيس||bg|Ница||ca|Niça||da|Nice||eo|Nico||et|Nice||fi|Nizza||fr|Nice||he|ניס||id|Nice||it|Nizza||ja|ニース||la|Nicaea||lad|Nice||lb|Nice||lt|Nica||nb|Nice||nl|Nice||no|Nice||oc|Niça||pl|Nicea||pt|Nice||ro|Nisa||ru|Ницца||sl|Nica||sv|Nice||cy|Nice||eu|Niza||zh|尼斯||ceb|Nice||hi|नीस||ka|ნიცა||lv|Nica||qu|Nice||scn|Nizza||sk|Nice||sr|Ница||post|06100||post|06000|p|post|06200||post|06300|
#

##
# Debugging support function
function printList(myArray) {
	printf ("%s", "Size: " length(myArray) "\n") > "/dev/stderr"
	for (idx in myArray) {
		printf ("%s", idx "^" myArray[idx]) > "/dev/stderr"
	}
	printf ("%s", "\n") > "/dev/stderr"
}

##
#
BEGIN {
	#
	tz_line = 0
	cont_line = 0
	por_line = 0
	alt_line = 0

	# Header
	printf ("%s", "iata_code^icao_code^geonameid")
	printf ("%s", "^name^asciiname^latitude^longitude")
	printf ("%s", "^country^cc2^ctry_name^continent^fclass^fcode")
	printf ("%s", "^adm1^adm1_name_utf^adm1_name_ascii")
	printf ("%s", "^adm2^adm2_name_utf^adm2_name_ascii^adm3^adm4")
	printf ("%s", "^population^elevation^gtopo30")
	printf ("%s", "^timezone^GMT_offset^DST_offset^raw_offset")
	printf ("%s", "^moddate")
	printf ("%s", "^alternatenames")
	printf ("%s", "^wiki_link")
	printf ("%s", "^altname_section")
	printf ("%s", "\n")
}

##
# admin1CodesASCII.txt
#
# Register the details for the first order administrative divisions
#
# DE.01 Baden-Württemberg Baden-Wuerttemberg 2953481
# FR.B8 Provence-Alpes-Côte d'Azur Provence-Alpes-Cote d'Azur 2985244
#
/^([A-Z]{2}\.[A-Z0-9]{0,3})\t.*\t([0-9]{1,10})$/ {
	# Primary key
	pk = $1

	# UTF8 Name
	name_utf = $2

	# ASCII Name
	name_ascii = $3

	# Archive the full line and the separator
	full_line = $0
	fs_org = FS

	# Change the separator in order to parse the primary key
	FS = "."
	$0 = pk

	# Country code
	ctry_code = $1

	# Administrative level 1 code
	adm1_code = $2

	# Register the details for that administrative level code
	adm1_list_name_utf[ctry_code, adm1_code] = name_utf
	adm1_list_name_ascii[ctry_code, adm1_code] = name_ascii

	# Restore the initial full line
	FS = fs_org
	#$0 = full_line
}

##
# admin2Codes.txt
#
# Register the details for the first order administrative divisions
#
# DE.01.084 Regierungsbezirk Tübingen Regierungsbezirk Tubingen 3214106
# FR.B8.06 Département des Alpes-Maritimes Departement des Alpes-Maritimes 3038049
# GB.ENG.GLA Greater London Greater London 2648110
# RU.84.462981 Zhirnovskiy Rayon Zhirnovskiy Rayon 462981
# US.TX.113 Dallas County Dallas County 4684904
#
/^([A-Z]{2}\.[A-Z0-9]{0,3}\..*)\t.*\t([0-9]{1,10})$/ {
	# Primary key
	pk = $1

	# UTF8 Name
	name_utf = $2

	# ASCII Name
	name_ascii = $3

	# Archive the full line and the separator
	full_line = $0
	fs_org = FS

	# Change the separator in order to parse the primary key
	FS = "."
	$0 = pk

	# Country code
	ctry_code = $1

	# Administrative level 1 code
	adm1_code = $2

	# Administrative level 2 code
	adm2_code = $3

	# Register the details for that administrative level code
	adm2_list_name_utf[ctry_code, adm1_code, adm2_code] = name_utf
	adm2_list_name_ascii[ctry_code, adm1_code, adm2_code] = name_ascii

	# Restore the initial full line
	FS = fs_org
	#$0 = full_line
}

##
# countryInfo.txt
#
# Register the details for the countries
#
# ISO ISO3 ISO-Numeric fips CountryName Capital Area(in sq km) Population Continent tld CurrencyCode CurrencyName Phone Postal Code Format Postal Code Regex Languages geonameid neighbours EquivalentFipsCode
# DE DEU 276 GM Germany Berlin 357021 81802257 EU .de EUR Euro 49 ##### ^(\d{5})$ de 2921044 CH,PL,NL,DK,BE,CZ,LU,FR,AT
# FR FRA 250 FR France Paris 547030 64768389 EU .fr EUR Euro 33 ##### ^(\d{5})$ fr-FR,frp,br,co,ca,eu,oc 3017382 CH,DE,BE,LU,IT,AD,MC,ES 
# GB GBR 826 UK United Kingdom London 244820 62348447 EU .uk GBP Pound 44 @# #@@|@## #@@|@@# #@@|@@## #@@|@#@ #@@|@@#@ #@@|GIR0AA ^(([A-Z]\d{2}[A-Z]{2})|([A-Z]\d{3}[A-Z]{2})|([A-Z]{2}\d{2}[A-Z]{2})|([A-Z]{2}\d{3}[A-Z]{2})|([A-Z]\d[A-Z]\d[A-Z]{2})|([A-Z]{2}\d[A-Z]\d[A-Z]{2})|(GIR0AA))$ en-GB,cy-GB,gd 2635167 IE
# RU RUS 643 RS Russia Moscow 1.71E+007 140702000 EU .ru RUB Ruble 7 ###### ^(\d{6})$ ru,tt,xal,cau,ady,kv,ce,tyv,cv,udm,tut,mns,bua,myv,mdf,chm,ba,inh,tut,kbd,krc,ava,sah,nog 2017370 GE,CN,BY,UA,KZ,LV,PL,EE,LT,FI,MN,NO,AZ,KP 
# US USA 840 US United States Washington 9629091 310232863 NA .us USD Dollar 1 #####-#### ^(\d{9})$ en-US,es-US,haw,fr 6252001 CA,MX,CU
#
/^([A-Z]{2})\t([A-Z]{3})\t([0-9]{1,3})\t.*\t([0-9]{1,10})\t.*\t.*$/ {
	# 2-character ISO code
	iso_2char_code = $1

	# 3-character ISO code
	iso_3char_code = $2

	# FIPS code
	fips_code = $3

	# (ASCII) Name
	ctry_name = $5

	# Continent code
	cont_code = $9

	# Register the details for that country
	ctry_list_name[iso_2char_code] = ctry_name
	ctry_list_cont[iso_2char_code] = cont_code
}

##
# timeZones.txt
#
# Register all the time-zones
#
# CountryCode TimeZoneId GMT offset 1. Jan 2012 DST offset 1. Jul 2012 rawOffset (independant of DST)
# US America/Los_Angeles -8.0 -7.0 -8.0
# US America/Indiana/Indianapolis -5.0 -4.0 -5.0
# GB Europe/London 0.0 1.0 0.0
# FR Europe/Paris 1.0 2.0 1.0
# RU Europe/Volgograd 4.0 4.0 4.0
# CN Asia/Shanghai 8.0 8.0 8.0
# AU Australia/Sydney 11.0 10.0 10.0
#
/^([A-Z]{2})\t.*\t([0-9.-]*)\t([0-9.-]*)\t([0-9.-]*)$/ {
	#
	tz_line++

	# Country code
	ctry_code = $1

	# Time-zone ID
	tz_id = $2

	# GMT offset
	gmt_offset = $3

	# DST offset
	dst_offset = $4

	# Raw offset
	raw_offset = $5

	# Register the time-zone details
	tz_list_ctry[tz_id] = ctry_code
	tz_list_gmt[tz_id] = gmt_offset
	tz_list_dst[tz_id] = dst_offset
	tz_list_raw[tz_id] = raw_offset
}

##
# continentCodes.txt
#
# Register the continents
#
# ContinentCode ContinentName geonameid
# EU Europe 6255148
# NA North America 6255149
/^([A-Z]{2})\t([A-Za-z ]+)\t([0-9]{1,9})$/ {
	#
	cont_line++

	# Continent code
	cont_code = $1

	# Continent name
	cont_name = $2

	# Register the continent name
	cont_list[cont_code] = cont_name
}

##
# alternateNames.txt
#
# For every Geoname ID, concatenate all the alternate name details
# into a single string/line.
#
/^([0-9]{1,9})\t([0-9]{1,9})\t([a-z]{0,5})(-[a-zA-Z]{2}|[_]{0,1}[0-9]{0,4})\t/ {
	#alt_line++

	# Alternate name ID
	alt_name_id = $1

	# Geoname ID
	geoname_id = $2

	# Alternate name type (IATA, ICAO, FAA, Wikipedia link, language code)
	alt_name_type = $3

	# Alternate name
	alt_name_content = $4

	# Whether that alternate name is historical
	is_historical = $8
	if (is_historical == "1") {
		is_historical = "h"
	}

	#
	if (alt_name_type == "iata") {
		if (is_historical != "h") {
			alt_name_list_iata[geoname_id] = alt_name_content
		} else {
			if (alt_name_list_iata[geoname_id] == "") {
				alt_name_list_iata[geoname_id] = "_" alt_name_content
			}
		}

	} else if (alt_name_type == "icao") {
		if (is_historical != "h") {
			alt_name_list_icao[geoname_id] = alt_name_content
		} else {
			if (alt_name_list_icao[geoname_id] == "") {
				alt_name_list_icao[geoname_id] = "_" alt_name_content
			}
		}

	} else if (alt_name_type == "faac") {
		if (is_historical != "h") {
			alt_name_list_faac[geoname_id] = alt_name_content
		} else {
			if (alt_name_list_faac[geoname_id] == "") {
				alt_name_list_faac[geoname_id] = "_" alt_name_content
			}
		}

	} else if (alt_name_type == "link") {
		# Check that the Wikipedia link is for English
		is_en_wiki_link = match (alt_name_content, "http://en.")

		# The Wikipedia link may have already been set (there are sometimes
		# multiple distinct English Wikipedia links)
		alt_name_link = alt_name_list_link[geoname_id]

		if (is_en_wiki_link != 0 && is_historical != "h") {
			# Register the link
			alt_name_list_link[geoname_id] = alt_name_content

			# Handle any override of the Wikipedia link. If any, the
			# notification will be issued later, when the type of the POR
			# will be known for sure (as we want to notify only for IATA
			# known POR).
			if (alt_name_link != "") {
				alt_name_list_link2[geoname_id] = alt_name_link
			}
		}

	} else {
		# Check whether the type is language-related
		is_lang_related = match (alt_name_type, "[a-z]{0,5}[_]{0,1}[0-9]{0,4}")
		if (alt_name_type == "") {
			is_lang_related = 1
		}

		# When it is language related
		if (is_lang_related == 1) {
			# Whether that alternate name is the preferred one in that language
			is_preferred = $5
			if (is_preferred == "1") {
				is_preferred = "p"
			}

			# Whether that alternate name is the short version in that language
			is_short = $6
			if (is_short == "1") {
				is_short = "s"
			}

			# Whether that alternate name is colloquial in that language
			is_colloquial = $7
			if (is_colloquial == "1") {
				is_colloquial = "c"
			}

			# Retrieve the concatenated string of the language-related
			# alternate names for that Geoname ID, if any.
			alt_name_lang_full = alt_name_list_lang[geoname_id]
			if (alt_name_lang_full != "") {
				alt_name_lang_full = alt_name_lang_full "|"
			}

			# Concatenate the new alternate name, and (re-)register it.
			alt_name_list_lang[geoname_id] = alt_name_lang_full alt_name_type \
				"|" alt_name_content \
				"|" is_preferred is_short is_colloquial is_historical

		} else {
			# Notification
			if (log_level >= 5) {
				print ("!!!! [" FNR "] The type of the alternate name ('" \
					   alt_name_type "') is unknown. The Geoname ID is " \
					   geoname_id) > "/dev/stderr"
			}
		}
	}
}

##
# allCountries.txt
#
# Parse the POR details, and output them in the desired format.
# The time-zone and alternate name details, corresponding to the every
# current line (for a given Geoname ID), are also integrated.
#
/^([0-9]{1,9})\t.*\t([0-9]{4}-[0-9]{2}-[0-9]{2})$/ {
	por_line++

	# Geoname ID
	geoname_id = $1

	# Name (may be in UTF8)
	utf8_name = $2

	# ASCII Name
	ascii_name = $3

	# Compact version (without language codes) of the list of alternate names
	alt_names_compact = $4

	# Geographical coordinates (latitude, longitude)
	latitude = $5
	longitude = $6

	# POR type
	fclass = $7
	fcode = $8

	# Country codes and name
	ctry_code = $9
	ctry_name = ctry_list_name[ctry_code]
	cc_code_list = $10

	# Continent
	cont_code = ctry_list_cont[ctry_code]
	cont_name = cont_list[cont_code]
	# Sanity check
	if (cont_name == "") {
		print ("!!!! [" FNR "] The " ctry_code							\
			   " country has no associated continent.") > "/dev/stderr"
		printList(cont_list)
	}

	# Codes and names for administrative levels
	adm1_code = $11
	adm1_name_utf = adm1_list_name_utf[ctry_code, adm1_code]
	adm1_name_ascii = adm1_list_name_ascii[ctry_code, adm1_code]
	adm2_code = $12
	adm2_name_utf = adm2_list_name_utf[ctry_code, adm1_code, adm2_code]
	adm2_name_ascii = adm2_list_name_ascii[ctry_code, adm1_code, adm2_code]
	adm3_code = $13
	adm4_code = $14

	# Population
	population = $15

	# Topology
	elevation = $16
	gtopo30 = $17

	# Time-zone
	tz_id = $18

	# Modification date
	mod_date = $19

	# Retrieve the details coming from the time zone.
	# Note that the time zone field may be missing on some (~2500) POR.
	tz_ctry = tz_list_ctry[tz_id]
	gmt_offset = tz_list_gmt[tz_id]
	dst_offset = tz_list_dst[tz_id]
	raw_offset = tz_list_raw[tz_id]

	# Retrieve the details coming from the alternate names
	iata_code = alt_name_list_iata[geoname_id]
	icao_code = alt_name_list_icao[geoname_id]
	faac_code = alt_name_list_faac[geoname_id]
	link_code = alt_name_list_link[geoname_id]
	link2_code = alt_name_list_link2[geoname_id]
	alt_names = alt_name_list_lang[geoname_id]

	# Cleaning
	delete alt_name_list_iata[geoname_id]
	delete alt_name_list_icao[geoname_id]
	delete alt_name_list_faac[geoname_id]
	delete alt_name_list_link[geoname_id]
	delete alt_name_list_link2[geoname_id]
	delete alt_name_list_lang[geoname_id]

	# Build the output line, in the desired format
	out_line = iata_code "^" icao_code "^" faac_code "^" geoname_id
	out_line = out_line "^" utf8_name "^" ascii_name
	out_line = out_line "^" latitude "^" longitude
	out_line = out_line "^" ctry_code "^" cc_code_list "^" ctry_name
	out_line = out_line "^" cont_name "^" fclass "^" fcode
	out_line = out_line "^" adm1_code "^" adm1_name_utf "^" adm1_name_ascii
	out_line = out_line "^" adm2_code "^" adm2_name_utf "^" adm2_name_ascii
	out_line = out_line "^" adm3_code "^" adm4_code
	out_line = out_line "^" population "^" elevation "^" gtopo30
	out_line = out_line "^" tz_id "^" gmt_offset "^" dst_offset "^" raw_offset
	out_line = out_line "^" mod_date
	out_line = out_line "^" alt_names_compact
	out_line = out_line "^" link_code
	out_line = out_line	"^" alt_names

	# Print the output line
	print (out_line)

	# Notification when multiple English Wikipedia links for a single POR
	if (link2_code != "" && iata_code != "" && log_level >= 5) {
		print ("!!!! [" FNR \
			   "] There are duplicated English Wikipedia links, i.e., at least "\
			   link2_code " and " link_code ". The Geoname ID is " geoname_id) \
			> "/dev/stderr"
	}
}

##
#
END {
	# DEBUG
	# print ("Nb of TZ: " tz_line ", nb of POR: " por_line ", nb of alternate names: " alt_line)
}
