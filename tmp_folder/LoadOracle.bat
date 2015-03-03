REM
REM 
REM Please edit this script and provide values for the variables below.
REM
SET ORACLE_HOME=C:\oracle\app\oracle\product\11.2.0\server
SET USERNAME=SYSTEM
SET PASSWORD=tiger
SET TNS_NAME=

ECHO Loading tables ... 

#%ORACLE_HOME%\bin\sqlldr %USERNAME%/%PASSWORD% control="tmp_folder/sample_biometric.ctl"
sqlldr SYSTEM/sys@pjsal control="sample_biometric.ctl"

ECHO Loading tables has completed.  
