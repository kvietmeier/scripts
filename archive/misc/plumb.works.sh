#!/bin/ksh
###=========================================================================###
# Plumb the ethernet interface on your laptop and share
# some filesystems.
#  There two usages for this script:
#
#  1) by itself - will prompt for IP settings
#     # plumb
# 
#  2) with a preconfigured choice - will copy over prebuilt hostfiles and set a 
#     defaultgateway etc....
#     # plumb <choice>
#     
#     Put your configuration files in a "netconfigs" directory under the 
#     directory where you put the script itself
#
#
#     Karl Vietmeier -
#     SSE Strategic Account Services - Verizon Wireless
#
###=========================================================================###

# what is the laptop's hostname?
LAPTOP=$(hostname)
BINDIR=$(pwd)
CONFIGDIR=${BINDIR}/net_configs
INTERFACE=iprb0

if (( $# < 1 ))
   then OPTION="none"
   else OPTION=$1
fi

echo $OPTION

#if (( $2 == 0 ))
#   then INTERFACE=iprb0
#   else INTERFACE=$2
#fi

###========================###
###    getinet
###========================###

# Loop through menus to set the value of INET and SUBNET for
# the ifconfig command
function getinet
{
  while true
   do
    echo "Use one of these subnets:"
    echo "a.) 192.168.1"
    echo "b.) 192.168.2"
    echo "c.) 10.10.10"
    echo "d.) 10.10.1"
    echo "e.) 10.1.1"
    echo "f.) Choose my own"
    echo "? \c"
    read SUBNET

    case $SUBNET in
    [aA]) SUBNET="192.168.1" break ;;
    [bB]) SUBNET="192.168.2" break ;;
    [cC]) SUBNET="10.10.10" break ;;
    [dD]) SUBNET="10.10.1" break ;;
    [eE]) SUBNET="10.1.1" break ;;
    [fF]) 
      echo "What subnet are you using? [xxx.xxx.xxx]: \c"
      read SUBNET
      while true
       do
        if [[ $SUBNET != +([0-9])\.+([0-9])\.+([0-9]) ]]
          then echo "${SUBNET} Not a valid subnet, try again!!!"
             continue
          else break
        fi
       done
     break;;
     *) echo "Invalid Choice"
   esac
  done

  echo "Choose a subnet mask:"
  echo "a.) 255.255.255.0"
  echo "b.) 255.255.0.0"
  echo "c.) 255.0.0.0"
  echo "d.) Create a Different One"
  echo "? \c"
  read NETMASK

  case $NETMASK in
    [aA]) NETMASK="255.255.255.0" ;;
    [bB]) NETMASK="255.255.0.0" ;;
    [cC]) NETMASK="255.0.0.0" ;;
    [dD]) echo "What subnetmask are you using? [xxx.xxx.xxx.xxx]: \c"
       read NETMASK
        while true
         do
          if [[ $NETMASK != +([0-9])\.+([0-9])\.+([0-9])\.+([0-9]) ]]
            then echo "${NETMASK} Not a valid mask, try again!!!"
               continue
            else break
          fi
         done
     break;;
    *) echo "Invalid Choice"
  esac

  while true
   do
    echo "What IP Do You Want to Plumb the Laptop With? [xxx]: \c"
    read IP
    if [[ $IP != +([0-9]) ]]
       then echo "$IP Not an integer - try again!"
            continue
       else break
    fi
  done

  INET="${SUBNET}.${IP}"

 # create a hosts file based on the subnet:
 cp ${CONFIGDIR}/empty_hosts /etc/hosts
 echo "$INET\t${LAPTOP}\t${LAPTOP}.laptop\tloghost" >> /etc/hosts
 for i in 1 2 3 4 5 6 7 8 9 10
  do
   echo "${SUBNET}.${i}\thost${i}" >> /etc/hosts
  done

}


###========================###
###   plumbit
###========================###

function plumbit
{
 # get rid of the stupid modem because it gets in the way! 
 #ifconfig ipdptp0 unplumb

 # Plumb interface ${INTERFACE}
 ifconfig ${INTERFACE} plumb  
 echo "ifconfig ${INTERFACE} plumb"

 if [[ $OPTION = "dhcp" ]]
   then ifconfig ${INTERFACE} dhcp start
        echo "ifconfig ${INTERFACE} dhcp start"
   else ifconfig ${INTERFACE} inet $INET netmask $NETMASK broadcast + up
        echo "ifconfig ${INTERFACE} inet $INET netmask $NETMASK broadcast + up"
 fi 

 # Check for shares in /etc/dfs/dfstab
 if [ $(grep ^share /etc/dfs/dfstab | head -1 | awk '{print $1}') ]
    then /etc/init.d/nfs.server start
    else echo "Nothing in /etc/dfs/dfshares, not starting NFS server"
 fi
}


###========================###
###   yes_or_no
###========================###
# stolen from VxVM ......
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


###===================================================================###
###                      Main Program				      ###
###===================================================================###

# Start doing all the work -
# Check for command line option and configure for preset locations
# Check to see if we should go interactive

if [[ $OPTION = "seattle" ]]
   then 
     # Configure networking for the Seattle lab
     INET="10.20.1.40"
     NETMASK="255.255.255.0"
     cp ${CONFIGDIR}/seattle_hosts /etc/hosts
     cp ${CONFIGDIR}/seattle_resolv /etc/resolv.conf
     plumbit
     route add net default 10.20.1.248

elif [[ $OPTION = "irv" ]]
   then 
     # Configure networking for the Irvine lab
     INET="192.168.221.100"
     NETMASK="255.255.255.0"
     cp ${CONFIGDIR}/irvlab_hosts /etc/hosts
     cp ${CONFIGDIR}/irvlab_resolv /etc/resolv.conf
     plumbit
     route add net default 192.168.221.1

elif [[ $OPTION = "sealab" ]]
   then 
     # Configure networking for the Irvine SEA lab
     INET="192.168.221.100"
     NETMASK="255.255.255.0"
     cp ${CONFIGDIR}/sealab_hosts /etc/hosts
     cp ${CONFIGDIR}/sealab_resolv /etc/resolv.conf
     plumbit

elif [[ $OPTION = "home" ]]
   then
     # Configure networking for home
     INET="192.168.0.100"
     NETMASK="255.255.255.0"
     cp ${CONFIGDIR}/home_hosts /etc/hosts
     cp ${CONFIGDIR}/home_resolv /etc/resolv.conf
     plumbit
     route add net default 192.168.0.1

elif [[ $OPTION = "default" ]]
   then 
     # Configure a default config
     INET="10.1.1.100"
     NETMASK="255.255.255.0"
     cp ${CONFIGDIR}/default_hosts /etc/hosts
     plumbit

elif [[ $OPTION = "dhcp" ]]
   then 
     # Configure a default DHCP config
     # Do nothing - get it from the DHCP server
     echo "Configuring for DHCP"
     plumbit

elif [[ $OPTION = "swan" ]]
   then 
     # Configure a default config
     # Do nothing - get it from the DHCP server
     echo "Configuring for SWAN DHCP"
     cp ${CONFIGDIR}/swan_resolv /etc/resolv.conf
     echo "cp ${CONFIGDIR}/swan_resolv /etc/resolv.conf"
     OPTION=dhcp
     plumbit

elif [[ $OPTION = "none" ]]
   then 
     # Go interactive for a specific location
     getinet
     plumbit
fi

