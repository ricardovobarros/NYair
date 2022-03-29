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
library(leaflet)

# get data from git 
# data = read.csv("https://raw.githubusercontent.com/ricardovobarros/NYair/main/ny_pollutants.csv")


# display loading settings
options(spinner.color="#0275D8", spinner.color.background="#ffffff", spinner.size=2)

# application UI 
ui <- fluidPage(
  theme = bs_theme(bootswatch = "darkly"),
  navbarPage(
    "NYair",
    tabPanel(
      "Neighborhood Map",
      wellPanel(
        "Input Panel",
        dateRangeInput(
          "daterangenei",
          "Date Range",
          start = "1990-01-01",
          end = "2020-01-01",
          max = "2020-01-01",
          min = "1990-01-01",
          startview = "decade"
        ),
        selectInput(
          "pollutantnei",
          "Pollutant",
          c(
            "Carbon Monoxide [ppm]" = "co",
            "Ozone [ppm]" = "o3",
            "Nitrogen dioxide [ppb]" = "no2",
            "Sulfur dioxide [ppb]" = "so2"
          )
        ),
        actionButton("updatemapnei",
                     "Update map")
        
      ),
      
      withSpinner(plotlyOutput("neimap"),
                  type = 1)
      
    ),
    tabPanel(
      "Monitors Map",
      wellPanel(
        "Input Panel",
        selectInput(
          "pollutantmon",
          "Pollutant",
          c(
            "Carbon Monoxide [ppm]" = "co",
            "Ozone [ppm]" = "o3",
            "Nitrogen dioxide [ppb]" = "no2",
            "Sulfur dioxide [ppb]" = "so2"
          )
          
        ),
        actionButton("updatemapmon",
                     "Update map")
        
      ),
      withSpinner(leafletOutput("monmap"),
                  type = 1)
      
    
  ),
  tabPanel(
    "About",
    # titlePanel("About"),
    includeMarkdown("about.md")
  ))
  
  
)
                           
                    
                


# Define server logic required to draw a histogram
server <- function(input, output) {
  
  #generate neimap
  df = reactive({
    parameter_to_key(data.frame(read_csv("ny_pollutants.csv",
                                         show_col_types = FALSE)))
  })

  # generate neighbor map
  output$neimap = renderPlotly({
    if (input$updatemapnei>0) { 
      isolate(generate_neimap(df(),
                              input$daterangenei,
                              input$pollutantnei
                              )
              ) 
    }
  })
  
    # generate monitors map
    output$monmap = renderLeaflet({
      if (input$updatemapmon>0) {
        isolate(generate_monmap(df(),
                                input$pollutantmon
               )
        )
      }

    })
    
    # # generate monitors map
    # output$monmap = renderUI({
    #     includeHTML("maps/ozone_analyse.html")
    # 
    #   
    # })
    # 
    
    #-------------------- print stuff
    # generate_neimap(
    #   data,
    #   isolate(input$datarangenei),
    #   isolate(input$poluttantnei),
    #   input$updatemapnei,
    #   
    # )

  
    observeEvent(input$updatemapnei,
                 print(input$daterangenei)
    )
    observeEvent(input$updatemapnei,
                 print(input$daterangenei[1])
    )
    observeEvent(input$updatemapnei,
                 print(input$daterangenei[2])
    )
    observeEvent(input$updatemapmon,
                 print(input$pollutantmon)
    )
    observeEvent(input$updatemapnei,
                 print(str(data()))
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
