###################################################
# Compiles separate nmds results files from multiple assessments 
# into a single NMDS site scores file, for plotting
###################################################

# Set base directory wd<-getwd()
rm(list=ls())
wd<-getwd()
setwd(wd)

##############################
# Parameters
##############################

# Project code
proj <- "teck-ev"
proj <- "ttg-bra"

# Source assessment subdirectories
SRC.ASSESS.SUBDIRS <- c(
	"006_2023-05_Ecosystem-Reclaimed", 
	"006_2023-05_Reclaimed", 
	"006_2023-05_Natural"
	)

# Destination assessment subdirectory
# where compiled td_raw file will be save
DEST.SUBDIR <- "006_2023-05"
	
# Base directories
BASEDIR <- "/Users/bboyle/Documents/hga/vqa/"		# Absolute path
#BASEDIR <- paste0(wd, "/../", )											# Relative path
DATA_BASEDIR <- paste0( BASEDIR, "data/", proj, "/" )

# Name of separate NMDS sites score files
f.site.scores <- "TD_raw.csv"

# Compiled NMDS sites score file
f.site.scores.compiled <- "nmds_site_scores.csv"		

# functions file relative path and name
f.functions <- "includes/functions.R"

##############################
# Load libraries & functions
#####################################

library(tidyverse)	# General tools
library(Hmisc)		# Import of MS Access files; requires mdb-tools
library(vegan)		# NMDS, used by td.R
library(picante)		# Convert file to vegan format 
source(f.functions, local=TRUE)

##############################
# Import & compile raw data, and save
#############################

# directory where compiled file will be saved
dest.dir <- paste0( DATA_BASEDIR, DEST.SUBDIR, "/results/" )

# Load the raw files and compile
for ( i in 1:length(SRC.ASSESS.SUBDIRS) ){
	src.subdir <- SRC.ASSESS.SUBDIRS[i]
	src.dir <- paste0(DATA_BASEDIR, src.subdir, "/results/")
	src.file.temp <- paste0( src.dir, f.site.scores )
	site.scores.temp <- read.csv( src.file.temp, header=TRUE )
	
	if ( i==1 ) {
		site.scores <- site.scores.temp
	} else {
		site.scores <- rbind(site.scores, site.scores.temp)
	}
}

# Save compiled NMDS site scores
file <- paste0( dest.dir, f.site.scores.compiled )
cat( "Saving compiled file '", f.site.scores.compiled, "' to directory '", dest.dir, "'...", sep="" )
write.csv( site.scores, file= file, row.names=FALSE )
cat( "done\n" )

