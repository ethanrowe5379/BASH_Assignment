
if [ "${3}" = "Y" ]; then
	read -p "Please add a small additional comment to the log file:" userCom
	echo $(date +"[%d-%m-%Y][%H:%M:%S]") "$userCom" | tee -a changes.log
else
	echo $(date +"[%d-%m-%Y][%H:%M:%S]") "Created New $2 under the name $1" | tee -a changes.log
fi