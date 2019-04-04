#!/bin/bash
###=================================================================###
#      Variables 
###=================================================================###

USAGE="Usage: $0 [-s] [-m initial|clone] [-t target c#t#d# ]\n"

###=================================================================###
#      Functions 
###=================================================================###

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
                "")     ANS=$2; break;;
                [Nn]|no)   ANS=no; break;;
                [Yy]|yes)  ANS=yes; break;;
                *)      echo "\nPlease answer \"yes\" or \"no\"."
                        continue;;
                esac
        done
        [ $ANS = yes ]
}

function initial_install
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

function just_mirror
{
  initialize_mirror
  mirror_vols "$MIRROR_DM"
  create_hard_slices
}

function create_clone
{
  print "clone one"
}

function what_task
{
 print "what task?"
 print "Task is: ${TASK}"

  if [[ ${TASK} = "mirror" ]]
	  then initial_install
  elif [[ ${TASK} = "clone" ]]
	  then create_clone
  else 
	  print "You are either initially instaling, or creating a clone"
     print "${USAGE}"
     exit
  fi

}

###=================================================================###
#                       Main Program:
###=================================================================###

### Parse command line options

# Check to see if we should go interactive
if (( $# <= 1 ))
  then 
		initial_install
		exit
fi

# If there are command line parameters check to see what we should do: 
while getopts :st: option
  do
	  case $option in
      \?)
		  print "invalid switch ${OPTARG}"
		  print ${USAGE}
		  exit 2;;
      \:)
		  print "You did not enter argument for ${OPTARG}"
		  print ${USAGE} 
		  exit 2;;
		s)
		  echo "Work with no prompting unless error encountered"
		  MODE="silent"
		  ;;
      t)
		  echo "target is ${OPTARG}"
		  MIRROR=${OPTARG}
		  ;;
     esac

 done

((NUM_PARAMS = OPTIND - 1))
shift $NUM_PARAMS

print $1
TASK=$1
what_task
