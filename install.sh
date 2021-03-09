#!/bin/bash

cd /opt/oracle-installer

# Pre-req
yum install -y wget screen
curl http://public-yum.oracle.com/public-yum-ol7.repo -o /etc/yum.repos.d/public-yum-ol7.repo
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/public-yum-ol7.repo
rpm --import http://yum.oracle.com/RPM-GPG-KEY-oracle-ol7
yum --enablerepo=ol7_latest -y install oracle-database-preinstall-19c

# Install Database
curl -v http://share-casa.whdns.com.ar/bin/oracle-database-ee-19c-1.0-1.x86_64.rpm -o ./oracle-database-ee-19c-1.0-1.x86_64.rpm
rpm -Uvh oracle-database-ee-19c-1.0-1.x86_64.rpm
/etc/init.d/oracledb_ORCLCDB-19c configure

# Configure Env Variables
echo "ORACLE_BASE=/opt/oracle/oradata" >> /etc/sysconfig/ORCLCDB.oracledb
echo "ORACLE_HOME=/opt/oracle/product/19c/dbhome_1" >> /etc/sysconfig/ORCLCDB.oracledb
echo "ORACLE_SID=ORCLCDB" >> /etc/sysconfig/ORCLCDB.oracledb

# Configure systemd listener service
echo "[Unit]"								>> /usr/lib/systemd/system/ORCLCDB@lsnrctl.service
echo "Description=Oracle Net Listener"					>> /usr/lib/systemd/system/ORCLCDB@lsnrctl.service
echo "After=network.target"						>> /usr/lib/systemd/system/ORCLCDB@lsnrctl.service
echo ""									>> /usr/lib/systemd/system/ORCLCDB@lsnrctl.service
echo "[Service]"							>> /usr/lib/systemd/system/ORCLCDB@lsnrctl.service
echo "Type=forking"							>> /usr/lib/systemd/system/ORCLCDB@lsnrctl.service
echo "EnvironmentFile=/etc/sysconfig/ORCLCDB.oracledb"			>> /usr/lib/systemd/system/ORCLCDB@lsnrctl.service
echo "ExecStart=/opt/oracle/product/19c/dbhome_1/bin/lsnrctl start"	>> /usr/lib/systemd/system/ORCLCDB@lsnrctl.service
echo "ExecStop=/opt/oracle/product/19c/dbhome_1/bin/lsnrctl stop"	>> /usr/lib/systemd/system/ORCLCDB@lsnrctl.service
echo "User=oracle"							>> /usr/lib/systemd/system/ORCLCDB@lsnrctl.service
echo ""									>> /usr/lib/systemd/system/ORCLCDB@lsnrctl.service
echo "[Install]"							>> /usr/lib/systemd/system/ORCLCDB@lsnrctl.service
echo "WantedBy=multi-user.target"					>> /usr/lib/systemd/system/ORCLCDB@lsnrctl.service

# Configure systemd database service
echo "[Unit]"									>> /usr/lib/systemd/system/ORCLCDB@oracledb.service
echo "Description=Oracle Database service"					>> /usr/lib/systemd/system/ORCLCDB@oracledb.service
echo "After=network.target lsnrctl.service"					>> /usr/lib/systemd/system/ORCLCDB@oracledb.service
echo ""										>> /usr/lib/systemd/system/ORCLCDB@oracledb.service
echo "[Service]"								>> /usr/lib/systemd/system/ORCLCDB@oracledb.service
echo "Type=forking"								>> /usr/lib/systemd/system/ORCLCDB@oracledb.service
echo "EnvironmentFile=/etc/sysconfig/ORCLCDB.oracledb"				>> /usr/lib/systemd/system/ORCLCDB@oracledb.service
echo 'ExecStart=/opt/oracle/product/19c/dbhome_1/bin/dbstart $ORACLE_HOME'	>> /usr/lib/systemd/system/ORCLCDB@oracledb.service
echo 'ExecStop=/opt/oracle/product/19c/dbhome_1/bin/dbshut $ORACLE_HOME'	>> /usr/lib/systemd/system/ORCLCDB@oracledb.service
echo "User=oracle"								>> /usr/lib/systemd/system/ORCLCDB@oracledb.service
echo ""										>> /usr/lib/systemd/system/ORCLCDB@oracledb.service
echo "[Install]"								>> /usr/lib/systemd/system/ORCLCDB@oracledb.service
echo "WantedBy=multi-user.target"						>> /usr/lib/systemd/system/ORCLCDB@oracledb.service

