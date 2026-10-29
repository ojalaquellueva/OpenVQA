# Project-specific parameters files

* A project-specific parameters file contains custom, project-specific parameters required to import raw data specific to a particular project (and if applicable, a project assessment) and normalize the data to the generic format of VQA input files

* Names of project-specific parameter files MUST adhere to one of two formats:
	1. 	`params.<PROJ>.R` (code applies to all assessments)
	2. `params.<PROJ>.<ASSESS>.R` (code applies to a single assessment only)
* All files resulting from the import will be saved to two directories the project-assessment data base directory `data/<PROJ>/<ASSESS>/`
   * Generic VQA input files are saved to directory `inputs/`
   * Sample size summary files and error reports are saved to directory `results/`

* These files are not run directly; they are sourced by script `import.R`
* Values of parameters PROJ and ASSESS (set in file `pa.params.R`) determine which project and assessment will be imported and prepared for VQA
* Import operations specific to a project and assessment are set in the project-specific import file named `import.<PROJ>.R` or `import.<PROJ>.<ASSESS>.R`