#!/bin/bash
#
# Four parameters are optional for this script:
# - the Geonames data dump file, only for its geographical coordinates
# - the ORI-maintained list of "best known" geographical coordinates
# - the ORI-maintained list of POR importance (i.e., PageRank) figures
# - the minimal distance (in km) triggering a difference
#

##
# Temporary path
TMP_DIR="/tmp/por"

##
# Path of the executable: set it to empty when this is the current directory.
EXEC_PATH=`dirname $0`
CURRENT_DIR=`pwd`
if [ ${CURRENT_DIR} -ef ${EXEC_PATH} ]
then
	EXEC_PATH="."
	TMP_DIR="."
fi
EXEC_PATH="${EXEC_PATH}/"
TMP_DIR="${TMP_DIR}/"

if [ ! -d ${TMP_DIR} -o ! -w ${TMP_DIR} ]
then
	\mkdir -p ${TMP_DIR}
fi

##
# Log level
LOG_LEVEL=3

##
# ORI path
OPTD_DIR_DIR=${EXEC_PATH}../
ORI_DIR=${OPTD_DIR_DIR}ORI/

##
# Geonames data dump file
GEONAME_FILE_RAW_FILENAME=dump_from_geonames.csv
GEONAME_FILENAME=wpk_${GEONAME_FILE_RAW_FILENAME}
GEONAME_FILE_SORTED=sorted_${GEONAME_FILENAME}
GEONAME_FILE_SORTED_CUT=cut_${GEONAME_FILE_SORTED}
#
GEONAME_FILE_RAW=${TMP_DIR}${GEONAME_FILE_RAW_FILENAME}
GEONAME_FILE=${TMP_DIR}${GEONAME_FILENAME}

##
# ORI-maintained list of "best known" geographical coordinates
ORI_BEST_FILENAME=best_coordinates_known_so_far.csv
#
ORI_BEST_FILE=${ORI_DIR}${ORI_BEST_FILENAME}

##
# ORI-maintained list of POR importance (i.e., PageRank) figures
AIRPORT_PR_FILENAME=ref_airport_pageranked.csv
AIRPORT_PR_SORTED=sorted_${AIRPORT_PR_FILENAME}
AIRPORT_PR_SORTED_CUT=cut_sorted_${AIRPORT_PR_FILENAME}
#
AIRPORT_PR_FILE=${ORI_DIR}${AIRPORT_PR_FILENAME}

##
# [No longer used]
# ORI-maintained list of POR popularity details
AIRPORT_POP_FILENAME=ref_airport_popularity.csv
AIRPORT_POP_SORTED=sorted_${AIRPORT_POP_FILENAME}
AIRPORT_POP_SORTED_CUT=cut_sorted_${AIRPORT_POP_FILENAME}
#
AIRPORT_POP=${ORI_DIR}${AIRPORT_POP_FILENAME}

##
# Comparison files
POR_MAIN_DIFF_FILENAME=por_main_diff.csv
#
POR_MAIN_DIFF=${TMP_DIR}${POR_MAIN_DIFF_FILENAME}

# Minimal distance triggering a difference (in km)
COMP_MIN_DIST=10

##
# Missing POR
GEONAME_FILE_MISSING=${GEONAME_FILE}.missing
ORI_BEST_FILE_MISSING=${ORI_BEST_FILE}.missing


##
# Temporary files
GEO_COMBINED_TMP_FILE=geo_combined_file.csv.tmp


##
# Usage helper
#
if [ "$1" = "-h" -o "$1" = "--help" ]
then
	echo
	echo "Usage: $0 [<Geonames data dump file> [<ORI file of best known coordinates> [<PageRanked POR file>] [<minimum distance>]]]]"
	echo " - Default name for the Geonames data dump file: '${GEONAME_FILE_RAW}'"
	echo " - Default name for the ORI-maintained file of best known coordinates: '${ORI_BEST_FILE}'"
	echo " - Default name for the PageRanked POR file: '${AIRPORT_PR_FILE}'"
	echo " - Default minimum distance (in km) triggering a difference: '${COMP_MIN_DIST}'"
	echo
	exit
fi


##
# Cleaning
#
if [ "$1" = "--clean" ]
then
	if [ "${TMP_DIR}" = "/tmp/por/" ]
	then
		\rm -rf ${TMP_DIR}
	else
		\rm -f ${GEONAME_FILE_MISSING} ${ORI_BEST_FILE_MISSING} \
			${GEONAME_FILE} ${GEONAME_FILE_SORTED} ${GEONAME_FILE_SORTED_CUT} \
			${AIRPORT_PR_SORTED} ${AIRPORT_PR_SORTED_CUT} ${POR_MAIN_DIFF}
	fi
	exit
fi


