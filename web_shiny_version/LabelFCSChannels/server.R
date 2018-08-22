###############################################################################
## LabelFCSChannels version 3.0.1-Shiny
## September 9, 2015
## This tool allows you to label channels (parameters) in an FCS list mode 
## data file based on externally supplied labels.
###############################################################################

###############################################################################
## Copyright (c) 2015 Josef Spidlen, Ph.D.
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
## R 3.2.0, flowCore 1.34.0., shiny 0.12.1
###############################################################################

library("shiny")
library("methods")
library("utils")

use_LMD_dataset_number <- 2

## This tool requires the flowCore library
if (!require("flowCore")) {
    cat("flowCore library not present, trying to install flowCore\n")
    source("http://bioconductor.org/biocLite.R")
    biocLite("flowCore")
    if (require("flowCore")) {
        cat("flowCore library installed successfully\n")
    } else {
        stop("Failed to install the flowCore library, please try installing flowCore manually and try again.", call. = FALSE)
    }
}

# Setting the maximum request size to 1 GB
# This limits the size of the FCS file(s) that can be uploaded
# Default was 5MB, which is not enough for us.
options(shiny.maxRequestSize=1000*1024^2) 

writeOutput <- function(what, file) {
    if (is(what, "flowFrame")) suppressWarnings(write.FCS(what, file))
    else {
        if (length(list.files(what)) == 0) {
            stop("Sorry, these files have been downloaded already. Please go back and select different FCS files for processing.")
        } else {
            current_wd <- getwd()
            setwd(what)
            zip(file, list.files())
            #file.remove(list.files())
            setwd(current_wd)
            #file.remove(what)
            ## It would be good to remove those files, but we cannot do that
            ## as we don't know for sure whether the user may click on the
            ## download button again. If no user input is changed, then this
            ## will result in executing this function directly without running
            ## the code that would reproduce the results.
        }
    }
}

createSmartFileName <- function(fcs_file, labels_file, suffix) {
    if (nrow(fcs_file) > 1)
        paste("Files labelled with ", sub("[.][^.]*$", "", labels_file$name), ".zip", sep = '')
    else {
        paste(sub("[.][^.]*$", "", fcs_file$name), suffix, '.fcs', sep='')
    }
}

labelFlowFrame <- function(inputFcs, labels) {
    
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
        }
        
    }
    
    return(inputFcs)
}

shinyServer(function(input, output) {
    
    output$contents <- renderTable({
        labelsFile <- input$labels_file
        if (is.null(labelsFile)) return(NULL)
        labels <- read.csv(labelsFile$datapath, header = TRUE, sep = "\t")
        if (!("Parameter" %in% colnames(labels))) {
            cat("Parameter column not found in the labels file; cannot work without it. Please see instructions on how to create a labelling template.\n")
            return(NULL)
        } 
        if ((!("Name" %in% colnames(labels)) && (!("Label" %in% colnames(labels)))))  {
            cat("Neither Name nor Label column found in the labels file; need at least one of those to know how to re-name or re-label parameters. Please see instructions on how to create a labelling template.\n")
            return(NULL)
        }
        read.csv(labelsFile$datapath, header=TRUE, sep='\t')
    })
    
    labelsSelected <- reactive({
        if (is.null(input$labels_file)) return(NULL)
        labels <- read.csv(input$labels_file$datapath, header = TRUE, sep = "\t")
        if (!("Parameter" %in% colnames(labels))) return(NULL)
        if ((!("Name" %in% colnames(labels)) && (!("Label" %in% colnames(labels)))))  return(NULL)
        return(TRUE)
    })
    
    fcsAlsoSelected <- reactive({
        if (is.null(input$fcs_file) || is.null(input$labels_file)) return(NULL)
        return(TRUE)
    })
    
    processFCS <- reactive({
        
        if (is.null(input$fcs_file) || is.null(input$labels_file)) return(NULL)
        
        labels <- read.table(input$labels_file$datapath, header = TRUE, sep = "\t")
        
        if (nrow(input$fcs_file) == 1) {
            if (nchar(input$fcs_file$name) > 4 && (substring(input$fcs_file$name, nchar(input$fcs_file$name)-3) == ".LMD" || substring(input$fcs_file$name, nchar(input$fcs_file$name)-3) == ".lmd"))
                inputFcs <- read.FCS(input$fcs_file$datapath, transformation = FALSE, dataset = use_LMD_dataset_number)
            else
                inputFcs <- read.FCS(input$fcs_file$datapath, transformation = FALSE)
            return(labelFlowFrame(inputFcs, labels))
        } else {
            outDir <- tempfile()
            dir.create(outDir)
            by(input$fcs_file, 1:nrow(input$fcs_file), function(row) {
                
                if (nchar(row$name) > 4 && (substring(row$name, nchar(row$name)-3) == ".LMD" || substring(row$name, nchar(row$name)-3) == ".lmd"))
                    inputFcs <- read.FCS(row$datapath, transformation = FALSE, dataset = use_LMD_dataset_number)
                else
                    inputFcs <- read.FCS(row$datapath, transformation = FALSE)
                
                inputFcs <- labelFlowFrame(inputFcs, labels)
                suppressWarnings(write.FCS(inputFcs, file.path(outDir, 
                    paste(sub("[.][^.]*$", "", row$name), input$addSuffix, '.fcs', sep=''))))
                rm(inputFcs)
            })
            return(outDir)
        }
    })
    
    output$labelsUploaded <- reactive({
        return(!is.null(labelsSelected()))
    })
    
    output$fcsUploaded <- reactive({
        return(!is.null(fcsAlsoSelected()))
    })
    
    output$downloadData <- downloadHandler(
        filename = function() {
            createSmartFileName(input$fcs_file, input$labels_file, input$addSuffix)
        },
        content = function(file) {
            writeOutput(processFCS(), file)
        }
    )
    
    output$tempDirMessage <- renderText({ 
        paste("Server working directory is", tempdir())
    })
    
    outputOptions(output, 'labelsUploaded', suspendWhenHidden=FALSE)
    outputOptions(output, 'fcsUploaded', suspendWhenHidden=FALSE)
})

