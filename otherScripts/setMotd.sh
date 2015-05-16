#!/bin/ksh
contDir="/var/gslsa/gslServInfo/content"
{
	echo
	echo "Hostname:	"`hostname`
	echo "Usage:   	"`[[ -f "${contDir}/usage.txt" ]] && cat "${contDir}/usage.txt"`
	echo "Contact: 	"`[[ -f "${contDir}/contact.txt" ]] && cat "${contDir}/contact.txt"`
	echo "Location:	"`[[ -f "${contDir}/location.txt" ]] && cat "${contDir}/location.txt"`
	echo
	echo "################################################################################"
	echo "#                                                                              #"
	echo "#   This is a SITA internal system.  Unauthorised use is NOT permitted.        #"
	echo "#                                                                              #"
	echo "################################################################################"
	echo
} > /tmp/t.$$
mv /tmp/t.$$ /etc/motd
exit 0
