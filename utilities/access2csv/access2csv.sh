#!/bin/bash

#################################################################
# Purpose: Exports tables from MS Access database to CSV files
# By: Brad Boyle (bboyle@email.arizona.edu)
# Date created: 12 May 2020
# Version 1.0
#
# Requirements:
# 1. mdbtools (http://mdbtools.sourceforge.net)
#
# Usage:
# access2csv.sh [-i] [-f pathAndAccessFileName] 
#
# Usage details:
# If no options provided, will use parameter values set below
# interactive (-i) option turns on echo and confirmation messages
# runs in silent mode by default, unless -i option set on command 
# line
# If file not in current working directory, accessfile MUST include 
# path from root
#
# Revision history:
# 1.0 Original version
#################################################################

###### Parameters

# Set default parameters here, or set as command line options
accessfile=""

######## Functions

echoi()
{
	# If first token = true echoes message, otherwise does nothing
	# Optionally accepts -n switch before message
	# Gotcha: may behave unexpectedly if message = "true" or true

	# first token MUST be 'true' to continue
	if [ "$1" = true ]; then
		shift
		msg=""
		n=" "
		while [ "$1" != "" ]; do
			# Get second token, if echo switch, treat next token 
			# as message, otherwise treat second token as message
			# echo the message
		
			case $1 in
				-n )			n=" -n "	
								shift
								;;
				* )            	msg=$1
								break
								;;
			esac
		done	
		echo $n $msg
	fi
}

###### Main

interactive="false"		# Interactive mode off by default
continue="true"

while [ "$1" != "" ]; do
    case $1 in
        -i | --interactive )	interactive="true"
        						#break
        						;;
        -f | --file )           shift
                                accessfile=$1
                                ;;
        * )                     echo "Error!"; exit 1
    esac
    shift
done

if [[ "$interactive" = "true" ]]; then
	# Run interactive checks and confirmations
	continue="false"
	
	echo
	echo "Exporting tables from MS Access database to CSV files. Settings:

	accessfile = $accessfile
	"
	read -p "Continue? (Y/N): " -r
	
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		continue="true"
	fi
fi

if [[ "$continue" == "false" ]]; then
	echoi $interactive "Operation cancelled"
	exit 0
fi

# Preliminary error checks
if [[ "$accessfile" == "" ]]
then
	echo "File parameter NOT set!"; exit 1
elif [ ! -f "$accessfile" ]; then
	# file not found
	echo "File $accessfile does not exist!"; exit 1	
else 
	echoi $interactive "Exporting tables:"
	
	# create csv subdirectory if it doesn't already exist
	mkdir -p csv
	
 	# export each table from Access as an sql file in subdirectory sql/
	tblstr=$( mdb-tables -d % $accessfile )	# delimited string of table names
	IFS='%' read -a tblarr <<< "$tblstr"	# convert string to array
	for i in "${tblarr[@]}"
	do 
		echo "  $i --> ${i}.csv"
		mdb-export -D "%Y-%m-%d %H:%M:%S" $accessfile "$i" > csv/"$i.csv"
	done

	echoi $interactive "Operation complete"
	echoi $interactive
fi

exit 0