#!/bin/bash
#
# That Bash script extracts data from the 'allCountries_w_alt.txt'
# Geonames-derived data file and exports them into internal
# standard-formatted data files.
#
# See ../geonames/data/por/admin/aggregateGeonamesPor.sh for more details on
# the way to derive that file from Geonames original data files.
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
# Snapshot date
SNAPSHOT_DATE=`date "+%Y%m%d"`
SNAPSHOT_DATE_HUMAN=`date`

##
# Retrieve the latest schedule file
POR_FILE_PFX1=por_iata
POR_FILE_PFX2=por_noiata
LATEST_EXTRACT_DATE=`ls ${EXEC_PATH}/${POR_FILE_PFX1}_????????.csv 2> /dev/null`
if [ "${LATEST_EXTRACT_DATE}" != "" ]
then
	# (Trick to) Extract the latest entry
	for myfile in ${LATEST_EXTRACT_DATE}; do echo > /dev/null; done
	LATEST_EXTRACT_DATE=`echo ${myfile} | sed -e "s/${POR_FILE_PFX1}_\([0-9]\+\)\.csv/\1/" | xargs basename`
fi
if [ "${LATEST_EXTRACT_DATE}" != "" ]
then
	LATEST_EXTRACT_DATE_HUMAN=`date -d ${LATEST_EXTRACT_DATE}`
fi
if [ "${LATEST_EXTRACT_DATE}" != "" \
	-a "${LATEST_EXTRACT_DATE}" != "${SNAPSHOT_DATE}" ]
then
	LATEST_DUMP_IATA_FILENAME=${POR_FILE_PFX1}_${LATEST_EXTRACT_DATE}.csv
	LATEST_DUMP_NOIATA_FILENAME=${POR_FILE_PFX2}_${LATEST_EXTRACT_DATE}.csv
fi

##
# Geonames data store
GEO_POR_DATA_DIR=${EXEC_PATH}../geonames/data/por/data/

##
# ORI directory
ORI_DIR=${EXEC_PATH}../ORI/


##
# Extract airport/city information from the Geonames data file
GEO_POR_FILENAME=allCountries_w_alt.txt
GEO_CTY_FILENAME=countryInfo.txt
GEO_CNT_FILENAME=continentCodes.txt
#
GEO_POR_FILE=${GEO_POR_DATA_DIR}${GEO_POR_FILENAME}
GEO_CTY_FILE=${GEO_POR_DATA_DIR}${GEO_CTY_FILENAME}
GEO_CNT_FILE=${GEO_POR_DATA_DIR}${GEO_CNT_FILENAME}

##
# Generated files
DUMP_GEO_FILENAME=dump_from_geonames.csv
DUMP_IATA_FILENAME=${POR_FILE_PFX1}_${SNAPSHOT_DATE}.csv
DUMP_NOIATA_FILENAME=${POR_FILE_PFX2}_${SNAPSHOT_DATE}.csv
# Light version of the country-related time-zones
ORI_TZ_FILENAME=ori_tz_light.csv
# Mapping between countries and continents
ORI_CNT_FILENAME=ori_cont.csv

#
DUMP_GEO_FILE=${TMP_DIR}${DUMP_GEO_FILENAME}
DUMP_IATA_FILE=${TMP_DIR}${DUMP_IATA_FILENAME}
DUMP_NOIATA_FILE=${TMP_DIR}${DUMP_NOIATA_FILENAME}
DUMP_GEO_FILE_HDR=${DUMP_IATA_FILE}.hdr
DUMP_GEO_FILE_TMP=${DUMP_IATA_FILE}.tmp
# ORI-related data files
ORI_TZ_FILE=${ORI_DIR}${ORI_TZ_FILENAME}
ORI_CNT_FILE=${ORI_DIR}${ORI_CNT_FILENAME}
ORI_CNT_FILE_TMP=${TMP_DIR}${ORI_CNT_FILENAME}.tmp
ORI_CNT_FILE_TMP_SORTED=${TMP_DIR}${ORI_CNT_FILENAME}.tmp.sorted
ORI_CNT_FILE_HDR=${TMP_DIR}${ORI_CNT_FILENAME}.tmp.hdr

##
# Latest snapshot data files
LATEST_DUMP_IATA_FILE=${TMP_DIR}${LATEST_DUMP_IATA_FILENAME}
LATEST_DUMP_NOIATA_FILE=${TMP_DIR}${LATEST_DUMP_NOIATA_FILENAME}

#
if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo
	echo "Usage: $0"
	echo "  - Snapshot date: '${SNAPSHOT_DATE}' (${SNAPSHOT_DATE_HUMAN})"
	if [ "${LATEST_EXTRACT_DATE}" != "" \
		-a "${LATEST_EXTRACT_DATE}" != "${SNAPSHOT_DATE}" ]
	then
		echo "  - Latest extraction date: '${LATEST_EXTRACT_DATE}' (${LATEST_EXTRACT_DATE_HUMAN})"
	fi
	echo "  - Geonames input data files from '${GEO_POR_DATA_DIR}':"
	echo "      + Detailed POR entry data file (~9 millions): '${GEO_POR_FILE}'"
	echo "      + Detailed country information data file: '${GEO_CTY_FILE}'"
	echo "      + Continent information data file: '${GEO_CNT_FILE}'"
	echo
	echo "  - Generated (CSV-formatted) data files in '${EXEC_PATH}':"
	echo "      + '${DUMP_IATA_FILE}'"
	echo "      + '${DUMP_NOIATA_FILE}'"
	echo
	echo "  - Generated (CSV-formatted) data files in '${ORI_DIR}':"
	echo "      + '${ORI_TZ_FILE}' (maybe sometimes in the future)"
	echo "      + '${ORI_CNT_FILE}'"
	echo
	exit