systemctl daemon-reload
systemctl enable ORCLCDB@lsnrctl ORCLCDB@oracledb

# Configure Env for user oracle
echo 'umask 022'									>> /home/oracle/.bash_profile
echo 'export ORACLE_SID=ORCLCDB'							>> /home/oracle/.bash_profile
echo 'export ORACLE_BASE=/opt/oracle/oradata'						>> /home/oracle/.bash_profile
echo 'export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1'				>> /home/oracle/.bash_profile
echo 'export PATH=$PATH:$ORACLE_HOME/bin'						>> /home/oracle/.bash_profile
echo ''											>> /home/oracle/.bash_profile
echo 'export LD_LIBRARY_PATH=/opt/oracle/oggs:$LD_LIBRARY_PATH'				>> /home/oracle/.bash_profile
echo 'export LD_LIBRARY_PATH=/opt/oracle/product/19c/dbhome_1/lib:$LD_LIBRARY_PATH'	>> /home/oracle/.bash_profile
echo 'export PATH=$PATH:/opt/oracle/oggs'						>> /home/oracle/.bash_profile
echo 'export GGHOME=/opt/oracle/oggs'							>> /home/oracle/.bash_profile

# Database Autostart
sed -i 's/:N$/:Y/g' /etc/oratab

# Get OGG Installer
curl -v http://share-casa.whdns.com.ar/bin/V983658-01.zip -o ./V983658-01.zip
unzip ./V983658-01.zip

# Response file for OGG
echo "oracle.install.responseFileVersion=/oracle/install/rspfmt_ogginstall_response_schema_v19_1_0"	>> ./fbo_ggs_Linux_x64_shiphome/Disk1/response/oggcore19.rsp
echo "INSTALL_OPTION=ORA19c"										>> ./fbo_ggs_Linux_x64_shiphome/Disk1/response/oggcore19.rsp
echo "SOFTWARE_LOCATION=/opt/oracle/oggs"								>> ./fbo_ggs_Linux_x64_shiphome/Disk1/response/oggcore19.rsp
echo "START_MANAGER="											>> ./fbo_ggs_Linux_x64_shiphome/Disk1/response/oggcore19.rsp
echo "MANAGER_PORT="											>> ./fbo_ggs_Linux_x64_shiphome/Disk1/response/oggcore19.rsp
echo "DATABASE_LOCATION="										>> ./fbo_ggs_Linux_x64_shiphome/Disk1/response/oggcore19.rsp
echo "INVENTORY_LOCATION=/opt/oracle/oraInventory"							>> ./fbo_ggs_Linux_x64_shiphome/Disk1/response/oggcore19.rsp
echo "UNIX_GROUP_NAME=oinstall"										>> ./fbo_ggs_Linux_x64_shiphome/Disk1/response/oggcore19.rsp

# Install OGG
mkdir /home/oracle/ogg
cp -a ./fbo_ggs_Linux_x64_shiphome /home/oracle/ogg/.
chown -R oracle.oinstall /home/oracle/ogg
su - oracle -c "cd /home/oracle/ogg/fbo_ggs_Linux_x64_shiphome/Disk1/; ./runInstaller -silent -showProgress -waitforcompletion -responseFile /home/oracle/ogg/fbo_ggs_Linux_x64_shiphome/Disk1/response/oggcore19.rsp"

# Configure OGG
echo "CheckpointTable CDB$ROOT.oggadm1.oggchkpt" >> /opt/oracle/oggs/GLOBALS
chown oracle.oinstall /opt/oracle/oggs/GLOBALS
chmod 644 /opt/oracle/oggs/GLOBALS

