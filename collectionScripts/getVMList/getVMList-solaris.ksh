#!/bin/ksh

contentDir="/var/servinfo/content"
[[ ! -d ${contentDir} ]] && mkdir -p ${contentDir}
vmListFile="${contentDir}/vmlist.txt"
vmDetailsFile="${contentDir}/vmDetails.txt"

physMem=`/usr/sbin/prtconf|grep "^Memory size:"|nawk '{print $3}'`
physMem=$(( $physMem * 1024 )) # in kb
physProcs=`/usr/sbin/psrinfo|wc -l|awk '{print $1}'`

physMemPagesFree=`sar -r 1 1|tail -1|nawk '{print $2}'`
physMemFree=$(( $physMemPagesFree * `pagesize` / (1024*1024*1024) ))  # in kb
physMemUsed=$(( $physMem - $physMemFree ))

numRunningZones=$(( `/usr/sbin/zoneadm list|wc -l` - 1 )) # must exclude global from count


echo "`hostname`:`hostname`:running:${physProcs}:${physMem}:${physMemUsed}" > "${vmDetailsFile}"

/usr/sbin/zoneadm list -i|egrep -v "^global$" > "${vmListFile}"

/usr/sbin/zoneadm list -iv|nawk '{print $2,$3}' > /tmp/zoneStatus  # name status
/usr/bin/prstat -Z -n1,15 -srss -c 1 1|nawk '$NF !~ /global/ {print $8,$4}'|tail -7|head -6  > /tmp/zoneMemUsage  # name memUsed

for X in `cat "${vmListFile}"`;do

        print -n "`hostname`:"

        zoneState=`nawk -v X=${X} '{if ($1 == X) print $2}' /tmp/zoneStatus`
        if [[ "${zoneState}" == "running" ]];then
                zoneMem=`nawk -v X=${X} '{if ($1 == X) print $2}' /tmp/zoneMemUsage`
                if echo "${zoneMem}" |grep G >/dev/null ;then
                        zoneMem=`echo "${zoneMem}"|sed s/G//`
                        zoneMem=$(( ${zoneMem} * 1024 ))
                elif echo "${zoneMem}" | grep M >/dev/null; then
                        zoneMem=`echo "${zoneMem}"|sed s/M//`
                elif echo "${zoneMem}" | grep K >/dev/null;then
                        zoneMem=`echo "${zoneMem}"|sed s/K//`
                        zoneMem=$(( ${zoneMem} / 1024 ))
                else
                        zoneMem=0
                fi
        else
                zoneMem=0
        fi
        zoneCpus=0
        zoneMaxMem=0
        echo "${X}:${zoneState}:${zoneCpus}:${zoneMaxMem}:${zoneMem}"
done >> "${vmDetailsFile}"

exit 0
