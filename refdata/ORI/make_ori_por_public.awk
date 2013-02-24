##
# That AWK script re-formats the full details of POR (points of reference)
# derived from a few sources:
#  * Amadeus ORI-maintained lists of:
#    * Best known coordinates:          best_coordinates_known_so_far.csv
#    * PageRank values:                 ref_airport_pageranked.csv
#    * Country-associated time-zones:   ori_tz_light.csv
#    * Country-associated continents:   ori_cont.csv
#  * Amadeus RFD (Referential Data):    dump_from_crb_city.csv
#  * Geonames:                          dump_from_geonames.csv
#
# Notes:
# 1. When the POR is existing only in Amadeus RFD data, the cryptic time-zone
#    ID is replaced by a more standard time-zone ID. That latter is a simplified
#    version of the standard time-zone ID (such as the one given by Geonames),
#    as there is then a single time-zone ID per country; that is obviously
#    inaccurate for countries such as Russia, Canada, USA, Antartica, Australia.
# 2. The city (UTF8 and ASCII) names are added afterwards, by another AWK script,
#    namely add_city_name.awk, located in the very same directory.
#
# Sample output lines:
# IEV^UKKK^^Y^6300960^^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^50.401694^30.449697^S^AIRP^0.0240196752049^^^^UA^^Ukraine^Europe^^^^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^IEV^^^^^A^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en|Kyiv Zhuliany International Airport|=en|Kyiv International Airport|=en|Kyiv Airport|s=en|Kiev International Airport|=uk|Міжнародний аеропорт «Київ» (Жуляни)|=ru|Аэропорт «Киев» (Жуляны)|=ru|Международный аеропорт «Киев» (Жуляни)|
# NCE^LFMN^^Y^6299418^^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.658411^7.215872^S^AIRP^0.157408761216^^^^FR^^France^Europe^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^NCE^^^^^CA^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de|Flughafen Nizza|=en|Nice Côte d'Azur International Airport|=es|Niza Aeropuerto|ps=fr|Aéroport de Nice Côte d'Azur|=en|Nice Airport|s
#

##
#
BEGIN {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "make_ori_por_public.awk"

	# Header
	printf ("%s","iata_code^icao_code^faa_code^is_geonames^geoname_id^valid_id")
	printf ("%s", "^name^asciiname^latitude^longitude")
	printf ("%s", "^fclass^fcode")
	printf ("%s", "^page_rank^date_from^date_until^comment")
	printf ("%s", "^country_code^cc2^country_name^continent_name")
	printf ("%s", "^adm1_code^adm1_name_utf^adm1_name_ascii")
	printf ("%s", "^adm2_code^adm2_name_utf^adm2_name_ascii")
	printf ("%s", "^adm3_code^adm4_code")
	printf ("%s", "^population^elevation^gtopo30")
	printf ("%s", "^timezone^gmt_offset^dst_offset^raw_offset^moddate")
	printf ("%s", "^city_code^city_name_utf^city_name_ascii^tvl_por_list")
	printf ("%s", "^state_code^location_type")
	printf ("%s", "^wiki_link")
	printf ("%s", "^alt_name_section")
	printf ("%s", "\n")

	#
	today_date = mktime ("YYYY-MM-DD")
	unknown_idx = 1
}


