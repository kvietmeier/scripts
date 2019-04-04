#! /usr/bin/ksh
# Mirror the bootdisk using a Best Practices Method.
#  
# Written By:
#             Karl Vietmeier
#             CPRE-AMER Network Storage
#             Newark, CA
#             karl.vietmeier@sun.com
#
#  Created:        12.13.2000
#  Last Modified:  
#  12.15.00
#    Added code to sanity check the CTD of the boot disk and mirror
#  01.12.01
#    Added instructions to disable relocation/enable hotsparing
#  01.19.01
#    Added vxeeprom command to set devalias
#    Added check for use-nvramrc?=true and set if false
#  01.22.01
#    Made minor changes to output
#    Won't let root and mirror be the same disk!
#  02.28.01
#    Strengthened warning regarding systems with non-standard partitions
#  03.09.01
#    Added check for non-standard partitions - script now quits if it finds them
#  03.29.01
#    Fixed typo in flag and tag definition
#    Added check for volume manager actually being installed and root encapsulated
#    Fixed broken check for invalid volumes (Thanks Ramesh!)
#  12.9.01
#    Changed tag on OPT - 09 would cause upgrade-start/finish to fail
#  02.01.02
#    Major rewrite - lots of changes:
#    Now mirrors any volumes found on the rootdisk
#    Creates vfstab files for root and mirror
#  02.13.02
#    Added check for minimum patch levels or quit.
#  04.05.02
#    Fixed problem with patch comparison and now check for
#    rootdiskPriv and exit if it exists
#  04.09.02
#    Resolved rootdiskPriv bug.
#    Now save restore files in /var/sadm/vx-restore
#    Added version information at run-time
#  08.19.02
#    Transition to version 6.  Break up functions to allow more flexibility
#    to add a "make clone" ability.
#  01.12.03
#    Add support for v3.5
#  07.22.03
#    Updated patch numbers and revisions.
#
#
#  WARNING - DISCLAIMER
#  This script is provided as is - and is not supported by Sun Microsystems
#  You use it at your own risk.  SMI can not accept any responsibility for
#  incorrect usage.  It is intended for use by trained Support Engineers 
#  who understand the use of the Vxvm scripts and commands called by the
#  script.
#

# Check for encapsulted boot disk - quit if we don't find one
 if [[ ! -e /etc/vx/reconfig.d/state.d/root-done ]]
  then 
       echo "####=================================================####"
       echo "Sorry - Need to have an encapsulated root disk! - Quiting"
       echo "####=================================================####"
       echo ""
       exit
 fi


###================= TRAPS =================###
#  Don't let the user kill the running script
#trap 'kill_script' INT
#trap 'print "Ctl-\ Will Not Kill this script!"' QUIT
#trap 'print "You tried to kill me! This will have distasterous results STOP"' TERM
#function kill_script
#{
# echo "Ctl-C Will Not Kill this script!"
# #fflush
# exit
#}


###=================================================================###
#                       Variables
###=================================================================###

# flags and tags for vxmksdpart
  VAR="0x07 0x00"   
  USR="0x04 0x00"
 SWAP="1 0x03 0x01"
 HOME="0x08 0x00"
UNASG="0x00 0x00"

# Get volumes that actually exist
set -A VOLS $(vxprint -g rootdg -v -F "%{name}")

# Get boot disk from vxprint 
set $(vxprint -htd -g rootdg | grep ^dm | awk '{print $2 "\t" $3}')
ROOT_DM=${1}
BOOT=${2%??}   

## Get ctd and dm_name for bootdisk
# Check for a clustered system with different dm names
for node in 1 2 3 4 5 6 7 8
 do
   # Need this to accomadate naming from scvxinstall
   if [[ $ROOT_DM = "rootdisk${node}" || $ROOT_DM = "rootdisk_${node}" ]]
       then MIRROR_DM="root${node}mirror"
            break
       else MIRROR_DM="rootmirror"
   fi
done

# Stuff for checking patches - these are the mimimums to get around the disk
# mirroring bugs.

