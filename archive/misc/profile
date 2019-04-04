#
# Initial settings for user root
# Version 27APR01
#
OPENWINHOME=/usr/openwin; export OPENWINHOME
PATH=$PATH:/usr/local/bin:/usr/ccs/bin:/usr/openwin/bin:/usr/dt/bin:/.
MANPATH=$MANPATH:/usr/man:/usr/share/man
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/openwin/lib
EDITOR=vi
export EDITOR


PRODPATH=/opt/sun/bin
echo $PATH | grep $PRODPATH >/dev/null
if [ $? -eq 1 ]
then
    PATH=$PRODPATH:$PATH
fi


#
#	Solstice Disc Suite Vns 4.0 - 4.2
#
if [ -d /usr/opt/SUNWmd ]
then
	PATH=/usr/opt/SUNWmd/sbin:$PATH
	MANPATH=/usr/opt/SUNWmd/man:$MANPATH
fi

#
#	Solstice Disc Suite Vn 4.2.1 - path is usr/sbin which is present
#

#
#	Enterprise Volume Manager 2
#
if [ -d /opt/SUNWvxvm ]
then
	PATH=/opt/SUNWvxva/bin:$PATH
	PATH=/etc/vx/bin:$PATH
	MANPATH=/opt/SUNWvxva/man:$MANPATH
	MANPATH=/opt/SUNWvxvm/man:$MANPATH
fi

#
#	Veritas Volume Manager 3
#

VXVM3_BASE=/opt/VRTSvxvm
VMSA_BASE=/opt/VRTSvmsa
if [ -d ${VXVM3_BASE} ]
then
        MANPATH=${VXVM3_BASE}/man:${MANPATH}
        PATH=${PATH}:/etc/vx/bin
fi
if [ -d ${VMSA_BASE} ]
then
        VMSAHOME=${VMSA_BASE}
        export VMSAHOME
        MANPATH=${VMSA_BASE}/man:${MANPATH}
        PATH=${PATH}:${VMSA_BASE}/bin
fi

#
#	Sun VTS
#

if [ -d /opt/SUNWvts/bin ]
then
	PATH=/opt/SUNWvts/bin:$PATH
fi

if [ -d /opt/SUNWpcnfs/bin ]
then
	PATH=/opt/SUNWpcnfs/bin:$PATH
fi

if [ -d /opt/SUNWss/bin ]
then
	PATH=/opt/SUNWss/bin:$PATH
fi

#
#	RAID Manager for A1000, A3x00
#
if [ -d /usr/sbin/osa ]
then
	PATH=/usr/sbin/osa:$PATH
fi

#
#	Networker
#
if [ -d /usr/sbin/nsr ]
then
	PATH=/usr/bin/nsr:$PATH
	PATH=/usr/sbin/nsr:$PATH
fi


#
#	Sun Cluster 2.2 Software
#
if [ -d /opt/SUNWcluster/bin ]
then
    PATH=/opt/SUNWcluster/bin:$PATH
    MANPATH=/opt/SUNWcluster/man:$MANPATH
fi

if [ -d /opt/SUNWpnm/bin ]
then
    PATH=/opt/SUNWpnm/bin:$PATH
    MANPATH=/opt/SUNWpnm/man:$MANPATH
fi


#
#	Sun Cluster 3.0 Software
#
if [ -d /usr/cluster/bin ]
then
    PATH=/usr/cluster/bin:$PATH
    MANPATH=/usr/cluster/man:$MANPATH
fi


#
#	STORtools 3.x to troubleshoot A5000
#
if [ -d /opt/STORtools/bin ]
then
    PATH=/opt/STORtools/bin:$PATH
    MANPATH=/opt/STORtools/man:$MANPATH
fi


#
#	STORtools 4.x to troubleshoot FC_AL Storage
#
if [ -d /opt/SUNWvtsst/bin ]
then
    MANPATH=/opt/SUNWvtsst/man:$MANPATH
    KERNEL=`isainfo -b`
    if [ $KERNEL = 32 ]
    then
        PATH=/opt/SUNWvtsst/bin:$PATH
    elif [ $KERNEL = 64 ]
    then
        PATH=/opt/SUNWvtsst/bin/sparcv9:$PATH
    fi
fi


#
#	Component Manager
#
if [ -d /opt/SUNWesm/bin ]
then
    PATH=/opt/SUNWesm/bin:$PATH
    MANPATH=/opt/SUNWesm/man:$MANPATH
fi


#
#	Automated Crash Analysis tool
#
if [ -d /opt/CTEact/bin ]
then
    PATH=/opt/CTEact/bin:$PATH
    MANPATH=/opt/CTEact/man:$MANPATH
fi


#
#	PROCTOOL
#
if [ -d /opt/proctool ]
then
    PATH=/opt/proctool/bin:$PATH
fi

export PATH MANPATH LD_LIBRARY_PATH

#
# Requested by many colleagues
#
stty erase 

#
# Set shell prompts
#
PS1="root@`uname -n`# "
PS2="root@`uname -n`> "
export PS1 PS2

# Load Some Aliases
. /.alias


#
#	Uncomment next section if on on cluster or E10k domain
#
#LOGINFROM=`who am i | cut -f2 -d"(" | cut -f1 -d")"`
#DISPLAY=${LOGINFROM}:0.0
#export LOGINFROM DISPLAY
#

TERM=vt100;export TERM
resize

#echo ""
#echo "DISPLAY=$DISPLAY"
#echo ""
