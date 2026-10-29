#!/usr/bin/env Rscript

# =================================================================================
# Script:         vqa.R
# Purpose:        Controller for all Vegetation Quality Analysis operations
# Author:         Brad Boyle (ojalaquellueva@gmail.com)
# Date Created:   2026-08-20
# R Version:      R version 4.4.1 (2024-06-14)
# 
# Note: This script take command line arguments and MUST be run from the
#   shell (Linux/Mac) or the RStudio Terminal tab (all operating systems).
#   It will not run correctly from the R Console.
# ==============================================

# ===============================================
# Libraries (for this script only)
# ===============================================

if (!requireNamespace("optparse", quietly = TRUE)) {
  stop("The 'optparse' package is required. Install it using install.packages('optparse')", 
    call. = FALSE)
}
library(optparse)

# ===============================================
# Functions
# ===============================================

source("includes/functions.R")

# ===============================================
# Default parameters
# ===============================================

# Application name for interactive display
app_name <- "Vegetation Quality Assessment"

# ============================================================
# Define command-line argument specifications
# ============================================================

option_spec <- list(
  mode = list(
    long        = "--mode",
    short       = "-m",
    type        = "character",
    takes_value = TRUE,
    required    = TRUE,
    allowed     = c("import", "vqa.batch", "qh.net")
  ),
  project = list(
    long        = "--project",
    short       = "-p",
    type        = "character",
    takes_value = TRUE,
    required    = TRUE,
    allowed     = NULL
  ),
  assess = list(
    long        = "--assess",
    short       = "-a",
    type        = "character",
    takes_value = TRUE,
    required    = TRUE,
    allowed     = NULL
  ),
  quiet = list(
    long        = "--quiet",
    short       = "-q",
    type        = "logical",
    takes_value = FALSE,
    default     = FALSE,
    required    = FALSE, # Don't omit, required for pre-optparse validations
    help="Turn off all messages except errors [default %default]"
  )
)

# ============================================================
# Build optparse specification
# ============================================================

option_list <- lapply(
  option_spec,
  function(spec) {
    
    if (spec$takes_value) {
      default <- if (!is.null(spec$default)) {
        spec$default
      } else {
        NULL
      }
      make_option(
        c(spec$short, spec$long),
        type = spec$type,
        default = default
      )
    } else {
      make_option(
        c(spec$short, spec$long),
        action = "store_true",
        default = spec$default
      )
    }
  }
)

parser <- OptionParser(
  option_list = option_list,
  description = "Vegetation Quality Assessment",
  #usage = "usage: %prog --mode <MODE> --project <PROJ> --assess <ASSESS>",
  add_help_option = FALSE
)

# ============================================================
# Retrieve raw command-line arguments
# ============================================================

args <- commandArgs(trailingOnly = TRUE)

# ============================================================
# Handle built-in optparse help request
# ============================================================

if ("-h" %in% args || "--help" %in% args) {
  # Some fussy re-formatting
  raw_lines <- capture.output(print_help(parser))
  clean_lines <- raw_lines[!grepl("^\\s*$", raw_lines)]
  final_lines <- c(clean_lines[2], clean_lines[-2])
  final_lines <- gsub("=", " ", final_lines)
  cat(final_lines, sep = "\n")
  quit(status = 0)
}

# ============================================================
# Generic option validator
# ============================================================

validate_option <- function(args, spec) {
  option_names <- c(spec$long, spec$short)
  option_index <- which(args %in% option_names)
  
  # ----------------------------------------------------------
  # Option absent
  # ----------------------------------------------------------
  
  if (length(option_index) == 0) {
    
    if (spec$required) {
      stop(
        sprintf(
          "[REQUIRED]: option '%s' is required.",
          spec$long
        ),
        call. = FALSE
      )
    }
    
    return(invisible(TRUE))
  }
  
  option_index <- option_index[1]
  
  # ----------------------------------------------------------
  # Flag -- no value to validate
  # ----------------------------------------------------------
  
  if (!spec$takes_value) {
    return(invisible(TRUE))
  }
  
  # ----------------------------------------------------------
  # Value missing
  # ----------------------------------------------------------
  
  if (option_index == length(args)) {
    stop(
      sprintf(
        "[VALUE_MISSING]: option '%s' requires a value.",
        spec$long
      ),
      call. = FALSE
    )
  }
  
  value <- args[option_index + 1]
  
  if (grepl("^-", value)) {
    stop(
      sprintf(
        "[VALUE_MISSING]: option '%s' requires a value.",
        spec$long
      ),
      call. = FALSE
    )
  }
  
  
  # ----------------------------------------------------------
  # Value invalid
  # ----------------------------------------------------------
  
  if (!is.null(spec$allowed) && !value %in% spec$allowed) {
    stop(
      sprintf(
        paste0(
          "[INVALID_VALUE]: invalid value for '%s': '%s'.\n",
          "Allowed values: %s."
        ),
        spec$long,
        value,
        paste(spec$allowed, collapse = ", ")
      ),
      call. = FALSE
    )
  }
  
  invisible(TRUE)
}