##
# Local helper scripts
PREPARE_EXEC="bash ${EXEC_PATH}prepare_geonames_dump_file.sh"
PREPARE_POP_EXEC="bash ${EXEC_PATH}prepare_popularity.sh"
PREPARE_PR_EXEC="bash ${EXEC_PATH}prepare_pagerank.sh"
COMPARE_EXEC="bash ${EXEC_PATH}compare_geo_files.sh"


##
# Geonames data dump file
if [ "$1" != "" ];
then
	GEONAME_FILE_RAW=$1
	GEONAME_FILE_RAW_FILENAME=`basename ${GEONAME_FILE_RAW}`
	GEONAME_FILENAME=wpk_${GEONAME_FILE_RAW_FILENAME}
	GEONAME_FILE_SORTED=sorted_${GEONAME_FILENAME}
	GEONAME_FILE_SORTED_CUT=cut_${GEONAME_FILE_SORTED}
	if [ "${GEONAME_FILE_RAW}" = "${GEONAME_FILE_RAW_FILENAME}" ]
	then
		GEONAME_FILE_RAW="${TMP_DIR}${GEONAME_FILE_RAW_FILENAME}"
	fi
fi
GEONAME_FILE=${TMP_DIR}${GEONAME_FILENAME}
GEONAME_FILE_SORTED=${TMP_DIR}${GEONAME_FILE_SORTED}
GEONAME_FILE_SORTED_CUT=${TMP_DIR}${GEONAME_FILE_SORTED_CUT}

if [ ! -f "${GEONAME_FILE_RAW}" ]
then
	echo
	echo "[$0:$LINENO] The '${GEONAME_FILE_RAW}' file does not exist."
	if [ "$1" = "" ];
	then
		${PREPARE_EXEC} --geonames
		echo "The default name of the Geonames data dump copy is '${GEONAME_FILE_RAW}'."
		echo
	fi
	exit -1
fi


##
# Prepare the Geonames dump file, downloaded from Geonames and pre-processed.
# Basically, a primary key is added and the coordinates are extracted,
# in order to keep a data file with only four fields/columns:
#  * The primary key (IATA code - location type)
#  * The airport/city code
#  * The geographical coordinates.
${PREPARE_EXEC} ${OPTD_DIR_DIR} ${LOG_LEVEL}


# ORI-maintained list of "best known" geographical coordinates
if [ "$2" != "" ];
then
	ORI_BEST_FILE="$2"
fi

if [ ! -f "${ORI_BEST_FILE}" ]
then
	echo
	echo "[$0:$LINENO] The '${ORI_BEST_FILE}' file does not exist."
	if [ "$2" = "" ];
	then
		echo
		echo "Hint:"
		echo "\cp -f ${EXEC_PATH}../ORI/${ORI_BEST_FILENAME} ${TMP_DIR}"
		echo
	fi
	exit -1
fi


##
# Data file of PageRanked POR
if [ "$3" != "" ];
then
	AIRPORT_PR_FILE=$3
	AIRPORT_PR_FILENAME=`basename ${AIRPORT_PR_FILE}`
	AIRPORT_PR_SORTED=sorted_${AIRPORT_PR_FILENAME}
	AIRPORT_PR_SORTED_CUT=cut_${AIRPORT_PR_SORTED}
	if [ "${AIRPORT_PR_FILE}" = "${AIRPORT_PR_FILENAME}" ]
	then
		AIRPORT_PR_FILE="${TMP_DIR}${AIRPORT_PR_FILENAME}"
	fi
fi
AIRPORT_PR_SORTED=${TMP_DIR}${AIRPORT_PR_SORTED}
AIRPORT_PR_SORTED_CUT=${TMP_DIR}${AIRPORT_PR_SORTED_CUT}

if [ ! -f "${AIRPORT_PR_FILE}" ]
then
	echo
	echo "[$0:$LINENO] The '${AIRPORT_PR_FILE}' file does not exist."
	if [ "$3" = "" ];
	then
		${PREPARE_PR_EXEC} --popularity
		echo "The default name of the airport popularity copy is '${AIRPORT_PR_FILE}'."
		echo
	fi
	exit -1
fi


##
# Prepare the ORI-maintained airport popularity dump file. Basically, the file
# is sorted by IATA code. Then, only two columns/fields are kept in that
# version of the file: the airport/city IATA code and the airport popularity.
${PREPARE_PR_EXEC} ${AIRPORT_PR_FILE}


##
# Minimal distance (in km) triggering a difference
if [ "$4" != "" ]
then
	COMP_MIN_DIST=$4
fi