##
# File of PageRank values.
#
# Note that the location types of that file are not the same as the ones
# in the best_coordinates_known_so_far.csv file. Indeed, the location types
# take a value from three possible ones: 'C', 'A' or 'CA', where 'A' actually
# means travel-related rather than airport. There are distinct entries for
# the city and for the corresponding travel-related POR, only when there are
# several travel-related POR serving the city.
#
# In the best_coordinates_known_so_far.csv file, instead, there are distinct
# entries when Geonames has got itself distinct entries.
#
# For instance:
#  * NCE has got:
#    - 2 distinct entries in the best_coordinates_known_so_far.csv file:
#       NCE-A-6299418^NCE^43.658411^7.215872^NCE^
#       NCE-C-2990440^NCE^43.70313^7.26608^NCE^
#    - 1 entry in the file of PageRank values:
#       NCE-CA^NCE^0.161281957529
#  * IEV has got:
#    - 2 distinct entries in the best_coordinates_known_so_far.csv file:
#       IEV-A-6300960^IEV^50.401694^30.449697^IEV^
#       IEV-C-703448^IEV^50.401694^30.449697^IEV^
#    - 2 entries in the file of PageRank values:
#       IEV-C^IEV^0.109334523229
#       IEV-A^IEV^0.0280192004497
#
# Sample input lines:
#   LON-C^LON^1.0
#   PAR-C^PAR^0.994632137197
#   NYC-C^NYC^0.948221089373
#   CHI-C^CHI^0.768305897463
#   ATL-A^ATL^0.686723208248
#   ATL-C^ATL^0.686723208248
#   NCE-CA^NCE^0.158985215433
#   ORD-A^ORD^0.677280625337
#   CDG-A^CDG^0.647060165878
#
/^([A-Z]{3})-([A-Z]{1,2})\^([A-Z]{3})\^([0-9.]{1,15})$/ {
	# Primary key (IATA code and location pseudo-code)
	pk = $1

	# IATA code
	iata_code = substr (pk, 1, 3)

	# Location pseudo-type ('C' means City, but 'A' means any related to travel,
	# e.g., airport, heliport, port, bus or train station)
	por_type = substr (pk, 5)

	# Sanity check
	if (iata_code != $2) {
		print ("[" awk_file "] !!! Error at recrod #" FNR \
			   ": the IATA code ('" iata_code			  \
			   "') should be equal to the field #2 ('" $2 \
			   "'), but is not. The whole line " $0) > error_stream
	}

	# Check whether it is a city
	is_city = match (por_type, "C")

	# Check whether it is travel-related
	is_tvl = match (por_type, "A")

	# PageRank value
	pr_value = $3

	# Store the PageRank value for that POR
	if (is_city != 0) {
		city_list[iata_code] = pr_value
	}
	if (is_tvl != 0) {
		tvl_list[iata_code] = pr_value
	}
}


##
# File of time-zone IDs
#
# Sample lines:
# country_code^time_zone
# ES^Europe/Spain
# RU^Europe/Russia
/^([A-Z]{2})\^([A-Za-z_\/]+)$/ {
	# Country code
	country_code = $1

	# Time-zone ID
	tz_id = $2

	# Register the time-zone ID associated to that country
	ctry_tz_list[country_code] = tz_id
}


##
# File of country-continent mappings
#
# Sample lines:
# country_code^country_name^continent_code^continent_name
# DE^Germany^EU^Europe
# AG^Antigua and Barbuda^NA^North America
# PE^Peru^SA^South America
/^([A-Z]{2})\^([A-Za-z,. \-]+)\^([A-Z]{2})\^([A-Za-z ]+)$/ {
	# Country code
	country_code = $1

	# Continent code
	continent_code = $3

	# Continent name
	continent_name = $4

	# Register the time-zone ID associated to that country
	# ctry_cont_code_list[country_code] = continent_code
	ctry_cont_name_list[country_code] = continent_name
}


##
# States whether that location type corresponds to a travel-related POR
function isTravel(myLocationType) {
	is_airport = match (myLocationType, "A")
	is_rail = match (myLocationType, "R")
	is_bus = match (myLocationType, "B")
	is_heliport = match (myLocationType, "H")
	is_port = match (myLocationType, "P")
	is_ground = match (myLocationType, "G")
	is_offpoint = match (myLocationType, "O")
	is_travel = is_airport + is_rail + is_bus + is_heliport + is_port	\
		+ is_ground + is_offpoint

	return is_travel
}

##
# Retrieve the PageRank value for that POR
function getPageRank(myIataCode, myLocationType, myGeonamesID) {
	is_city = match (myLocationType, "C")
	is_tvl = isTravel(myLocationType)
	
	if (is_city != 0) {
		page_rank = city_list[myIataCode]

	} else if (is_tvl != 0) {
		page_rank = tvl_list[myIataCode]

	} else {
		page_rank = ""
	}

	return page_rank
}

