#!/bin/ksh

vmListFile="/var/servinfo/gslServInfo/content/vmlist.txt"
vmDetailsFile="/var/servinfo/gslServInfo/content/vmDetails.txt"

physProcs=`grep ^processor /proc/cpuinfo|wc -l`
physMem=`grep ^MemTotal /proc/meminfo|awk '{print $2}'`
physMemFree=`grep ^MemFree /proc/meminfo|awk '{print $2}'`
physMemUsed=$(( $physMem - $physMemFree ))

hostName=`hostname|sed s/-db1$/db1/|sed s/-db2$/db2/`

echo "${hostName}:${hostName}:running:${physProcs}:${physMem}:${physMemUsed}" > "${vmDetailsFile}"
touch "${vmListFile}"
if [[ -f /usr/bin/virsh ]];then
	sudo -u root virsh -q list --all | awk '{print $2}' > "${vmListFile}"
	for X in `cat "${vmListFile}"`;do
		print -n "`hostname`:"
		sudo -u root virsh -q dominfo "${X}" \
			| sed s/\ /_/|egrep "^Name:|^State:|^CPU\(s\):|^Max_memory:|^Used_memory:" \
			|awk '{print $2}' \
			|tr '\n' ':' \
			|sed s/:$/\\n/
	done >> "${vmDetailsFile}"
fi
exit 0