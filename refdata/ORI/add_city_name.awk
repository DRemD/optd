##
# That AWK script:
#  1. Adds the name, in both UTF8 and ASCII encodings, of the served cities.
#  2. Adds the list of travel-related POR IATA codes.
# The ori_por_public.csv data file is parsed twice:
#  * once to store the city names,
#  * the second time to write the corresponding fields in that very same
#    ori_por_public.csv file, which is therefore amended.
#
# As of January 2013:
#  * The city code is the field #36
#  * The city UTF8 name is the field #37
#  * The city ASCII name is the field #38
#  * The list of travel-related POR IATA codes is the field #39
#


##
# States whether that location type corresponds to a travel-related POR
function isTravel(porLocType) {
	is_airport = match (myLocationType, "A")
	is_heliport = match (myLocationType, "H")
	is_rail = match (myLocationType, "R")
	is_bus = match (myLocationType, "B")
	is_port = match (myLocationType, "P")
	is_ground = match (myLocationType, "G")
	is_offpoint = match (myLocationType, "O")
	is_travel = is_airport + is_rail + is_bus + is_heliport + is_port	\
		+ is_ground + is_offpoint

	return is_travel
}

##
#
BEGIN {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "add_city_name.awk"

	#
	idx_file = 0
}


##
#
BEGINFILE {
	#
	idx_file++

	# Sanity check
	if (idx_file >=3) {
		print ("[" awk_file "] !!!! Error - The '" FILENAME "' data file " \
			   "should not be parsed more than twice" ) > error_stream
	}
}

##
# First parsing - extraction of the city (UTF8 and ASCII) names
function extractAndStoreCityNames(porIataCode, porUtfName, porAsciiName, \
								  porLocType) {
	# Parse the location type
	is_city = match (porLocType, "C")
	is_tvl = isTravel(porLocType)

	# Store the names of the point of reference (POR) when it is a city
	if (is_city != 0) {
		name_utf_list[porIataCode] = porUtfName
		name_ascii_list[porIataCode] = porAsciiName
	}
}

##
# First parsing - collection of the travel-related points serving a given city
function collectTravelPoints(porIataCodePk, porIataCodeServed, porLocType) {
	# Store the names of the point of reference (POR) when it is not only a city
	if (porLocType != "C") {
		tvl_por_list = travel_por_list_array[porIataCodeServed]
		if (tvl_por_list == "") {
			travel_por_list_array[porIataCodeServed] = porIataCodePk
		} else {
			travel_por_list_array[porIataCodeServed] =	\
				tvl_por_list "," porIataCodePk
		}
	}
}

##
# Second parsing - writing of the city (UTF8 and ASCII) names
function writeCityNames(porIataCode, porLocType, cityIataCode, \
						porUtfName, porAsciiName) {
	# Output separator
	OFS = FS

	# UTF8 name of the served city
	utfName = name_utf_list[cityIataCode]
	if (utfName == "") {
		utfName = porUtfName
	}
	$37 = utfName

	# ASCII name of the served city
	asciiName = name_ascii_list[cityIataCode]
	if (asciiName == "") {
		asciiName = porAsciiName
	}
	$38 = asciiName
}

##
# Second parsing - writing of the travel-related points serving a given city
function writeTravelPORList(porIataCode, porLocType, cityIataCode) {
	# Parse the location type
	is_city = match (porLocType, "C")

	if (is_city != 0) {
		# Output separator
		OFS = FS

		# Travel-related POR list
		tvl_por_list = travel_por_list_array[cityIataCode]
		$39 = tvl_por_list
	}
}

##
# Header
/^iata_code\^/ {
	if (idx_file == 2) {
		print ($0)
	}
}

##
# Sample input and output lines:
# iata_code^icao_code^faa_code^is_geonames^geoname_id^valid_id^name^asciiname^latitude^longitude^fclass^fcode^page_rank^date_from^date_until^comment^country_code^cc2^country_name^adm1_code^adm1_name_utf^adm1_name_ascii^adm2_code^adm2_name_utf^adm2_name_ascii^adm3_code^adm4_code^population^elevation^gtopo30^timezone^gmt_offset^dst_offset^raw_offset^moddate^city_code^city_name_utf^city_name_ascii^tvl_por_list^state_code^location_type^wiki_link^alt_name_section
#
# IEV^UKKK^^Y^6300960^^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^50.401694^30.449697^S^AIRP^0.0240196752049^^^^UA^^Ukraine^^^^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^IEV^^^^^A^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en|Kyiv Zhuliany International Airport|=en|Kyiv International Airport|=en|Kyiv Airport|s=en|Kiev International Airport|=uk|Міжнародний аеропорт «Київ» (Жуляни)|=ru|Аэропорт «Киев» (Жуляны)|=ru|Международный аеропорт «Киев» (Жуляни)|
#
# NCE^LFMN^^Y^6299418^^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.658411^7.215872^S^AIRP^0.157408761216^^^^FR^^France^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^NCE^^^^^CA^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de|Flughafen Nizza|=en|Nice Côte d'Azur International Airport|=es|Niza Aeropuerto|ps=fr|Aéroport de Nice Côte d'Azur|=en|Nice Airport|s
#
/^([A-Z0-9]{3})\^([A-Z0-9]{0,4})\^([A-Z0-9]{0,4})\^/{

	if (idx_file == 1) {
		# IATA code of the point of reference (POR) itself
		iata_code = $1

		# UTF8 name of the POR itself
		name_utf = $7

		# ASCII name of the POR itself
		name_ascii = $8

		# Served city IATA code
		served_city_code = $36

		# IATA location type
		location_type = $41

		# Store the POR names for the POR IATA code
		extractAndStoreCityNames(iata_code, name_utf, name_ascii, location_type)

		# Collect the travel-related POR IATA code
		collectTravelPoints(iata_code, served_city_code, location_type)

	} else if (idx_file == 2) {
		# IATA code of the point of reference (POR) itself
		iata_code = $1

		# UTF8 name of the POR itself
		name_utf = $7

		# ASCII name of the POR itself
		name_ascii = $8

		# IATA code of the city served by that POR
		city_iata_code = $36

		# IATA location type
		location_type = $41

		# Write the city names for that POR
		writeCityNames(iata_code, location_type, city_iata_code, \
					   name_utf, name_ascii)

		# Write the travel-related points serving a given city
		writeTravelPORList(iata_code, location_type, city_iata_code)

		# Write the full line, amended by the call to the writeCityNames()
		# function
		print ($0)

	} else {
		# Sanity check
		print ("[" awk_file "] !!!! Error - The '" FILENAME "' data file " \
			   "should not be parsed more than twice" ) > error_stream
	}
}
