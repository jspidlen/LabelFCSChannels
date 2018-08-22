# Label FCS Channels Version 3.0.2

The *Label FCS Channels* tool allows you to label channels (parameters) in an FCS 2.0, FCS 3.0 or FCS 3.1 list mode data file. Labelling means adding or rewriting the values of parameter names, i.e., values of the $PnS and $PnN FCS keywords ([see FCS format](http://www.ncbi.nlm.nih.gov/pubmed/19937951)) based on externally supplied labels and names. Rewriting $PnN keyword values is a new functionality that has been added in version 3.0 of this tool. Labels and names are provided in text file templates (see below). This tool is intended to be used post-acquisition to standardize the FCS channel description of IMPC acquired flow cytometry data, but can be applied on other FCS data files as well.

There are two kinds of parameter names in FCS data files:

1. Short names (values of **$PnN** keywords). Those are required to be present and unique among all parameters within the FCS data file as they are also used for parameter indexing purposes (e.g., in the spillover matrix for proper compensation). Historically, those have been "useless" identifiers, such as FL1-A, FL2-A, FL3-A, etc. While this tool can be used to assign any $PnN name, you may want to consider following Mario Roederer's proposal for unified flow cytometer parameter naming ([Cytometry A, 2015, 87(8), 689-691](http://onlinelibrary.wiley.com/doi/10.1002/cyto.a.22670/abstract)), which reveals some additional information about the cytometer configuration, such as the laser type and the peak filer wavelength for each of the FCS parameters.
1. Long names (values of **$PnS** keywords). Those are supposed to be more meaningful descriptions (labels). We intend to fill out the marker and fluorochrome information in $PnS keyword values.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

This tools requires *R 3.2.0* and the *flowCore* library, version 1.34.0. Other versions of R and flowCore may also work but have not been tested. In addition, the web-based version of the tool requires the *shiny* library (tested with version 0.12.1), and the non-web-based version of the tool requires the *svDialogs* library (tested with version 0.9-57) if used in an interactive mode (see Usage below). Version 3.0.1 of this tool is not compatible with the flowCore 1.46.0 and newer package; this has been resolved in a version 3.0.2.


### Installation

1. Download and install R, follow instructions at [http://www.r-project.org/](http://www.r-project.org/)
1. Install the required R libraries (flowCore, svDialogs and shiny). To install these libraries, start
your R console and enter:

```R
source("http://bioconductor.org/biocLite.R")
biocLite("flowCore")
biocLite("svDialogs")
biocLite("shiny")
```

*Note*: It is recommended to install all the libraries although svDialogs is only required for the non-web version in interactive mode, and shiny is only required for the web version of the tool.

Clone or download and extract a zip with this project.

## Usage

There are two versions of the *Label FCS Channels* tool: a web-based version and a non-web-based version. They both include the same functionality, but they are used differently. Most users will likely prefer the web-based version as prettier and easier to use. The non-web-based option may be more suitable for a high-throughput setting.

### Web-based Version, Interactive Mode

Start the tool as follows:

1. Open your R console (R 3.2.0 recommended, libraries flowCore and shiny have to be installed, see Installation section above for instruction on how to install R and the required libraries)
1. Enter
```R
library("shiny")
runApp("path/to/Label FCS Channels/web_shiny_version/LabelFCSChannels")
```
where **path/to/Label FCS Channels/web_shiny_version/LabelFCSChannels** is the actual path to the directory with the web version of the Label FCS Channels tool. There are two files in this directory, *server.R* and *ui.R*. The exact location depends on where you have extracted the provided LabelFCSChannels.zip file during installation. This will start the tool and print a local URL that it is listening on as shown below.

![Start Shiny App](images/screen1.png)

In this example, the tool is listening on http://127.0.0.1:3803. Your URL address may be different. With most computers, the tool will automatically open your default web browser on the corresponding page. If that does not happen, open your web browser and copy and paste the address to the address bar. You should see a page similar to the one shown below. Now you can start using the tool.

![Web based version opened](images/screen2.png)

1. Choose your labels file by clicking on the Browse... button and selecting your file in the file open dialogue. Label files are panel-specific templates of how FCS channels will be described. Selecting a labels file will “upload it” and show you the labels that you are going to apply.
1. The page will change to include additional controls as shown below.
1. Similary, select one or more FCS files from a panel that corresponds to the previously selected labels. You can select all files in a directory by clicking on the first file, holding down the Shift key and then clicking on the last file. Selecting over 300 MB of FCS files is not recommended.
1. The “Labelled FCS file suffix” (.labelled by default) determines how labelled FCS files will be named. For example, a labelled version of file P1x12.fcs will be named P1x12.labelled.fcs if the default suffix is used. The .fcs file extension is always added. You can delete the value in the “Labelled FCS file suffix” text field if you want to keep the original file names. This will not rewrite your input files.
1. The nature of a web-based tool implies that the tool cannot delete all temporary files used during its operation. Therefore, we are displaying a temporary directory where data processing is taking place. On most computers, these directories will eventually get deleted automatically by the operating system, but if you are concerned about the space on your drive, you may want to manually delete the contents of this directory after you finish working with the tool.
1. Finally, click on the “Label and download FCS file(s)” button. If you have selected only a single FCS file to be labelled, the tool will send a labelled FCS file to your web browser. Some browsers will give you the option to either open or save the file, and you will either be prompted for the location where to save the files, or the file will be placed to your “Downloads” by default. If you have selected more than one FCS file to be labelled, the tool will send you a ZIP file with labelled FCS files. Consequently, you will need to unzip the files once saved from your browser. In addition, please note that labelling and zipping the result files may take some time. Based on our testing, labelling and zipping 5 FCS files (150 MB of data) took about 10 to 20 seconds depending on which computer was used. Please exercise patience and wait for the labelling and zipping to finish if you are planning to submit a larger amount of files at once.
1. In order to label additional files, simply change the labels file (upload new labels file), upload new FCS files and click on the “Label and download FCS file(s)” button again.
1. Once you are finished, shut down the tool by pressing Ctrl+C in your R console (or press the stop button or just close R). The browser window will turn grey. You may also close the browser window. Note that simply closing the browser window will not shut down the tool within R.


![Web based version labels loaded](images/screen3.png)
![Web based version data loaded](images/screen4.png)

### Non-web-based Version, Interactive Mode

Start the tool as follows:

1. Open your R console (R 3.2.0 recommended) with flowCore and svDialogs installed (see Installation section above for instruction on how to install R and the required libraries)
1. Enter  ``source("path/to/Label FCS Channels/non_web_version/LabelFCSChannels.R")`` where path/to/Label FCS Channels/non_web_version/LabelFCSChannels.R is the actual path to the LabelFCSChannels.R file (i.e., where you have extracted it from the provided ZIP file, or clone from git.
1. A file open dialogue asking you to “Select your labels file” will pop-up. Depending on your panel, select one of the provided labels file or your own labels file (see below).
1. Once a label file is selected, another file open dialogue opens asking you to “Select your input FCS file directory”. Select the **directory** with FCS file you would like to add labels to. It is very important that all files in that directory correspond to the right panel based on the chosen labels! The directory is not processed recursively, i.e., the files need to be in the input directory directly, not in any sub-directory of the input directory.
1. After the input FCS file directory is selected, a final dialogue window will open and ask for the location where to save the labelled FCS files.
1. Once the output directory is provided, the tool will label the channels in the input FCS files and save the resulting FCS files. By default, a ``.labelled`` suffix will be added to the file names. For example, a labelled version of file ``P1x12.fcs`` will be named ``P1x12.labelled.fcs``. The ``.fcs`` file extension is always added. Should you prefer a different (or no) suffix, you could edit the ``LabelFCSChannels.R`` file and change the labelled_FCS_file_suffix variable at the beginning of the file.
1. Next, you may quit R by entering ``quit()`` or repeat the process from Step 2 in order to label additional FCS files.

### Non-web-based Version, Non-interactive Mode

The LabelFCSChannels tool can be run from a command line using Rscript and providing all arguments on the command line as follows:

```R
Rscript path/to/Label FCS Channels/non_web_version/LabelFCSChannels.R -­l <labels.txt> -­i <input.directory> -­o <output.directory>
```
where
*  ``Rscript`` has to be on your path, or full path to ``Rscript`` needs to be provided. Generally, ``Rscript`` is part of an R installation.
*  ``path/to/Label FCS Channels/non_web_version/LabelFCSChannels.R`` is the actual path to the ``LabelFCSChannels.R`` file.
*  ``<labels.txt>`` is a path to the labels file to be used
*  ``<input.directory>`` is a path to the directory with input FCS files that should be labelled; all the FCS files in that directory shall be from the same panel corresponding to the selected labels. The directory is not processed recursively, i.e., the FCS files need to be in the input directory directly, not in any sub-directory of the input directory.
* ``<output.directory>`` is the path to the directory where output (labelled) FCS file will be saved. By default, a ``.labelled`` suffix will be added to the output file names. For example, a labelled version of file ``P1x12.fcs`` will be named ``P1x12.labelled.fcs``. The ``.fcs`` file extension is always added. Should you prefer a different (or no) suffix, you could edit the ``LabelFCSChannels.R`` file and change the ``labelled_FCS_file_suffix`` variable at the beginning of the file.

The order of the labels, input and output arguments is not important as long as they are all provided and labels are prefixed with ­l, input FCS file directory with ­i and the output FCS file directory with ­o.

### Which Version to Use?

The web-based version provides a nicer user interface than the non-web based version and it is likely the preferred way of using the Label FCS Channels tool for many users. However, compared to the non-web-based version, there are a few potential limitations resulting from the web-based character. In the web-based version, the tool is running as a “server” on your computer, and your web browser is used as a client providing the user interface. The server does not have direct access to the input FCS files. Instead, those files must be “uploaded” to the server using the web browser. In practise, the upload will only create a local copy of the input files, so it should not create a significant performance bottleneck, but there will be multiple copies of the input files occupying your drive (some of the uploaded and labelled files may also keep occupying the temporary folders on your computer after the tool is finished). Once the files are labelled, the server cannot serve more than a single file as the result of a download request submitted by the browser. Therefore, the tool will zip the labelled FCS files and send those back to the browser. The zipping part will add time to processing the request and therefore, we do not recommend adding “too many” FCS files at once using the web-based version. While the non-web-based version is not as user friendly, there is virtually no limit to how many files you can label at once.

## Labelling Templates

The provided labelling templates .txt files in the ``example_labels`` directory can be used as examples and adapted, or new labelling .txt files can be created provided the file format remains consistent. The labelling templates .txt files are tab-separated text files with 2 or 3 columns. The first row shall include headings, such as ``Parameter``, ``Label`` and/or ``Name``. FCS channels (a.k.a FCS parameters) are labelled by matching the value of the Parameter column with the short name of the FCS parameter (i.e, the value of the *$PnN* keyword) and then using the value from the ``Label`` column to assign the parameter label (i.e., the value of the *$PnS* keyword) and the value from the ``Name`` column to assign a new parameter name (i.e., the value of the *$PnN* keyword). If you want the tool to be assigning both parameter names (*$PnN*) and labels (*$PnS*), then all 3 columns need to be present. If you don't want to be assigning parameter names (*$PnN*) then you can omit the ``Name`` column. If you don't want to be assigning parameter labels (*$PnS*) then you can omit the ``Label`` column. In all cases, the ``Parameter`` column shall be present and at least one of the ``Name`` or ``Label`` shall be present.

If an incorrectly formatted labels file is loaded then the tool will not allow you to proceed with labelling, and an appropriate error message will be displayed in the R console (e.g., ``Parameter column not found in the labels file; cannot work without it. Please see instructions on how to create a labelling template``).
Even if you use all 3 columns, the values and/or new names for particular parameters are optional. If no label is provided or a parameter match is not found, then the parameter short name (i.e., the value of the *$PnN* keyword) is used to label the parameter (i.e., the value of the *$PnN* keyword is copied to the value of *$PnS* keyword). This may be useful for forward and side scatter parameters as well as for the Time parameter.


## Troubleshooting

### Compatibility Notes
The Label FCS Channels tool is compatible with Linux, (Mac) OS X and Windows. The web-based version requires the presence of an an external ZIP tool on your command path. A compatible zip tool is “guaranteed” to be present in Linux, OS X and newer versions of Windows. If you have some older Windows (such as Windows XP), a zip tool may or may not be present. If it is not, you may have to install it first before being able to run the web-based version of this tool.

Version 3.0.1 of this tool is not compatible with the flowCore 1.46.0 and newer package. This has been resolved in version 3.0.2.

### Path to the Tool

The actual path to the tool depends on where you extracted the zip file with the tool provided. The syntax to write the path depends on the platform that you are using. For example, if you are using a Linux or a Mac computer and you extracted the zip on your desktop, the path to the web-based version may look like

```
/home/username/Desktop/Label FCS Channels/web_shiny_version/LabelFCSChannels
```

On a Windows computer, the same path would possibly look like

```
C://Users\\username\\Desktop\\Label FCS Channels\\web_shiny_version\\LabelFCSChannels
```

The ``\`` character often has a special meaning in scripting languages and therefore, the ``\\`` is used instead of ``\`` to escape the ``\`` character (i.e., to prevent R from invoking the special interpretation). You will likely need to use ``\\`` when providing your path to the R console under Windows.

## Frequently Asked Questions

### What is my path to the tool?

It depends on where you have extracted or clones it to. Also, see the Troubleshooting – Path to the Tool section above and note that you may have to use “\\” instead of “\” when providing your path to the R console under Windows. If your user name was Smith and you extracted the tool on your Desktop under Windows, then commonly, the path to provide to R in order to run the web-based version of the tool may be
```
C://Users\\Smith\\Desktop\\Label FCS Channels\\web_shiny_version\\LabelFCSChannels
```

### Does the tool work with RStudio?
Yes, you can use RStudio to run the tool if you prefer.

### How do I create additional labelling templates?
Please see the Labelling Templates section above. In summary, a template for each panel is a tab-separated text file with two or three columns, one corresponding to existing parameter names (*$PnN* values, required) and another one corresponding to new parameter names (new *$PnN* values, optional), and another one corresponding to new parameter labels (*$PnS* values, optional).

### If I have 20 parameters at acquisition, do I need to establish a list for all 20 parameters? 
No, only those that you want to label or rename using this tool.

### How do I get the parameter order?
You don't need it. The order is not important, the matching is done based on parameter names as explained above.

### Do I need the exact same spelling of the parameter name in my labelling template?
Yes, the spelling needs to be exact and it is considered case sensitive. If your parameter naming is inconsistent, then you could provide all variants in the template as separate “labelling rules” on separate lines. For example, if parameter "APC-Cy7-A" is sometimes called "APC-Cy7-A" and sometimes "APC.Cy7-A", but it should always be labelled as "CD62L APC-Cy7-A” and named as “R780-A”, then you could provide two lines in the template file as follows:

**Parameter** |  **Label** | **Name**
---------------- | ------------ | -----------
APC-Cy7-A | CD62L APC-Cy7-A | R780-A
APC.Cy7-A | CD62L APC-Cy7-A | R780-A

### If I change the $PnN names using this tool, won't it break other parts in the FCS file (e.g., the spillover matrix used for compensation and stored in the FCS file uses $PnN parameter names to reference FCS parameters).

This tool will update the values of the SPILL, $SPILLOVER, SPILLOVER and $TR keywords using the new parameter names, so the FCS file will remain consistent. These are the only places where $PnN values are being used based on the FCS data file standard and based on our experience with IMPC data. Having said that, please make sure your new FCS parameter names are unique (i.e., don't try to assign the same name to multiple different parameters or assign a name of another existing parameter to a different parameter). In addition, note that if you have saved existing Diva projects, FlowJo workspaces ets., then those will not be useable with the new FCS files once you rename the FCS parameters (i.e, Diva, FlowJo or other software will not be able to find the original FCS parameters in the new FCS files).

## Author

**Josef Spidlen**

## License

This tools is licensed under Apache License Version 2.0, see the [LICENSE](LICENSE) for details.

