# Label FCS Channels Version 3.0.1

The *Label FCS Channels* tool allows you to label channels (parameters) in an FCS 2.0, FCS 3.0 or FCS 3.1 list mode data file. Labelling means adding or rewriting the values of parameter names, i.e., values of the $PnS and $PnN FCS keywords ([see FCS format](http://www.ncbi.nlm.nih.gov/pubmed/19937951)) based on externally supplied labels and names. Rewriting $PnN keyword values is a new functionality that has been added in version 3.0 of this tool. Labels and names are provided in text file templates (see below). This tool is intended to be used post-acquisition to standardize the FCS channel description of IMPC acquired flow cytometry data, but can be applied on other FCS data files as well.

There are two kinds of parameter names in FCS data files:

1. Short names (values of **$PnN** keywords). Those are required to be present and unique among all parameters within the FCS data file as they are also used for parameter indexing purposes (e.g., in the spillover matrix for proper compensation). Historically, those have been "useless" identifiers, such as FL1-A, FL2-A, FL3-A, etc. While this tool can be used to assign any $PnN name, you may want to consider following Mario Roederer's proposal for unified flow cytometer parameter naming ([Cytometry A, 2015, 87(8), 689-691](http://onlinelibrary.wiley.com/doi/10.1002/cyto.a.22670/abstract)), which reveals some additional information about the cytometer configuration, such as the laser type and the peak filer wavelength for each of the FCS parameters.
1. Long names (values of **$PnS** keywords). Those are supposed to be more meaningful descriptions (labels). We intend to fill out the marker and fluorochrome information in $PnS keyword values.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

This tools requires *R 3.2.0* and the *flowCore* library, version 1.34.0. Other versions of R and flowCore may also work but have not been tested. In addition, the web-based version of the tool requires the *shiny* library (tested with version 0.12.1), and the non-web-based version of the tool requires the *svDialogs* library (tested with version 0.9-57) if used in an interactive mode (see Usage below).

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
runApp("path/to/Label FCS Channels/web_shiny_version/LabelFCSChannels"
```
where **path/to/Label FCS Channels/web_shiny_version/LabelFCSChannels** is the actual path to the directory with the web version of the Label FCS Channels tool. There are two files in this directory, *server.R* and *ui.R*. The exact location depends on where you have extracted the provided LabelFCSChannels.zip file during installation. This will start the tool and print a local URL that it is listening on as shown below.

![Start Shiny Version](images/screen1.png)


## Author

**Josef Spidlen**

## License

This tools is licensed under Apache License Version 2.0, see the [LICENSE](LICENSE) for details.

