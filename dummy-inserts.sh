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

echo -n "" > $ORACLE_SCRIPT
echo "SELECT ID FROM \"MYSCHEMA1\".\"CUSTOMERS\" ORDER BY ID DESC FETCH FIRST 1 ROWS ONLY;" >> $ORACLE_SCRIPT
echo "quit;" >> $ORACLE_SCRIPT
sqlplus $ORACLE_USER/$ORACLE_PASS@$ORACLE_HOST:$ORACLE_PORT/$ORACLE_SERVICE @$ORACLE_SCRIPT > lastid.log
I=`cat lastid.log | grep -A 1 '\---' | tail -n 1`

if [ "x$I" == "x" ]; then
	I=0
fi

echo $I

#I=20
while [ 1 ]; do
	I=`echo "$I+1" | bc -l`
	echo -n "" > $ORACLE_SCRIPT
	echo "INSERT INTO \"MYSCHEMA1\".\"CUSTOMERS\" (ID, NAME, ADDRESS, AGE) VALUES ('$I', 'aaa', 'bbb', '$I');" >> $ORACLE_SCRIPT
	echo "INSERT INTO \"MYSCHEMA1\".\"CUSTOMERS2\" (ID, NAME, ADDRESS, AGE) VALUES ('$I', 'aaa', 'bbb', '$I');" >> $ORACLE_SCRIPT
	echo "INSERT INTO \"MYSCHEMA1\".\"CUSTOMERS3\" (ID, NAME, ADDRESS, AGE) VALUES ('$I', 'aaa', 'bbb', '$I');" >> $ORACLE_SCRIPT
	echo "INSERT INTO \"MYSCHEMA1\".\"CUSTOMERS4\" (ID, NAME, ADDRESS, AGE) VALUES ('$I', 'aaa', 'bbb', '$I');" >> $ORACLE_SCRIPT
	echo "quit;" >> $ORACLE_SCRIPT
	cat $ORACLE_SCRIPT
	sqlplus $ORACLE_USER/$ORACLE_PASS@$ORACLE_HOST:$ORACLE_PORT/$ORACLE_SERVICE @$ORACLE_SCRIPT
	sleep 1
done
