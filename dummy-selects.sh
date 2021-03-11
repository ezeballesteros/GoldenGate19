#!/bin/bash
#####################################
#
# Run SQL script in an Oracle DB
#
#####################################

ORACLE_USER="MYSCHEMA1"
ORACLE_PASS="p4ssw0rd"
ORACLE_HOST="localhost"
ORACLE_PORT="1521"
#ORACLE_SERVICE="ORCLCDB"
ORACLE_SERVICE="ORCLPDB1"
ORACLE_SCRIPT="script.sql"

while [ 1 ]; do
	echo -n "" > $ORACLE_SCRIPT
	echo "SET LINESIZE 300;" >> $ORACLE_SCRIPT
	echo "SET PAGESIZE 60" >> $ORACLE_SCRIPT
	echo "SELECT * FROM \"MYSCHEMA1\".\"CUSTOMERS\" ORDER BY ID DESC FETCH FIRST 10 ROWS ONLY;" >> $ORACLE_SCRIPT
	echo "quit;" >> $ORACLE_SCRIPT
	sqlplus $ORACLE_USER/$ORACLE_PASS@$ORACLE_HOST:$ORACLE_PORT/$ORACLE_SERVICE @$ORACLE_SCRIPT
	sleep 1
done
