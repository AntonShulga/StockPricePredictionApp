# server.R

library(quantmod)
library(forecast)
Sys.setlocale(category = "LC_ALL", locale = "English")

shinyServer(function(input, output) {
        
  dataInput <- reactive({
    data <- as.data.frame(getSymbols(input$symb, src = "yahoo", 
      from = as.character(Sys.Date()-input$mLearn*30.5-input$mPredict*30.5),
      to = as.character(Sys.Date()),
      auto.assign = FALSE))

    data <- to.monthly(data)
    
    data <- Cl(data)
    
    ts1 <- ts(data, frequency = 12)
    
    ts1Train <- window(ts1, start = 1, end = (input$mLearn)/12+1-0.01)
    ts1Test <- window(ts1, start = input$mLearn/12+1, end = length(ts1)/12+1-0.1)
    
    ets1 <- ets(ts1Train, model="MMM")
    
    fcast <- forecast(ets1, h = input$mPredict, level = input$confInt)
    
    errIndex <- fcast$lower > ts1Test | fcast$upper < ts1Test 
    
    return(list(ts = ts1, tsTrain = ts1Train, tsTest = ts1Test, ets = ets1, fcast = fcast, errIndex = errIndex)) 
  })
        
  output$stockPlot <- renderPlot({
     
     stockData <- dataInput() # returns list with monthly stock data, train/test split, exp smoothing model and forecast 
     colInd <- rep("green", input$mPredict)
     colInd[stockData$errIndex] <- "red"
     
     plot(stockData$fcast, 
          main = paste0(input$mPredict, "M close price forecast for ", input$symb),
          xlab = "Years",
          ylab = "Stock price, USD")
     lines(stockData$tsTest, col="black")
     points(stockData$tsTest, col = colInd)
     
  })
  
  output$stockText <- renderText({
     
     stockData <- dataInput()
     
     RMSE <- sqrt(mean((stockData$fcast$mean - stockData$tsTest)^2))
     errRate <- sum(stockData$errIndex) / length(stockData$errIndex)
     
     paste0("RMSE of prediction is ", round(RMSE,2), " and Error rate is ", round(errRate*100,2),"%")
  })
  
})