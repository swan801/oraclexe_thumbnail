# oraclexe_thumbnail
Create a thumbnail image from an Oracle XE Blob

Using oracle apex, create a procedure that will download an image from the database to the operating system using the  x_to_os procedure.  A cron job runs as often as you like to take the downloaded files using imagemagick mogrify command to convert to a smaller size file and a plsql to run the x_load_blob procedure to upload the new o/s file to Oracle server.  Uses a stored oracle password so may not be secure for you use.

Rquirements
           Oracle XE
           Oracle linux enviroment
           Install imagemagick
           Crontab to run script as required 
           Using    */1 * * * * $HOME/[scriptname]    next line for example, runs every minute:
             */1 * * * * /raid/oracle/src/img.sh
           Oracle procedures
                            To write file to O/S              x_to_os.sql
                            To wirte file to Oracle server    x_load_blob
           Oracle Directory with read/write permissions
           O/S script                                         img.sh
           O/S password file                                  img_db.txt
           Oracle Attachment Table

             
 Dirctory Structure
 
        ./images
        ./src
        ./src/bin
        ./src/files
        ./src/images
        ./src/log
        /location for img_db.txt

