#/bin/sh

OLDNAME='uname -n'
echo "changing hostname from $OLDNAME to $1"
for FILE in /etc/hosts		\
	    /etc/nodename	\
	    /etc/hostname.*l	\
	    /etc/net/tic*/hosts ;

do
	cp $FILE $FILE.bak;
	echo "created $FILE.bak"
	sed 's/$OLDNAME/$1/g' $FILE.bak > $FILE;
done

echo "rebooting"
init 6