echo "CREATE SUBDIRS" >> /opt/oracle/oggs/ggsci1.script
chown oracle.oinstall /opt/oracle/oggs/ggsci1.script
chmod 644 /opt/oracle/oggs/ggsci1.script
su - oracle -c "cd /opt/oracle/oggs/; ./ggsci < ggsci1.script"

echo "PORT 8199"							>> /opt/oracle/oggs/dirprm/mgr.prm
echo "PurgeOldExtracts ./dirdat/*, UseCheckpoints, MINKEEPDAYS 5"	>> /opt/oracle/oggs/dirprm/mgr.prm
chown oracle.oinstall /opt/oracle/oggs/dirprm/mgr.prm
chmod 644 /opt/oracle/oggs/dirprm/mgr.prm

echo "start mgr" >> /opt/oracle/oggs/ggsci2.script
chown oracle.oinstall /opt/oracle/oggs/ggsci2.script
chmod 644 /opt/oracle/oggs/ggsci2.script
su - oracle -c "cd /opt/oracle/oggs/; ./ggsci < ggsci2.script"

# Set this in the DB Source (WARNING: This depends on the origin, check this carefully.)
echo '# Set COMPATIBLE (ex. for a  new 19c db.)'
echo 'SQL> SELECT name, value, description FROM v$parameter WHERE name = 'compatible'; <--- Validate'
echo 'SQL> ALTER SYSTEM SET COMPATIBLE = '19.0.0' SCOPE=SPFILE;'
echo 'SQL> SHUTDOWN IMMEDIATE'
echo 'SQL> Startup'
echo 'SQL> SELECT name, value, description FROM v$parameter WHERE name = 'compatible';'
echo ''
echo '# Set GG Replication'
echo 'ALTER SYSTEM SET enable_goldengate_replication=true SCOPE=SPFILE;'
echo ''
echo '# Enable ARCHIVELOG.'
echo 'SQL> ARCHIVE LOG LIST <--- Validate'
echo 'SQL> SHUTDOWN IMMEDIATE '
echo 'SQL> STARTUP MOUNT'
echo 'SQL> ALTER DATABASE ARCHIVELOG;'
echo 'SQL> ALTER DATABASE OPEN;'
echo 'SQL> ARCHIVE LOG LIST'
echo ''
echo '# Select PDB.'
echo 'alter session set container=ORCLPDB1;'
echo ''
echo '# Create ogg user.'
echo 'CREATE TABLESPACE tbs_oggperm_1'
echo '  DATAFILE 'tbs_oggperm_1.dat''
echo '    SIZE 1G'
echo '  ONLINE;'
echo ''
echo 'CREATE TEMPORARY TABLESPACE tbs_oggtemp_2'
echo '  TEMPFILE 'tbs_oggtemp_2.dbf''
echo '    SIZE 1G'
echo '    AUTOEXTEND ON;'
echo ''
echo 'CREATE USER oggadm1'
echo 'IDENTIFIED BY p4ssw0rd'
echo '  DEFAULT TABLESPACE tbs_oggperm_1'
echo '  TEMPORARY TABLESPACE tbs_oggtemp_1;'
echo 'ALTER USER oggadm1 QUOTA UNLIMITED ON tbs_oggperm_1;'
echo 'GRANT CREATE SESSION, ALTER SESSION TO oggadm1;'
echo 'GRANT RESOURCE TO oggadm1;'
echo 'GRANT SELECT ANY DICTIONARY TO oggadm1;'
echo 'GRANT FLASHBACK ANY TABLE TO oggadm1;'
echo 'GRANT SELECT ANY TABLE TO oggadm1;'
#echo 'GRANT SELECT_CATALOG_ROLE TO rds_master_user_name WITH ADMIN OPTION;'
#echo 'exec rdsadmin.rdsadmin_util.grant_sys_object ('DBA_CLUSTERS', 'OGGADM1');'
echo 'exec dbms_goldengate_auth.grant_admin_privilege('oggadm1');'
echo 'GRANT EXECUTE ON DBMS_FLASHBACK TO oggadm1;'
echo 'GRANT SELECT ON SYS.V_$DATABASE TO oggadm1;'
echo 'GRANT ALTER ANY TABLE TO oggadm1;'
echo 'GRANT create table TO oggadm1;'
echo 'GRANT create view TO oggadm1;'
echo 'GRANT create any trigger TO oggadm1;'
echo 'GRANT create any procedure TO oggadm1;'
echo 'GRANT create sequence TO oggadm1;'
echo 'GRANT create synonym TO oggadm1;'
echo ''

