validation=N

until [[ "${validation}" = "Y" ]]; do
	#statements
	read -p "Please Enter the Name of the File: " fileName
	read -p "Is $fileName Correct? (Y/N)" validation
done

touch $fileName
read -p "Would you like to add comment to the log file?(Y/N)" addCom
log $fileName Directory $addCom
