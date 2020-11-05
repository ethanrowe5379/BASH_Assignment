read -p "Please Name your Archive File: " archiveName
tar -zcvf $archiveName.tar.gz $(pwd)
