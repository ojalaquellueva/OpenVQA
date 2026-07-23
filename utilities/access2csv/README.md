# Extract Microsoft Access database to CSV (access2csv)

## Overview

Extract a Microsoft Access database file (X.mdb or X.accdb) to one or more CSV files. 

## Requirements
* mdbtools (http://mdbtools.sourceforge.net)

## Usage
* Dumps files to subdirectory "csv" in working directory (whatever directory command is invoked from). Will create directory "csv" if it doesn't exist.

```
access2csv.sh [-i] [-f pathAndAccessFileName] 
```
* The above assumes `access2csv` is located in `~/bin` or `/usr/local/bin` and your PATH modified accordingly. If not, just copy this file to the same location as the Access file and run as follows:

```
./access2csv.sh [-i] [-f pathAndAccessFileName] 
``` 

#### Options

Option | Details | Required
--- | --- | ---
-i  | Turn on interactive mode (runs in silent mode by default | No
-f  | Path and name MS Access file to extract | Yes

## Known issues
1. Spatial objects (e.g., shapefiles) will be corrupted on export to CSV. This will not throw an error, but prior to importing to most applications, you will need to manually open (i.e., in a spreadsheet) any csv files from tables that contain spatial objects and delete the sparial column(s).



