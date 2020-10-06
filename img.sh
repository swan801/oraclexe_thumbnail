#!/bin/sh


#   Script to: 
#              Files downloaded from the Oracle server to this o/#!/bin/sh
#              Use Imagemagick to change file resize
#              Use SQLPlus to upload from O/S to Oracle server
#              Crontab to run script at set interval
#              Files are removed from O/S after processing

##   Crontab command
#     */1 * * * * $HOME/$script name
#     */1 * * * * /raid/oracle/src/img.sh # runs every minute  

EMP=`[ "$(ls -A /raid/oracle/images )" ] && echo "1" || echo "0"`
if [ ${EMP} -eq 0 ]; then
exit
fi
#*** Variables
HOME=/raid/oracle/images                #Home Directory    
LOG=/raid/oracle/src/log                #Log Directoru
# SHORT                                 #Filename without ext, declared line **ADD LINE # HERE**
source /home/oracle/img_db.txt
DB_PASSWORD=$(eval echo ${DB_PASSWORD} )
echo $DB_PASSWORD
 

#*** End Variables

#**** Configure Oracle Variables
export ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE    #ORACLE_HOME
export TGT=/raid/oracle/images                         #Oracle directory for download to o/s 
export SRC=/raid/oracle/src/files                      #Oracle directory for upload to Oracle server
export BIN=/raid/oracle/src/bin                        #Working directory for processing files
export PATH=$ORACLE_HOME:$PATH
#**** End Configure Oracle Variables


# Check for files in  home directory
if [ "$(ls -A $HOME)"]; then
     echo "Files exist in $HOME, continue."
else
     echo "Files do not exist in $HOME, exit."  
fi 
      echo "Continue with script."        

# Move file from $TGT to $BIN  and change to #BIN    

mv $TGT/* $BIN/ ; cd $BIN

#**** Rename *.png files to *.jpg
for PNG in *.png
 do
  
  SHORT=`echo $PNG | sed 's/\.[^.]*$//'`    # File name excluding extension                       
  convert "$PNG" -scale 50% -background white -flatten  "$SHORT.jpg" 
  echo $PNG >>$LOG/image.log                #Insert file name into log file
  rm -rf $PNG                               #remove the png file keeping jpg file
done
#**** End Rename
#******Get Saved DB_PASSWORD
source /home/oracle/img_db.txt
DB_PASSWORD=$(eval echo ${DB_PASSWORD} )
 
#Run mogrify on all files in $BIN  saving to $SRC
mogrify -resize 80x80 -background white -gravity center -extent 80x80 -format jpg -quality 75 -path $SRC/ $BIN/*
rm $BIN/* ; cd $SRC   #clear $BIN cd to $SRC
#*****Create sql script to upload files to Oracle server.
#*****Eache letter in case statement represents procedure to run


for JPG in *.jpg
do
echo $JPG >> $LOG/img.sh
ID=`echo $JPG | sed 's/\%[^%]*$//'`
echo "begin"  >> $SRC/$ID.sh
case "$JPG" in
 W*) echo "fms_load_blob('${JPG}');" >> $SRC/$ID.sh
;;
 E*) echo "fms_eoc_load_blob('${JPG}');"  >> $SRC/$ID.sh
;;
 P*) echo "fms_pm_load_blob('${JPG}');"  >> $SRC/$ID.sh
;;
 C*) echo "fms_ck_load_blob('${JPG}');"  >> $SRC/$ID.sh
;;
 J*) echo "fms_prj_load_blob('${JPG}');"  >> $SRC/$ID.sh
;;

esac
echo "end;" >> $SRC/$ID.sh
echo "/" >> $SRC/$ID.sh
echo "exit" >> $SRC/$ID.sh
/opt/oracle/product/18c/dbhomeXE/bin/sqlplus -s /nolog << EOF > /raid/oracle/src/log/log.txt 2>&1
connect fms@xepdb1/${DB_PASSWORD};
@$SRC/$ID.sh
exit;
EOF
rm -rf $ID
done
