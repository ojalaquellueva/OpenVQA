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
# Default parameters
# ===============================================

# Application name for interactive display
app_name <- "Vegetation Quality Assessment"

# ============================================================
# Define command-line argument specifications
# ============================================================

option_spec <- list(
  mode = list(
    long     = "--mode",
    short    = "-m",
    required = TRUE,
    allowed  = c("import", "vqa.batch", "qh.net")
  ),
  project = list(
    long     = "--project",
    short    = "-p",
    required = TRUE,
    allowed  = NULL
  ),
  assess = list(
    long     = "--assess",
    short    = "-a",
    required = TRUE,
    allowed  = NULL
  ),
  quiet = list(
    long     = "--quiet",
    short    = "-q",
    action="store_false", 
    default=TRUE,
    required = FALSE, # Don't omit, required for pre-optparse validations
    help="Turn off all messages except errors [default %default]"
  )
)

# ============================================================
# Build optparse specification
# ============================================================

option_list <- lapply(
  option_spec,

  function(spec) {
    make_option(
      c(spec$short, spec$long),
      type = "character"
    )
  }

)

parser <- OptionParser(
  option_list = option_list,
  description = "Vegetation Quality Assessment",
  #usage = "usage: %prog --mode <MODE> --project <PROJ> --assess <ASSESS>",
  add_help_option = FALSE
)

# ============================================================
# Echo application name & retrieve raw command-line arguments
# ============================================================

cat(rep("-", nchar(app_name)), "\n", sep="")
cat(app_name, "\n", sep="")
cat(rep("-", nchar(app_name)), "\n", sep="")

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
  
  # Find either the long or short form
  option_index <- which(args %in% option_names)
  
  # ----------------------------------------------------------
  # Required option missing
  # ----------------------------------------------------------
  
  if (length(option_index) == 0) {
    
    if (spec$required) {
      stop(
        sprintf(
          "Option '%s' is required.",
          spec$long
        ),
        call. = FALSE
      )
    }
    
    return(invisible(TRUE))
  }
  
  # Use the first occurrence
  option_index <- option_index[1]

  # ----------------------------------------------------------
  # Option value missing
  # ----------------------------------------------------------
  
  if (option_index == length(args)) {
    stop(
      sprintf(
        "Option '%s' requires a value.",
        spec$long
      ),
      call. = FALSE
    )
  }
  
  value <- args[option_index + 1]
  
  if (grepl("^-", value)) {
    stop(
      sprintf(
        "Option '%s' requires a value.",
        spec$long
      ),
      call. = FALSE
    )
  }
  
  # ----------------------------------------------------------
  # Option value invalid
  # ----------------------------------------------------------
  
  if (!is.null(spec$allowed) && !value %in% spec$allowed) {
    stop(
      sprintf(
        paste0(
          "Invalid value for option '%s': '%s'.\n",
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
opt_src_dir <- normalizePath(this_script_dir, mustWork = TRUE)
opt_app_dir <- dirname(opt_src_dir)

# ----------------------------------------------------------
# Locate project directory
# Notes: 
# 1. For now, assume default directory name "<vqa_>opt_proj".
# 2. Looks in the following locations in the order shown: 
#    `<opt_base_dir_app>/../projects/` and `<opt_base_dir_src>/`.
# 3. Will add option custom project path command line option later
# ----------------------------------------------------------

opt_project_path <- file.path(opt_app_dir, "projects", opt_project)
cat("Locating project directory '", opt_project_path, "'...")

if (dir.exists(opt_project_path)) {
  cat("done\n")
} else {
  cat("failed\n")
  
  # Check alternate path
  opt_project_path <- file.path(opt_src_dir, opt_project)
  cat("Checking alternate location '", opt_project_path, "'...")
  
  if (dir.exists(opt_project_path)) {
    cat("done\n")
  } else {
    cat("failed\n")
    stop(
      sprintf(
        "Project directory for project '%s' not found.",
        opt_project
      ),
      call. = FALSE
    )
  }
}

# ----------------------------------------------------------
# Locate assessment data directory
# Notes: 
# 1. For now, assume default "<vqa_>opt_proj".
#    Later will add project path command line option.
# 2. Looks in the following locations in the order shown: 
#    `<opt_base_dir_app>/../projects/` and `<opt_base_dir_src>/`.
# ----------------------------------------------------------


# ============================================================
# Launch the requested operation
# ============================================================

# Set target path and execute the requested script
target_script_name <- paste0(opt_mode, ".R")
target_script <- file.path(opt_src_dir, target_script_name)


# Echo all paths
cat("opt_src_dir: ", opt_src_dir, "\n", sep="")
cat("opt_app_dir: ", opt_app_dir, "\n", sep="")
cat("opt_project_path: ", opt_project_path, "\n", sep="")
# cat("opt_assess_path: ", opt_assess_path, "\n", sep="")
# cat("opt_data_path: ", opt_data_path, "\n", sep="")
cat("target_script_name: ", target_script_name, "\n", sep="")
cat("target_script: ", target_script, "\n", sep="")



cat("\n")

#source(target_script)
