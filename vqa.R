# =================================================================================
# Script:         vqa.R
# Purpose:        Controller script for all Vegetation Quality Analysis operations
# Author:         Brad Boyle (ojalaquellueva@gmail.com)
# Date Created:   2026-08-20
# R Version:      R version 4.4.1 (2024-06-14)
# =================================================================================

# ==============================================
# Note: This script take command line arguments, 
# and MUST be run from the shell, or the Terminal 
# window in RStudio
# ==============================================

# ===============================================
# Load libraries for just this script (others
# loaded later, depending on which part of the
# pipeline is called)
# ===============================================

# CLI Parsing Library
if (!requireNamespace("optparse", quietly = TRUE)) {
  stop("The 'optparse' package is required. Install it using install.packages('optparse')", call. = FALSE)
}
library(optparse)

# ===============================================
# Parameters
# ===============================================

# ===============================================
# Parameters
# ===============================================

# Each mode is a different step in the vqa pipeline.
# It is also the name of the file launched ("sourced")
# by this script, minus the ".R" extension
allowed_modes <- c("import", "vqa.batch", "qh.net")

# Help hint appended to all error messages
hint_help <- "(Use option '-h' or '--help' for full usage details)"

# ===============================================
# Main
# ===============================================

# Define Command-Line Options
option_list <- list(
  make_option(
    c("-m", "--mode"), type = "character", default = NULL,
    help = "Execution mode: 'import', 'vqa_batch', or 'qh.net' [REQUIRED]", 
    metavar = "MODE"),
  make_option(c("-p", "--project"), type = "character", default = NULL, 
    help = "Project code [REQUIRED]", metavar = "PROJ"),
  make_option(c("-a", "--assess"), type = "character", default = NULL, 
    help = "Assessment code [REQUIRED]", metavar = "ASSESS")
)

# Parse Arguments
parser <- OptionParser(
  usage = "usage: %prog --mode <MODE> --project <PROJ> --assess <ASSESS>",
  add_help_option = TRUE, 
  option_list = option_list,
  description = "\nVegetation Quality Assessment analysis pipeline."
)
args <- parse_args(parser)

# ==================
# Validate Arguments
# ==================

# Enforce required --mode argument
if (is.null(args$mode)) { # Argument missing
  msg_err <- "Missing required option --mode | -m"
  stop(paste0(msg_err, " ", hint_help), call. = FALSE)
}
if (!(args$mode %in% allowed_modes)) { # Invalid argument
  msg_err <- "Invalid argument for --mode | -m"
  stop(paste0(msg_err, " ", hint_help), call. = FALSE)
}
# Assign validated option to a clean variable name
opt_mode <- args$mode

# Check that remaining options have values
if (is.null(args$project)) { # Argument missing
  msg_err <- "Missing required argument: --project / -m"
  stop(paste0(msg_err, " ", hint_help), call. = FALSE)
}
# 'opt_' prefix marks this as command line setting:
# takes precedence over parameters set in params files
opt_project <- args$project

if (is.null(args$assess)) { # Argument missing
  msg_err <- "Missing required argument: --assess / -m"
  stop(paste0(msg_err, " ", hint_help), call. = FALSE)
}
# 'opt_' prefix marks this as command line setting:
# takes precedence over parameters set in params files
opt_assess <- args$assess

# Find where this script is located
# Only works from shell, but OK for this script.
initial_options <- commandArgs(trailingOnly = FALSE)
file_arg <- "--file="
script_name <- sub(file_arg, "", initial_options[grep(file_arg, initial_options)])
script_dir <- dirname(script_name)
script_dir <- normalizePath(script_dir, mustWork = TRUE)

# Launch the target script
source(file.path(script_dir, paste0(opt_mode, ".R")))




