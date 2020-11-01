validation=E
toFile=""
until [[ "${validation}" = "EOF" ]]; do
	#statements
	echo $toFile
	read -p "Please Enter the Log Information: " userInput
	toFile="${toFile} ${userInput} \n " 
	read -p "To Finish type 'EOF'" validation
done
echo $toFile >> changes.log