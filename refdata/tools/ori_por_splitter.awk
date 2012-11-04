##
# That AWK script de-duplicates combined POR (point of reference) entries
# when Geonames has got the full details for every location type of the
# combined entry. For instance, a 'CA' (city and airport) entry may be split
# into a city and an airport when Geonames knows about those two POR
# individually: they can therefore be distinguished.
#
# In the ../ORI/best_coordinates_known_so_far.csv data file, the primary key
# is made of the IATA code and location type. For instance:
#  * ARN-A means the Arlanda airport in Stockholm, Sweden
#  * ARN-R means the Arlanda railway station in Stockholm, Sweden
#  * CDG-A means the Charles de Gaulle airport in Paris, France
#  * PAR-C means the city of Paris, France
#  * NCE-CA means Nice, France, indifferentiating the airport from the city
#  * SFO-A means the San Francisco airport, California, US
#  * SFO-C means the city of San Francisco, California, US
#
# A few examples of IATA location types:
#  * 'C' for city
#  * 'A' for airport
#  * 'CA' for a combination of both
#  * 'H' for heliport
#  * 'R' for railway station
#  * 'B' for bus station,
#  * 'P' for (maritime) port,
#  * 'G' for ground station,
#  * 'O' for off-line point (usually a small city/village or a railway station)
#
# A few examples of Geonames feature codes
# (see http://www.geonames.org/export/codes.html):
#  * PPLx:  Populated place (city)
#  * ADMx:  Administrative division (which may be a city in some cases)
#  * AIRB:  Air base; AIRF: Air field; AIRP: Airport; AIRS: Seaplane landing
#           field
#  * AIRQ:  Abandoned air field
#  * AIRH:  Heliport
#  * FY:    Ferry port
#  * PRT:   Maritime port
#  * RSTN:  Railway station
#  * BUSTN: Bus station; BUSTP: Bus stop
#

# Helper functions
function displayList(myListType, myList) {
	print (myListType ":")
	for (idx in myList) {
		print (idx)
	}
}
function displayLists() {
	displayList("Cities", city_list)
	displayList("Airports", airport_list)
	displayList("Heliports", heliport_list)
	displayList("Railway stations", rail_list)
	displayList("Bus stations", bus_list)
	displayList("Ports", port_list)
	displayList("Ground stations", ground_list)
	displayList("Off-line points", offpoint_list)
}


##
# Derive the boolean values for all the location types, as well as the
# myLocTypes[] array.
#
function deriveLocationTypes(myLocType) {
	# City-related type
	is_city = match (myLocType, "[C]")

	# Travel-related type
	is_airport = match (myLocType, "[A]")
	is_rail = match (myLocType, "[R]")
	is_bus = match (myLocType, "[B]")
	is_heliport = match (myLocType, "[H]")
	is_port = match (myLocType, "[P]")
	is_ground = match (myLocType, "[G]")
	is_offpoint = match (myLocType, "[O]")
	is_travel = is_airport + is_rail + is_bus + is_heliport + is_port	\
		+ is_ground + is_offpoint

	# Remaining location type, when the city is removed
	myRemainingLocType = gensub ("[C]", "", "g", myLocType)

	#
	if (is_city != 0) {
		myLocTypes[0] = "C"
	} else {
		myLocTypes[0] = ""
	}

	#
	myLocTypeSize = length(myRemainingLocType)
	if (myLocTypeSize == 0) {
		# Nothing more to be done at that stage
		# Notification
		if (log_level >= 5) {
			print ("[" awk_file "] !! Notification: the POR #" FNR " and #"	\
				   FNR-1 ", with IATA code=" myIataCode ", have got a rare " \
				   "location type: '" myLocType "'.") > error_stream
		}

	} else if (myLocTypeSize == 1) {
		# A single location type in addition to the city, if that latter exists
		myLocTypes[1] = myRemainingLocType

	} else if (myLocTypeSize == 2) {
		# Several location types in addition to the city, if that latter exists
		for (idx = 1; idx <= myLocTypeSize; idx++) {
			myLocTypes[idx] = substr (myRemainingLocType, idx, 1)
		}

	} else {
		# Several location types in addition to the city, if that latter exists
		for (idx = 1; idx <= myLocTypeSize; idx++) {
			myLocTypes[idx] = substr (myRemainingLocType, idx, 1)
		}

		# Notification
		if (log_level >= 5) {
			print ("[" awk_file "] !! Notification: the POR #" FNR " and #"	\
				   FNR-1 ", with IATA code=" myIataCode ", have got a rare " \
				   "location type: '" myLocType "'.") > error_stream
		}
	}
	#return myLocTypes
}


