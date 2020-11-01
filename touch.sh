validation=N

until [[ "${validation}" = "Y" ]]; do
	#statements
	read -p "Please Enter the Name of the File: " fileName
	read -p "Is $fileName Correct? (Y/N)" validation
done

touch $fileName
