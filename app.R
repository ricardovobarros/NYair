library(shiny)
library(bslib)
source("utils.R")
library(geojsonio)
library(sp)
library(broom)
library(geosphere)
library(plotly)
library(rjson)
library(shinycssloaders)
library(readr)
library(data.table)
library(ggplot2)
library(dplyr)
library(stringr)
library(gridExtra)
library(scales)
library(pivottabler)
library(tidyr)

# get data from git 
# data = read.csv("https://raw.githubusercontent.com/ricardovobarros/NYair/main/ny_pollutants.csv")


# display loading settings
options(spinner.color="#0275D8", spinner.color.background="#ffffff", spinner.size=2)

# application UI 
ui <- fluidPage(theme = bs_theme(bootswatch = "darkly"),
                navbarPage("NYair",
                           tabPanel("Neighborhood Map",
                                    wellPanel("Input Panel",
                                              dateRangeInput("datarangenei",
                                                             "Date Range"
                                              ),
                                              selectInput("poluttantnei",
                                                          "Pollutant",
                                                          c("Carbon Monoxide" = "co",
                                                            "Ozone" = "o3",
                                                            "Nitrogen dioxide"= "no2",
                                                            "Sulfur dioxide" = "so2")
                                              ),
                                              actionButton("updatemapnei",
                                                           "Update map"
                                              )
                                                                  
                                    ),
                      
                                    withSpinner(plotlyOutput("neimap"),
                                                type=1
                                    )
                          
                            )))
                           
                    
                


# Define server logic required to draw a histogram
server <- function(input, output) {
  
  #generate neimap
  df = reactive({
    data.frame(read_csv("ny_pollutants.csv",  show_col_types = FALSE))
  })
  
  neimap = reactive({
    generate_neimap(df())
  })


  # generate neighbor map
  output$neimap = renderPlotly({
    if (input$updatemapnei>0) { 
      isolate(neimap()) 
    } 
    # generate_neimap(
    #   data,
    #   isolate(input$datarangenei),
    #   isolate(input$poluttantnei),
    #   input$updatemapnei,
    #   
    # )
    })
  
    observeEvent(input$updatemapnei,
                 print(input$datarangenei)
    )
    observeEvent(input$updatemapnei,
                 print(input$datarangenei[1])
    )
    observeEvent(input$updatemapnei,
                 print(input$poluttantnei)
    )
    # observeEvent(input$updatemapnei,
    #              print(class(generate_neimap(
    #                data,
    #                isolate(input$datarangenei),
    #                isolate(input$poluttantnei),
    #                input$updatemapnei,
    #                
    #              ))))
    # 


}
# Run the application 
shinyApp(ui = ui, server = server)