# Set this in the DB Target (WARNING: This depends on the target, check this carefully.)
echo '# Set COMPATIBLE (ex. for a  new 19c db.)'
echo 'SQL> SELECT name, value, description FROM v$parameter WHERE name = 'compatible'; <--- Validate'
echo 'SQL> ALTER SYSTEM SET COMPATIBLE = '19.0.0' SCOPE=SPFILE;'
echo 'SQL> SHUTDOWN IMMEDIATE'
echo 'SQL> Startup'
echo 'SQL> SELECT name, value, description FROM v$parameter WHERE name = 'compatible';'
echo ''
echo '# Set GG Replication'
echo 'ALTER SYSTEM SET enable_goldengate_replication=true SCOPE=SPFILE;'
echo ''
echo '# Select PDB.'
echo 'alter session set container=ORCLPDB1;'
echo ''
echo '# Create ogg user.'
echo 'CREATE TABLESPACE tbs_oggperm_1'
echo '  DATAFILE 'tbs_oggperm_1.dat''
echo '    SIZE 1G'
echo '  ONLINE;'
echo ''
echo 'CREATE TEMPORARY TABLESPACE tbs_oggtemp_2'
echo '  TEMPFILE 'tbs_oggtemp_2.dbf''
echo '    SIZE 1G'
echo '    AUTOEXTEND ON;'
echo ''
echo 'CREATE USER oggadm1'
echo 'IDENTIFIED BY p4ssw0rd'
echo '  DEFAULT TABLESPACE tbs_oggperm_1'
echo '  TEMPORARY TABLESPACE tbs_oggtemp_1;'
echo 'ALTER USER oggadm1 QUOTA UNLIMITED ON tbs_oggperm_1;'
echo 'GRANT CREATE SESSION        TO oggadm1;'
echo 'GRANT ALTER SESSION         TO oggadm1;'
echo 'GRANT CREATE CLUSTER        TO oggadm1;'
echo 'GRANT CREATE INDEXTYPE      TO oggadm1;'
echo 'GRANT CREATE OPERATOR       TO oggadm1;'
echo 'GRANT CREATE PROCEDURE      TO oggadm1;'
echo 'GRANT CREATE SEQUENCE       TO oggadm1;'
echo 'GRANT CREATE TABLE          TO oggadm1;'
echo 'GRANT CREATE TRIGGER        TO oggadm1;'
echo 'GRANT CREATE TYPE           TO oggadm1;'
echo 'GRANT SELECT ANY DICTIONARY TO oggadm1;'
echo 'GRANT CREATE ANY TABLE      TO oggadm1;'
echo 'GRANT ALTER ANY TABLE       TO oggadm1;'
echo 'GRANT LOCK ANY TABLE        TO oggadm1;'
echo 'GRANT SELECT ANY TABLE      TO oggadm1;'
echo 'GRANT INSERT ANY TABLE      TO oggadm1;'
echo 'GRANT UPDATE ANY TABLE      TO oggadm1;'
echo 'GRANT DELETE ANY TABLE      TO oggadm1;'
echo ''

