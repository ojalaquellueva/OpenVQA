#!/usr/bin/env Rscript

# =================================================================================
# Script:         vqa.R
# Purpose:        Controller script for all Vegetation Quality Analysis operations.
# Author:         Brad Boyle (ojalaquellueva@gmail.com)
# Date Created:   2026-08-20
# R Version:      R version 4.4.1 (2024-06-14)
# =================================================================================

# Load CLI Parsing Library
if (!requireNamespace("optparse", quietly = TRUE)) {
  stop("The 'optparse' package is required. Install it using install.packages('optparse')", call. = FALSE)
}
library(optparse)

# Define Command-Line Options
option_list <- list(
  make_option(
    c("-m", "--mode"), 
    type = "character", 
    default = NULL,
    help = "Execution mode: 'import', 'vqa_batch', or 'qh.net' [REQUIRED]", 
    metavar = "MODE"
    ),
  
  make_option(c("-p", "--project"), type = "character", default = NULL, 
    help = "Project code [REQUIRED]", metavar = "PROJ"),
  
  make_option(c("-a", "--assess"), type = "character", default = NULL, 
    help = "Assessment code [REQUIRED]", metavar = "ASSESS")
  
)

# Parse Arguments
parser <- OptionParser(
  usage = "usage: %prog --mode <MODE> --project <PROJ> --assess <ASSESS>",
  option_list = option_list,
  description = "\nVegetation Quality Assessment analysis pipeline."
)

args <- parse_args(parser)

# ==================
# Validate Arguments
# ==================

# Enforce required --mode argument
if (is.null(args$mode)) {
  print_help(parser)
  stop("\nError: Missing required argument: --mode / -m", call. = FALSE)
}
allowed_modes <- c("import", "vqa_batch", "qh.net")
if (!(args$mode %in% allowed_modes)) {
  print_help(parser)
  stop(paste0("\nError: Invalid mode '", args$mode, "'. Must be one of: ", 
    paste(allowed_modes, collapse = ", ")), call. = FALSE)
}

# Assign validated option to a clean variable name
mode <- args$mode

# Check that remaining options have values
if (is.null(args$project)) {
  print_help(parser)
  stop("\nError: Missing required argument: --project / -m", call. = FALSE)
}
project <- args$project
if (is.null(args$assess)) {
  print_help(parser)
  stop("\nError: Missing required argument: --assess / -m", call. = FALSE)
}
assess <- args$assess

cat("Arguments successfully processed:\n")
cat("  mode: ", mode, "\n", sep="")
cat("  project: ", project, "\n", sep="")
cat("  assess: ", assess, "\n", sep="")

cat("\n\nOperation completed\n")


