# Project-specific import files

* A project-specific import file contains project-specific code required to import raw data and reformat to generic input files required by VQA

* Names of project-specific import files MUST adhere to one of two formats:
	1. 	`import.<PROJ>.R` (code applies to all assessments)
	2. `import.<PROJ>.<ASSESS>.R` (code applies to a single assessment only)
* All files resulting from the import will be saved to two directories the project-assessment data base directory `data/<PROJ>/<ASSESS>/`
   * Generic VQA input files are saved to directory `inputs/`
   * Sample size summary files and error reports are saved to directory `results/`

* These files are not run directly; they are sourced by script `import.R`
* Values of parameters PROJ and ASSESS (set in file `pa.params.R`) determine which project and assessment will be imported and prepared for VQA
* Additional import parameters specific to a given project and assessment are set in the project-specific parameters filed, name `params.<PROJ>.R` or `params.<PROJ>.<ASSESS>.R`