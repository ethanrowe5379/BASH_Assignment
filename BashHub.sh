#!/bin/bash
#
# This system allows to create, remove repositories of files. Also it allows to handle files of a repository.
# User can store files, add comments to modifications, create a log file with updates.
#
cat << END > Options
	1)Create_Repository 2)Select_Repository 3)Manage_Repository
	4)Display_Repository 5)Remove_Repository 
	6)Create a new repository copying files from folder
END

syspath="./"
current=""
currentName=""
clear
# This option creates a new empty repository
createEmptyRepository()
{
	echo "This option allow you to create a new empty repository"
	echo "Please insert the name of the new repository:"
	echo "Press enter to cancel"
    lloop=1 # this variable controls the loop below
    while [ $lloop -eq 1 ]
    do
	    echo -n "Insert the name of the repository: "
	    read repository
        if [ -z "$repository" ]; then
            #empty lets suppose user wants to cancel
            echo "Cancelled"
            return
        fi 
		lloop=0 # finish the loop

    done
    current=".vcs."$repository
    if [ -d "$current" ]; then
        echo "Repository already exist. Leaving."
        echo
        continue
    fi

	mkdir $current
    echo "Done."
}
addFile()
{
	validation=N
	until [[ "${validation}" = "Y" ]]; do
		#statements
		read -p "Please Enter the Name of the File: " fileName
		read -p "Is $fileName Correct? (Y/N)" validation
	done
	touch $fileName
	read -p "Would you like to add a comment to the log file?(Y/N)" addCom
	log $fileName Directory $addCom
}
# This routine creates a new repository copying files from an existing folder
createRepository()
{
    echo "This option allow you to create a new repository copying files from an existing folder"
    echo "You must specify the folder where the files will be copied, please "
    echo "don't use '.' or '..'"
	echo "Please insert the folder where is stored your repository files:"
	echo "Press enter to cancel"
    lloop=1 # this variable control the loop below
    while [ $lloop -eq 1 ]
    do
	    echo -n "Insert full path: "
	    read fullpath
        if [ -z "$fullpath" ]; then
            #empty lets suppose user want to cancel
            echo "Cancelled"
            return
        fi 
        # check is a valid folder
        if [ "$fullpath" == *".//"* ]; then
            echo "Please don't use '.' or '..' Use absolute paths"
            echo "Try again"
            continue
        fi
        # Check it's a valid directory
        if [ -d "$fullpath" ]; then
    
            # this is a valid folder
	        lloop=0 # finish the loop
         
        else
            echo "Invalid folder. Try again"
            continue
        fi

    done
    # remove trailing slash if any 
    fullpath=`echo "$fullpath" | sed 's/\/$//'`
    #change any '/' to '_'
    current=`echo "$fullpath" | sed -r 's/\//_/g'`
    current=".vcs."$current
    if [ -d "$current" ]; then
        echo "Repository already exist. Leaving."
        echo
        continue
    fi

	mkdir $current
	cp $fullpath/* $current
    echo "Done."

}
log(){
	if [ "${3}" = "Y" ]; then
		read -p "Please add a small additional comment to the log file:" userCom
		echo $(date +"[%d-%m-%Y][%H:%M:%S]") "$userCom" | tee -a changes.log
	else
		echo $(date +"[%d-%m-%Y][%H:%M:%S]") "Created New $2 under the name $1" | tee -a changes.log
	fi
}

# This repository selects a repository from a list
selectRepository()
{
    echo "Select a repository from the following list:"
    # display only the folder's name and remove the prefix
    # send any error to /dev/null
    n=`ls -d .vcs.* 2> /dev/null | wc -l`   # count how many folder we found
    if [ "$n" -eq 0 ]; then
        echo "No repositories registered at this momment"
        echo "You must create one first"
        return
    fi
    list=( `ls -d .vcs.* | sed -e 's/.vcs.//'` )
    idx=0
    while [ $idx -lt $n ]
    do
        let "idx2 = idx + 1"

        reponame=${list[idx]}
        reponame=`echo "$reponame" | sed -r 's/_/\//g'`
        echo $idx2") "$reponame
        let "idx = idx + 1"
    done
    lloop=1
    while [ $lloop -eq 1 ]
    do
	    echo -n "Insert your option: "
	    read number
        if [ -z "$number" ]; then
            #empty lets suppose user wants to cancel
            echo "Cancelled"
            return
        fi 
        let "idx = number + 0"  # integer conversion
        # check is a valid option
        if [ $idx -lt 1 -o $idx -gt $n ]; then
            echo "Invalid option. Try again"
            continue
        else
            # this is a valid folder
	        lloop=0 # finish the loop
        fi

    done
    let "idx = idx - 1"  # back to index
    current=".vcs."${list[idx]}    # current Repository path 
    currentName=${list[idx]}        # current Repository name
    # convert back to the full path and store it in currentName
    currentName=`echo "$currentName" | sed -r 's/_/\//g'`
	echo $currentName
}

# Submenu that provides general functions add file, edit file, etc
manageRepository()
{
    checkRepository
    
    echo "Current Repository: "$currentName
    echo "Date   File name"
    echo "****************"
    ls -l $current | awk '{print $6, $7, $9}'
    echo
    lloop=1 # this variable controls the loop below



    while [ $lloop -eq 1 ]
    do
        echo "Please choose one option below"
        echo
	    echo "1) Add File to the repository"
        echo "2) Edit File"
        echo "3) Restore File"
        echo "4) Archive current repository (using tar)"
        echo "5) check in/out a file"
        echo "6) to copy a file"
	    echo "B) Return to previous menu"
	    echo -n "Enter Choice: "
	    read opt	# read the choice
	    case "$opt" in
	    "b" ) lloop=0 # finish the loop
	    ;;
	    "B" ) lloop=0
	    ;;
	    "1") addFile
	    ;;
	    "2") editFile
	    ;;
	    "3") restoreFile
	    ;;
	    "4") archiveRepository 
		;;
		"5")
			checkFile
		;;
		"6")
			copyFile
	    ;;
	    * ) echo "Invalid option try again"
        ;;
	    esac
    done
}
# this function checks the current repository is selected
checkRepository()
{
    if [ -z "$current" ]; then
        # repository not selected
        echo "Repository not selected"
	    selectRepository 
        # warn we're editing a file
        echo "Manage Repository"
    fi
}
# This routine displays the content of the repository,
# ie the files stored in the repository
displayRepository()
{
    checkRepository
    echo "Current Repository: "$currentName
    echo "Date   File name"
    echo "****************"
    ls -l $current | awk '{print $6, $7, $9}'
    echo
}
# This routine stores the current repository in a tar file

archiveRepository()
{
    # validate there are a repository selected
    checkRepository
    echo "This option prepare a tar file of the current selected repository"
    # prepare the archive name
    day=$(date -d "$D" '+%d')
    month=$(date -d "$D" '+%m')
    year=$(date -d "$D" '+%Y')
    archiveName=`echo $current | sed -e 's/.vcs.//'`
    archiveName=$archiveName"-"$year"-"$month"-"$day".tar"

    echo "Repository stored in "$archiveName
    tar cvf $archiveName $currentName
 
}
# this function allows to remove a repository
removeRepository()
{
	echo "Remove a repotitory"
    echo "Press enter to cancel"
    lloop=1 # this variable controls the loop below
    while [ $lloop -eq 1 ]
    do
	    echo -n "Insert the repository name: "
	    read name
        path=".vcs."$name
        if [ -z "$path" ]; then
            #empty lets suppose user wants to cancel
            echo "Cancelled"
            return
        fi 
        if [ -d "$path" ]; then
            # this is a valid repository
	        lloop=0 # finish the loop
        else
            echo "Invalid folder. Try again"
            continue
        fi

    done
    current=$path
    
	# Everything looks ok  
	# 
    echo  "Enter yes or no"
	echo -n "Are you sure you want to remove the repository? "
	read answer
	case "$answer" in
	"y" ) ;;
	"Y" ) ;;
	"yes" ) ;;
	"YES" );;
	* ) return ;;
	esac
	# remove it
	rm -fr $path
    echo "Done"
    current=""
}
checkFile(){
	validation="N"
	echo "Your current working directory is: $PWD"
	echo "the repositories/files in this directory are: "
	ls -1
	file=""
	until [[ "${validation}" = "Y" ]]; do
		read -p "type the name of the file you would like to check In/Out: " file

		if [[ -f $file  ]];then

			validation="Y"
			if [[ -w $file ]];then
				if [[ -r $file ]];then

						checkOutFile="O"
						exit="N"

						until [[ "$exit" = "Y" ]];do
							read -p "You currently have access to this file do you want to check it in or out?(I/O):" checkOutFile
							if [[ "$checkOutFile" = "O" ]]; then
								chmod 744 $file
								echo "You have checked out this file"
								exit="Y"
							elif [[ "$checkOutFile" = "I" ]];then
								read -p "Would you like to add comment to the log file?(Y/N)" addCom
								log $file Directory $addCom
								chmod 774 $file
								echo "This file is checked in"
								exit="Y"
							else
								read -p "incorrect input enter 'N' to try again or 'Y' to exit" exit

							fi
						done
				else
					echo "This file is writeable but not readable, it might be checked out to someone else"
				fi
			else
				echo "This file is currently checked out to someone else"
			fi
		else
			read -p "The name  of the file you entered isnt in this directory or is mispelt enter Y to exit N to try again(Y/N) :" validation
			if [[ validation = "Y" ]];then
				return 0
			fi
		fi
	done
}
# This routine allow to add a file to the repository
copyFile()
{
    echo "This option allow you to add a file to the repository by copying the file from an existing path"
    echo "You must specify the folder where the files will be copied, please "
    echo "don't use '.' or '..'"
	echo "Please insert the path of the file:"
	echo "Press enter to cancel"
    lloop=1 # this variable controls the loop below
    while [ $lloop -eq 1 ]
    do
	    echo -n "Insert full path: "
	    read fullpath
        if [ -z "$fullpath" ]; then
            #empty lets suppose user wants to cancel
            echo "Cancelled"
            return
        fi 
        # check it's a valid folder
        if [ "$fullpath" == *".//"* ]; then
            echo "Please don't use '.' or '..' Use absolute paths"
            echo "Try again"
            continue
        fi
        # Check it's a valid file
        if [ -f "$fullpath" ]; then
    
            # this is a valid folder
	        lloop=0 # finish the loop
         
        else
            echo "Invalid file. Try again"
            continue
        fi

    done
    
	cp $fullpath $current
    echo "Done."

}
# Restore a file from a previous edit session
restoreFile()
{
    echo "This option restore a file backup"
    lloop=1 # this variable controls the loop below
    while [ $lloop -eq 1 ]
    do
        echo -n "Insert the file name: "
	    read file	# read the choice
        if [ -z "$file" ]; then
            #empty lets suppose user wants to cancel
            echo "Cancelled"
            return
        fi 
        # we check this file exist in the repository
        thispath=$current"/"$file
        if [ ! -f "$thispath" ]; then
            echo "Invalid file. Try again"
            continue
        fi

        # Now we check if there is a backup of this file
        thispath=$current"/"$file".bak"
        if [ ! -f "$thispath" ]; then
            echo "Unfortunately there are no backup of such file"
            pause
            return
        fi
        # finally restore the file
        cp -f $thispath $currentName"/"$file 
        
        lloop=0
    done 
}
# Allow to edit a file
editFile()
{
    lloop=1 # this variable controls the loop below
    while [ $lloop -eq 1 ]
    do
        echo -n "Insert the file name: "
	    read file	# read the choice
        if [ -z "$file" ]; then
            #empty lets suppose user wants to cancel
            echo "Cancelled"
            return
        fi 
        # we check file in the user's folder
        thispath=".vcs."$currentName"/"$file
        if [ ! -f "$thispath" ]; then
            echo "Invalid file. Try again"
            continue
        fi
        # generate a backup of each file before edit
        cp -f $thispath $current"/"$file".bak"
        if [[ -w "$thispath" ]];then
        	vi $thispath
        else
        	echo "this file is checked out to another user"
        	return
        fi
        lloop=0
    done 
}

# Standard routine to display a "press a key" to continue 
pause()
{
	echo -n "Press RETURN to continue... "
	read key
}
Menu(){
	exit="N"

	until [[ "exit" = "Y" ]];do
		cat Options
		read -p "enter the option would uou like to use enter Q to quit:" option
		
		case $option in
			1)
				createEmptyRepository;;
			2)
				selectRepository;;
			3)
				manageRepository;;
			4)
				displayRepository;;
			5)
				removeRepository;;
			6)
				Create_Repository;;
			Q)
				exit="Y";;
			q)
				exit="Y";;
			*)
				echo "invalid Input try again";;
		esac
	done
}
Menu