##
# The two files contain only four fields (the primary key, the IATA code and
# both coordinates).
#
# Note that the ${PREPARE_EXEC} (e.g., prepare_geonames_dump_file.sh) script
# prepares such a file for Geonames (named ${GEONAME_FILE_SORTED_CUT}, e.g.,
# cut_sorted_wpk_dump_from_geonames.csv) from the data dump (named
# ${GEONAME_FILE}, e.g., wpk_dump_from_geonames.csv).
#
# The 'join' command aggregates:
#  * The four fields of the (stripped) Geonames dump file.
#    That is the file #1 for the join command.
#  * The five fields of the file of best known coordinates (the primary key has
#    been stripped by the join command), i.e.:
#    * the IATA codes of both the POR and its served city
#    * the two geographical coordinates.
#    * the effective date (when empty, it means the POR has always existed).
#
# The 'join' command takes all the rows from the file #1 (Geonames dump file).
# When there is no corresponding entry in the file of best coordinates, only
# the four (extracted) fields of the Geonames dump file are kept.
# Hence, lines may have:
#  * 9 fields: the primary key, IATA code and both coordinates of the Geonames
#    dump file, followed by the IATA codes of the POR and its served city,
#    as well as the best coordinates, ended by the from validity date.
#  * 4 fields: the primary key, IATA code and both coordinates of the Geonames
#    dump file.
#
GEONAME_MASTER=${GEO_COMBINED_TMP_FILE}.geomst
join -t'^' -a 1 -1 1 -2 1 -e NULL ${GEONAME_FILE_SORTED_CUT} ${ORI_BEST_FILE} \
	> ${GEONAME_MASTER}

##
# Sanity check: calculate the minimal number of fields on the resulting file
#
MIN_FIELD_NB=`awk -F'^' 'BEGIN{n=10} {if (NF<n) {n=NF}} END{print n}' ${GEONAME_MASTER} | uniq | sort | uniq`

if [ "${MIN_FIELD_NB}" != "9" -a "${MIN_FIELD_NB}" != "4" ]
then
	echo
	echo "Sanity check"
	echo "------------"
	echo "[$0:$LINENO] Error! The file aggregating all the geographical coordinates should have a specific number of fields (that is, either 4 or 9). It is ${MIN_FIELD_NB}"
	echo "Check that file (${GEONAME_MASTER}), which is a join of the coordinates from ${GEONAME_FILE_SORTED_CUT} and from ${ORI_BEST_FILE}."
	echo "That error generally indicates that the format of one of the files (i.e., ${GEONAME_FILENAME} and/or ${ORI_BEST_FILE}) has changed, and that this script ($0) is not aware of it."
	echo
  exit -1
fi


##
# Operate the same way as above, except that, this time, the points of reference
# with the best known coordinates have the precedence over those of Geonames.
# Note that, however, when they exist, the Geonames coordinates themselves
# (not the point of reference) have the precedence over the "best known" ones.
#
# Therefore, the 'join' command aggregates:
#  * The six fields of the file of best known coordinates, i.e.:
#    * the IATA codes of both the POR and its served city
#    * the two geographical coordinates.
#    * the effective date (when empty, it means the POR has always existed).
#    That is the file #1 for the join command.
#  * The three fields of the Geonames dump file (the primary key has been
#    stripped by the join command.
#    That is the file #2 for the join command.
#
# The 'join' command takes all the rows from the file #1 (file of best known
# coordinates).
# When there is no corresponding entry in the file of best coordinates, only
# the six (extracted) fields of the file of best known coordinates are kept.
# Hence, lines may have:
#  * 9 fields: the primary key, IATA code and both coordinates of the file of
#    best known coordinates, followed by the IATA code of its served city,
#    ended by the from validity date, as well as the Geonames coordinates.
#  * 6 fields: the primary key, IATA code and both coordinates of the file of
#    best known coordinates, followed by the IATA code of its served city,
#    ended by the from validity date.
#
ORI_BEST_MASTER=${GEO_COMBINED_TMP_FILE}.bstmst
join -t'^' -a 2 -1 1 -2 1 -e NULL ${GEONAME_FILE_SORTED_CUT} ${ORI_BEST_FILE} \
	> ${ORI_BEST_MASTER}

##
# Sanity check: calculate the minimal number of fields on the resulting file
#
MIN_FIELD_NB=`awk -F'^' 'BEGIN{n=10} {if (NF<n) {n=NF}} END{print n}' ${ORI_BEST_MASTER} | uniq | sort | uniq`

if [ "${MIN_FIELD_NB}" != "9" -a "${MIN_FIELD_NB}" != "6" ]
then
	echo
	echo "Sanity check"
	echo "------------"
	echo "[$0:$LINENO] Error! The file aggregating all the geographical coordinates should have a specific number of fields (that is, either 6 or 9). It is ${MIN_FIELD_NB}"
	echo "Check that file (${ORI_BEST_MASTER}), which is a join of the coordinates from ${GEONAME_FILE_SORTED_CUT} and from ${ORI_BEST_FILE}."
	echo "That error generally indicates that the format of one of the files (i.e., ${GEONAME_FILENAME} and/or ${ORI_BEST_FILE}) has changed, and that this script ($0) is not aware of it."
	echo
  exit -1
