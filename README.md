# Vegetation Quality Assessment (VQA)

VQA is a R language data analysis pipeline for measuring similarity of reclaimed vegetation to undisturbed native vegetation.

## Contents

- [What is VQA?](#What-VQA)  
- [Dependencies](#Dependencies)  
- [Installation](#Installation)  
- [Adding new VQA projects](#Projects)  
- [Usage](#Usage)  
- [Examples](#Examples)  
- [References](#References)  

<a name="What-VQA"></a>
## What is VQA?

VQA is an analysis framework for measuring similarity of reclaimed or disturbed vegetation to undisturbed native vegetation (also called the benchmark vegetation). Similarity, called "Quality" in VQA, is estimated by comparing ecological indicators in random samples of reclaimed vegetation to samples from the corresponding benchmark vegetation. Quality can then be used to calculate Quality Hectares (QH), the quality-discount area of the reclaimed vegetation.  Subtracting baseline QH (QH of vegetation before disturbance) from current QH gives Net Quality Hectares, a key measure of progress towards No Net Loss and, ultimately, Net Positive Impact. 

### What is quality?

Quality (Q) is an index of similarity to a benchmark of undisturbed native vegetation. Q varies between 0 (no similarity) and 1 (identical). Don’t get too hung up on the word “quality”. In the context of VQA, quality is simply shorthand for “statistical similarity to natural, undisturbed vegetation”. Restored vegetation with a quality of 1 is statistically indistinguishable from pristine native vegetation, based on the indicators measured.

### What are quality hectares?

Q is also the discount factor used to convert actual hectares (Ha) to quality hectares (QH), where QH = Ha * Q (i.e., quality-discounted area). 

QH is commonly  using in loss-gain accounting as a standardized unit of comparison for balancing ecosystem losses due to industrial impacts against gains due to restoration and averted losses. QH can be used to track progress to a Net Positive Impact (NPI), the point at which current QH exceeds baseline QH (the QH of undisturbed native vegetation present prior to project impacts). Loss-gain accounting based on QH has a long history of use in industry, where it also known as habitat hectares. VQA is a more recent, rigorous implementation of Quality Hectares and Habitat Hectares.

### What is Net Quality Hectares?

Net Quality Hectares (QH.net) is a critical measure of progress to No Net Loss (NNL) and Net Positive Impact (NPI). QH.net is the difference between current QH and baseline QH. NPI is reached when QH.net>0.

### Where can I learn more?

For more information on VQA, see this open access [publication](https://www.sciencedirect.com/science/article/pii/S1470160X23016527). 

<a name="Dependencies"></a>
## Dependencies
* R >= 4.4.3   
* Multiple R packages (see script `libraries.R` for details)  

<a name="Installation"></a>
## Installation
* All commands below are shell commands run from from a terminal window in Linux or Mac (OSX), or from the RStudio terminal tab (all operating systems).
* The instructions below assume you are comfortable navigating through directory trees and are familiar with creating, copying and moving files and directories

#### 1. Create the VQA application base directory  
* This will hold all VQA components: code, configuration files, data and results

```
mkdir vqa
```

#### 2. Download VQA
* There are two main options:
  1. Most recent stable release (recommended):   
     * Go to: [https://github.com/ojalaquellueva/OpenVQA/releases/](https://github.com/ojalaquellueva/OpenVQA/releases/)
     * Click on "zip" under the most recent tagged version (i.e., the one at the top, which should also have the highest version number)
     * The zip file will download as "OpenVQA-\<version#>.zip"
  * Latest development version ("bleeding edge"):
      * Go to: [https://github.com/ojalaquellueva/OpenVQA](https://github.com/ojalaquellueva/OpenVQA). 
      * Click on button "<>Code"
      * Select "Download ZIP"
     * The zip file will download as "OpenVQA-main.zip"

#### 3. Unzip and rename the VQA source code directory
* Move the zip file inside your vqa directory and unzip it. 
  * The archive will unpack to a directory named either "OpenVQA-\<version#>.zip" or "OpenVQA-main.zip", depending on where you got if from (see above). This is the source code directory.
* Rename the source code directory. 
  * You can called it whatever you want. For this example, we’ll call it "src" (the standard Linux source code directory name).
* Your VQA configuration should look like this:

```
vqa/            [Application base directory]
 |__ src/       [VQA code directory: code and demo project data]

```

#### 4. Move the projects directory outside the code directory

* All data, parameters and custom import scripts specific to particular projects are stored in the `projects/` directory
* An example projects directory containing two demonstration projects is included with the VQA download. 
* Although the demo projects and any new projects you add will run from this location, we **strongly** recommend you move `projects/` *outside* the source code directory. 
* To do so, move the projects directory one level up so it is inside the application base directory at the same level as the source code directory. You can copy instead if you prefer to keep the original projects directory inside `src/`.
* The high-level configuration of your vqa directory should now look like this:

```
vqa/            [Application base directory]  
 |__ projects/  [Projects directory: data and project-specific scripts]
 |__ src/  	   [VQA code directory: application code only]

```

Look inside the projects directory and confirm that it is structured as follows:

```
projects/                        
 |__ vqa-demo1/                    [vqa-demo1 project directory]
 |   |__ data/                     [data directory]
 |   |   |__ vqa-demo1/            [project-specific data directory]
 |   |       |__ main_001_current/ [assessment directory (empty)]
 |   |       |__ offset_001_current/ [assessment directory (empty)]
 |   |       |__ raw/              [raw data directory (files not shown)]
 |   |__ import/                   [project-specific import directory]
 |   |     |__ import.vqa-demo1.R  [vqa-demo1 import script]
 |   |__ params/                   [project-specific parameters directory]
 |         |__ params.vqa-demo1.R  [vqa-demo1 parameters script]
 |__ vqa-demo2/                    [vqa-demo2 project directory]
     |__ data/                     [data directory]
     |   |__ vqa-demo2/            [project-specific data directory]
     |       |__ offset_baseline/  [assessment directory (empty)]
     |       |__ offset_current/   [assessment directory (empty)]
     |       |__ project_baseline/ [assessment directory (empty)]
     |       |__ project_current/  [assessment directory (empty)]
     |       |__ raw/              [raw data directory (files not shown)]
     |__ import/                   [project-specific import directory]
     |     |__ import.vqa-demo2.R  [vqa-demo2 import script]
     |__ params/                   [project-specific parameters directory]
           |__ params.vqa-demo2.R  [vqa-demo2 parameters script]
```

At this point you are ready to run the VQA examples, vqa-demo1 and vqa-demo2. To do so, skip to [Usage](#Usage). If you are ready to set up your own project, continue on with the next section.

<a name="Projects"></a>
## Adding new  VQA projects

To run your own analysis, you will need to set up a project directory. A project directory must contain (a) a project-specific parameter file, (b) a project-specific import script, and (c) a project data directory containing the raw project input data and at least one assessment directory. The assessment directory is empty to start with. It will be populated by the VQA application with normalized VQA input files and VQA results files and graphics.

#### Project directory structure

Each project directory should be structured as follows:

```
projects/                        [projects directory]
 |__ <PROJ>/                      [project directory]
     |__ data/                   [data directory]
     |   |__ <PROJ>/              [project data directory]
     |       |__ <ASSESS1>/        [assessment directory]
     |       |__ <ASSESS2>/        [assessment directory]
     |       |__ <ASSESS3>/        [assessment directory]
     |       |__ raw/            [raw data directory]
     |__ import/                 [project-specific import directory]
     |     |__ import.<PROJ>.R    [project-specific import script]
     |__ params/                 [project-specific parameters directory]
           |__ params.<PROJ>.R    [project-specific import script]

```
* In the above structure diagram, variable \<PROJ> is the project code. Each project much have a unique short code (no spaces). Variables <ASSESS1>, <ASSESS2> and <ASSESS3> assessment codes. Assessment codes must be unique within a given project. 
* Note that \<PROJ> is also embedded in the names of the project-specific parameters file (params.\<PROJ>.R) and the project-specific import script (import.\<PROJ>.R). This naming convention is extremely important. 
* The names of all the other directories (projects, data, raw, import, params) must be spelled exactly as shown.

#### Project directory contents

##### Project-specific parameters file
 
The project-specific parameters file (PSP file) contains a subset of the main VQA parameters file (params.R), with parameter values adjusted for the current project. The main VQA parameters file lives in the VQA source code base directory (`src/`).  It contains the default settings for VQA and should never be changed. These parameter setting are adjusted for a particular project by copying them to the PSP file and editing them there. The main VQA parameters file should never be changed.

##### VQA parameters

[Coming soon: detailed descriptions of VQA parameters]

##### Project-specific import file

The project-specific import script (PSI script) performs the standardizations and normalizations the convert a project-specific dataset into the standard VQA input, also called the VQA schema. Writing a PSI script to convert your data requires detailed knowledge of the VQA schema. 

##### The VQA schema

[Coming soon: detailed description of the VQA schema]

#### How Does VQA find my data?

VQA will know where to find your data if:

1. You structure your projects directory correctly (see above).
2. You keep the projects directory in one of the two supported locations: (1) Inside the VQA code directory or (2) In the application base directory (preferred)
3. You submit the correct project and assessment codes (PROJ and ASSESS) for the project and assessment you wish to analyze via the VQA command line (see [Usage](#Usage))

<a name="Usage"></a>
## Usage

* VQA must be run from the command line, either the Terminal application in Linux & Mac OSX, or the RStudio Terminal tab in all operating systems, including Windows. 
* Note: the Terminal tab in RStudio is used for entering system commands. It is not the same as the Console tab used to paste and run R code.

### General syntax 

```
Rscript vqa.R --mode MODE --project PROJ --assess ASSESS

```
* Options mode, project and assess are required
* Option mode determines the VQA program to run, and takes one of three values: 

  Mode value | Action
  ---------- | ---------- 
  import |  Import raw data and normalize to VQA input schema.
  vqa.batch |  Complete VQA analysis for a single assessment.
  qh.net |  Net Quality Hectares comparison of two or more assessments.


* Options project and assess correspond to parameters PROJ (project code) and ASSESS (assessment code)

Alternatively, you can use the following short option codes:

```
Rscript vqa.R -m MODE -p PROJ -a ASSESS

```

### Getting help:

```
Rscript vqa.R --h/--help
```

### Running vqa.R as a bash command:
Depending on your environment, you may be able to omit the call to Rscript and run vqa.R as a standard bash command as follows:

```
./vqa.R --mode MODE --project PROJ --assess ASSESS
```

To do so, you will need to make sure the controller command file vqa.R is executable:

```
chmod ug+x vqa.R
```

<a name="Examples"></a>
## Examples
* These VQA demonstration applications can be found inside the projects directory
* For more details, see the README inside the project directory of each demo.

### Example 1: VQA of a single assessment, using vqa-demo1

##### Import raw data

```
Rscript vqa.R -m import -p vqa-demo1 -a main_001_current
```

##### Run VQA analysis on a single assessment

```
Rscript vqa.R -m vqa.batch -p vqa-demo1 -a main_001_current

```

### Example 2: Offset Net Quality Hectares analysis, using vqa-demo2
* This example assumes that you have already run VQA for assessments offset_baseline and offset_current.
* Currently, you can only name the current assessment on the command line. You must set the name of the baseline assessment in the PSP file for the project. I will add the baseline assessment as a command line option in the near future.

```
Rscript vqa.R -m qh.net -p vqa-demo2 -a offset_current
```

* For more example VQA analyses, see the READMEs for both demonstration projects.

<a name="References"></a>
## References
    
2. Boyle, B.L., Franklin, W., Burton, A., Gullison, R.E., 2024. Vegetation Quality Assessment: a sampling-based, loss-gain accounting framework for native, disturbed and reclaimed vegetation. Ecol. Indic. 158, 111510. [https://doi.org/https://doi.org/10.1016/j.ecolind.2023.111510](#https://doi.org/https://doi.org/10.1016/j.ecolind.2023.111510)

1. Boyle, B. L., R. E. Gullison, D. J. Vasiga, G. L. Luini, and W. F. Franklin. 2018. Vegetation Quality Assessment: Measuring Quality of Vegetation Communities to Support the Accounting Metrics of the Biodiversity Vision of Net Positive Impact for a Large-Scale Mining Operation. Page 41st Annual TRCR Mine Reclamation Symposium. The University of British Columbia, Fort Williams, BC, Canada.

