##########################################
# Run all VQA scripts as single pipeline
##########################################

#########################################
# Set paths, load functions & parameters
#########################################

rm(list=ls())		# clear the workspace

# Set working directory (base application directory)
# Must set first to set remaining directory parameters
if(!exists("params.loaded", mode="function")) {
  wd<-getwd()
  setwd(wd)
  SRCDIR <- paste0(wd, "/")
}

# Set job so params.R know which parameters to load
job <- "vqa.batch"

# Load parameters file & functions
source("includes/functions.R", local=TRUE)
#source("params.R")
source(paste0(SRCDIR, "params.R"))

##########################################
# Start log file
##########################################

if (REPLACE.LOG==TRUE) {
	logfile <- paste0( LOGDIR, LOGFILE.BASENAME, ".txt" )
} else {
	logfile <- paste0( LOGDIR, LOGFILE.BASENAME, format( Sys.time(), "_%Y%m%d_%H%M%S"), ".txt" )
}
log <- file( logfile )
# Write console output to log file as well
sink( log, append = TRUE, type = "output", split=TRUE) 	

##########################################
# Report parameters & confirm operation
##########################################

# Display confirmation message
cat(paste0("Run VQA Batch for project '", PROJ, "', assessment '", ASSESS, "' using the following settings: \n"))
cat(paste0(MSG.CONF.START, MSG.CONF.BATCH))

if (interactive()==FALSE) {
	yes <- c("y", "Y", "Yes", "yes")
	cat("Continue? (y/n):")
	response <- readLines("stdin",n=1)
	if ( ! response %in% yes ) stop_quietly("Operation cancelled\n\n")
} else {
	cat("\n\n")
}

cat("\n")
cat("############################################\n")
cat("Begin operation\n")
cat("\n")

#########################################
# Check required input files present
#########################################
cat("Checking for required input files...")
if (QH.METHOD=="empirical") {
  required_files <- input_file_list(DF.LANDCOVER, DF.PLOTMETADATA, DF.SPECIES, EI.vec)
} else {
  # Only land cover input file required
  required_files <- DF.LANDCOVER
}

for (fname in required_files) {
  rf <- paste0(INPUTDIR, fname, ".csv")
  msg_err <- "ERROR: one or more required input files missing!\nHave you run import.R yet?\n"
  if (!file.exists(rf)) stop_quietly(msg_err)
}
cat("done\n")

#########################################
# Load libraries
#########################################

source("libraries.R")

#########################################
# Run quality calculations
#########################################

if ( QH.METHOD %in% c("assume.0", "assume.1") ) {
  # Just generate the summary files needed for qh.net.R
  source("q.fixed.R")
} else if ( VQA.SUMMARY.ONLY==FALSE ) {

  #########################################
  # Calculate quality for each indicator
  #########################################
  
  cat("******************************************\n")
  cat("Calculate indicator quality\n\n")
  
  # Loops through each indicator in EI.vec
  # To run indicator td only to adjust NMDS parameters,
  # set TD.ONLY<-TRUE in params file, preferably the 
  # project-specific params file in folder params/
  if ( !exists("TD.ONLY") ) TD.ONLY==FALSE
  
  if ( TD.ONLY==TRUE ) {
    # Run indicator td only
    # Use this option when running td2.R multiple 
    # times to adjust NMDS parameters and remove outliers
    cat("*** Running indicator TD only ***\n\n")
    ei.file <- "indicators/td.R"
    source( ei.file, local=TRUE)
  } else {
    for ( EI in EI.vec ) {
      ei <- tolower(EI)
      ei.fname <- paste0( ei, ".R")
      #if (ei %in% c("sr", "td" ) ) ei.fname <- paste0( ei, "2.R")
      #if (ei %in% c("sr", "td" ) ) ei.fname <- paste0( ei, "3.R")
      ei.file <- paste0( "indicators/", ei.fname )
      source( ei.file, local=TRUE)	
    }
  }
}

##########################################
# Prepare land cover data & metadata
##########################################

if ( PLOT.FIGS.ONLY==FALSE && TD.ONLY==FALSE && QH.METHOD=="empirical") {
	###############################################
	# For each land cover class, summarize indicator
  # quality, functional group quality, and overall
  # quality. Also calculate quality
  # hectares, if applicable.
	###############################################
  source("vqa.summary.R", local=TRUE)			# Calculate quality and confidence limits
	source("vqa.summary/vqa.summary.csv.R", local=TRUE)  # Prepare formatted csv summary files
  source("vqa.summary/vqa.summary.xl.R", local=TRUE)  # Prepare formatted csv summary files
}

##########################################
# Tidy up
##########################################

closeAllConnections() # Close connection to log file

cat("\n")
cat("Operation completed\n")
cat("############################################\n")
cat("\n")

##########################################
# End pipeline
##########################################
