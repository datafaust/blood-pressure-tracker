#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)

# initalize credentials
source("init_credentials.R")

# source modules
source("data_input_module.R")

# Define UI for application that draws a histogram
ui <- shinymanager::secure_app(
  shinyUI(
    uiOutput("ui")
  )
)
 
# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # call the server part
  # check_credentials returns a function to authenticate users
  res_auth <- shinymanager::secure_server(
    check_credentials = shinymanager::check_credentials(credentials)
  )
  
  output$auth_output <- renderPrint({
    reactiveValuesToList(res_auth)
  })
  
  # ui server side
   output$ui <- renderUI({
      uiOutput("authenticated") 
   })
   
   # authentication
   output$authenticated <- renderUI({
       
       fluidPage(
           fluidRow(
               mainPanel(
                   tabsetPanel(
                       tabPanel("Log Blood Pressure", uiOutput("bplogger")),
                       tabPanel("Blood Pressure Trends", uiOutput("bpstats")),
                   )
               )
       )
      )
   })
   
   # logging inputs - bplogger
   output$bplogger <- renderUI({
       fluidPage(
           fluidRow(
             write_data_ui("inputs")
           )
       )
   })
   
   # graphs and trends - bpstats
   output$bpstats <- renderUI({
     fluidPage(
       br(),
       fluidRow(
            actionButton("refresh", "Refresh My Data")
       ),
       br(),
       # first row of graphs
       fluidRow(
         column(
           plotOutput("datetime_trend"),
           width = 12
         ),
         column(
           plotOutput("hour_trend"),
           width = 12
         )
       ),
       # other chart
       fluidRow(
         plotOutput("bp_scatter"),
       ),
       # second row of charts
       fluidRow(
         plotOutput("tbls"),
       )
     )
   })
   
   
   # pull google drive sheet
   bp_df_proc <- eventReactive(input$refresh, {
      googlesheets4::gs4_auth(cache=".secrets", email="faustolopez110@gmail.com")
      bp_df <- googlesheets4::read_sheet("https://docs.google.com/spreadsheets/d/1U3nQXyiIrDMTtts9zjT1d5ra-9k5I2i-fuM0I4Hi4Rc/edit#gid=0")
      bp_df_proc <- bp::process_data(bp_df,
                   sbp = "systolic",
                   dbp = "diastolic",
                   date_time = "date_time",
                   hr = "pulse",
      )
   })
   
   # datetime trend
   output$datetime_trend <- renderPlot({
      if(!is.null(bp_df_proc())) {
         q <- bp::bp_ts_plots(bp_df_proc())
         q$dt_plots$`1`
      }
   })
   
   # hour trend
   output$hour_trend <- renderPlot({
      if(!is.null(bp_df_proc())) {
         q <- bp::bp_ts_plots(bp_df_proc())
         q$hour_plots$`1`
      }
   })
   
   # dow
   output$tbls <- renderPlot({
      if(!is.null(bp_df_proc())) {
         bptable_ex <- bp::dow_tod_plots(bp_df_proc())
         gridExtra::grid.arrange(bptable_ex[[1]], bptable_ex[[2]], nrow = 2)
      }
   })
   
   # blood pressure scatter
   output$bp_scatter <- renderPlot({
      if(!is.null(bp_df_proc())) {
         bp::bp_scatter(data = bp_df_proc())
      }
   })
   
   # submit data
   write_data_server("inputs")
}

# Run the application 
shinyApp(ui = ui, server = server)