fi


##
# Keep only the first 4 fields in each file:
#  * The primary key, IATA code and both coordinates of the Geonames dump file,
#    when they exist.
#  * The primary key, IATA code and the best coordinates, when no entry exists
#    in the Geonames dump file.
#
cut -d'^' -f 1-4 ${GEONAME_MASTER} > ${GEONAME_MASTER}.dup
\mv -f ${GEONAME_MASTER}.dup ${GEONAME_MASTER}
cut -d'^' -f 1-4 ${ORI_BEST_MASTER} > ${ORI_BEST_MASTER}.dup
\mv -f ${ORI_BEST_MASTER}.dup ${ORI_BEST_MASTER}


##
# Do some reporting
#
# Reminder:
#  * ${GEONAME_MASTER} (e.g., geo_combined_file.csv.tmp.geomst) has got all
#    the entries of the Geonames dump file (./wpk_dump_from_geonames.csv)
#  * ${ORI_BEST_MASTER} (e.g., geo_combined_file.csv.tmp.bstmst) has got all
#    the entries of the ORI-maintained list of best known geographical
#    coordinates (best_coordinates_known_so_far.csv)
#
POR_NB_COMMON=`comm -12 ${GEONAME_MASTER} ${ORI_BEST_MASTER} | wc -l`
POR_NB_FILE1=`comm -23 ${GEONAME_MASTER} ${ORI_BEST_MASTER} | wc -l`
POR_NB_FILE2=`comm -13 ${GEONAME_MASTER} ${ORI_BEST_MASTER} | wc -l`
echo
echo "Reporting step"
echo "--------------"
echo "'${GEONAME_FILE}' and '${ORI_BEST_FILE}' have got ${POR_NB_COMMON} common lines."
echo "'${GEONAME_FILE}' has got ${POR_NB_FILE1} POR, missing from '${ORI_BEST_FILE}'"
echo "'${ORI_BEST_FILE}' has got ${POR_NB_FILE2} POR, missing from '${GEONAME_FILE}'"
echo

if [ ${POR_NB_FILE2} -gt 0 ]
then
	comm -13 ${GEONAME_MASTER} ${ORI_BEST_MASTER} > ${GEONAME_FILE_MISSING}
	POR_MISSING_GEONAMES_NB=`wc -l ${GEONAME_FILE_MISSING} | cut -d' ' -f1`
	echo
	echo "Suggestion step"
	echo "---------------"
	echo "${POR_MISSING_GEONAMES_NB} points of reference (POR) are missing from Geonames ('${GEONAME_FILE}')."
	echo "They can be displayed with: less ${GEONAME_FILE_MISSING}"
	echo "You may also want to launch the following script:"
	echo "./generate_por_lists_for_geonames.sh"
	echo
fi

if [ ${POR_NB_FILE1} -gt 0 ]
then
	comm -23 ${GEONAME_MASTER} ${ORI_BEST_MASTER} > ${ORI_BEST_FILE_MISSING}
	POR_MISSING_BEST_NB=`wc -l ${ORI_BEST_FILE_MISSING} | cut -d' ' -f1`
	echo
	echo "Suggestion step"
	echo "---------------"
	echo "${POR_MISSING_BEST_NB} points of reference (POR) are missing from the file of best coordinates ('${ORI_BEST_FILE}')."
	echo "To incorporate the missing POR into '${ORI_BEST_FILE}', just do:"
	echo "cat ${ORI_BEST_FILE} ${ORI_BEST_FILE_MISSING} | sort -t'^' -k1,1 > ${ORI_BEST_FILE}.tmp && \mv -f ${ORI_BEST_FILE}.tmp ${ORI_BEST_FILE} && \rm -f ${ORI_BEST_FILE_MISSING}"
	echo
fi


##
# Compare the Geonames coordinates to the best known ones (unil now).
# It generates a data file (${POR_MAIN_DIFF}, e.g., por_main_diff.csv)
# containing the greatest distances (in km), for each airport/city, between
# both sets of coordinates (Geonames and best known ones).
${COMPARE_EXEC} ${GEONAME_FILE_SORTED_CUT} ${ORI_BEST_FILE} \
	${AIRPORT_PR_SORTED_CUT} ${COMP_MIN_DIST}


##
# Cleaning of temporary files
#
if [ "${TMP_DIR}" != "/tmp/por/" ]
then
	\rm -f ${JOINED_COORD} ${JOINED_COORD_FULL}
	\rm -f ${GEONAME_MASTER} ${ORI_BEST_MASTER}
	\rm -f ${GEONAME_FILE_SORTED} ${GEONAME_FILE_SORTED_CUT}
fi