# ============================================================
# Validate command line
# ============================================================

for (spec in option_spec) {
  validate_option(args, spec)
}

# ============================================================
# Parse with optparse
# ============================================================

opt <- parse_args(parser)

# ----------------------------------------------------------
# Save the option values as variables with "opt_" prefix
# to indicate parameters set by controller. Parameter
# value set via command line over-rides the corresponding 
# parameter values set in the parameter files.
# ----------------------------------------------------------
opt_mode <- opt$mode
opt_project <-opt$project
opt_assess <- opt$assess
quiet <- opt$quiet

# ============================================================
# Echo app name & mode
# ============================================================

if (!quiet) {
  cat(rep("-", nchar(app_name)), "\n", sep="")
  cat(app_name, "\n", sep="")
  cat(rep("-", nchar(app_name)), "\n", sep="")
  cat("Mode: ", opt_mode, "\n", sep="")
}

# ============================================================
# Locate project and assessment directories
# ============================================================

# ----------------------------------------------------------
# Locate source code and application base directories
# ----------------------------------------------------------

# Source code base directory (i.e., abs path to this script)
initial_options <- commandArgs(trailingOnly = FALSE)
file_arg <- "--file="
this_script <- sub(file_arg, "", initial_options[grep(file_arg, initial_options)])
this_script_dir <- dirname(this_script)

# Save as "opt_" variables to indicate parameters set by controller 
opt_src_path <- normalizePath(this_script_dir, mustWork = TRUE)
opt_app_path <- dirname(opt_src_path)

if (!quiet) {
  cat("Project: ", opt_project, "\n", sep="")
  cat("Assessment: ", opt_assess, "\n", sep="")
  cat("Application directory: ", opt_app_path, "\n", sep="")
  cat("Source code directory: ", opt_src_path, "\n", sep="")
  cat("Project directory: ")
}

# ----------------------------------------------------------
# Locate project directory
#
# Notes: 
# 1. Looks in the following locations in the order shown: 
#    `<opt_base_dir_app>/projects/opt_proj>/` 
#    `<opt_base_dir_src>/projects/opt_proj>/`
# 2. Will add option to set custom project path via command
#    line later
# ----------------------------------------------------------

opt_project_path <- file.path(opt_app_path, "projects", opt_project)

if (!dir.exists(opt_project_path)) {
  if (!quiet) {
    cat ("directory '", opt_project_path, "'   not found!\n")
    cat("Project directory: ")
  }
  
  # Check alternate path
  opt_project_path <- file.path(opt_src_path, "projects", opt_project)
  if (!quiet) {
    cat("Checking for project directory: ", opt_project_path, "...", sep="")
  }
  
  if (!dir.exists(opt_project_path)) {
    if (!quiet) {
      cat ("alt project directory '", opt_project_path, "'   not found!\n")
      cat("Operation aborted\n")
      quit(save = "no", status = 1) 
    }
    
  }
}

# Set project data base directory relative to project directory
opt_data_base_path <- file.path(opt_project_path, "data", opt_project)

# ----------------------------------------------------------
# Echo final project directory
# ----------------------------------------------------------

if (!quiet) {
  cat("", opt_project_path, "\n", sep="") # Concludes previous echo "Project directory: "
  cat("Project data directory: ", opt_data_base_path, "\n", sep="")
}

# ----------------------------------------------------------
# Locate assessment data directory
#
# Note: Only one possible locations: 
# 2. `<opt_project_path>/data/<opt_proj>/<opt_assess>/`
#    * Support multiple data directories for >1 projects
#    * Even if only 1 project, you must use this structure
# ----------------------------------------------------------

#opt_assess_path <- file.path(opt_data_base_path, opt_project, opt_assess)
opt_assess_path <- file.path(opt_data_base_path, opt_assess)

if (!dir.exists(opt_assess_path)) {
  stop(
    sprintf(
      "Data directory for assessment '%s' not found.",
      opt_assess
    ),
    call. = FALSE
  )
}

# ----------------------------------------------------------
# Echo assessment data directory
# ----------------------------------------------------------

if (!quiet) {
  cat("Assessment data directory: ", opt_assess_path, "\n", sep="")
}

# ============================================================
# Confirm (if applicable) and launch the requested operation
# ============================================================

# Display parameters & confirm operation
if (!quiet) {
  yes <- c("y", "Y", "Yes", "yes")
  cat("Launch the requested operation? (y/n):")
  response <- readLines("stdin",n=1)
  if ( ! response %in% yes ) {
    cat("Operation cancelled\n")
    quit(save = "no", status = 0) 
  } else {
    cat("\n")
  }
}

# Set target path and execute the requested script
target_script_name <- paste0(opt_mode, ".R")
target_script <- file.path(opt_src_path, target_script_name)
source(target_script)
