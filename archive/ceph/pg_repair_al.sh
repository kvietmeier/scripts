#!/bin/bash

###
# pg_repair_all
#    Attempts to repair all PGs that are inconsistent.
#
#    Not all 'repair' attempts follow the expected order of 'Incons' -> 'repair' -> 'clean'
#    So, some flexible logic has to be applied.
#    Even when a PG is being repaired, the 'inconsistent' flag will be part of its state.
#    Thus, We have to check if 'inconsistent' is the last flag of its state.
#    Once 'inconsistent' is not the last flag, then something is occuring..
#    It will either enter 'repair' or eventually pop back to 'inconsistent' as the last flag
#    The final state of the PG will either be inconsistent or clean
#    Either of these signify the end of the repair attempt and will continue to the next PG
#
###

function getJsonVal () { 
	python -c 'import json,sys;obj=json.load(sys.stdin);print obj["'$1'"]';
}

count_in_state() {

# Get the current state data
# Grep for the desired state and count outputs
# Grep for the state itself and 1 line after it (its own count)
# Get just the count line
# Print just the count
# Get rid of any non-numeric values

	mycount=$(ceph -s --format json-pretty \
		| egrep "(state_name.*$1|count)" \
		| egrep -A1 "$1" \
		| grep count \
		| awk '{print $2}' \
		| sed -e 's/[^0-9]//g')
	if [ "$mycount"x == ""x ]; then
		mycount=0
	fi
	if [ $(echo $mycount | grep -c \ ) -gt 0 ]; then
		mycount=$(echo $mycount | sed -e 's/\ /+/g' | bc)
	fi
	echo $mycount
}

mydate() {
	date +'%Y-%m-%d %T'
}

myunixdate() {
	date +'%s'
}

incons_count=$(count_in_state 'inconsistent')
if [ $incons_count -gt 0 ]; then
	ceph pg dump | grep inconsistent > pg_dump_inconsistent.$(date +'%Y-%m-%d_%H-%M-%S')
	echo $(mydate) Starting repair process of $incons_count PGs.
	pgs=$(ceph pg dump 2> /dev/null | grep incons | awk '{print $1}')
	for i in $pgs; do
		isIncons=$(ceph pg $i query | getJsonVal 'state' | grep inconsistent -c)
		if [ $isIncons -gt 0 ]; then
			echo $(mydate) Issuing repair for $i
			ceph pg repair $i &> /dev/null
			waitforrepair=$(myunixdate)
			pgState=3 # Waiting for some action (repair, clean, back to incons...)
			lastState=$(ceph pg $i query | getJsonVal 'state')
			echo $(mydate) PG: $i State: $lastState
			while [ $pgState -gt 0 ]; do
				sleep 1
				curState=$(ceph pg $i query | getJsonVal 'state')
				if [ "$curState" != "$lastState" ]; then 
					echo
					echo $(mydate) PG: $i State: $curState
					lastState=$curState
				fi
				if [ $pgState -eq 3 ]; then
					if [ $(echo $curState | egrep -c '(inconsistent|peering|recovery_wait|recovery)$') -gt 0 ]; then
						pgState=3
						echo -n .
					else
						echo
						pgState=2
						waitforrepair=$(echo $(myunixdate)-${waitforrepair} | bc)
						echo $(mydate) Repairing $i now... \(after $waitforrepair seconds\)
						waitforrepair=$(myunixdate)
					fi
				else
					if [ $(echo $curState | grep -c 'repair$') -gt 0 ]; then
						echo -n .
						pgState=1
					else
						echo
						pgState=0
						waitforrepair=$(echo $(myunixdate)-${waitforrepair} | bc)
						if [ $(echo $curState | grep -c inconsistent) -gt 0 ]; then
							echo $(mydate) Repair failed after $waitforrepair seconds.
						else
							echo $(mydate) Repair success after $waitforrepair seconds.
						fi
					fi
				fi
			done
		else
			echo $(mydate) PG $i no longer inconsistent.
		fi
		sleep 1
	done
else
	echo No inconsistent PGs found
fi

