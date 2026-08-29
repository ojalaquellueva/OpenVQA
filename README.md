# Vegetation Quality Assessment (VQA)

VQA is a R language data analysis pipeline for estimating quality and quality hectares of reclaimed vegetation relative to undisturbed native vegetation.

## Contents

- [What is VQA?](#What-VQA)  
- [Dependencies](#Dependencies)  
- [Installation & setup](#Installation-setup)  
- [Usage](#Usage)  
- [Examples](#Examples)  
- [References](#References)  

<a name="What-VQA"></a>
## What is VQA?

Vegetation Quality Assessment (VQA) is an application for estimating condition (quality) of reclaimed vegetation relative to undisturbed native vegetation, and quantifying negative and positive impacts on biodiversity in terms of quality hectares. VQA is also a loss-gain accounting workflow encompassing experimental design, field sampling, preparation of GIS inputs, statistical analysis, and reporting. 

### What is quality?

Quality (Q) is an index of similarity to a benchmark of undisturbed native vegetation. Q varies between 0 (no similarity) and 1 (identical). Don’t get too hung up on the word “quality”. In the context of VQA, quality is simply shorthand for “statistical similarity to natural, undisturbed vegetation”. Restored vegetation with a quality of 1 is statistically indistinguishable (by field sampling and VQA analysis) from pristine native vegetation. 

### What are quality hectares?

In addition to its use as a standalone measure of restoration progress, Q is also a discount factor used to convert actual hectares (Ha) to quality hectares (QH), where QH = Ha * Q (i.e., quality-discounted area). 

QH is commonly  using in loss-gain accounting as a standardized unit of comparison for balancing ecosystem losses due to industrial impacts against gains due to restoration and averted losses. QH can be used to track progress to a Net Positive Impact (NPI), the point at which current QH equals baseline QH (the QH of undisturbed native vegetation present prior to project impacts). Loss-gain accounting based on QH has a long history of use in industry, where it also known as habitat hectares. VQA is simply a more recent, rigorous implementation of quality hectares and habitat hectares.

### What is Net Quality Hectares?

Net Quality Hectares (QH.net), a critical measure of progress to No Net Loss (NNL) and Net Positive Impact (NPI), is the difference between current QH and baseline QH. NPI is reached when QH.net>0.

### Where can I learn more?

You can read more about VQA in detail in this open access [publication](https://www.sciencedirect.com/science/article/pii/S1470160X23016527). 

<a name="Dependencies"></a>
## Dependencies
* R >= 4.4.3   
* Multiple R packages (see script `libraries.R` for details)  

<a name="Installation-setup"></a>
## Installation & setup
* All commands below are shell commands run from from a terminal application on a Linux or Mac (OSX) machine, or from the RStudio terminal window.

#### Create the VQA base directory  
* This will hold all application components: code, configuration files, data and results

```
mkdir vqa
```

#### Clone the main VQA source code directory from GitHub
* Copy the OpenVQA zip file from GitHub
* Repo is here: [https://github.com/ojalaquellueva/OpenVQA](https://github.com/ojalaquellueva/OpenVQA). Specific releases are available here: [https://github.com/ojalaquellueva/OpenVQA/releases/](https://github.com/ojalaquellueva/OpenVQA/releases/)
* Unzip the archive inside directory vqa. It will unzip inside new folder which will be named something like "OpenVQA-<RELEASE_NUMBER>". This is now the VQA source code directory
* Rename it to "src/" or similar to help distinguish it from "vqa/", the application base directory.
* At this point, you should be able to run one of the demo application, say, vqa-demo1, buy running the following commands from the shell or the RStudio Terminal tab:

```
Rscript vqa.R --mode import --project vqa-demo1 --assess main_001_current 
```

and

```
Rscript vqa.R --mode vqa.batch --project vqa-demo1 --assess main_001_current 
```
However, read on to learn how you should move and structure you project (data) directory before continuing.

<a name="Set up the projects directory"></a>
## Set up the projects directory

All data, as well as parameters and custom import scripts specific to a particular application, are stored in directory `projects/`. An example projects directory containing demonstration applications and data is included in the VQA repository. We recommend you move or copy this directory *outside* the source code directory, at the same level as the the vqa code directory. Building on the recommend setup discussed above, the high-level configuration of your vqa code and data would be as follows:

```
vqa/            [Application base directory]
 |__ projects/  [Projects directory: all data and project-specific scripts]
 |__ src/       [VQA code directory: all application code]

```

The basic project directory must be structured as follows:

```
projects/                        [projects directory]
 |__ proj1/                      [project directory]
 |   |__ data/                   [data directory]
 |   |   |__ proj1/              [project data directory]
 |   |       |__ assess1/        [assessment directory]
 |   |       |__ assess2/        [assessment directory]
 |   |       |__ raw/            [raw data directory]
 |   |__ import/                 [project-specific import directory]
 |   |     |__ import.proj1.R    [project-specific import script]
 |   |__ params/                 [project-specific parameters directory]
 |         |__ params.proj1.R    [project-specific import script]
 |__ proj2/  [other projects: same schema as proj1]

```
* In the above structure diagram "proj1" and "proj2" are project codes, represented by parameter PROJ in the VQA code. "assess1" and "assess2" are assessment codes, represented by parameter ASSESS in the VQA code. Both are extremely important. You can call your projects and assessments whatever you want as long as they are unique and don’t include spaces. 
* Note that PROJ is also embedded in the names of the project-specific parameters file (params.proj1.R) and the project-specific import file (import.proj1.R). This naming convention is extremely important. Please stick to it.
* Finally, all the other directories (projects, data, raw, import, params) should be spelled exactly as shown.

### How Does VQA find my data?

VQA will know where to find your data as long as:

1. You structure your projects directory correctly (see above),
2. You keep the project directory in one of the two supported locations (inside the VQA code directory or one level up in the application base directory (the preferred location),
3. You use the correct project and assessment codes

<a name="Usage"></a>
## Usage

### General syntax
* VQA must be run from the command line, either the Terminal application in Linux & Mac OSX, or the RStudio Terminal tab (**not** the Console) in all operating systems.
* After installing VQA, 

```
Rscript vqa.R --mode MODE --project PROJ --assess ASSESS

```
* Options mode, project and assess are all required
* Option mode determines the VQA program to run, and takes on of three values: "import" (import raw data and normalize to VQA input schema), "vqa.batch" (complete VQA analysis of a single assessment) and "qh.net" (Net Quality Hectares analysis of multiple assessments)
* Options project and assess correspond to parameters PROJ (the project code) and ASSESS (the code of an assessment in project PROJ)

Alternatively, you can use short option codes:

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
* This example assumes that you have already completed the VQA analysis of assessments offset_baseline and offset_current.
* Currently, you can only name the current assessment on the command line. You must set the name of the baseline assessment in the PSP file for the project. I will add the baseline assessment as a command line option in the near future.

```
Rscript vqa.R -m qh.net -p vqa-demo2 -a offset_current
```

<a name="References"></a>
## References
    
2. Boyle, B.L., Franklin, W., Burton, A., Gullison, R.E., 2024. Vegetation Quality Assessment: a sampling-based, loss-gain accounting framework for native, disturbed and reclaimed vegetation. Ecol. Indic. 158, 111510. [https://doi.org/https://doi.org/10.1016/j.ecolind.2023.111510](#https://doi.org/https://doi.org/10.1016/j.ecolind.2023.111510)

1. Boyle, B. L., R. E. Gullison, D. J. Vasiga, G. L. Luini, and W. F. Franklin. 2018. Vegetation Quality Assessment: Measuring Quality of Vegetation Communities to Support the Accounting Metrics of the Biodiversity Vision of Net Positive Impact for a Large-Scale Mining Operation. Page 41st Annual TRCR Mine Reclamation Symposium. The University of British Columbia, Fort Williams, BC, Canada.