fi

##
#
if [ "$1" = "--clean" ]
	then
	if [ "${TMP_DIR}" = "/tmp/por/" ]
	then
		\rm -rf ${TMP_DIR}
	else
		\rm -f ${ORI_CNT_FILE_HDR} ${ORI_CNT_FILE_TMP}
		\rm -f ${ORI_CNT_FILE_TMP_SORTED}
		\rm -f ${DUMP_GEO_FILE_HDR} ${DUMP_GEO_FILE_TMP}
	fi
	exit
fi

##
# Data extraction from the Geonames data file

# For country-related information (continent, for now)
echo
echo "Extracting country-related information from '${GEO_CTY_FILE}'"
CONT_EXTRACTOR=${EXEC_PATH}extract_continent_mapping.awk
awk -F'\t' -f ${CONT_EXTRACTOR} ${GEO_CNT_FILE} ${GEO_CTY_FILE} \
	> ${ORI_CNT_FILE_TMP}
# Extract and remove the header
grep "^country_code\(.\+\)" ${ORI_CNT_FILE_TMP} > ${ORI_CNT_FILE_HDR}
sed -i -e "s/^country_code\(.\+\)//g" ${ORI_CNT_FILE_TMP}
sed -i -e "/^$/d" ${ORI_CNT_FILE_TMP}
# Sort by country code
sort -t'^' -k1,1 ${ORI_CNT_FILE_TMP} > ${ORI_CNT_FILE_TMP_SORTED}
# Re-add the header
cat ${ORI_CNT_FILE_HDR} ${ORI_CNT_FILE_TMP_SORTED} > ${ORI_CNT_FILE_TMP}
sed -e "/^$/d" ${ORI_CNT_FILE_TMP} > ${ORI_CNT_FILE}

# For travel-related POR and cities.
echo
echo "Extracting travel-related points of reference (POR, i.e., airports, railway stations)"
echo "and populated place (city) data from the Geonames dump data file."
echo "The '${GEO_POR_FILE}' input data file allows to generate '${DUMP_IATA_FILE}' and '${DUMP_NOIATA_FILE}' files."
echo "That operation may take several minutes..."
IATA_EXTRACTOR=${EXEC_PATH}extract_por_with_iata_icao.awk
time awk -F'^' \
	-v iata_file=${DUMP_IATA_FILE} -v noiata_file=${DUMP_NOIATA_FILE} \
	-f ${IATA_EXTRACTOR} ${GEO_POR_FILE}
echo "... Done"
echo

##
# Extract and remove the header
grep "^iata_code\(.\+\)" ${DUMP_IATA_FILE} > ${DUMP_GEO_FILE_HDR}
sed -i -e "s/^iata_code\(.\+\)//g" ${DUMP_IATA_FILE}
sed -i -e "/^$/d" ${DUMP_IATA_FILE}
sed -i -e "s/^iata_code\(.\+\)//g" ${DUMP_NOIATA_FILE}
sed -i -e "/^$/d" ${DUMP_NOIATA_FILE}

# Sort the data files
echo "Sorting ${DUMP_IATA_FILE}..."
sort -t'^' -k1,1 -k4,4 ${DUMP_IATA_FILE} > ${DUMP_GEO_FILE_TMP}
cat ${DUMP_GEO_FILE_HDR} ${DUMP_GEO_FILE_TMP} > ${DUMP_IATA_FILE}
echo "... done"
echo "Sorting ${DUMP_NOIATA_FILE}..."
sort -t'^' -k1,1 -k4,4 ${DUMP_NOIATA_FILE} > ${DUMP_GEO_FILE_TMP}
cat ${DUMP_GEO_FILE_HDR} ${DUMP_GEO_FILE_TMP} > ${DUMP_NOIATA_FILE}
echo "... done"


##
# Reporting
#
echo
echo "Reporting step"
echo "--------------"
echo
echo "From the '${GEO_POR_FILE}' input data file, the following data files have been derived:"
echo " + '${DUMP_IATA_FILE}'"
echo " + '${DUMP_NOIATA_FILE}'"
echo
echo
echo "Other temporary files have been generated. Just issue the following command to delete them:"
echo "$0 --clean"
echo
echo "Following steps:"
echo "----------------"
if [ "${LATEST_EXTRACT_DATE}" != "" \
	-a "${LATEST_EXTRACT_DATE}" != "${SNAPSHOT_DATE}" ]
then
	echo "After having checked that the updates brought by Geonames are legitimate and not disruptive, i.e.:"
	echo "diff -c ${LATEST_DUMP_IATA_FILE} ${DUMP_IATA_FILE} | less"
	echo "diff -c ${LATEST_DUMP_NOIATA_FILE} ${DUMP_NOIATA_FILE} | less"
	echo "mkdir -p archives && bzip2 *_${LATEST_EXTRACT_DATE}.csv && mv *_${LATEST_EXTRACT_DATE}.csv.bz2 archives"
	echo
	echo "The Geonames data file (dump_from_geonames.csv) may be updated:"
else
	echo "Today (${SNAPSHOT_DATE}), the Geonames data has already been extracted."
	echo
	echo "The Geonames data file (dump_from_geonames.csv) has to set up:"
fi
echo "\cp -f ${DUMP_IATA_FILE} ${DUMP_GEO_FILE}"
echo
echo

