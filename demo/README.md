# Demonstration scripts

Use these scripts to demonstrate functions and algorithms, test changes, and/or produce figures for publications. 

Most of these scripts are standalone, but some require parameters and libraries set in the main parameters file. You may need to move or copy such scripts one directory up to run, or modify paths of included scripts, functions, parameters, etc.

### Script descriptions

**`overlap.demo.R`**  
* Demo animation of bootstrap confidence limits calculation   
* Run any VQA indicator script first. `sr.R` generally works well.  
* Must also set the vegetation to be plotted. Inspect values of vector `allveg` and use appropriate index to set variable `curr.veg`.  
