
cat << END > Options2
	A) View file
	B) edit file
	C) delete file
	D) Exit menu
END
cat << END > Options
	A) Access a repository
	B) Make a repository
	C) Create a file in current
	D) Check out a file
	E) Make changes to a file
	F) Exit menu
END
touch(){
	validation=N
	until [[ "${validation}" = "Y" ]]; do
		#statements
		read -p "Please Enter the Name of the File: " fileName
		read -p "Is $fileName Correct? (Y/N)" validation
	done
	touch $fileName
	read -p "Would you like to add a comment to the log file?(Y/N)" addCom
	loginfo $dirName "New File" $addCom
}
mkdir(){
	validation=N
	until [[ "${validation}" = "Y" ]]; do
		#statements
		read -p "Please Enter the Name of the New Directory: " dirName
		read -p "Is $dirName Correct? (Y/N)" validation
	done
	mkdir $dirName
	read -p "Would you like to add a comment to the log file?(Y/N)" addCom
	loginfo $dirName "New Directory" $addCom
}
loginfo(){
	if [ "${3}" = "Y" ]; then
		echo $(date +"[%d-%m-%Y][%H:%M:%S]") " $2 under the name $1" | tee -a changes.log
		read -p "Please add a small additional comment to the log file:" userCom
		echo $(date +"[%d-%m-%Y][%H:%M:%S]") "$userCom" | tee -a changes.log
	else
		echo $(date +"[%d-%m-%Y][%H:%M:%S]") " $2 under the name $1" | tee -a changes.log
	fi
}

accessRepo(){
	validation=N
	echo "Your current working directory is: $PWD"
	echo "the repositories/files in this directory are: "
	ls -1
	repo=""
	until [[ "${validation}" = "Y" ]]; do
		read -p "type the name of the repository you would like to move to (leave empty to return to home directory) : " repo
		if [[ $repo = "" ]];then
			cd
		else
			cd "$repo"
		fi

		if [ $? = 0 ];then
			validation=Y
		else
			read -p "an error occured do you want to exit(Y/N):" validation
		fi
	done
	echo $PWD
	read -p "Would you like to add a comment to the log file?(Y/N)" addCom
	loginfo $repo "Accesing Repo" $addCom
}
checkOutFile(){
	validation="N"
	echo "Your current working directory is: $PWD"
	echo "the repositories/files in this directory are: "
	ls -1
	file=""
	until [[ "${validation}" = "Y" ]]; do
		read -p "type the name of the file you would like to check out: " file
		if [[ $file = "" ]];then
			read -p "no input entererd do you want to exit the menu?(Y/N):" validation
			continue
		fi

		if [[ -f $file  ]];then
			if [[ -w -x $file ]];then
				checkOutFile="N"
				read -p "You currently have access to this file do you want to check it out?(Y/N):" checkOutFile
				if [[ checkOutFile = "Y" ]]; then
					chmod 744 $file
					echo "You have checked out this file"
					validation="Y"
				else
					checkInFile="N"
					read -p "do you want to check in this file?(Y/N);" checkInFile
					if [[ checkInFile = "Y" ]];then
						chmod 774 $file
						echo "This file is checked in"
					else
						echo "Nothing has happened to the file"
			else
				echo "This file is currently checked out to someone else"
		else
			read -p "The name  of the file you entered isnt in this directory or is mispelt enter Y to exit N to try again(Y/N) :" validation
		fi
	done
	read -p "Would you like to add a comment to the log file?(Y/N)" addCom
	loginfo $file "Checked out File" $addCom
}

alterfile(){
	validation="N"
	echo "Your current working directory is: $PWD"
	echo "the repositories/files in this directory are: "
	ls -1
	file=""
	until [[ "${validation}" = "Y" ]]; do
		read -p "type the name of the file you would like to check out: " file
		if [[ $file = "" ]];then
			read -p "no input entererd do you want to exit the menu?(Y/N):" validation
			continue
		fi

		if [[ -f $file  ]];then
	else
			read -p "The name  of the file you entered isnt in this directory or is mispelt enter 'Y' to exit or 'N' to try again(Y/N) :" validation
		fi
	done
	exit="N"
	until [[ "${exit}" = "Y" ]];do
		cat Options2
		read -p "enter the option which you want to use here:"
		case $option in
			A)
				if[ -r $file ]];then
					cat $file
				else
					echo "you do not have permissions to read"
				fi;;
			B)
				if[ -w $file ]];then
					nano $file
				else
					echo "you do not have permissions to read"
				fi;;
				
			C)
				if[ -O $file ]];then
					rm $file
				else
					echo "you do not have permissions to read"
				fi;;
				
			D) 	
				exit="Y";;
			*)
				echo "invalid Input try again";;		
		esac
	done
	read -p "Would you like to add a comment to the log file?(Y/N)" addCom
	loginfo $file "Altered File" $addCom
}
Menu(){
	exit="N"

	until [[ exit = "Y" ]];do
		cat option
		read -p "enter the option you want to use" option
		case $option in
			A)
				accessRepo;;
			B)
				mkdir;;
			C)
				touch;;
			D)
				checkOutFile;;
			E)
				;;
			F)
				exit="Y";;
			*)
				echo "invalid Input try again";;
		esac


}
