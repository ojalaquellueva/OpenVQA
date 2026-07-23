# VQA Demo Data Directory

## Introduction

This is an example VQA data directory, for demonstration purposes only. It contains example data for demo applications that show how to use VQA. 

## The demos

Currently there are two demos. See the READMEs in each project subdirectory for details.

### Demo #1
* In project subdirectory `vqa-demo-1/`
* A simple demo that shows how to import data and calculate vegetation quality for a couple of assessments. 

### Demo #2
* In project subdirectory `vqa-demo-2/`
* A more complex demo with four assessments: baseline and current condition assessments for a project site, and baseline and current assessments for an offset site. 
* Also demonstrates how to run a Net Quality Hectares analysis

## Where do I keep my data?

### Don’t keep your data here!
* Don’t keep your data here, especially if you are forking VQA to a new repository with a public remote master repository. You will blow up the repository,  and expose your data if the repo is public! 
* Store your data outside this repo, one level up, in a separate data repository called `data/`. This is the default location for VQA data. If you need to version your data (rather than just a simple backup) use a separate repository just for data.

### The simple way to set the data directory location
* The simplest way to switch between this data directory (for demos) and the main data directory (for you data and everything else, is to adjust the parameter `LOC_DATA_DIR`.
* `LOC_DATA_DIR` is found at the very beginning of `params.R`. To use the default data directory outside the code repository, set LOC_DATA_DIR as follows:

```
LOC_DATA_DIR <- "out"
```

To use the demo data directory inside the code repository (this one), set LOC_DATA_DIR as follows:

```
LOC_DATA_DIR <- "in"
```

That’s it!  

### The infinitely customizable way to set the data directory

* You can set whatever data directory you want in section "# DIRECTORY OPTIONS" of the main parameter file `params.R`. 
* If you have added a "# DIRECTORY OPTIONS" section to your project-specific parameters file (`params.<PROJ>.R`), you should set it there as it will over-ride any settings in `params.R`.