##
# The POR/lines have to be combined or split the same way as in the ORI list:
#  - A single, combined, POR for a 'CX' location type (X = A, H, B, R, P, O, G)
#  - One POR by other location type (e.g., 'C', 'A', 'H', 'R', 'B', 'P', 'O',
#    'G')
#
function displayPOR(myIataCode, myTravelLine, myCityLine, myNbOfPOR) {

	# DEBUG
	# print ("[" myIataCode "] myNbOfPOR=" myNbOfPOR) > error_stream

	# Retrieve the full location type from the ORI-maintained list
	myLocationType = location_type_list[myIataCode]
	myLocationTypeAlt = location_type_alt_list[myIataCode]

	if (myNbOfPOR >= 2) {
		# There are two POR in Geonames sharing the same IATA code

		# Derive the boolean values for all the location types, as well as the
		# myLocTypes[] array.
		deriveLocationTypes(myLocationType)

		if (myIataCode in combined_list) {
			# The location type is made of several characters (by construction
			# of the 'combined_list' list).

			# Sanity check
			if (myLocTypes[0] != "C" || myLocTypes[1] == "") {
				print ("[" awk_file "] !! Error: the POR #" FNR " and #" FNR-1 \
					   ", with IATA code=" myIataCode ", should have a " \
					   "combined location type, but they do not. Location " \
					   "type: '" myLocationType "'. Both POR:\n"		\
					   myTravelLine "\n" myCityLine) > error_stream
			}

			# The travel-related POR will inherit from the location type
			# associated (by ORI) to that POR. The city POR will be left
			# untouched.
			print (myIataCode "-" myLocTypes[1] "^" myTravelLine)
			print (myIataCode "-C" "^" myCityLine)

		} else if (myLocationTypeAlt == "") {
			# The location type is made of a single character (otherwise, that
			# POR would be part of the 'combined_list' list, by construction of
			# that latter).
			#
			# Moreover, there is no alternate location type for that IATA code,
			# meaning that there is a single line in the ORI-maintained list.
			# Typically, the location type is 'O', standing for off-line point.

			if (is_travel >= 1) {
				# The travel-related POR will inherit from the location type
				# associated (by ORI) to that POR. The city POR will be left
				# untouched.

				# Sanity check
				if (myLocTypes[0] == "C" || myLocTypes[1] == "") {
					print ("[" awk_file "] !! Error: the POR #" FNR " and #" \
						   FNR-1 ", with IATA code=" myIataCode ", should " \
						   "have a location type with no city, but they don't." \
						   " Location type: '" myLocationType "'. Both POR:\n" \
						   myTravelLine "\n" myCityLine) > error_stream
				}

				if (length(myLocTypes) >= 3) {
					myOtherLocType = myLocTypes[2]
				} else {
					myOtherLocType = myLocTypes[1]
				}

				print (myIataCode "-" myLocTypes[1] "^" myTravelLine)
				print (myIataCode "-" myOtherLocType "^" myCityLine)

			} else if (is_city >= 1) {
				# The city POR will inherit from the location type associated
				# (by ORI) to that POR. The travel-related POR will be left
				# untouched.

				# Sanity check
				if (myLocTypes[0] != "C" || myLocTypes[1] != "") {
					print ("[" awk_file "] !! Error: the POR #" FNR " and #" \
						   FNR-1 ", with IATA code=" myIataCode ", should " \
						   "have a city as location type, but they do not." \
						   " Location type: '" myLocationType "'. Both POR:\n" \
						   myTravelLine "\n" myCityLine) > error_stream
				}

				if (length(myLocTypes) >= 2) {
					myOtherLocType = myLocTypes[1]
				} else {
					myOtherLocType = "C"
				}

				print (myIataCode "-" myOtherLocType "^" myTravelLine)
				print (myIataCode "-C" "^" myCityLine)

			} else {
				# Notification
				print ("[" awk_file "] !! Error: the POR #" FNR " and #" FNR-1 \
					   ", with IATA code=" myIataCode					\
					   ", are distinct in Geonames, but combined "		\
					   " in the ORI-maintained list. However, the location"	\
					   "type ('" myLocationType "') is unknown. Both POR:\n" \
					   myTravelLine "\n" myCityLine) > error_stream
			}

		} else {
			# The ORI-maintained list does provide two distinct lines for that
			# IATA code, exactly like for Geonames. So, there is nothing more
			# to be done at that stage.
		}

	} else {
		# Sanity check: that function is called only when there are several
		# entries for that IATA code.
		# Notification
		print ("[" awk_file "] !! Error: the POR #" FNR " and #" FNR-1	\
			   ", with IATA code=" myIataCode							\
			   ", have supposedly the same IATA code, but the number of POR " \
			   "is equal to 1. That is a code error, not recoverable. " \
			   "Both POR:\n"											\
			   myTravelLine "\n" myCityLine) > error_stream
	}
}


