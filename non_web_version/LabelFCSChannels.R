###############################################################################
## LabelFCSChannels version 3.0.2
## September 9, 2015 (version 3.0.1)
## August 22, 2018 (version 3.0.2 to add compatibility with new flowCore)
##
## This tool allows you to label channels (parameters) in an FCS list mode 
## data file based on externally supplied labels.
###############################################################################

###############################################################################
## Copyright (c) 2015-2018 Josef Spidlen, Ph.D.
##
## License
## The software is distributed under the terms of the 
## Artistic License 2.0
## http://www.r-project.org/Licenses/Artistic-2.0
## 
## Disclaimer
## This software and documentation come with no warranties of any kind.
## This software is provided "as is" and any express or implied 
## warranties, including, but not limited to, the implied warranties of
## merchantability and fitness for a particular purpose are disclaimed.
## In no event shall the  copyright holder be liable for any direct, 
## indirect, incidental, special, exemplary, or consequential damages
## (including but not limited to, procurement of substitute goods or 
## services; loss of use, data or profits; or business interruption)
## however caused and on any theory of liability, whether in contract,
## strict liability, or tort arising in any way out of the use of this 
## software.    
###############################################################################

###############################################################################
## Requirements:
## R 3.2.0, flowCore 1.34.0., svDialogs 0.9-57 (for interactive mode only)
###############################################################################

## This is needed, if we don't have it then let's fail right away
library("methods")

labelled_FCS_file_suffix <- ".labelled"
use_LMD_dataset_number <- 2

labelsFileName <- ""
inputFcsDirName <- ""
outputFcsDirName <- ""
whatIsNext <- 0

## Print Usage and Stop
printUsageAndStop <- function() {
    stop("Usage:\nRscript LabelFCSChannels.R -l <labels.txt> -i <input.directory> -o <output.directory>\nwhere\n <labels.txt> is a path to a tab-delimited Parameter/Label labels file\n <input.directory> is the input FCS directory path\n <output.directory> is the output FCS directory path\nCommand line arguments are required in non-interactive mode.", call. = FALSE)
}

