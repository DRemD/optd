#!/bin/sh
#
# Two parameters are optional:
# - the host server of the database
# - the port of the database
#

if [ "$1" = "-h" -o "$1" = "--help" ];
then
	echo "Usage: $0 [<Database Server Hostname> [<Database Server Port>]]"
	echo ""
	exit -1
fi

##
# Database Server Hostname
DB_HOST="localhost"
if [ "$1" != "" ];
then
	DB_HOST="$1"
fi

# Database Server Port
DB_PORT="3306"
if [ "$2" != "" ];
then
	DB_PORT="$2"
fi

# Database User
DB_USER="geo"

# Database Password
DB_PASSWD="${DB_USER}"

# Database Name
DB_NAME="geo_ori"

#
# Count the number of elements of a given database table
function countElements() {
        echo
        echo "Number of elements for the '${DB_TABLE}' table"
        SQL_QUERY="select count(*) from ${DB_TABLE}"
        mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} -e "${SQL_QUERY}"
}

##
# Create the tables for the ORI-generated list of POR (points of reference,
# i.e., airports, cities, places, etc.)
SQL_FILE="create_ori_tables.sql"
echo "Creating the tables for ORI-generated POR (points of reference, i.e., airports, cities, places, etc.):"
mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} < ${SQL_FILE}

##
# Load the ORI-related data
SQL_FILE="fill_table_ori_por.sql"
echo "Load data into the MySQL table for the ORI-generated POR:"
mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} < ${SQL_FILE}

##
# Create the indexes for the ORI tables
SQL_FILE="create_ori_indexes.sql"
echo "Creating the indexes for ORI-generated POR:"
mysql -u ${DB_USER} --password=${DB_PASSWD} -P ${DB_PORT} -h ${DB_HOST} ${DB_NAME} < ${SQL_FILE}

TABLES="por"

# Count rows
for table_name in ${TABLES}
do
	DB_TABLE="${table_name}"
	countElements
done
