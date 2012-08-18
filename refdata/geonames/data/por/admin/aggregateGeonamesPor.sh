#!/bin/bash

##
# That Shell script, helped by AWK, concatenates the alternate name details,
# and add them back to the line of details for every Geoname POR.
#
# There are two input files, normally 'alternateNames.txt' for the
# alternate name details, and 'allCountries.txt' for the details of every
# Geoname POR (Point Of Reference).

##
# Log level
LOG_LEVEL=4

##
# Temporary path
TMP_DIR="/tmp/por"

##
# Path of the executable: set it to empty when this is the current directory.
EXEC_PATH=`dirname $0`
# Trick to get the actual full-path
EXEC_FULL_PATH=`pushd ${EXEC_PATH}`
EXEC_FULL_PATH=`echo ${EXEC_FULL_PATH} | cut -d' ' -f1`
EXEC_FULL_PATH=`echo ${EXEC_FULL_PATH} | sed -e 's|~|'${HOME}'|'`
#
CURRENT_DIR=`pwd`
if [ ${CURRENT_DIR} -ef ${EXEC_PATH} ]
then
	EXEC_PATH="."
	TMP_DIR="."
fi
# If the Geonames dump file is in the current directory, then the current
# directory is certainly intended to be the temporary directory.
if [ -f ${GEO_RAW_FILENAME} ]
then
	TMP_DIR="."
fi
EXEC_PATH="${EXEC_PATH}/"
TMP_DIR="${TMP_DIR}/"

if [ ! -d ${TMP_DIR} -o ! -w ${TMP_DIR} ]
then
	\mkdir -p ${TMP_DIR}
fi

##
# Sanity check: that (executable) script should be located in the admin/
# sub-directory of the OpenTravelData project Git clone
EXEC_DIR_NAME=`basename ${EXEC_FULL_PATH}`
if [ "${EXEC_DIR_NAME}" != "admin" ]
then
	echo
	echo "[$0:$LINENO] Inconsistency error: this script ($0) should be located in the refdata/geonames/data/por/admin/ sub-directory of the OpenTravelData project Git clone, but apparently is not. EXEC_FULL_PATH=\"${EXEC_FULL_PATH}\""
	echo
	exit -1
fi

##
# OpenTravelData Geonames-related directory
GEO_POR_DIR=`dirname ${EXEC_FULL_PATH}`
GEO_POR_DIR="${GEO_POR_DIR}/"

##
# Admin sub-directory
DATA_DIR=${EXEC_PATH}../data/

# Input data files
GEO_TZ_FILENAME=timeZones.txt
GEO_POR_FILENAME=allCountries.txt
GEO_POR_ALT_FILENAME=alternateNames.txt
#
GEO_TZ_FILE=${DATA_DIR}${GEO_TZ_FILENAME}
GEO_POR_FILE=${DATA_DIR}${GEO_POR_FILENAME}
GEO_POR_ALT_FILE=${DATA_DIR}${GEO_POR_ALT_FILENAME}

# Output data file
GEO_POR_CONC_FILENAME=allCountries_w_alt.txt
GEO_POR_CONC_FILE=${DATA_DIR}${GEO_POR_CONC_FILENAME}

# Reference details for the Nice airport (IATA/ICAO codes: NCE/LFMN, Geoname ID: 6299418)
NCE_POR_REF="NCE^LFMN^6299418^Nice Côte d'Azur International Airport^Nice Cote d'Azur International Airport^43.66272^7.20787^FR^^S^AIRP^B8^06^062^06088^0^3^-9999^Europe/Paris^^^^^Aeroport de Nice Cote d'Azur,Aéroport de Nice Côte d'Azur,Flughafen Nizza,LFMN,NCE,Nice Airport,Nice Cote d'Azur International Airport,Nice Côte d'Azur International Airport,Niza Aeropuerto^http://en.wikipedia.org/wiki/Nice_C%C3%B4te_d%27Azur_Airport^de^Flughafen Nizza^^en^Nice Côte d'Azur International Airport^^es^Niza Aeropuerto^ps^fr^Aéroport de Nice Côte d'Azur^^en^Nice Airport^s"

##
# Usage
if [ "$1" = "-h" -o "$1" = "--help" ]
then
	echo
	echo "Usage: $0 [<log level>]"
	echo "  - Default refdata Geonames-related directory for the OpenTravelData project Git clone: '${DATA_DIR}'"
	echo "  - Default log level: ${LOG_LEVEL}"
	echo "    + 0: No log; 1: Critical; 2: Error; 3; Notification; 4: Debug; 5: Verbose"
	echo "  - Generated files:"
	echo "    + '${GEO_POR_CONC_FILE}'"
	echo
	exit
fi

##
# Log level
if [ "$1" != "" ]
then
	LOG_LEVEL="$1"
fi