##
# Retrieve the time-zone ID for that country
function getTimeZone(myCountryCode) {
	tz_id = ctry_tz_list[myCountryCode]
	return tz_id
}

##
# Retrieve the continent code for that country
function getContinentCode(myCountryCode) {
	# cnt_code = ctry_cont_code_list[myCountryCode]
	return cnt_code
}

##
# Retrieve the continent name for that country
function getContinentName(myCountryCode) {
	cnt_name = ctry_cont_name_list[myCountryCode]
	return cnt_name
}

##
#
function printAltNameSection(myAltNameSection) {
	# Archive the full line and the separator
	full_line = $0
	fs_org = FS

	# Change the separator in order to parse the section of alternate names
	FS = "|"
	$0 = myAltNameSection

	# Print the alternate names
	printf ("%s", "^")
	for (fld = 1; fld <= NF; fld++) {
		printf ("%s", $fld)

		# Separate the details of a given alternate name with the equal (=) sign
		# and the alternate name blocks with the pipe (|) sign.
		if (fld != NF) {

			idx = fld % 3
			if (idx == 0) {
				printf ("%s", "=")

			} else {
				printf ("%s", "|")
			}
		}
	}

	# Restore the initial separator (and full line, if needed)
	FS = fs_org
	#$0 = full_line
}