CHK_VXVM=$(pkginfo -l VRTSvxvm | grep VERSION | awk '{print $2}')
VXVM_VER=${CHK_VXVM%,*}
GET_OSVER=$(uname -r)
OS_VER=${GET_OSVER#??}

# Check for minimum patch levels
# 3.5
VXVM_35_PATCH_9="112392-04"
VXVM_35_PATCH_8="112392-02"
VXVM_35_PATCH_7="112392-04"
# 3.2
VXVM_32_PATCH_9="112385-05"
VXVM_32_PATCH_8="113201-04"
VXVM_32_PATCH_7="113201-04"
VXVM_32_PATCH_6="113201-04"
# 3.1.1
VXVM_311_PATCH_8="111118-10"
VXVM_311_PATCH_7="110452-09"
VXVM_311_PATCH_6="110451-09"
# 3.1
VXVM_31_PATCH_8="110255-04"
VXVM_31_PATCH_7="110254-04"
VXVM_31_PATCH_6="110255-04"
# 3.0.4
VXVM_304_PATCH_8="110263-05"
VXVM_304_PATCH_7="110262-05"
VXVM_304_PATCH_6="110261-05"

# Misc
SAV_DIR="/var/sadm/vx-recover/"
SCRIPT_VER="VX BootMirror 6.0"



###=================================================================###
#                       Functions
###=================================================================###

###=====  Utility Functions =====###
function wait_continue
{
        echo "\nHit RETURN to continue.\c"
        read ANSWER
}

# Call this function with a question string and a default answer:
#  ex: yes_or_no "Is this correct?" y || { echo "bad answer" }
function yes_or_no
{
 while :
  do
     echo "\n$1? [$2] \c"
     ANSWER=
     read ANSWER
     case $ANSWER in
         "") ANSWER=$2; break;;
         [Nn]|no)   ANSWER=no; break;;
         [Yy]|yes)  ANSWER=yes; break;;
         *) echo "\nPlease answer \"yes\" or \"no\"."
         continue;;
         esac
      done
}


function patch_exit
{
 # Call this from patch test function when we find a problem
 echo "   This system does not meet the minimum requirements for" 
 echo "   successful mirroring of the boot disk:" 
 echo ""
 echo "   VXVM $VXVM_VER on Solaris $OS_VER Requires ${PATCH} or higher"
 echo "####====================================================####"
 echo ""
 exit

}


function give_exit_status
{
 echo "####===============================================####"
 echo "####=========  Fatal Error Encountered  ===========####"
 echo "####===============================================####"
 echo ""
 echo "     The last VxVM Command exited with error code $?"
 echo ""
 echo "  The description can be found in the vxintro manpage"
 echo ""
 echo "####===============================================####"
 exit
}


function rootdiskPriv_explain
{
cat <<EOF
####=======================================================================####

The subdisk rootdiskPriv exists in the rootdg configuration.
This means that when the OS was installed there were no extra
cycliners left at the end of the disk for Volume Manager to use
for the private region.  In this situation it will be impossible
to mirror the volumes in rootvol to another disk.  You will have
to do the following:

        1.)  Unencapsulate the rootdisk (save a reboot - do it now)
        2.)  Boot CDROM
        3.)  Zero out the public and private region slices.
        4.)  Shrink swap by a few cylinders, you need at least 10mb free.
        5.)  Reboot and re-encapsulate using your method of choice.

If you don't understand the steps just described, please get
someone who does to help you.  

Call 1-800-USA4SUN

####=======================================================================####
EOF
}