labelFCSChannels <- function() {
    
    ## Try to parce command line arguments
    args <- commandArgs(trailingOnly = TRUE)
    for (arg in args) {
        if (whatIsNext == 0) {
            if (arg == '-l') whatIsNext <- 1
            else if (arg == '-i') whatIsNext <- 2
            else if (arg == '-o') whatIsNext <- 3
            else {
                cat("Error: Failed to parse the command line arguments.\n")
                printUsageAndStop()
            }
        } else {
            if (whatIsNext == 1) labelsFileName <- arg
            else if(whatIsNext == 2) inputFcsDirName <- arg
            else if(whatIsNext == 3) outputFcsDirName <- arg
            whatIsNext = 0
        }
    }
    
    ## If some or arguments were missing, we need the interactive mode and we will try to ask for those
    if ((labelsFileName == "") || (inputFcsDirName == "") || (outputFcsDirName == "")) {
        if(!interactive()) {
            cat("Error: We are not in an interactive mode, all arguments are required on the command line when executed in non interactive mode.\n")
            printUsageAndStop()
        }
        # This tool requires the svDialogs library unless options are specified on the command line
        if(!require("svDialogs")) {
            cat("svDialogs library not present, trying to install svDialogs\n")
            source("http://bioconductor.org/biocLite.R")
            biocLite("svDialogs")
            if(require("svDialogs")) {
                cat("svDialogs library installed successfully\n")
            } else {
                stop("Failed to install the svDialogs library, please try installing svDialogs manually and try again.", call. = FALSE)
            }
        }
    }
    
    ## This tool requires the flowCore library
    if(!require("flowCore")) {
        cat("flowCore library not present, trying to install flowCore\n")
        source("http://bioconductor.org/biocLite.R")
        biocLite("flowCore")
        if(require("flowCore")) {
            cat("flowCore library installed successfully\n")
        } else {
            stop("Failed to install the flowCore library, please try installing flowCore manually and try again.", call. = FALSE)
        }
    }
    
    ## If we are missing any of the input, then ask for it. If not provided, then stop.
    if (labelsFileName == "") {
        labelsFileName <- dlgOpen(title = "Select your labels file", filters = dlgFilters[c("txt", "All"), ])$res
        if ((length(labelsFileName) == 0) && (typeof(labelsFileName) == "character")) stop("You need to select a labels file.", call. = FALSE)
    }
    if (inputFcsDirName == "") {
        inputFcsDirName <- dlgDir(title = "Select your input FCS file directory", filters = dlgFilters["All", ])$res
        if ((length(inputFcsDirName) == 0) && (typeof(inputFcsDirName) == "character")) stop("You need to specify the input file name.", call. = FALSE)
    }
    if (outputFcsDirName == "") {
        default_out <- file.path(inputFcsDirName, "labelled")
        suppressWarnings(dir.create(default_out))
        outputFcsDirName <- dlgDir(default = default_out, title = "Save the output FCS files in", filters = dlgFilters["All", ])$res
        if ((length(outputFcsDirName) == 0) && (typeof(outputFcsDirName) == "character")) stop("You need to specify the output file name.", call. = FALSE)
    }
    
    ## Finally, now let's actually do the work, read labels, read FCS file, apply labels and save the file.
    labels <- read.table(labelsFileName, header = TRUE, sep = "\t")
    if (!("Parameter" %in% colnames(labels))) {
        stop("Parameter column not found in the labels file; cannot work without it. Please see instructions on how to create a labelling template.", call. = FALSE)
    } else {
        if ((!("Name" %in% colnames(labels)) && (!("Label" %in% colnames(labels)))))  {
            stop("Neither Name nor Label column found in the labels file; need at least one of those to know how to re-name or re-label parameters. Please see instructions on how to create a labelling template.", call. = FALSE)
        } else {
            for(inputFcsFileName in list.files(inputFcsDirName, include.dirs = FALSE)) {
                # Skipping directories
                if (file.info(file.path(inputFcsDirName, inputFcsFileName))$isdir) next
                
                inputFcs <- NULL
                if (nchar(inputFcsFileName) > 4 && (substring(inputFcsFileName, nchar(inputFcsFileName)-3) == ".LMD" || substring(inputFcsFileName, nchar(inputFcsFileName)-3) == ".lmd"))
                    try(inputFcs <- read.FCS(file.path(inputFcsDirName, inputFcsFileName), transformation = FALSE, dataset = use_LMD_dataset_number), silent = TRUE)
                else
                    try(inputFcs <- read.FCS(file.path(inputFcsDirName, inputFcsFileName), transformation = FALSE), silent = TRUE)
                
                if (is.null(inputFcs)) {
                    cat(paste(inputFcsFileName, "is not a valid FCS file, skipping.\n"))
                } else {
                    
                    ## Fix labels, names and some keywords.
                    for(i in 1:as.integer(inputFcs@description$'$PAR')) {
                        kwParName <- paste0('$P', i, 'N')
                        parName <- inputFcs@description[[kwParName]]
                        kwParLabel <- paste0('$P', i, 'S')
                        newName <- parName
                        
                        ## Are we supposed to fix $PnN values?
                        if ("Name" %in% colnames(labels)) {
                            newName <- as.character(labels[which(labels[,'Parameter'] == parName), 'Name'])
                            if (((length(newName) == 0) && (typeof(newName) == "character")) || (newName == "")) newName <- parName
                            ## Fix SPILL keyword
                            if ((!is.null(inputFcs@description[['SPILL']])) && (class(inputFcs@description[['SPILL']]) == "matrix"))
                                colnames(inputFcs@description[['SPILL']])[which(colnames(inputFcs@description[['SPILL']])==parName)] <- newName
                            ## Fix SPILLOVER keyword
                            if ((!is.null(inputFcs@description[['SPILLOVER']])) && (class(inputFcs@description[['SPILLOVER']]) == "matrix"))
                                colnames(inputFcs@description[['SPILLOVER']])[which(colnames(inputFcs@description[['SPILLOVER']])==parName)] <- newName
                            ## Fix $SPILLOVER keyword
                            if ((!is.null(inputFcs@description[['$SPILLOVER']])) && (class(inputFcs@description[['$SPILLOVER']]) == "matrix"))
                                colnames(inputFcs@description[['$SPILLOVER']])[which(colnames(inputFcs@description[['$SPILLOVER']])==parName)] <- newName
                            ## Fix $TR keyword
                            if ((!is.null(inputFcs@description[['$TR']])) && (typeof(inputFcs@description[['$TR']]) == "character"))
                                inputFcs@description[['$TR']] <- gsub(parName, newName, inputFcs@description[['$TR']], fixed=TRUE)
                            
                            inputFcs@description[[kwParName]] <- as.character(newName)
                            colnames(inputFcs)[which(colnames(inputFcs) == parName)] <- newName
                        }
                        
                        ## Are we supposed to fix $PnS values?
                        if ("Label" %in% colnames(labels)) {
                            newLabel <- as.character(labels[which(labels[,'Parameter'] == parName), 'Label'])
                            if (((length(newLabel) == 0) && (typeof(newLabel) == "character")) || (newLabel == "")) newLabel <- newName
                            inputFcs@description[[kwParLabel]] <- as.character(newLabel)
                            names(newLabel) <- newName
                            markernames(inputFcs) <- newLabel
                        }
                        
                    }
                    
                    ## Save the file
                    suppressWarnings(write.FCS(inputFcs, filename = file.path(outputFcsDirName, paste(sub("[.][^.]*$", "", inputFcsFileName), labelled_FCS_file_suffix, '.fcs', sep=''))))
                    cat(paste(inputFcsFileName, "processed.\n"))
                    rm(inputFcs)
                }
            }
        }
    }
}

labelFCSChannels()

