# Included scripts that summarize VQA results at end of VQA pipeline

The following scripts are sourced by `vqa.summary.R`:

***1. vqa.summary.csv.R***  
* Dumps indicator, functional group and overall quality & QH summaries to three separate CSV files  

***3. vqa.summary.xl.R***  
* Generates formatted Excel workbook summarizing VQA results. Converts indicator, functional group and overall quality CSV files into sheets within the Excel file, plus additional metadata tabs.