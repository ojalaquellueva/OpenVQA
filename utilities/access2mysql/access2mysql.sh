#!/bin/bash

#################################################################
# Purpose: Imports MS Access database to MySQL
# By: Brad Boyle (bboyle@email.arizona.edu)
# Date created: 11 Feb. 2015
# Date last modified: 16 Nov. 2018
# Version 1.3
#
# Requirements:
# 1. mdbtools 0.7.1
#	 Old repo: https://github.com/brianb/mdbtools/releases 
# 	 Current repo: https://github.com/brianb/mdbtools/releases
#	 To install on Mac OS: brew install mdbtools
# 2. MySQL
# 3. Write access to MySQL, including CREATE DATABASE permission
#
# Warnings: 
# 1. Existing MySQL database will be replaced!
#
# Usage:
# access2mysql.sh [-s] [-o] [-r] [-f pathAndAccessFileName] [-d mysqlDbName] [-u mysqlUserName] [-p mysqlPwd]
#
# Options:
#	s	Silent mode 
#	o	Dump schema only
#	r	Reuse previously dumped schema
#	f	Path and name of MS Access file
#	d	Name of target MySQL database
#	u	MySQL user
# 	p 	MySQL password
#
# Usage details:
# 	* If no options provided, will use parameter values set below
# interactive mode (default) by default. 
# 	* Use silent mode (-s) to turn off all echoes and confirmation messages
#	* Each option must be listed separately. E.g., 
#	" -s, -o " [correct]
#	" -so " [incorrect]
#
# Revision history:
# 1.0 Original version
# 1.1 Added support for table names with spaces
# 1.2 Added options -o, -r
# 1.3 Remove option -i (interactive mode), added -s (silent more)
#	  and made interactive mode the default
#################################################################

###### Parameters

# Set default parameters here
# If using interactive mode, you MUST set these parameters as script will
# ignore any additional parameters provided by command
# If not in current working directory, accessfile MUST include path from root
accessfile=""
mysqldb=""
mysqlusr=""
mysqlpwd=""

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

interactive="true"		# Interactive mode off by default
schema_only="false"		# Dump schema and quit (for making corrections)
reuse_schema="false"	# Reuse previous schema
continue="true"

while [ "$1" != "" ]; do
    case $1 in
        -s | --silent-mode )	interactive="false"
        						;;
        -f | --file )           shift
                                accessfile=$1
                                ;;
        -d | --database )        shift
                                mysqldb=$1
                                ;;
        -u | --user )           shift
                                mysqlusr=$1
                                ;;
        -p | --password )        shift
                                mysqlpwd=$1
                                ;;                                                                
        -r | --reuse-schema )	reuse_schema="true"
                                ;;                                                                
        -o | --schema-only )	schema_only="true"
                                ;;                                                                
        * )                     echo "ERROR: bad option(s)"; exit 1
    esac
    shift
done

if [[ "$interactive" = "true" ]]; then
	# Run interactive checks and confirmations
	continue="false"
	
	if ! [[ "$schema_only" == "true" ]]; then
		if [[ "$mysqlpwd" == "" ]]; then
			pwdmsg="[pwd not provided!]"
		else
			pwdmsg="*******"
		fi
	fi
	
	echo
	echo "Importing MS Access database to MySQL. Settings:

	accessfile:	$accessfile
	mysqldb:	$mysqldb
	mysqlusr:	$mysqlusr
	mysqlpwd:	$pwdmsg
	
	Schema only?	$schema_only
	Reuse schema?	$reuse_schema
	
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
if [[ "$accessfile" == "" ]]; then
	# parameters not set
	echo "Access file name not set!"; exit 1
elif [[ "$mysqldb" == "" || "$mysqlusr" == "" || "$mysqlpwd" == "" ]] && [[ "$schema_only" == "false" ]]; then
	echo "One or more MySQL parameters not set!"; exit 1
elif [ ! -f "$accessfile" ]; then
	# file not found
	echo "File $accessfile does not exist!"; exit 1	
elif [ ! true ]; then
	# mysql user doesn't exist
	echo "Check for mysql user not yet implemented"; exit 1
elif [ ! true ]; then
	# Bad mysql login credentials valid 
	echo "Check for value login not yet implemented"; exit 1	
elif [ ! true ]; then
	# mysql database already exists, warn user
	echoi $interactive "Confirm replace existing MySQL database not yet implemented"		
else 
	if [[ "$reuse_schema" == "true" && "$schema_only" == "false" ]]; then
		echoi $interactive "Reusing previously-exported schema...done"
	else
		echoi $interactive -n "Exporting schema from Access..."

		# dump the schema:
		mdb-schema $accessfile mysql > schema.sql
		echoi $interactive "done"
	fi

	if [[ "$schema_only" == "true" ]]; then
		echoi $interactive "Operation complete. See 'schema.sql'"; exit 0
	fi

	echoi $interactive -n "Creating MySQL database '$mysqldb'..."
	mysql --user=$mysqlusr --password=$mysqlpwd -e "DROP DATABASE IF EXISTS $mysqldb"
	mysql --user=$mysqlusr --password=$mysqlpwd -e "CREATE DATABASE $mysqldb"
	echoi $interactive "done"

	# import the schema to MySQL (destination db must already exist)
	echoi $interactive " Importing schema:"
	mysql --user=$mysqlusr --password=$mysqlpwd -B $mysqldb < schema.sql

	# create sql subdirectory if it doesn't already exist
	mkdir -p sql

	# export each table from Access as an sql file in subdirectory sql/		
	tblstr=$( mdb-tables -d % $accessfile )	# delimited string of table names
	IFS='%' read -a tblarr <<< "$tblstr"	# convert string to array
	for i in "${tblarr[@]}"
	do 
		echo "  $i"
		mdb-export -D "%Y-%m-%d %H:%M:%S" -H -I mysql $accessfile "$i" > sql/"$i.sql"
	done

	# import all tables
	echoi $interactive " Importing data:"
	for i in "${tblarr[@]}"
	do 
		echo "  $i"
		mysql --compress --user=$mysqlusr --password=$mysqlpwd -B $mysqldb < sql/"$i.sql"
	done

	# Remove sql/ directory and insert files
	# Do this file by file to be safe
	echoi $interactive -n " Cleaning up..."
	for i in "${tblarr[@]}"
	do
		rm sql/"$i.sql"
	done
	rmdir sql
	rm schema.sql
	echoi $interactive "done"

	echoi $interactive "Operation complete"
	echoi $interactive
fi

exit 0
