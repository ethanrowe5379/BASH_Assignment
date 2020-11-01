validation=N


until [[ "${validation}" = "Y" ]]; do
	#statements
	read -p "Please Enter the Name of the New Directory: " dirName
	read -p "Is $dirName Correct? (Y/N)" validation
done

mkdir $dirName



