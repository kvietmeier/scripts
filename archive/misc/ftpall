#!/usr/bin/ksh
#  Karl Vietmeier
#  Enterprise Services - Pacific Northwest Region
#  karl.vietmeier@sun.com
#
#  Script to ftp/upload system files to T300 trays.
#
#  NOTES:
#  Edit the FILES variable to choose which files you will ftp
#  to the T3's.
#
#  The script will first look for the t3hosts file in the T3Extractor
#  directory, if it doesn't find one, it will prompt for hostnames until
#  you are done.
#
#  The script assumes you have untarred T3tools.tar and are running it
#  from the directory created.
#



###========================================================###
###                     Variables                          ###
###========================================================###

USER=root       		  # login as root on T3
TRUE=1                    # Boolean true
FALSE=0                   # Boolean false
ERR=0			          # Error Counter
TMPNETRC=/tmp/netrc.$$    # Backup copy of existing .netrc
HOMEDIR=$HOME		      # User's default home directory.
FILES="schd.conf syslog.conf hosts"
T3TOOLDIR=$(pwd)
EXTRACTOR=$(ls -1 ${T3TOOLDIR} | grep T3extractor)
EXTRACTDIR=${T3TOOLDIR}/$(echo $EXTRACTOR | awk '{print $1}')

###========================================================###
###                     Function Definitions               ###
###========================================================###

netrc_gen() {
  #  Routine to Create ~/.netrc

  if [ -f $HOMEDIR/.netrc ]; then
    mv $HOMEDIR/.netrc $TMPNETRC    # Preserve existing .netrc
  fi
  echo "Creating Auto ftp File In [$HOMEDIR/.netrc]..."
  echo "machine $TARGET login $USER password $PASS" > $HOMEDIR/.netrc
  echo "macdef init" >> $HOMEDIR/.netrc
  echo "prompt"  >> $HOMEDIR/.netrc
  echo "cd /"  >> $HOMEDIR/.netrc  

  # FTP /etc files 
  echo "lcd ${SYSFILEDIR}" >> $HOMEDIR/.netrc
  echo "cd etc"  >> $HOMEDIR/.netrc
  echo "mput $FILES" >> $HOMEDIR/.netrc      
  echo "quit \n\n" >> $HOMEDIR/.netrc      
  chmod 700 $HOME/.netrc
}


cleanup() 
{
  echo "\nCleaning Up Temporary Files..."
  rm -f $HOMEDIR/.netrc		# Remove .netrc file
  if [ -f $TMPNETRC ]; then
    mv $TMPNETRC $HOMEDIR/.netrc  # Restore previous .netrc
  fi
}


error_exit_code() 
{
  cleanup
  echo "Exiting $0...."
  exit 1
}
trap "error_exit_code" 1 2 3


###========================================================###
###			Main Script			   ###
###========================================================###

clear
# Get Location of T300 System Files To Upload
echo "By Default the T3 System Files are in: ${T3TOOLDIR}/sysfiles"
echo "Enter System File Location [${T3TOOLDIR}/sysfiles] : \c"
read TMP    

if [ "999$TMP" != "999" ]; 
   then T3TOOLDIR=$TMP
   else SYSFILEDIR=${T3TOOLDIR}/sysfiles
fi

echo "What is the root password on the T3/s? \c"
read PASS

if [[ -a ${EXTRACTDIR}/t3hosts ]]
  then 
   for host in $(cat ${EXTRACTDIR}/t3hosts)
   do
    TARGET=$host 

    # Is T3 there? 
     ping $TARGET
     ERRCODE=$?      
     if [ $ERRCODE -ne $FALSE ]; then
      echo 'TARGET Unreachable '
      echo ""
      continue
     fi 

    # Generate netrc file
    netrc_gen

    # Start ftp process
    ftp $TARGET

    # Remove netrc file 
    cleanup
   done
  
  else

    while true;
     do
      echo "Hit return with no entry to exit the script"
      echo "Enter Hostname or IP Address Of T300: \c"
      read TARGET

      if [ "999$TARGET" = "999" ]
         then break
      fi

      # Is T3 there? 
       ping $TARGET
       ERRCODE=$?      
       if [ $ERRCODE -ne $FALSE ]; then
        echo 'Target System Unreachable - Try Again.'
        echo ""
        continue
       fi 

      # Generate netrc file
      netrc_gen

      # Start ftp process
      ftp $TARGET

      # Remove netrc file 
      cleanup
     done

fi


