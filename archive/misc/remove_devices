#!/usr/bin/ksh
# This script will remove all the devices for a given driver.
#
#  It should be used with caution, esp on systems booting from
#  these devices
#
#  Written by: Karl Vietmeier
#              Sun Microsystems
#  Last Modified
#       04/20/03
#
#  To do - add functions for removing JNI drivers and devices


echo "What driver are you removing?"
echo "Choose:"
echo "a.) ifp (PCI FCAL)"
echo "b.) socal (sbus FCAL)"
echo "c.) qlc (leadville)"
echo "d.) rdnexus (leadville)"
echo "Which Letter? \c"
read DRIVER
case $DRIVER in
'a')
    DRIVER=ifp
;;
'b')
    DRIVER=socal
;;
'c')
    DRIVER=qlc
;;
'd')
    DRIVER=rdnexus
esac

cp /etc/path_to_inst /etc/path_to_inst.bak

ed -s /etc/path_to_inst << EOF
g/${DRIVER}@/d
w
q
EOF

# In case we are dealing with A5x00 arrays
if [ -e /dev/es ]
   then echo "rm -rf /dev/es"
        rm -rf /dev/es
   else echo "No es devices found - skipping this step"
fi 

# Remove /dev/dsk and rdsk entries for each driver
for i in $(ls -l /dev/dsk | grep ${DRIVER}@\* | awk '{print $9}')
do
echo "rm /dev/dsk/${i}"
rm /dev/dsk/${i}
done

for i in $(ls -l /dev/rdsk | grep ${DRIVER}@\* | awk '{print $9}')
do
echo "rm /dev/rdsk/${i}"
rm /dev/rdsk/${i}
done

# Remove /devices nodes
cd /devices
find . -name \*${DRIVER}\* 
find . -name \*${DRIVER}\* -exec rm -rf {} \;