# Configure TNSnames in OGG
echo ''										>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo 'OGGSOURCE='								>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo '   (DESCRIPTION='								>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo '        (ENABLE=BROKEN)'							>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo '        (ADDRESS_LIST='							>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo '            (ADDRESS=(PROTOCOL=TCP)(HOST=10.0.1.150)(PORT=1521)))'	>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo '        (CONNECT_DATA=(SID=ORCLCDB))'					>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo '    )'									>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo ''										>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo 'OGGTARGET='								>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo '    (DESCRIPTION='							>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo '        (ENABLE=BROKEN)'							>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo '        (ADDRESS_LIST='							>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo '            (ADDRESS=(PROTOCOL=TCP)(HOST=10.0.1.141)(PORT=1521)))'	>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo '        #(CONNECT_DATA=(SID=ORCLCDB))'					>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo '        (CONNECT_DATA ='							>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo '          (SERVER = DEDICATED)'						>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo '          (SERVICE_NAME = ORCLPDB1)'					>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo '        )'								>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
echo '    )'									>> /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora
cat /opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora

# Configure OGG Extract Params
echo 'EXTRACT EORIGEN'					>> /opt/oracle/oggs/dirprm/eorigen.prm
echo 'SETENV (ORACLE_SID=ORCLCDB)'			>> /opt/oracle/oggs/dirprm/eorigen.prm
echo 'SETENV (NLSLANG=AL32UTF8)'			>> /opt/oracle/oggs/dirprm/eorigen.prm
echo 'USERID oggadm1@OGGSOURCE, PASSWORD "p4ssw0rd"'	>> /opt/oracle/oggs/dirprm/eorigen.prm
echo 'EXTTRAIL /opt/oracle/ggs/dirdat/or'		>> /opt/oracle/oggs/dirprm/eorigen.prm
echo 'IGNOREREPLICATES'					>> /opt/oracle/oggs/dirprm/eorigen.prm
echo 'GETAPPLOPS'					>> /opt/oracle/oggs/dirprm/eorigen.prm
echo 'TABLE ORCLPDB1.MYSCHEMA1.*;'			>> /opt/oracle/oggs/dirprm/eorigen.prm
chown oracle.oinstall /opt/oracle/oggs/dirprm/eorigen.prm
chmod 644 /opt/oracle/oggs/dirprm/eorigen.prm

# Configure OGG Replicat Params
echo 'REPLICAT RDESTINO'				>> /opt/oracle/oggs/dirprm/rdestino.prm
echo 'SETENV (ORACLE_SID=ORCLCDB)'			>> /opt/oracle/oggs/dirprm/rdestino.prm
echo 'SETENV (NLSLANG=AL32UTF8)'			>> /opt/oracle/oggs/dirprm/rdestino.prm
echo 'USERID oggadm1@OGGTARGET, password "p4ssw0rd"'	>> /opt/oracle/oggs/dirprm/rdestino.prm
echo 'ASSUMETARGETDEFS'					>> /opt/oracle/oggs/dirprm/rdestino.prm
echo 'MAP ORCLPDB1.MYSCHEMA1.*, TARGET ORCLPDB1.MYSCHEMA1.*, FILTER ( @GETENV('TRANSACTION', 'CSN') > 2688904);'	>> /opt/oracle/oggs/dirprm/rdestino.prm
chown oracle.oinstall /opt/oracle/oggs/dirprm/rdestino.prm
chmod 644 /opt/oracle/oggs/dirprm/rdestino.prm

echo 'dblogin userid oggadm1@OGGORIGEN password p4ssw0rd'			>> /opt/oracle/oggs/ggsci3.script
echo 'add checkpointtable '							>> /opt/oracle/oggs/ggsci3.script
echo 'add trandata ORCLPDB1.MYSCHEMA1.*'					>> /opt/oracle/oggs/ggsci3.script
echo 'add extract EORIGEN tranlog, INTEGRATED tranlog, begin now'		>> /opt/oracle/oggs/ggsci3.script
echo 'add exttrail /opt/oracle/ggs/dirdat/or extract EORIGEN, MEGABYTES 100'	>> /opt/oracle/oggs/ggsci3.script
echo 'register EXTRACT EORIGEN, DATABASE'					>> /opt/oracle/oggs/ggsci3.script
echo 'start EORIGEN'								>> /opt/oracle/oggs/ggsci3.script
echo 'quit'									>> /opt/oracle/oggs/ggsci3.script
chown oracle.oinstall /opt/oracle/oggs/ggsci3.script
chmod 644 /opt/oracle/oggs/ggsci3.script
su - oracle -c "cd /opt/oracle/oggs/; ./ggsci < ggsci3.script"

