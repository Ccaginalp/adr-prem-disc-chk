#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyquant)
library(stringr)
library(tidyverse)
library(lubridate)
library(plyr)
library(glue)
options("getSymbols.warning4.0"=FALSE)
options("getSymbols.yahoo.warning"=FALSE)



# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    stocks <- eventReactive(input$calc, {
        # turn off warnings
        options("getSymbols.warning4.0"=FALSE)
        options("getSymbols.yahoo.warning"=FALSE)
        # load in stocks
        start_date <- as.Date(glue('{input$year[1]}-01-01'))
        end_date <- as.Date(glue('{input$year[2]}-01-01'))
        adr_price <- getSymbols(input$us_adr, from = start_date,
                                to = end_date , .warnings = FALSE,
                                auto.assign = FALSE)
        home_price <- getSymbols(input$home_market, from = start_date,
                                 to = end_date, .warnings = FALSE,
                                 auto.assign = FALSE)
        curr <- getSymbols(input$curr_conv, from = start_date,
                           to = end_date, .warnings = FALSE,
                           auto.assign = FALSE)
        adr_name <- toupper(input$us_adr)
        adr <- data.frame(adr_price[, glue("{adr_name}.Adjusted")])
        home <- data.frame(home_price[, glue("{toupper(input$home_market)}.Adjusted")])
        curr <- data.frame(curr[, glue("{toupper(input$curr_conv)}.Adjusted")])
        df1 <- adr %>% 
            merge(home, all.x = TRUE, by = 0)
        df2 <- adr %>% 
            merge(curr, all.x = TRUE, by = 0)
        stocks <- df1 %>% # is there a better way? maybe, but this works for now
            left_join(df2, by = c("Row.names", glue("{adr_name}.Adjusted")))
        stocks <- na.locf(stocks)
        colnames(stocks) <- c("Date", "ADR", "HOME", "CURR")
        stocks$FV <- stocks$HOME * as.numeric(input$adr_shr) / stocks$CURR
        stocks$prem_disc <- (stocks$ADR/stocks$FV - 1) * 100
        stocks$Date <- as.Date(as.character(stocks$Date), format = "%Y-%m-%d")
        stocks
    })
    
    output$prem_disc_chart <- renderPlotly({
        adr_name <- toupper(input$us_adr)
        date_space <- ifelse(input$year[2] - input$year[1] > 2, "1 year", "1 month")
        stocks() %>% 
            filter(abs(prem_disc) < 30 | is.na(prem_disc)) %>% # get rid of any extreme outliers
            mutate(`Smoothed FV` = rollmean(FV, as.numeric(input$days_smooth), fill = NA, align = 'right') %>% 
                       round(2),
                   Date = as.Date(Date, "%Y-%m-%d")) %>% 
            pivot_longer(cols = c("ADR", "Smoothed FV"), names_to = "Metric", values_to = "Price") %>% 
            ggplot() +
            geom_line(aes(Date, Price, col = Metric)) +
            scale_x_date(date_labels = "%b'%y", breaks = date_space) +
            labs(x = "Time",
                 y = glue("Price of {adr_name}/FV [$]"),
                 title = glue("{adr_name} stock price and fair value over time [{input$days_smooth} day lagged]"))
    })
    
    output$margin_val_chart <- renderPlotly({
        adr_name <- toupper(input$us_adr)
        date_space <- ifelse(input$year[2] - input$year[1] > 2, "1 year", "1 month")
        stocks() %>% 
            filter(abs(prem_disc) < 30 | is.na(prem_disc)) %>% # get rid of any extreme outliers
            mutate(`Prem/disc` = rollmean(prem_disc, as.numeric(input$days_smooth), fill = NA, align = 'right') %>% 
                       round(2),
                   Date = as.Date(Date, "%Y-%m-%d")) %>% 
            ggplot() +
            geom_line(aes(Date, `Prem/disc`, col = "Prem/disc")) +
            scale_x_date(date_labels = "%b'%y", breaks = date_space) +
        labs(x = "Time",
             y = glue("Premium/discount amount [%]"),
             title = glue("{adr_name} valuation over underlying asset [{input$days_smooth} day lagged]")) + 
            theme(legend.title = element_blank()) 
    })
})