function patch_check
{
 #set -sA INSTALLED_PATCH $(showrev -p | grep ${PATCH%-*} | awk '{print $2}')
 set -sA INSTALLED_PATCH $(showrev -p | cut -c7-16 | grep ${PATCH%-*})

 # Is patch even installed?
 if [[ ${#INSTALLED_PATCH[@]} != 0 ]]
      then
           # Need this to grab the highest revision number
           NUM_VERSIONS=${#INSTALLED_PATCH[@]}
           (( HIGHEST_REV = NUM_VERSIONS - 1 ))
           INSTALLED_REV=${INSTALLED_PATCH[$HIGHEST_REV]}

           if (( ${INSTALLED_REV#*-} == ${PATCH#*-} ))
               then continue

           elif (( ${INSTALLED_REV#*-} < ${PATCH#*-} ))
               then patch_exit
                                
           elif (( ${INSTALLED_REV#*-} > ${PATCH#*-} ))
               then continue
           fi
      else patch_exit
 fi
}


function check_patches
{

 ###  Check to see if we have the rootdiskPriv subdisk"
 ###  If it exists - the script must exit if we are 
 ###  using VxVM 3.2 because mirroring will fail.

 PRIV_EXISTS=$(vxprint -Q -s | grep ${ROOT_DM}Priv)
 if [[ ${#PRIV_EXISTS} > 0 && $VXVM_VER = "3.2" ]]
   then rootdiskPriv_explain
        exit
 fi

  if [[ $OS_VER = "9" ]]
   then
      if [[ $VXVM_VER = "3.5" ]]
         then PATCH=$VXVM_35_PATCH_9
              patch_check
      elif [[ $VXVM_VER = "3.2" ]]
         then PATCH=$VXVM_32_PATCH_9
              patch_check
      fi

  if [[ $OS_VER = "8" ]]
   then
      # Only really need this first one - but hey - you should
      # patch it anyway!
      if [[ $VXVM_VER = "3.5" ]]
         then PATCH=$VXVM_35_PATCH_8
              patch_check
      elif [[ $VXVM_VER = "3.2" ]]
         then PATCH=$VXVM_32_PATCH_8
              patch_check
      elif [[ $VXVM_VER = "3.1.1" ]]
         then PATCH=$VXVM_311_PATCH_8
              patch_check
      elif [[ $VXVM_VER = "3.1" ]]
         then PATCH=$VXVM_31_PATCH_8
              patch_check
      elif [[ $VXVM_VER = "3.0.4" ]]
         then PATCH=$VXVM_304_PATCH_8
              patch_check
      fi

  elif [[ $OS_VER = "7" ]]
   then
      if [[ $VXVM_VER = "3.5" ]]
         then PATCH=$VXVM_35_PATCH_7
              patch_check
      elif [[ $VXVM_VER = "3.2" ]]
         then PATCH=$VXVM_32_PATCH_7
              patch_check
      elif [[ $VXVM_VER = "3.1.1" ]]
         then PATCH=$VXVM_311_PATCH_7
              patch_check
      elif [[ $VXVM_VER = "3.1" ]]
         then PATCH=$VXVM_31_PATCH_7
              patch_check
      elif [[ $VXVM_VER = "3.0.4" ]]
         then PATCH=$VXVM_304_PATCH_6
              patch_check
      fi

  elif [[ $OS_VER = "6" ]]
   then
      if [[ $VXVM_VER = "3.5" ]]
         then PATCH=$VXVM_35_PATCH_6
              patch_check
      elif [[ $VXVM_VER = "3.2" ]]
         then PATCH=$VXVM_32_PATCH_6
              patch_check
      elif [[ $VXVM_VER = "3.1.1" ]]
         then PATCH=$VXVM_311_PATCH_6
              patch_check
      elif [[ $VXVM_VER = "3.1" ]]
         then PATCH=$VXVM_31_PATCH_6
              patch_check
      elif [[ $VXVM_VER = "3.0.4" ]]
         then PATCH=$VXVM_304_PATCH_6
              patch_check
      fi

  fi
}


# Check value of use-nvramrc?, and set if not true
function check_nvramrc
{
 if [ `eeprom 'use-nvramrc?'` != "use-nvramrc?=true" ]
    then echo "It is set to false - fixing"
         echo "eeprom 'use-nvramrc?=true"
         eeprom 'use-nvramrc?=true'
    else continue
 fi
}


###=====  Start Mirroring Functions =====###

function intro
{
cat <<EOF


[================================================================]

This script is designed to mirror a boot disk using a "Best
Practices" methodology developed by Engineers within Sun
Microsystems.  After running the script the boot disk and mirror
will have identical vtocs, subdisk to plex mapping, and all
volumes will have hard partitions mountable by Solaris.  This will
simplify recovery and upgrades, and produce more readable vxprint
output.

It is *strongly* encouraged that you do this procedure by hand
several times before using the script.  It is important to
understand what happens when a boot disk is encapsulated and
mirrored.

Information on this procedure is available in a Blueprint Article
on the main Sun website:
http://www.sun.com/software/solutions/blueprints/browsesubject.html

The article:
"Towards a Reference Configuration for VxVM Managed Boot Disks"
Gene Trantham and John S. Howard


*****   WARNING - DISCLAIMER   *****
This script is provided as is - and is not supported by Sun Microsystems
You use it at your own risk.  SMI can not accept any responsibility for
incorrect usage.  It is intended for use by trained Support Engineers 
who understand the use of the Vxvm scripts and commands called by the
script.
*****   WARNING - DISCLAIMER   *****

[================================================================]

You are running $SCRIPT_VER

EOF
wait_continue
}


# Get the bootdisk and mirror CTD numbers
function get_boot_mirror
{
 # This very long section tries to catch most fatal config problems
 # Lots of checks for already in use disks etc.

 while true
  do
   while true
    do 
      vxdisk list
      echo ""
      echo "What is the C#T#D# of the mirror? \c"
      read MIRROR

      if [[ $MIRROR != [Cc]+([0-9])[Tt]+([0-9])[Dd]+([0-9]) ]]
          then echo "$MIRROR is a Malformed CTD# - try again"
               continue
      elif [[ $MIRROR = $BOOT ]]
          then echo "The boot disk and mirror are the same disk - try again!"
               continue
      fi    
      break
    done

  # Check the mirror's status....
  STATUS=$(vxdisk list | grep $MIRROR)
  echo "$STATUS"

  if [[ ${#STATUS} = 0 ]]
      then
           echo "This disk not in VXVM config - exiting.... "
           echo "Check vxdisk list output and run vxdctl enable if needed"
           echo ""
           vxdisk list
           exit
  elif [[ ${#STATUS} > 0 ]]
      then set ${STATUS}
  fi    

  if [[ $5 = "error" ]]
      then echo "$MIRROR Not under VxVM Control - Continuing"
           break
  elif [[ $5 = "online" ]]
      then
           set -A MIRROR_PLEXES $(vxprint -Q -g rootdg -e "pl_sd.sd_dm_name == \"$MIRROR_DM\"" -p -F "%{name:-14} %{sdaslist}")
           echo ""
           if [[ ${#MIRROR_PLEXES} != 0 ]]
               then
                    echo ""
                    echo "[================================================================]"
                    echo "######  This disk has ${#MIRROR_PLEXES} associated plexs!!!  #######"
                    echo "[================================================================]"
                    echo ""
                    print "Exiting.............. "
                    sleep 2
                    echo ""
                    exit

               else
                    echo ""
                    echo "[================================================================]"
                    echo " WARNING -> This disk is initialized but has no associated plexes"
                    echo "            It is probably safe to use....."
                    echo "[================================================================]"
                    echo ""
                    echo "${STATUS}"
                    yes_or_no "Remove it Before Continuing? (no will exit script)" n 
           fi
  fi

  if [[ $ANSWER = "no" ]]
      then echo "Exiting ....  Must Have Valid Mirror"
           exit    
  elif [[ $ANSWER = "yes" ]] 
      then yes_or_no "Are You *REALLY* Sure? This Could be Dangerous" n
           if [[  $ANSWER = "yes" ]]
               then
                  if [[ $4 = "-" ]]
                      then echo "/etc/vx/bin/vxdiskunsetup -C ${1%??}"
                           /etc/vx/bin/vxdiskunsetup -C ${1%??}
                           if [[ $? -ne 0 ]] ; then give_exit_status ; fi  

                           break
                      else
                           echo "Removing $MIRROR from VxVM Config"
                           echo "vxdg -g ${4} rmdisk ${3}"
                           echo "/etc/vx/bin/vxdiskunsetup -C ${1%??}" 
                           vxdg -g ${4} rmdisk ${3}
                           if [[ $? -ne 0 ]] ; then give_exit_status ; fi  
                           /etc/vx/bin/vxdiskunsetup -C ${1%??} 
                           if [[ $? -ne 0 ]] ; then give_exit_status ; fi  

                           break
                  fi
           fi
  fi

 done
}    


# Initialize mirror and add it to rootdg
function create_rootmirror
{
 echo ""
 echo ""
 echo "Add rootmirror to the rootdg config"
 echo "/etc/vx/bin/vxdisksetup -i $MIRROR"
 /etc/vx/bin/vxdisksetup -i $MIRROR
 if [[ $? -ne 0 ]] ; then give_exit_status ; fi 

 # Check to see if the disk name exists - if it does you need the -k flag for adddisk
 MIRROR_DMNAME_EXISTS=$(vxprint -Q -d | grep ${MIRROR_DM})

 if [[ ${#MIRROR_DMNAME_EXISTS} != 0 ]]
     then
       echo ""
       echo "vxdg -g rootdg -k adddisk $MIRROR_DM=$MIRROR"
       vxdg -g rootdg -k adddisk $MIRROR_DM=$MIRROR
       if [[ $? -ne 0 ]] ; then give_exit_status ; fi    
     else
       echo ""
       echo "vxdg -g rootdg adddisk $MIRROR_DM=$MIRROR"
       vxdg -g rootdg adddisk $MIRROR_DM=$MIRROR
       if [[ $? -ne 0 ]] ; then give_exit_status ; fi    
 fi

 echo ""
 echo "[================================================================]"
 echo "         The system has been prepared for mirroring.              " 
 echo "          If one of the above commands failed or                  "
 echo "          if you have any doubts - use CTL-C now.                 "
 echo "        Once you hit return DO NOT STOP THE PROCESS               " 
 echo "[================================================================]"
 echo ""
 wait_continue

}


function mirror_vols
{
 TARGET=$1
 echo ""
 echo "Mirror the rootvol"
 echo "/etc/vx/bin/vxrootmir $TARGET"
 /etc/vx/bin/vxrootmir $TARGET
 if [[ $? -ne 0 ]] ; then give_exit_status ; fi

 for VOL in ${VOLS[@]}
  do
   if [ $VOL = "rootvol" ]
      then continue
      else
           echo "vxassist -g rootdg mirror $VOL $TARGET"
           vxassist -g rootdg mirror $VOL $TARGET
           if [[ $? -ne 0 ]] ; then give_exit_status ; fi     
   fi
 done
}


####=========================================================####
####  The following section implements the "Best Practices"  ####
####=========================================================####

function break_plexes
{
 #  Note - will need to change the "-01" to make function
 #  more general for add/remove clone
 ### Break the mirrors and remove the plexes ###
 echo ""
 echo "Break the mirrors and remove the plexes"
 for VOL in ${VOLS[@]}
   do
     echo "vxplex -g rootdg -o rm dis ${VOL}-01" 
     vxplex -g rootdg -o rm dis ${VOL}-01
     if [[ $? -ne 0 ]] ; then give_exit_status ; fi   
   done
}


function rm_disk_rootdg
{
 ### Remove rootdisk from rootdg  ###
 echo ""
 echo "Remove ${ROOT_DM} from rootdg"
 echo "vxdg -g rootdg -k rmdisk ${ROOT_DM}" 
 vxdg -g rootdg -k rmdisk ${ROOT_DM}
 if [[ $? -ne 0 ]] ; then give_exit_status ; fi 
 echo "/etc/vx/bin/vxdiskunsetup $BOOT"
 /etc/vx/bin/vxdiskunsetup $BOOT
 if [[ $? -ne 0 ]] ; then give_exit_status ; fi 
}


function reinit_bootdisk
{
 ### Reinitialize the boot disk and add it back into rootdg ###
 echo ""
 echo "Reinitialize the boot disk and add it back into rootdg"
 echo "/etc/vx/bin/vxdisksetup -i $BOOT"
 /etc/vx/bin/vxdisksetup -i $BOOT
 if [[ $? -ne 0 ]] ; then give_exit_status ; fi 

 # Check to see if the disk name exists:
 ROOT_DMNAME_EXISTS=$(vxprint -Q -d | grep ${ROOT_DM})

 if [[ ${#ROOT_DMNAME_EXISTS} = 0 ]] 
     then echo "${ROOT_DM} name does not exist"
          echo "vxdg -g rootdg adddisk ${ROOT_DM}=$BOOT"
          vxdg -g rootdg adddisk ${ROOT_DM}=$BOOT
          if [[ $? -ne 0 ]] ; then give_exit_status ; fi      
     else
          echo "Using -k flag - ${ROOT_DM} exists"
          echo "vxdg -g rootdg -k adddisk ${ROOT_DM}=$BOOT"
          vxdg -g rootdg -k adddisk ${ROOT_DM}=$BOOT
          if [[ $? -ne 0 ]] ; then give_exit_status ; fi      
 fi
 echo ""
}


function rm_rootdiskPriv
{
 ### If it exists - remove the rootdiskPriv plex ###
 echo ""
 PRIV_EXISTS=$(vxprint -Q -s | grep ${ROOT_DM}Priv)
 if [[ ${#PRIV_EXISTS} = 0 ]]
     then echo "No ${ROOT_DM}Priv" 
     else
          echo "Removing ${ROOT_DM}Priv"
          echo "vxedit rm ${ROOT_DM}Priv"
          vxedit rm ${ROOT_DM}Priv
          if [[ $? -ne 0 ]] ; then give_exit_status ; fi     
 fi

}


####=========================================================####
####       The following functions are for vxmksdpart        ####
####     Because I use vxassist to mirror plexes you have    ####
####     to do this for each plex that has been mirrored.    ####
####=========================================================####

function get_plex_sd
{
 # Get the mapping for subdisk to plex for mksdpart
 if [[ -e /tmp/vols ]]
     then rm /tmp/vols
 fi

 let count=0
 while (( $count < ${#SUBDISKS[*]} ))
   do
     echo "${SUBDISKS[$count]}" >> /tmp/vols
     let count="count + 1"
   done
}


function create_hard_slices
{
  # Run vxmksdpart and create a vfstab for both root and mirror
  if [[ ! -d ${SAV_DIR} ]]
      then echo "Creating Recovery Directory ${SAV_DIR} "
           mkdir ${SAV_DIR} 
  elif [[ -e ${SAV_DIR} ]]
      then echo "${SAV_DIR} exists, continuing"
  fi


  for DISK in $ROOT_DM $MIRROR_DM
   do
     if [[ $DISK = *disk* ]]
         then CTD=${BOOT}
     elif [[ $DISK = *mirror* ]]
         then CTD=${MIRROR}
     fi

     echo "Partitioning $DISK"
     IFS="\n"
     set -A SUBDISKS $(vxprint -Q -g rootdg -e "pl_sd.sd_dm_name == \"$DISK\"" -p -F "%{name:-14} %{sdaslist}")
     get_plex_sd
     cat /tmp/vols

     IFS=" "
     SLICE=5
     exec < /tmp/vols

# Start creating vfstab for both disks
# HERE docs cannot be indented - leave like this
cat > ${SAV_DIR}vfstab_${DISK} << EOFVFSTAB                      
#device         device          mount           FS      fsck    mount   mount
#to mount       to fsck         point           type    pass    at boot options
# 
#  vfstab for ${DISK}
fd      -       /dev/fd fd      -       no      -
/proc   -       /proc   proc    -       no      -
/dev/dsk/${CTD}s1       -       -       swap    -       no      -
/dev/dsk/${CTD}s0       /dev/rdsk/${CTD}s0      /       ufs     1       no      logging
EOFVFSTAB

     while read PLEX SD
      do
        # Skip rootvol since we always have a slice for root
        if [ ${PLEX%-*} = "rootvol" ]
           then continue
        elif [ ${PLEX%-*} = "swapvol" ]
           then
                # Do swap seperately because it is always on 1"
                TNF=$SWAP
                echo "Run vxmksdpart on $PLEX"
                echo "/etc/vx/bin/vxmksdpart -g rootdg ${SD%:*} $TNF"
                /etc/vx/bin/vxmksdpart -g rootdg ${SD%:*} $TNF
                if [[ $? -ne 0 ]] ; then give_exit_status ; fi       
                continue
        fi

        if [ ${PLEX%-*} = "usr" ]
           then TNF=$USR
                echo "/dev/dsk/${CTD}s${SLICE}\t/dev/rdsk/${CTD}s${SLICE}\t/usr\tufs\t1\tno\tlogging" >> ${SAV_DIR}vfstab_${DISK}
        elif [ ${PLEX%-*} = "var" ]
           then TNF=$VAR
                echo "/dev/dsk/${CTD}s${SLICE}\t/dev/rdsk/${CTD}s${SLICE}\t/var\tufs\t1\tno\tlogging" >> ${SAV_DIR}vfstab_${DISK}
        elif [ ${PLEX%-*} = "home" ]
           then TNF=$HOME 
		        echo "/dev/dsk/${CTD}s${SLICE}\t/dev/rdsk/${CTD}s${SLICE}\t/export/home\tufs\t1\tno\tlogging" >> ${SAV_DIR}vfstab_${DISK}
        else TNF=$UNASG 
		     echo "/dev/dsk/${CTD}s${SLICE}\t/dev/rdsk/${CTD}s${SLICE}\t/${PLEX%-*}\tufs\t1\tno\tlogging" >> ${SAV_DIR}vfstab_${DISK}
        fi


        echo "Run vxmksdpart on $PLEX"
        echo "/etc/vx/bin/vxmksdpart -g rootdg ${SD%:*} $SLICE $TNF"
        /etc/vx/bin/vxmksdpart -g rootdg ${SD%:*} $SLICE $TNF
        if [[ $? -ne 0 ]] ; then give_exit_status ; fi   

        echo ""
		
        (( SLICE = SLICE + 1 ))
        #echo "$SLICE - ${PLEX%-*} "
        wait_continue
      done

      # Add the last line to vfstab
      echo "swap\t-\t/tmp\ttmpfs\t-\tyes\t-" >> ${SAV_DIR}vfstab_${DISK}
  done
}
 

####=========================================================####
####      The following functions finish up the details      ####
####=========================================================####

function finishing_touches
{

 # Check for the files created by the install_vxvm script and
 # remove them - saving the system.orig
 if [[ -e /var/tmp/vfstab.mirror ]]
    then rm /var/tmp/vfstab.mirror 
 fi

 if [[ -e /var/tmp/vfstab.boot ]]
    then rm /var/tmp/vfstab.boot
 fi

 if [[ -e /var/tmp/system.orig ]]
    then cp /var/tmp/system.orig ${SAV_DIR} 
 fi

 # Create the boot aliases and copy some basic configuration information
 # to backup files.
 echo "*** Making backup copies of boot/mirror configuration information ***"
 echo ""
 echo "Using vxeeprom to set device aliases:"
 echo "/usr/lib/vxvm/bin/vxeeprom devalias vx-rootdisk /dev/dsk/${BOOT}s0"
 /usr/lib/vxvm/bin/vxeeprom devalias vx-rootdisk /dev/dsk/${BOOT}s0
 echo "/usr/lib/vxvm/bin/vxeeprom devalias vx-rootmirror /dev/dsk/${MIRROR}s0"
 /usr/lib/vxvm/bin/vxeeprom devalias vx-rootmirror /dev/dsk/${MIRROR}s0

 echo ""

 echo "Creating boot and diag devices"
 echo "eeprom boot-device="vx-rootdisk vx-rootmirror""
 eeprom boot-device="vx-rootdisk vx-rootmirror"
 echo "eeprom diag-device="vx-rootmirror vx-rootdisk""
 eeprom diag-device="vx-rootmirror vx-rootdisk"

 echo ""

 echo "Saving vtoc for the disks to a file"
 echo "prtvtoc /dev/dsk/${BOOT}s2 > ${SAV_DIR}vtoc_bootdisk.sav"
 echo "prtvtoc /dev/dsk/${MIRROR}s2 > ${SAV_DIR}vtoc_mirror.sav"
 prtvtoc /dev/dsk/${BOOT}s2 > ${SAV_DIR}vtoc_bootdisk.sav
 prtvtoc /dev/dsk/${MIRROR}s2 > ${SAV_DIR}vtoc_mirror.sav

 echo ""

 echo "Saving boot aliases to file in /var/tmp"
 echo "eeprom nvramrc 2> /dev/null | sed -e "1s/nvramrc=//p" -e 1d > ${SAV_DIR}bootaliases.sav"
 eeprom nvramrc 2> /dev/null | sed -e "1s/nvramrc=//p" -e 1d > ${SAV_DIR}bootaliases.sav

 echo ""

 echo "Creating an edited version of vxrelocd"
 echo "sed -e 's/spare=yes/spare=only/g' /etc/vx/bin/vxrelocd > ${SAV_DIR}vxrelocd_spare-disabled"
 sed -e 's/spare=yes/spare=only/g' /etc/vx/bin/vxrelocd > ${SAV_DIR}vxrelocd_spare-disabled

 echo ""

 echo "Creating configuration copies on all rootdg disks"
 echo "vxedit set nconfig=all nlog=all rootdg"
 vxedit set nconfig=all nlog=all rootdg

}


function conclude
{
cat <<EOF
[================================================================]

 The boot disk is now mirrored.

 The script has created the following backup files in ${SAV_DIR}
   Backup copies of the vtocs
    vtoc_bootdisk.sav
    vtoc_mirror.sav

   A backup of the nvramrc boot aliases
    bootaliases.sav
        
   Solaris vtocs for both the bootdisk and mirror that reflect
   the underlying hard slice numbering
    vfstab_boot
    vfstab_mirror

   A version of vxrelocd with sparing disabled
    vxrelocd_spare-disabled

   If you used the Seattle Offices VxVM install script you may
   also have a copy of the /etc/system file before encapsulation:
    system.orig

 You should also verify the following:
   ** Disable vxrelocate and enable hot sparing (INFODOC 21882)

      vxrelocd edit method: (prefered)
          (NOTE- the file vxrelocd_spare-disabled has already been
          prepared for you)

      Edit the /etc/vx/bin/vxrelocd script and replace ALL 'spare=yes'
      to 'spare=only' then kill off both vxrelocd daemons and restart
      them with:

      # /etc/vx/bin/vxrelocd root &
                
  ** Check dump device.

  ** Check your OBP variables
     boot-device, diag-device, and the nvalias information

  ** Remove extra forceloads from /etc/system

  ** Validate that you can in fact boot from both disks/aliases.


[================================================================]
EOF

}

###=================================================================###
#                       Main Program:
###=================================================================###

# Make sure we have minimum patch levels - then mirror, or quit.
check_patches

# set the value for nvramrc
check_nvramrc

# Print the intro
intro

# Get my boot and mirror devices
get_boot_mirror

# initialize and add the mirror
create_rootmirror

# mirror rootdisk volumes
mirror_vols "$MIRROR_DM"

# break the mirrors and remove rootdisk then put it back
break_plexes
rm_rootdiskPriv
rm_disk_rootdg
reinit_bootdisk

# mirror rootmirror back to rootdisk
mirror_vols "$ROOT_DM"

# Run vxmksdpart
create_hard_slices

# set OBP boot and diag device values
finishing_touches

# Print concluding message
conclude