##
#
BEGINFILE {
	# Global variables
	error_stream = "/dev/stderr"
	awk_file = "ori_por_splitter.awk"

	#
	last_iata_code = ""
	last_location_type = ""
	last_pk = ""
	last_pk_alt = ""
	last_full_line = ""
	last_is_city = 0
	last_is_travel = 0
	last_city_line = ""
	last_travel_line = ""
	nb_of_por = 0
	last_nb_of_por = 0
}

##
# The ../ORI/best_coordinates_known_so_far.csv data file is used, in order to
# specify the POR primary key and its location type.
#
# Sample lines:
#  ALV-O^ALV^40.98^0.45^ALV^         (1 line in ORI, 2 lines in Geonames)
#  ARN-A^ARN^59.651944^17.918611^STO^(2 lines in ORI, split from a combined line,
#  ARN-R^ARN^59.649463^17.929^STO^    1 line in Geonames)
#  IES-CA^IES^51.3^13.28^IES^        (1 combined line in ORI, 1 line in Geonames)
#  IEV-A^IEV^50.401694^30.449697^IEV^(2 lines in ORI, split from a combined line,
#  IEV-C^IEV^50.401694^30.449697^IEV^ 2 lines in Geonames)
#  KBP-A^KBP^50.345^30.894722^IEV^   (1 line in ORI, 1 line in Geonames)
#  LHR-A^LHR^51.4775^-0.461389^LON^  (1 line in ORI, 1 line in Geonames)
#  LON-C^LON^51.5^-0.1667^LON^       (1 line in ORI, 1 line in Geonames)
#  NCE-CA^NCE^43.658411^7.215872^NCE^(1 combined line in ORI 2 lines in Geonames)
#
/^([A-Z]{3})-([A-Z]{1,2})\^([A-Z]{3})\^/ {

	# Primary key (combination of IATA code and location type)
	pk = $1

	# IATA code
	iata_code = $2

	# Location type
	location_type = substr (pk, 5)

	# Check whether the POR is a city. It can be a city only or, most often,
	# a combination of a city with a travel-related type (e.g., airport,
	# rail station). In some rare cases, an airport may be combined with
	# something else than a city (e.g., railway station); ARN is such
	# an example, and CDG might be another one.
	is_city = match (location_type, "[C]")

	# Travel-related type
	is_airport = match (location_type, "[A]")
	is_rail = match (location_type, "[R]")
	is_bus = match (location_type, "[B]")
	is_heliport = match (location_type, "[H]")
	is_port = match (location_type, "[P]")
	is_ground = match (location_type, "[G]")
	is_offpoint = match (location_type, "[O]")
	is_travel = is_airport + is_heliport + is_rail + is_bus + is_port \
		+ is_ground + is_offpoint

	# Sanity check
	if (length(location_type) >= 2 && is_travel == 0) {
		print ("[" awk_file "] !!!! Error at line #" FNR		\
			   ", the location type ('" location_type			\
			   "') is unknown - Full line: " $0) > error_stream
	}

	# Store the location types. If there are two location types for that POR,
	# the first should be the travel-related one and the second should be
	# the city.
	# Note that in some rare cases (e.g., ARN-AR, i.e. Stockholm Arlanda airport
	# and railway station, both serving STO-C), the location type is combined
	# ('AR' here), but there is no city.
	last_location_type = location_type_list[iata_code]
	if (last_location_type == "") {
		# No location type has been registered yet
		location_type_list[iata_code] = location_type

	} else {
		# A location type has already been registered
		is_last_city = match (last_location_type, "[C]")
		is_last_airport = match (last_location_type, "[A]")
		is_last_rail = match (last_location_type, "[R]")
		is_last_bus = match (last_location_type, "[B]")
		is_last_heliport = match (last_location_type, "[H]")
		is_last_port = match (last_location_type, "[P]")
		is_last_ground = match (last_location_type, "[G]")
		is_last_offpoint = match (last_location_type, "[O]")
		is_last_travel = is_last_airport + is_last_rail + is_last_bus \
			+ is_last_heliport + is_last_port + is_last_ground + is_last_offpoint

		if (is_last_city == 1) {
			# The previously registered location type is a city. So, it is now
			# re-registered in second position. The first position is devoted to
			# the travel-related POR.
			location_type_list[iata_code] = location_type
			location_type_alt_list[iata_code] = last_location_type

			# Sanity check: the new location type should be travel-related
			if (is_travel == 0) {
				print ("[" awk_file "] !!!! Rare case at line #" FNR \
					   ", there are at least two location types ('" \
					   last_location_type "' and '" location_type \
					   "'), but the latter one is neither a city nor" \
					   " travel-related - Full line: " $0) > error_stream
			}

		} else if (is_city == 1) {
			# The city is the new location type; the previously
			# registered one must then be travel-related.
			location_type_list[iata_code] = last_location_type
			location_type_alt_list[iata_code] = location_type

			# Sanity check: the last location type should be travel-related
			if (is_last_travel == 0) {
				print ("[" awk_file "] !!!! Rare case at line #" FNR \
					   ", there are at least two location types ('" \
					   last_location_type "' and '" location_type \
					   "'), but the former one is neither a city nor" \
					   " travel-related - Full line: " $0) > error_stream
			}

		} else {
			# Neither the previously registered location type nor the current
			# one is a city. So, if there is an airport, it will be registered
			# in the first position; otherwise, the alphabetical order of
			# the location type is used by construction.
			if (is_last_airport == 1) {
				location_type_list[iata_code] = last_location_type
				location_type_alt_list[iata_code] = location_type

			} else if (is_airport == 1) {
				location_type_list[iata_code] = location_type
				location_type_alt_list[iata_code] = last_location_type

			} else {
				location_type_alt_list[iata_code] = location_type
			}
		}
	}

	#
	if (is_city != 0) {
		city_list[iata_code] = 1

		if (is_travel != 0) {
			combined_list[iata_code] = 1
		}
	}

	if (is_travel != 0) {
		travel_list[iata_code] = 1
	}

	if (is_airport != 0) {
		airport_list[iata_code] = 1
	}

	if (is_rail != 0) {
		rail_list[iata_code] = 1
	}

	if (is_bus != 0) {
		bus_list[iata_code] = 1
	}

	if (is_ground != 0) {
		ground_list[iata_code] = 1
	}

	if (is_heliport != 0) {
		heliport_list[iata_code] = 1
	}

	if (is_port != 0) {
		port_list[iata_code] = 1
	}

	if (is_offpoint != 0) {
		offpoint_list[iata_code] = 1
	}
}