##
# Aggregated content from Amadeus ORI, Amadeus RFD and Geonames
#
# Sample input lines:
#
# # Both in Geonames and in RFD (56 fields)
# NCE-A-6299418^NCE^43.658411^7.215872^NCE^6299418^NCE^LFMN^^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.66272^7.20787^FR^^France^Europe^S^AIRP^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^Nice Airport,...^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^NCE^A^Nice^Cote D Azur^Nice^Nice FR Cote D Azur^Nice^NCE^Y^^FR^EUROP^ITC2^FR052^43.6653^7.215^^Y^en|Nice Côte d'Azur International Airport|s
#
# # In RFD (24 fields)
# XIT-R-0^XIT^51.42^12.42^LEJ^^XIT^R^Leipzig Rail^Leipzig Hbf Rail Stn^Leipzig Rail^Leipzig HALLE DE Leipzig Hbf R^Leipzig HALLE^LEJ^Y^^DE^EUROP^ITC2^DE040^51.3^12.3333^^N
#
# # In Geonames (38 fields)
# SQX-CA-7731508^SQX^-26.7816^-53.5035^SQX^7731508^SQX^SSOE^^7731508^São Miguel do Oeste Airport^Sao Miguel do Oeste Airport^-26.7816^-53.5035^BR^^Brazil^South America^S^AIRP^26^Santa Catarina^Santa Catarina^4204905^Descanso^Descanso^^^0^^655^America/Sao_Paulo^-2.0^-3.0^-3.0^2012-08-03^SQX,SSOE^^
#
/^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})\^([A-Z]{3})\^([0-9.+-]{0,12})\^/ {

	if (NF == 57) {
		####
		## Both in Geonames and in RFD
		####

		# Primary key
		pk = $1

		# Location type (extracted from the primary key)
		location_type = gensub ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$", \
								"\\2", "g", pk)

		# Geonames ID
		geonames_id = gensub ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$", \
							  "\\3",	"g", pk)

		# IATA code
		iata_code = $2

		# PageRank value
		page_rank = getPageRank(iata_code, location_type, geonames_id)

		# Is in Geonames?
		geonameID = $10
		isGeonames = "Y"
		if (geonameID == "0" || geonameID == "") {
			isGeonames = "N"
		}

		# Sanity check
		if (geonames_id != geonameID) {
			print ("[" awk_file "] !!!! Warning !!!! The two Geonames ID" \
				   " are not equal: pk="	pk " and " geonameID		\
				   " for the record #" FNR ":" $0)						\
				> error_stream
		}

		# IATA code ^ ICAO code ^ FAA ^ Is in Geonames ^ GeonameID ^ Validity ID
		printf ("%s", iata_code "^" $8 "^" $9 "^" isGeonames "^" geonameID "^")

		# ^ Name ^ ASCII name
		printf ("%s", "^" $11 "^" $12)

		# ^ Alternate names
		# printf ("%s", "^" $37)

		# ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("%s", "^" $3 "^" $4 "^" $19 "^" $20)

		# ^ PageRank value
		printf ("%s", "^" page_rank)

		# ^ Valid from date ^ Valid until date ^ Comment
		printf ("%s", "^" $6 "^^")

		# ^ Country code ^ Alt. country codes ^ Country name ^ Continent name
		printf ("%s", "^" $15 "^" $16 "^" $17 "^" $18)

		# ^ Admin1 code ^ Admin1 UTF8 name ^ Admin1 ASCII name
		printf ("%s", "^" $21 "^" $22 "^" $23)
		# ^ Admin2 code ^ Admin2 UTF8 name ^ Admin2 ASCII name
		printf ("%s", "^" $24 "^" $25 "^" $26)
		# ^ Admin3 code ^ Admin4 code
		printf ("%s", "^" $27 "^" $28)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^" $29 "^" $30 "^" $31)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $32 "^" $33 "^" $34 "^" $35)

		# ^ Modification date
		printf ("%s", "^" $36)

		# ^ City code ^ City UTF8 name ^ City ASCII name ^ Travel-related list
		# Notes:
		#   1. The actual name values are added by the add_city_name.awk script.
		#   2. The city code is the one from the file of best known coordinates,
		#      not the one from Amadeus RFD (as it is sometimes inaccurate).
		printf ("%s", "^" $5 "^"  "^"  "^" )

		# ^ State code
		printf ("%s", "^" $48)

		# ^ Location type ^ Wiki link
		printf ("%s", "^" location_type "^" $38)

		##
		# ^ Section of alternate names
		altname_section = $57
		printAltNameSection(altname_section)

		# End of line
		printf ("%s", "\n")

		# ----
		# From ORI-POR ($1 - $6)
		# (1) NCE-A-6299418 ^ (2) NCE ^ (3) 43.658411 ^ (4) 7.215872 ^
		# (5) NCE ^ (6) 6299418 ^

		# From Geonames ($7 - $38)
		# (7) NCE ^ (8) LFMN ^ (9)  ^ (10) 6299418 ^
		# (11) Nice Côte d'Azur International Airport ^
		# (12) Nice Cote d'Azur International Airport ^
		# (13) 43.66272 ^ (14) 7.20787 ^
		# (15) FR ^ (16)  ^ (17) France ^ (18) Europe ^ (19) S ^ (20) AIRP ^
		# (21) B8 ^ (22) Provence-Alpes-Côte d'Azur ^
		# (23) Provence-Alpes-Cote d'Azur ^
		# (24) 06 ^ (25) Département des Alpes-Maritimes ^ 
		# (26) Departement des Alpes-Maritimes ^
		# (27) 062 ^ (28) 06088 ^
		# (29) 0 ^ (30) 3 ^ (31) -9999
		# (32) Europe/Paris ^ (33) 1.0 ^ (34) 2.0 ^ (35) 1.0 ^
		# (36) 2012-06-30 ^
		# (37) Aeroport de Nice Cote d'Azur, ...,Niza Aeropuerto ^
		# (38) http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport ^

		# From RFD ($39 - $56)
		# (39) NCE ^ (40) CA ^ (41) NICE ^ (42) COTE D AZUR ^ (43) NICE ^
		# (44) NICE/FR:COTE D AZUR ^ (45) NICE ^ (46) NCE ^
		# (47) Y ^ (48)  ^ (49) FR ^ (50) EUROP ^ (51) ITC2 ^ (52) FR052 ^
		# (53) 43.6653 ^ (54) 7.215 ^ (55)  ^ (56) Y ^

		# From Geonames alternate names ($57)
		# (57) en | Nice Airport | s |
		#      en | Nice Côte d'Azur International Airport | 

	} else if (NF == 24) {
		####
		## Not in Geonames
		####

		# Primary key
		pk = $1

		# Location type (extracted from the primary key)
		location_type = gensub ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$", \
								"\\2", "g", pk)

		# Geonames ID
		geonames_id = gensub ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$", \
							  "\\3", "g", pk)

		# IATA code
		iata_code = $2

		# PageRank value
		page_rank = getPageRank(iata_code, location_type, geonames_id)

		# Is in Geonames?
		geonameID = "0"
		isGeonames = "N"

		# IATA code ^ ICAO code ^ FAA ^ Is in Geonames ^ GeonameID ^ Validity ID
		printf ("%s", iata_code "^ZZZZ^^" isGeonames "^" geonameID "^")

		# ^ Name ^ ASCII name
		printf ("%s", "^" $12 "^" $12)

		# ^ Alternate names
		# printf ("%s", "^")

		# ^ Latitude ^ Longitude
		printf ("%s", "^" $3 "^" $4)

		# ^ Feat. class ^ Feat. code
		is_city = match (location_type, "C")
		is_offpoint = match (location_type, "O")
		is_airport = match (location_type, "A")
		is_heliport = match (location_type, "H")
		is_railway = match (location_type, "R")
		is_bus = match (location_type, "B")
		is_port = match (location_type, "P")
		is_ground = match (location_type, "G")
		if (is_airport != 0) {
			# The POR is an airport. Note that it takes precedence over the
			# city, when the POR is both an airport and a city. 
			printf ("%s", "^S^AIRP")
		} else if (is_heliport != 0) {
			# The POR is an heliport
			printf ("%s", "^S^AIRH")
		} else if (is_railway != 0) {
			# The POR is a railway station
			printf ("%s", "^S^RSTN")
		} else if (is_bus != 0) {
			# The POR is a bus station
			printf ("%s", "^S^BUSTN")
		} else if (is_port != 0) {
			# The POR is a (maritime) port
			printf ("%s", "^S^PORT")
		} else if (is_ground != 0) {
			# The POR is a ground station
			printf ("%s", "^S^XXXX")
		} else if (is_city != 0) {
			# The POR is (only) a city
			printf ("%s", "^P^PPLC")
		} else if (is_offpoint != 0) {
			# The POR is an off-line point, which could be
			# a bus/railway station, or even a city/village.
			printf ("%s", "^X^XXXX")
		} else {
			# The location type can not be determined
			printf ("%s", "^Z^ZZZZ")
			print ("[" awk_file "] !!!! Warning !!!! The location type " \
				   "cannot be determined for the record #" FNR ":")		\
				> error_stream
			print ($0) > error_stream
		}

		# ^ PageRank value
		printf ("%s", "^" page_rank)

		# ^ Valid from date ^ Valid until date ^ Comment
		printf ("%s", "^" $6 "^^")

		# ^ Country code ^ Alt. country codes ^ Country name ^ Continent name
		country_code = $17
		time_zone_id = getTimeZone(country_code)
		continent_name = getContinentName(country_code)
		# continent_name = gensub ("/[A-Za-z_]+", "", "g", time_zone_id)
		printf ("%s", "^" country_code "^^" country_code "^" continent_name)

		# ^ Admin1 code ^ Admin1 UTF8 name ^ Admin1 ASCII name
		printf ("%s", "^^^")
		# ^ Admin2 code ^ Admin2 UTF8 name ^ Admin2 ASCII name
		printf ("%s", "^^^")
		# ^ Admin3 code ^ Admin4 code
		printf ("%s", "^^")

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^^^")

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" time_zone_id "^^^")

		# ^ Modification date
		printf ("%s", "^" today_date)

		# ^ City code ^ City UTF8 name ^ City ASCII name ^ Travel-related list
		# Notes:
		#   1. The actual name values are added by the add_city_name.awk script.
		#   2. The city code is the one from the file of best known coordinates,
		#      not the one from Amadeus RFD (as it is sometimes inaccurate).
		printf ("%s", "^" $5 "^"  "^"  "^" )

		# ^ State code
		printf ("%s", "^" $16)

		# ^ Location type
		printf ("%s", "^" location_type)

		# ^ Wiki link (empty here)
		printf ("%s", "^")

		# ^ Section of alternate names (empty here)
		printf ("%s", "^")

		# End of line
		printf ("%s", "\n")

		# ----
		# From ORI-POR ($1 - $6)
		# (1) XIT-R-0 ^ (2) XIT (3) 51.42 ^ (4) 12.42 ^
		# (5) LEJ ^ (6)  ^

		# From RFD ($7 - $24)
		# (7) XIT ^ (8) R ^ (9) LEIPZIG RAIL ^ (10) LEIPZIG HBF RAIL STN ^
		# (11) LEIPZIG RAIL ^ (12) LEIPZIG/HALLE/DE:LEIPZIG HBF R ^
		# (13) LEIPZIG/HALLE ^
		# (14) LEJ ^ (15) Y ^ (16)  ^ (17) DE ^ (18) EUROP ^ (19) ITC2 ^
		# (20) DE040 ^ (21) 51.3 ^ (22) 12.3333 ^ (23)  ^ (24) N

	} else if (NF == 39) {
		####
		## Not in RFD
		####

		# Primary key
		pk = $1

		# Location type (extracted from the primary key)
		location_type = gensub ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$", \
								"\\2", "g", pk)

		# Geonames ID
		geonames_id = gensub ("^([A-Z]{3})-([A-Z]{1,2})-([0-9]{1,10})$", \
							  "\\3", "g", pk)

		# IATA code
		iata_code = $2

		# PageRank value
		page_rank = getPageRank(iata_code, location_type, geonames_id)

		# Is in Geonames?
		geonameID = $10
		isGeonames = "Y"
		if (geonameID == "0" || geonameID == "") {
			isGeonames = "N"
		}

		# IATA code ^ ICAO code ^ FAA ^ Is in Geonames ^ GeonameID ^ Validity ID
		printf ("%s", iata_code "^" $8 "^" $9 "^" isGeonames "^" geonameID "^")

		# ^ Name ^ ASCII name
		printf ("%s", "^" $11 "^" $12)

		# ^ Alternate names
		# printf ("%s", "^" $37)

		# ^ Latitude ^ Longitude ^ Feat. class ^ Feat. code
		printf ("%s", "^" $3 "^" $4 "^" $19 "^" $20)

		# ^ PageRank value
		printf ("%s", "^" page_rank)

		# ^ Valid from date ^ Valid until date ^ Comment
		printf ("%s", "^" $6 "^^")

		# ^ Country code ^ Alt. country codes ^ Country name ^ Continent name
		printf ("%s", "^" $15 "^" $16 "^" $17 "^" $18)

		# ^ Admin1 code ^ Admin1 UTF8 name ^ Admin1 ASCII name
		printf ("%s", "^" $21 "^" $22 "^" $23)
		# ^ Admin2 code ^ Admin2 UTF8 name ^ Admin2 ASCII name
		printf ("%s", "^" $24 "^" $25 "^" $26)
		# ^ Admin3 code ^ Admin4 code
		printf ("%s", "^" $27 "^" $28)

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^" $29 "^" $30 "^" $31)

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" $32 "^" $33 "^" $34 "^" $35)

		# ^ Modification date
		printf ("%s", "^" $36)

		# ^ City code ^ City UTF8 name ^ City ASCII name ^ Travel-related list
		# Notes:
		#   1. The actual name values are added by the add_city_name.awk script.
		#   2. The city code is the one from the file of best known coordinates,
		#      not the one from Amadeus RFD (as it is sometimes inaccurate).
		printf ("%s", "^" $5 "^"  "^"  "^" )

		# ^ State code
		printf ("%s", "^" $21)

		#  ^ Location type
		printf ("%s", "^" location_type)

		# ^ Wiki link (potentially empty)
		printf ("%s", "^" $38)

		##
		# ^ Section of alternate names
		altname_section = $39
		printAltNameSection(altname_section)

		# End of line
		printf ("%s", "\n")

		# ----
		# From ORI-POR ($1 - $6)
		# (1) SQX-CA-7731508 ^ (2) SQX ^ (3) -26.7816 ^ (4) -53.5035 ^ 
		# (5) SQX ^ (6) 7731508 ^

		# From Geonames ($7 - $39)
		# (7) SQX ^ (8) SSOE ^ (9)  ^ (10) 7731508 ^
		# (11) São Miguel do Oeste Airport ^
		# (12) Sao Miguel do Oeste Airport ^ (13) -26.7816 ^ (14) -53.5035 ^
		# (15) BR ^ (16)  ^ (17) Brazil ^ (18) South America ^
		# (19) S ^ (20) AIRP ^
		# (21) 26 ^ (22) Santa Catarina ^ (23) Santa Catarina ^
		# (24) 4204905 ^ (25) Descanso ^ (26) Descanso ^ (27)  ^ (28)  ^
		# (29) 0 ^ (30)  ^ (31) 655 ^ (32) America/Sao_Paulo ^
		# (33) -2.0 ^ (34) -3.0 ^ (35) -3.0 ^ (36) 2011-03-18 ^ (37) SQX,SSOE ^
		# (38)  ^ (39)  

	} else if (NF == 6) {
		####
		## Neither in Geonames nor in RFD
		####
		# Location type (hard-coded to be an airport)
		location_type = "A"

		# Geonames ID
		geonames_id = "0"

		# IATA code
		iata_code = $1

		# PageRank value
		page_rank = getPageRank(iata_code, location_type, geonames_id)

		# Is in Geonames?
		geonameID = "0"
		isGeonames = "N"

		# IATA code ^ ICAO code ^ FAA ^ Is in Geonames ^ GeonameID ^ Validity ID
		printf ("%s", iata_code "^ZZZZ^^" isGeonames "^" geonameID "^") \
			> non_ori_por_file

		# ^ Name ^ ASCII name
		printf ("%s", "^UNKNOWN" unknown_idx "^UNKNOWN" unknown_idx) \
			> non_ori_por_file

		# ^ Alternate names
		# printf ("%s", "^") > non_ori_por_file

		# ^ Latitude ^ Longitude
		printf ("%s", "^" $3 "^" $4) > non_ori_por_file

		#  ^ Feat. class ^ Feat. code
		printf ("%s", "^S^AIRP") > non_ori_por_file

		# ^ PageRank value
		printf ("%s", "^" page_rank) > non_ori_por_file

		# ^ Valid from date ^ Valid until date ^ Comment
		printf ("%s", "^" $6 "^^") > non_ori_por_file

		# ^ Country code ^ Alt. country codes ^ Country name
		printf ("%s", "^" "ZZ" "^" "Zzzzz") > non_ori_por_file

		# ^ Admin1 code ^ Admin1 UTF8 name ^ Admin1 ASCII name
		printf ("%s", "^^^") > non_ori_por_file
		# ^ Admin2 code ^ Admin2 UTF8 name ^ Admin2 ASCII name
		printf ("%s", "^^^") > non_ori_por_file
		# ^ Admin3 code ^ Admin4 code
		printf ("%s", "^^") > non_ori_por_file

		# ^ Population ^ Elevation ^ gtopo30
		printf ("%s", "^^^") > non_ori_por_file

		# ^ Time-zone ^ GMT offset ^ DST offset ^ Raw offset
		printf ("%s", "^" "Europe/Greenwich" "^^^") > non_ori_por_file

		# ^ Modification date
		printf ("%s", "^" today_date) > non_ori_por_file

		# ^ City code ^ City UTF8 name ^ City ASCII name ^ Travel-related list
		printf ("%s", "^" "ZZZ" "^"  "^"  "^" ) > non_ori_por_file

		# ^ State code
		printf ("%s", "^" ) > non_ori_por_file

		#  ^ Location type (the default, i.e., city and airport)
		printf ("%s", "^CA") > non_ori_por_file

		#  ^ Wiki link (empty here)
		printf ("%s", "^") > non_ori_por_file

		#  ^ Section of alternate names  (empty here)
		printf ("%s", "^") > non_ori_por_file

		# End of line
		printf ("%s", "\n") > non_ori_por_file

		# ----
		# From ORI-POR ($1 - $6)
		# (1) SZD-C ^ (2) SZD ^ (3) 53.394256 ^ (4) -1.388486 ^ (5) SZD ^ (6)  

		#
		unknown_idx++

	} else {
		print ("[" awk_file "] !!!! Error for row #" FNR ", having " NF \
			   " fields: " $0) > error_stream
	}

}