echo 'dblogin userid oggadm1@OGGTARGET password p4ssw0rd'			>> /opt/oracle/oggs/ggsci4.script
echo 'add checkpointtable ORCLPDB1.oggadm1.gg_checkpoint'			>> /opt/oracle/oggs/ggsci4.script
echo 'add replicat RDESTINO EXTTRAIL /opt/oracle/ggs/dirdat/or CHECKPOINTTABLE ORCLPDB1.oggadm1.gg_checkpoint'	>> /opt/oracle/oggs/ggsci4.script
echo 'start RDESTINO'								>> /opt/oracle/oggs/ggsci4.script
echo 'quit'									>> /opt/oracle/oggs/ggsci4.script
chown oracle.oinstall /opt/oracle/oggs/ggsci4.script
chmod 644 /opt/oracle/oggs/ggsci4.script
su - oracle -c "cd /opt/oracle/oggs/; ./ggsci < ggsci4.script"

exit 1

# Dump/export in Source

select current_scn from v$database;

DECLARE
  l_datapump_handle    NUMBER;
  l_datapump_dir       VARCHAR2(20) := 'DATA_PUMP_DIR';
  l_status             varchar2(200);
BEGIN
  l_datapump_handle := dbms_datapump.open(operation => 'EXPORT',
                                          job_mode =>'SCHEMA',
                                          job_name => 'EXPORT MYSCHEMA1 JOB RUN 001',
                                          version => '12');
  dbms_datapump.add_file(handle => l_datapump_handle,
                         filename  => 'exp_MYSCHEMA1_%U.dmp',
                         directory => l_datapump_dir);
  dbms_datapump.add_file(handle => l_datapump_handle,
                         filename  => 'exp_MYSCHEMA1.log' ,
                         directory => l_datapump_dir ,
                         filetype  => DBMS_DATAPUMP.ku$_file_type_log_file);
  dbms_datapump.set_parameter(l_datapump_handle,'CLIENT_COMMAND','Schema Data Pump Export of MYSCHEMA1 with PARALLEL 8');
  dbms_datapump.set_parameter(l_datapump_handle,'FLASHBACK_SCN',3624571);
  dbms_datapump.set_parameter(l_datapump_handle,'COMPRESSION','ALL');
  dbms_datapump.set_parallel(l_datapump_handle,8);
  DBMS_DATAPUMP.METADATA_FILTER(l_datapump_handle,'SCHEMA_EXPR','IN (''MYSCHEMA1'')');
  dbms_datapump.start_job(handle => l_datapump_handle);
  dbms_datapump.wait_for_job(handle => l_datapump_handle,
                             job_state => l_status );
  dbms_output.put_line( l_status );
END;

# Import on Target
DECLARE
  v_hdnl NUMBER;
BEGIN
  v_hdnl := DBMS_DATAPUMP.OPEN( 
    operation => 'IMPORT', 
    job_mode  => 'SCHEMA', 
    job_name  => null);
  DBMS_DATAPUMP.ADD_FILE( 
    handle    => v_hdnl, 
    filename  => 'exp_MYSCHEMA1_%U.dmp', 
    directory => 'DATA_PUMP_DIR', 
    filetype  => dbms_datapump.ku$_file_type_dump_file);
  DBMS_DATAPUMP.ADD_FILE( 
    handle    => v_hdnl, 
    filename  => 'exp_MYSCHEMA1.log', 
    directory => 'DATA_PUMP_DIR', 
    filetype  => dbms_datapump.ku$_file_type_log_file);
  DBMS_DATAPUMP.METADATA_FILTER(v_hdnl,'SCHEMA_EXPR','IN (''MYSCHEMA1'')');
  DBMS_DATAPUMP.START_JOB(v_hdnl);
END;
/