##
# Check that the line format has not been changed and/or for outliers.
#
# Note that, contrary to awk, grep takes \t as a mere 't' (\t is not a POSIX
# standard). So, the \t of awk must be replaced by actual TAB characters,
# which may be entered thanks to the <CTRL-q TAB> sequence in Emacs and
# <CTRL-v TAB> sequence in the Shell command-line.
#
# Test 1 - Count the lines with the given regex
# The following three commands:
# grep "^\([A-Z]\{2\}\)<TAB>.*<TAB>\([0-9.-]*\)<TAB>\([0-9.-]*\)<TAB>\([0-9.-]*\)$" ${GEO_TZ_FILE} | wc -l
# grep "^\([0-9]\{1,9\}\)<TAB>.*<TAB>\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)$" ${GEO_POR_FILE} | wc -l
# grep "^\([0-9]\{1,9\}\)<TAB>\([0-9]\{1,9\}\)<TAB>\([a-z]\{0,5\}[_]\{0,1\}[0-9]\{0,4\}\)<TAB>" ${GEO_POR_ALT_FILE} | wc -l
# should give the same result as:
# wc -l ${GEO_TZ_FILE} ${GEO_POR_FILE} ${GEO_POR_ALT_FILE}
#
# Test 2 - Output the lines not matching the regex
# The following commands should yield empty results:
# grep -nv "^\([A-Z]\{2\}\)<TAB>.*<TAB>\([0-9.-]*\)<TAB>\([0-9.-]*\)<TAB>\([0-9.-]*\)$" ${GEO_TZ_FILE}
# grep -nv "^\([0-9]\{1,9\}\)<TAB>.*<TAB>\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)$" ${GEO_POR_FILE}
# grep -nv "^\([0-9]\{1,9\}\)<TAB>\([0-9]\{1,9\}\)<TAB>\([a-z]\{0,5\}[_]\{0,1\}[0-9]\{0,4\}\)<TAB>" ${GEO_POR_ALT_FILE}
#
# Test 3 - Output the lines of the other files matching the regex
# The following commands should yield empty results:
# grep -n "^\([A-Z]\{2\}\)<TAB>.*<TAB>\([0-9.-]*\)<TAB>\([0-9.-]*\)<TAB>\([0-9.-]*\)$" ${GEO_POR_FILE} ${GEO_POR_ALT_FILE}
# grep -n "^\([0-9]\{1,9\}\)<TAB>.*<TAB>\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)$" ${GEO_TZ_FILE} ${GEO_POR_ALT_FILE}
# grep -n "^\([0-9]\{1,9\}\)<TAB>\([0-9]\{1,9\}\)<TAB>\([a-z]\{0,5\}[_]\{0,1\}[0-9]\{0,4\}\)<TAB>" ${GEO_TZ_FILE} ${GEO_POR_FILE}

##
# Concatenate the alternate name details, and add them back to the line of
# details for every Geoname POR.
AGGREGATOR=aggregateGeonamesPor.awk
echo
echo "Aggregating '${GEO_POR_ALT_FILE}' and '${GEO_POR_FILE}' input files..."
time awk -F'\t' -v log_level=${LOG_LEVEL} -f ${AGGREGATOR} ${GEO_TZ_FILE} ${GEO_POR_ALT_FILE} ${GEO_POR_FILE} > ${GEO_POR_CONC_FILE}
echo "... done"
echo

##
# Reporting
echo
echo "The '${GEO_POR_CONC_FILE}' file has been generated from both the '${GEO_POR_ALT_FILE}' and '${GEO_POR_FILE}' input files."
echo

# Check #1
echo "Simple check #1 (the size of the output file should be roughly equal to the sum of the sizes of the input files): ls -lh ${GEO_POR_ALT_FILE} ${GEO_POR_FILE} ${GEO_POR_CONC_FILE}"
ls -lh ${GEO_POR_ALT_FILE} ${GEO_POR_FILE} ${GEO_POR_CONC_FILE}
echo

# Check #2
echo "Simple check #2: wc -l ${GEO_POR_ALT_FILE} ${GEO_POR_FILE} ${GEO_POR_CONC_FILE}"
time wc -l ${GEO_POR_ALT_FILE} ${GEO_POR_FILE} ${GEO_POR_CONC_FILE}
echo

# Check #3
echo "Simple check #3: grep -n \"^NCE\^LFMN\" ${GEO_POR_CONC_FILE}"
NCE_POR=`grep "^NCE\^LFMN" ${GEO_POR_CONC_FILE}`
if [ "${NCE_POR}" = "${NCE_POR_REF}" ]
then
	echo "	Strings are equal"
else
	echo "	Strings are not equal. Someone may have added some alternate names?"
	echo "	Compare (result of grep -n \"^NCE\^LFMN\" ${GEO_POR_CONC_FILE}):"
	echo "	${NCE_POR}"
	echo "	to (reference):"
	echo "	${NCE_POR_REF}"
fi
echo

#
echo
