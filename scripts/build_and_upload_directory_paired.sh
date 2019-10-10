#!/bin/bash

#################################################
# This script will find all the fastq.gz files
# within a directory and create a valid
# SampleList.csv file in the directory, and then
# prompt the user for their IRIDA info before
# uploading to IRIDA
#
# This version only supports paired end reads.
#################################################


# uploader options to be modified as needed
CLIENTID=uploader
CLIENTPW=2N8K6uik0AHo1g6QX0w7d63GAG7f37Pbn33x4hFedJ
BASEURL=http://localhost:8080/api/
# This script will only work the the directory parser
PARSER=directory

# filename extention to use when looking for files
extention=.fastq.gz
# last characters in filename to determine forward and reverse reads
forward_ending=_R1
reverse_ending=_R2

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

UPLOADERCMD=$ROOT_DIR/../irida-uploader.sh

if [ ! -d "$1" ]; then
  # Control will enter here if $1 doesn't exist.
  echo error: Directory \"$1\" is not a valid directory.
  exit 1
fi

echo Please enter the Project ID to upload samples to.
read project

# regex to make sure project id is an int
if ! [[ "$project" =~ ^[0-9]+$ ]] ; 
 then exec >&2; echo "error: Project ID given is not a number."; exit 1
fi

rundir=$1

echo Creating new SampleList.csv file in directory \"$rundir\" ...

cd $rundir

echo '[Data]' > SampleList.csv

echo 'Sample_Name,Project_ID,File_Forward,File_Reverse' >> SampleList.csv

echo Done.

echo Parsing files...

for filename in `ls | grep ${forward_ending}${extention}`
	do samplename=${filename%${forward_ending}${extention}}
	forward_file_name=$samplename$forward_ending$extention
	reverse_file_name=$samplename$reverse_ending$extention
	if [ ! -f "$forward_file_name" ]; then
		echo error: Could not find file $forward_file_name while parsing
		exit 1
	fi
	if [ ! -f "$reverse_file_name" ]; then
                echo error: Could not find file $reverse_file_name while parsing
                exit 1
	fi
	echo $samplename,$project,$forward_file_name,$reverse_file_name >> SampleList.csv
done

echo Done.

echo Enter IRIDA Username
read USERNAME

read -s -p "Enter IRIDA Password: " PASSWORD

echo ""
echo Starting Upload...

$UPLOADERCMD -d $rundir -ci $CLIENTID -cs $CLIENTPW -cu $USERNAME -cp $PASSWORD -cb $BASEURL -cr $PARSER

echo Done.
