###############################################################################
## LabelFCSChannels version 3.0.2-Shiny
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
## R 3.2.0, flowCore 1.34.0., shiny 0.12.1
###############################################################################

library("shiny")

shinyUI(fluidPage(
    titlePanel("Label FCS Channels, Version 3.0.2-Shiny"),
    sidebarLayout(
        sidebarPanel(
            fileInput('labels_file', 'Choose Labels File', accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
            conditionalPanel(
                condition = "output.labelsUploaded",
                tags$p(style="color:red;", "Select FCS files from a corresponding panel only!"),
                fileInput('fcs_file', 'Choose FCS File(s)', multiple = TRUE, accept=c('application/vnd.isac.fcs')),
                textInput('addSuffix', label = 'Labelled FCS file suffix', value = ".labelled")
            ),
            tags$hr(),
            conditionalPanel(
                condition = "output.fcsUploaded",
                tags$i(textOutput("tempDirMessage")),
                tags$br(),
                downloadButton('downloadData', 'Label and download FCS file(s)')
            )
        ),
        mainPanel(
            conditionalPanel(
                condition = "output.labelsUploaded",
                tags$h4("You will be applying the following labels:")
            ),
            tableOutput('contents')
        )
    )
))

