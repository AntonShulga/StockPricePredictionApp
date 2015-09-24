library(shiny)

shinyUI(fluidPage(
  titlePanel("Stock Price Predictions"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Select a stock to examine. 
        Information will be collected from yahoo finance. ", 
               a("Stock symbols lookup", href = "http://finance.yahoo.com/lookup")),
    
      textInput("symb", "Symbol", "SPY"),

      br(),
      
      sliderInput("mLearn", h4("Learning depth (months)"),
                  min = 30, max = 60, value = 36),
      
      br(),      

      sliderInput("mPredict", h4("Prediction horizon (months)"),
                  min = 1, max = 24, value = 12),
      
      br(),      
      
      sliderInput("confInt", h4("Confidence interval (%)"),
                  min = 1, max = 99, value = 95),
      
      br(),
      
      submitButton("Update Plot", icon("refresh"))
      
    ),
    
    mainPanel(
       p("Basic idea of this application is to develop prediction of chosen 
         stock price for the selected number of months preceding the date of 
         use. This period is used to test accuracy of prediction. The user 
         is allowed to chose the length of learning horizon (which is certain 
         amount of months preceding the test period) and width of prediction 
         confidence interval. The accuracy of prediction can be analyzed on 
         the plot provided as well as based on RMSE and error rate (the share 
         of data points in test period which are out of prediction confidence 
         interval). The app is based on the time series analysis method 
         (exponential smoothing) which is part of ", 
       em("forecast"), 
       "R package. 
         One can further use this application to try develop stock investment 
         strategies."), 
       
       p(strong("NOTE:"), "Please note that changes to user 
         controls will only affect the outcomes after Update Plot button is pushed."),
       
       plotOutput("stockPlot"),
       textOutput("stockText")
    )
  )
))