#module that covers writing bp data to server

write_data_ui <- function(id) {
  ns <- NS(id)
  shiny::tagList(
    wellPanel(
      shinyjs::useShinyjs(),
      id ="inputs",
      numericInput(inputId = ns("systolic"), "Enter Systolic value : ", 0, width = "500px"),
      numericInput(inputId = ns("diastolic"), "Enter Diastolic value: ", 0, width = "500px"),
      numericInput(inputId = ns("pulse"), "Enter Pulse: ", 0, width = "500px"),
      radioButtons(inputId = ns("ate"), label = h4("Have you eaten in the last 60 minutes: "),
                   choices = list("Yes" = 1, "No" = 2), 
                   selected = 1, width = "500px"),
      textAreaInput(inputId = ns("notes"), "Any comments to add?", width = "500px"),
      actionButton(inputId = ns("submit"), "Submit my data")
    )
  )
}

write_data_server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      observeEvent(input$submit, {
        gs4_auth(cache=".secrets", email = TRUE, use_oob = TRUE)
        
        df <- 
          data.frame(
            #id = id,
            date_time = Sys.time(),
            systolic = input$systolic,
            diastolic = input$diastolic,
            pulse = input$pulse,
            ate_hour_before = input$ate,
            notes = input$notes
          )
        tryCatch({
          ss <- gs4_get("https://docs.google.com/spreadsheets/d/1U3nQXyiIrDMTtts9zjT1d5ra-9k5I2i-fuM0I4Hi4Rc/edit#gid=0")
          sheet_append(ss, df, sheet = 1)
          
          showModal(modalDialog(
            title = "Data Submission",
            "Your data was submitted successfully.",
            easyClose = TRUE,
            footer = NULL
          ))
          
          #reset values
          shinyjs::reset("inputs")
          
          
        }, error=function(e) {
          cat(paste("in err handler2\n"),e)
        }, warning=function(w) {
          cat(paste("in warn handler2\n"),w)
        })
        
      })
      
    }
  )
   
}





