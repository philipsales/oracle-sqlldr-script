#!/bin/bash -xv

# file: ETL.sh 
# author: Philip
# date: March 12, 2014
# function: ETL fingerprint data to .csv for automated loading on sqlldr
# Windows based only
# sort -k1.15n

FOLDERNAME=$(basename "$PWD" | sed -e 's/ /_/g' )                      #get current folder name
mkdir -p tmp_folder
rm -f fingerprint-format.txt
rm -f tmp.txt
rm -f parent_dir.txt 
rm -f tmp_folder/data.csv
rm -f tmp_folder/date_pin.csv
rm -f tmp_folder/$FOLDERNAME.csv
rm -f $FOLDERNAME.ctl
rm -f $FOLDERNAME.log
rm -f $FOLDERNAME.bad
rm -f $FOLDERNAME.dsc
rm -f LoadOracle.bat 

ls -lR | grep -i '.ansi-*'                                                #loading purposes
ls -lR | grep -i '.ansi-*' | awk '{print $9","}'  > fingerprint-format.txt          #get all file 
find ./  | grep -i '.ansi-*' | sort -n | awk  -F "/" '{print $(NF-2) "," $(NF-1)}' > parent_dir.txt          #get parent directory 
sed -n -e '1~4p' parent_dir.txt > tmp_folder/date_pin.csv                      #print every 4th line only
tr '\n' ' ' <  fingerprint-format.txt >  tmp.txt                              #remove all newline 


echo "PLEASE WAIT.. LOADING .csv file"

#cat tmp.txt | awk '{for(i=1;i<=NF;i=i+4)print substr($i,0,12)",",$i,$(i+1),$(i+2),$(i+3)}' | sed 's/\ //g'  > tmp_folder/$FOLDERNAME.csv 
cat tmp.txt | awk '{for(i=1;i<=NF;i=i+4)print $i,$(i+1),$(i+2),$(i+3)}' | sed 's/\ //g'  > tmp_folder/data.csv 
#print .csv without spaces

awk 'FNR==NR{a[FNR""]=$0; next} {print a[FNR""],$0}' tmp_folder/date_pin.csv tmp_folder/data.csv | tr ' ' ',' > tmp_folder/$FOLDERNAME.csv

NUMOFMEMBER=$(cat fingerprint-format.txt | wc -l)


echo "creating tmp_folder" 
echo "copying match files TO tmp_folder" 
find . -name "*.ansi-*" | xargs --verbose -I '{}' cp '{}' tmp_folder

echo 
echo $NUMOFMEMBER "MEMBER FingerPrint found"
echo

echo "Creating $FOLDERNAME.ctl file into tmp_folder" 
echo
touch tmp_folder/$FOLDERNAME.ctl 
echo "LOAD DATA 
INFILE '$FOLDERNAME.csv'
BADFILE '$FOLDERNAME.bad'
DISCARDFILE '$FOLDERNAME.dsc'
APPEND
INTO TABLE SAGIP.KIOSK_BIOMETRIC
FIELDS TERMINATED BY ',' 
(
    DATE_CAPTURED            CHAR(100),
    PHILHEALTH_ID            CHAR(100),
    LEFT_BACKUP_FILENAME     FILLER CHAR(100),
    LEFT_BACKUP              LOBFILE(LEFT_BACKUP_FILENAME) TERMINATED BY EOF,
    LEFT_PRIMARY_FILENAME    FILLER CHAR(100),
    LEFT_PRIMARY             LOBFILE(LEFT_PRIMARY_FILENAME) TERMINATED BY EOF,
    RIGHT_BACKUP_FILENAME    FILLER CHAR(100),
    RIGHT_BACKUP             LOBFILE(RIGHT_BACKUP_FILENAME) TERMINATED BY EOF,
    RIGHT_PRIMARY_FILENAME   FILLER CHAR(100),
    RIGHT_PRIMARY            LOBFILE(RIGHT_PRIMARY_FILENAME) TERMINATED BY EOF
)" > tmp_folder/$FOLDERNAME.ctl


echo "Craeting LoadOracle.bat file into tmp_folder" 
touch tmp_folder/LoadOracle.bat
echo "REM
REM 
REM Please edit this script and provide values for the variables below.
REM
SET ORACLE_HOME=C:\oracle\app\oracle\product\11.2.0\server
SET USERNAME=SYSTEM
SET PASSWORD=tiger
SET TNS_NAME=

ECHO Loading tables ... 

#%ORACLE_HOME%\bin\sqlldr %USERNAME%/%PASSWORD% control=\"tmp_folder/$FOLDERNAME.ctl\"
sqlldr SYSTEM/sys@pjsal control=\"$FOLDERNAME.ctl\"

ECHO Loading tables has completed.  " > tmp_folder/LoadOracle.bat


rm -f fingerprint-format.txt
rm -f tmp.txt
rm -f parent_dir.txt 
rm -f tmp_folder/data.csv
rm -f tmp_folder/date_pin.csv
