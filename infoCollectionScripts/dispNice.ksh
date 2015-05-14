#!/bin/ksh

cd `dirname $0`

# generate html table:

(
echo "<html>"
echo "<head>"
echo "<script type=\"text/javascript\" src=\"/jquery-1.11.1.min.js\"></script>"
echo "<script type=\"text/javascript\" src=\"/jquery.tablesorter.js\"></script>"
echo "<script type=\"text/javascript\">"
echo "\$(document).ready(function()"
echo "    {"
echo "        \$(\"#vmList\").tablesorter();"
echo "    }"
echo ");"
echo "</script>"
echo "<link rel=\"stylesheet\" type=\"text/css\" href=\"./blue.css\" />"
echo "</head>"
echo "<body>"
echo "<table id=\"vmList\" class=\"tablesorter\" >"
echo "<thead>"
echo "<tr><th>System Name</th><th>Physical Host</th><th>IP Address</th><th>State</th><th>VCPUs</th><th>RAM(max)</th><th>RAM(curr)</th><th>Contact</th><th>Type</th><th>OS</th><th>Usage</th><th>Project</th><th>Env ID</th><th>Notes</th></tr>"
echo "</thead>"
echo "<tbody>"
for X in `cat $1.txt|sed s/\	/\ /g|sed s/\ /u_s_c_o_r_e/g`;do
    Y=`echo ${X}|sed s%u_s_c_o_r_e%\ %g`
    type=`echo $Y|awk -F: '{print $9}'`
    project=`echo $Y|awk -F: '{print $12}'`
    if [[ "${project}" == "mexico" ]];then
        class="mexico"
    elif [[ "${project}" == "oman" ]];then
	class="oman"
    elif [[ "${project}" == "infrastructure" ]];then
	class="inf"
    elif [[ "${project}" == "qatar" ]];then
	class="qatar"
    elif [[ "${project}" == "saudi" ]];then
	class="saudi"
    elif [[ "${project}" == "argentina" ]];then
	class="argentina"
    else
        class="unset"
    fi
    if [[ "${type}" == "Physical" ]];then
        Y=`echo ${Y}|sed s%:%"</b></td><td class=\"${class} physical\"><b>"%g`
        Y=`echo "<tr><td class=\"${class} physical\"><b>${Y}</b></td></tr>"`
    else
        Y=`echo ${Y}|sed s%:%"</td><td class=\"${class}\">"%g`
        Y=`echo "<tr><td class=\"${class}\">${Y}</td></tr>"`
    fi
	

    echo $Y
done
echo "</tbody>"
echo "</table>"
echo "</body></html>"
) > ${1}.html.$$
mv ${1}.html.$$ ${1}.html




pprint() 
{
	print $*|sed s/u_s_c_o_r_e/\ /g
}


(

echo "var systems = {"
echo "	\"servers\":	["

for X in `cat $1.txt|sed s/\	/\ /g|sed s/\ /u_s_c_o_r_e/g`;do
	hostName=`echo $X|awk -F: '{print $1}'`
	physName=`echo $X|awk -F: '{print $2}'`
	ipAddr=`echo $X|awk -F: '{print $3}'`
	state=`echo $X|awk -F: '{print $4}'`
	cpus=`echo $X|awk -F: '{print $5}'`
	maxMem=`echo $X|awk -F: '{print $6}'`
	usedMem=`echo $X|awk -F: '{print $7}'`
	owner=`echo $X|awk -F: '{print $8}'`
	type=`echo $X|awk -F: '{print $9}'`
	os=`echo $X|awk -F: '{print $10}'`
	usage=`echo $X|awk -F: '{print $11}'`
	project=`echo $X|awk -F: '{print $12}'`
	envId=`echo $X|awk -F: '{print $13}'`
	notes=`echo $X|awk -F: '{print $14}'`
	if [[ "${hostName}" == "${physName}" ]];then
		pprint "{"
		pprint "\"name\": \"$physName\","
		pprint "\"ipAddr\": \"$ipAddr\","
		pprint "\"state\": \"$state\","
		pprint "\"cpus\": \"$cpus\","
		pprint "\"maxMem\": \"$maxMem\","
		pprint "\"usedMem\": \"$usedMem\","
		pprint "\"owner\": \"$owner\","
		pprint "\"type\": \"$type\","
		pprint "\"os\": \"$os\","
		pprint "\"usage\": \"$usage\","
		pprint "\"envId\": \"$envId\","
		pprint "\"project\": \"$project\","
		pprint "\"notes\": \"$notes\","
		pprint "\"vms\": ["
		for Y in `awk -F: -v p=$physName '$2 == p && $1 != p {print $0}' $1.txt|sed s/\	/\ /g|sed s/\ /u_s_c_o_r_e/g`;do
			vhostName=`echo $Y|awk -F: '{print $1}'|sed s///g`
			vipAddr=`echo $Y|awk -F: '{print $3}'|sed s///g`
			vstate=`echo $Y|awk -F: '{print $4}'|sed s///g`
			vcpus=`echo $Y|awk -F: '{print $5}'|sed s///g`
			vmaxMem=`echo $Y|awk -F: '{print $6}'|sed s///g`
			vusedMem=`echo $Y|awk -F: '{print $7}'|sed s///g`
			vowner=`echo $Y|awk -F: '{print $8}'|sed s///g`
			vtype=`echo $Y|awk -F: '{print $9}'|sed s///g`
			vos=`echo $Y|awk -F: '{print $10}'|sed s///g`
			vusage=`echo $Y|awk -F: '{print $11}'|sed s///g`
			vproject=`echo $Y|awk -F: '{print $12}'|sed s///g`
			venvId=`echo $Y|awk -F: '{print $13}'|sed s///g`
			vnotes=`echo $Y|awk -F: '{print $14}'|sed s///g`
			pprint "{"
			pprint "\"name\": \"$vhostName\","
			pprint "\"ipAddr\": \"$vipAddr\","
			pprint "\"state\": \"$vstate\","
			pprint "\"cpus\": \"$vcpus\","
			pprint "\"maxMem\": \"$vmaxMem\","
			pprint "\"usedMem\": \"$vusedMem\","
			pprint "\"owner\": \"$vowner\","
			pprint "\"type\": \"$vtype\","
			pprint "\"os\": \"$vos\","
			pprint "\"usage\": \"$vusage\","
			pprint "\"envId\": \"$venvId\","
			pprint "\"project\": \"$vproject\","
			pprint "\"notes\": \"$vnotes\","
			pprint "},"
		done
			pprint "],"
		pprint "},"
	fi
		
done
print "]"
print "}"


) > $1.js.$$
mv ${1}.js.$$ ${1}.js

exit 0