####
## Geonames dump file

##
# Geonames header line
/^iata_code/ {
	print ("pk^" $0)
}

##
# Geonames regular lines
# Sample lines (truncated):
#  IEV^UKKK^^6300960^Kyiv Zhuliany International Airport^Kyiv Zhuliany International Airport^50.40169^30.4497^UA^^Ukraine^S^AIRP^^^^^^^^^0^178^174^Europe/Kiev^2.0^3.0^2.0^2012-06-03^Kyiv Airport,...^http://en.wikipedia.org/wiki/Kyiv_Zhuliany_International_Airport^en|Kyiv Zhuliany International Airport|
#  IEV^ZZZZ^^703448^Kiev^Kiev^50.45466^30.5238^UA^^Ukraine^P^PPLC^12^Kyiv City^Kyiv City^^^^^^2514227^^187^Europe/Kiev^2.0^3.0^2.0^2012-08-18^Kiev,...,Київ^http://en.wikipedia.org/wiki/Kiev^en|Kiev|h|en|Kyiv|p
#  LHR^EGLL^^2647216^London Heathrow Airport^London Heathrow Airport^51.47115^-0.45649^GB^^United Kingdom^S^AIRP^ENG^England^England^GLA^Greater London^Greater London^F9^^0^^27^Europe/London^0.0^1.0^0.0^2010-08-03^London Heathrow,...,伦敦 海斯楼 飞机场,倫敦希斯路機場,런던 히드로 공항^http://en.wikipedia.org/wiki/London_Heathrow_Airport^en|Heathrow Airport||en|Heathrow|s
#  LON^ZZZZ^^2643743^London^London^51.50853^-0.12574^GB^^United Kingdom^P^PPLC^ENG^England^England^GLA^Greater London^Greater London^^^7556900^^25^Europe/London^0.0^1.0^0.0^2012-08-19^City of London,...伦敦,倫敦^http://en.wikipedia.org/wiki/London^en|London|p|en|London City|
#  NCE^LFMN^^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.66272^7.20787^FR^^France^S^AIRP^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^0^3^-9999^Europe/Paris^1.0^2.0^1.0^2012-06-30^Nice Airport,...^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^en|Nice Airport|s
#  NCE^ZZZZ^^2990440^Nice^Nice^43.70313^7.26608^FR^^France^P^PPLA2^B8^Provence-Alpes-Côte d'Azur^Provence-Alpes-Cote d'Azur^06^Département des Alpes-Maritimes^Departement des Alpes-Maritimes^062^06088^338620^25^18^Europe/Paris^1.0^2.0^1.0^2011-11-02^Nice,...,Ница,尼斯^http://en.wikipedia.org/wiki/Nice^en|Nice||ru|Ницца|
#
/^([A-Z]{3})\^([A-Z0-9]{4})\^([A-Z0-9]{0,4})\^([0-9]{1,10})\^/ {
	#
	nb_of_por++

	# IATA code
	iata_code = $1

	# ICAO code
	icao_code = $2

	# FAA code
	faa_code = $3

	# Feature code
	fcode = $13

	#
	is_city = match (fcode, "PPL") + match (fcode, "ADM")

	is_airport = match (fcode, "AIRB") + match (fcode, "AIRF") \
		+ match (fcode, "AIRP") + match (fcode, "AIRS")
	is_rail = match (fcode, "RSTN")
	is_bus = match (fcode, "BUST")
	is_heliport = match (fcode, "AIRH")
	is_port = match (fcode, "NVB") + match (fcode, "PRT") + match (fcode, "FY")
	is_travel = is_airport + is_rail + is_bus + is_heliport + is_port

	# Store the full line
	full_line = $0
	city_line = full_line
	travel_line = full_line

	# ORI-maintained location type
	location_type = location_type_list[iata_code]
	location_type_alt = location_type_alt_list[iata_code]

	# Sanity check: the POR should be known from ORI
	if (location_type == "") {
  		print ("[" awk_file "] !!!! Error at line #" FNR	\
			   ", the POR with that IATA code ('" iata_code \
			   "') is not referenced in the ORI-maintained list: " full_line) \
			> error_stream
	}

	# New primary key, made of the IATA code and ORI-maintained location type
	pk = iata_code "-" location_type
	pk_alt = iata_code "-" location_type_alt

	if (iata_code == last_iata_code) {
		# This is (at least) the second POR sharing the same IATA code.
		# Normally, the second POR is a city, and the first POR is
		# travel-related (e.g., airport, railway station).

		# Sanity check (there should not be more than two POR with the
		# same IATA code).
		if (nb_of_por >= 3) {
			print ("[" awk_file "] !!!! Error at line #" FNR \
				   ", there are over two POR with the same IATA code ('" \
				   iata_code "') - Last line: " full_line) > error_stream
		}

		if (last_is_city != 0) {
			# The previous POR is the city.
			travel_line = full_line
			city_line = last_full_line

			# Sanith check: the other POR should be travel-related
			# (e.g., airport, heliport, railway station, off-point).
			if (is_travel == 0) {
				print ("[" awk_file "] !!!! Error for the POR #" FNR \
					   " and #" FNR-1 ", with IATA code=" iata_code \
					   ". The first POR is a"							\
					   " city, but the second one is not travel-related." \
					   " Both POR:\n" last_full_line "\n" full_line) \
					> error_stream
			}

		} else if (is_city == 1) {
			# The current POR is the city.
			travel_line = last_full_line
			city_line = full_line

			# Sanith check: the other POR should be travel-related
			# (e.g., airport, heliport, railway station, off-point).
			if (last_is_travel == 0) {
				print ("[" awk_file "] !!!! Error for the POR #" FNR \
					   " and #" FNR-1 ", with IATA code=" iata_code \
					   ". The second POR is a city, but the first one is not" \
					   " travel-related. Both POR:\n" last_full_line "\n" \
					   full_line) > error_stream
			}

		} else {
			# Neither POR is a city. It is a rare case, such as ARN-AR (Arlanda
			# airport and railway station; the served city is STO/Stockholm).
			# The display then respects the input:
			# last line first, new line second (in the displayPOR() function,
			# the city POR is displayed second).
			travel_line = last_full_line
			city_line = full_line
		}

		# Display the POR entries, only when the IATA code is specified in the
		# ORI-maintained list (and, hence, the location type is defined).
		if (location_type != "") {
			displayPOR(iata_code, travel_line, city_line, nb_of_por)
		}

	} else {
		# This is a POR entry with a IATA code different from the last POR entry.
		# Geonames has therefore no more information than ORI for that POR.
		nb_of_por = 1
	}

	# Iteration
	last_iata_code = iata_code
	last_location_type = location_type
	last_pk = pk
	last_pk_alt = pk_alt
	last_full_line = full_line
	last_city_line = city_line
	last_travel_line = travel_line
	last_is_city = is_city
	last_is_travel = is_travel
	last_nb_of_por = nb_of_por
}

#
ENDFILE {
	# DEBUG
	#displayLists()
}

