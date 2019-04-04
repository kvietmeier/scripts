#!/bin/ksh
###=================================================================###
#      Variables 
###=================================================================###


###=================================================================###
#      Functions 
###=================================================================###

function usage
{
  USAGE="Usage: $0 [-m|-c|-r c#t#d# ]\n"
  print " "
  print $USAGE
  print "Use no parameters for interactive mode"
  print " "
  print "Choose one of the following tasks: "
  print "  [ -m c#t#d# ]   Use Best Practices to mirror rootdisk to c#t#d#"
  print "  [ -c c#t#d# ]   Create a Solaris bootable clone on c#t#d#"
  print "  [ -r c#t#d# ]   Replace c#t#d# using Best Practices methodology"
  print " "
}
  

function check_patches
{

  echo "check patches" 
  echo ""

}


function check_nvramrc
{

  echo "check nvramrc"
  echo ""

}


function intro
{

  echo "intro"
  echo ""

}


function get_boot_mirror
{

  echo "get boot and mirror"
  echo ""

}


function initialize_mirror
{

  echo "Initialize Mirror"
  echo ""

}


function mirror_vols
{

  echo "Mirror Volumes"
  echo ""

}

function break_plexes
{

  echo "dissasociate plexes"
  echo ""

}

function rm_rootdiskPriv
{

  echo "rm_rootdiskPriv"
  echo ""

}



function rm_disk_rootdg
{

  echo "rm_disk_rootdg"
  echo ""

}



function reinit_bootdisk
{

  echo "reinit_bootdisk"
  echo ""

}


function mirror_vols
{

  echo "mirror_vols"
  echo ""

}


function create_hard_slices
{

  echo "create_hard_slices"
  echo ""

}

function finishing_touches
{

  echo "finishing_touches"
  echo ""

}

function conclude
{

  echo "conclude"
  echo ""

}

wait_continue()
{
        echo "\nHit RETURN to continue.\c"
        read ANS
}

# Call this function with a question string and a default answer:
#  ex: yes_or_no "Is this correct?" y || { echo "bad answer" }
yes_or_no()
{
  while :
    do
      echo "\n$1? [$2] \c"
      ANS=
      read ANS
      case $ANS in
             "") ANS=$2; break;;
        [Nn]|no) ANS=no; break;;
       [Yy]|yes) ANS=yes; break;;
              *) echo "\nPlease answer \"yes\" or \"no\"."
                 continue;;
      esac
   done
 [ $ANS = yes ]
}


function interactive_mirror
{
  # Make sure we have minimum patch levels - then mirror, or quit.
  check_patches

  # set the value for nvramrc
  check_nvramrc

  # Print the intro
  intro

  # Get my boot and mirror devices
  get_boot_mirror

  # initialize and add the mirror
  initialize_mirror

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

}


function silent_mirror
{
  # Make sure we have minimum patch levels - then mirror, or quit.
  check_patches

  # set the value for nvramrc
  check_nvramrc

  # Print the intro
  #intro

  # Get my boot and mirror devices
  #get_boot_mirror

  # initialize and add the mirror
  initialize_mirror 

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
  #conclude

}



function just_mirror
{
  initialize_mirror
  mirror_vols "$MIRROR_DM"
  create_hard_slices
}


function create_clone
{
  # Create a bootable clone disk
  print "clone one"
  initialize_mirror
  mirror_vols "$MIRROR_DM"
  create_hard_slices
  break_plexes
  rm_disk_rootdg

  # Need -
  mount_partitions
  unencapsulate_disk
}


function what_mode
{
 print "Mode is: ${TASK}"
}


function what_task
{
 print "Task is: ${TASK}"
 wait_continue

 if [[ ${TASK} = "mirror" ]]
    then silent_mirror
 elif [[ ${TASK} = "clone" ]]
    then create_clone
 elif [[ ${TASK} = "replace" ]]
    then replace_disk
 elif [[ ${TASK} = "initial" ]]
    then interactive_mirror 
 fi

}

###=================================================================###
#                       Main Program:
###=================================================================###

### Parse command line options

# Check to see if we should go interactive
if (( $# == 0 ))
  then 
        MODE="interactive"
        TASK="initial"
        what_task
fi

# If there are command line parameters check to see what we should do: 
while getopts :m:c:r: option
  do
      case $option in
      \?)
          print "Invalid Switch ${OPTARG}"
          usage 
          exit 2;;
      \:)
          print "You did not enter argument for ${OPTARG}"
          usage 
          exit 2;;
      c)
          echo "clone is ${OPTARG}"
          TASK="clone"
          CLONE=${OPTARG}
          ;;
      r)
          echo "replacement is ${OPTARG}"
          TASK="replace"
          REPLACEMENT=${OPTARG}
          ;;
      m)
          echo "target is ${OPTARG}"
          TASK="mirror"
          MIRROR=${OPTARG}
          ;;
     esac
 done

((NUM_PARAMS = OPTIND - 1))
shift $NUM_PARAMS

print $1
TASK=$1
what_task
