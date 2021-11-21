#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyWidgets)
library(shinydashboard)
library(plotly)

# Define UI for application that draws a histogram
dashboardPage(skin = 'blue',
              dashboardHeader(title = "ADR valuation app", titleWidth = 280),
              dashboardSidebar(width = 280,  
                               sidebarMenu(
                                   menuItem("Welcome!", tabName = "intro", icon = icon("th")),
                                   menuItem("Premium/discount over time", tabName = "corplot", icon = icon("th")),
                                   menuItem("Credits", tabName = "credit", icon = icon("th"))
                               )),
              dashboardBody(
                  tabItems(
                      # First tab content
                      tabItem(tabName = "intro",
                              fluidPage(
                                  title = "Welcome to the app!",
                                  mainPanel(
                                      p("Welcome to the app! This app was created to examine the relationship 
                                        between foreign stocks with U.S.-based ADRs. In particular, a question 
                                        of interest concerns the discount/premium of the ADR asset. In many 
                                        circumstances, access to foreign markets can be limited or restricted 
                                        from a U.S. investor's point of view, so it is possible for them to trade 
                                        at a nontrivial premium which may vary over time. Given the correct inputs 
                                        and conversion factors, this app aims to assist a user in examining the 
                                        discount or premium of an ADR over time. An additional support feature 
                                        allows the user to smooth the fair value of the underlying asset by taking 
                                        a lagged mean to reduce some of the day-to-day volatility and clarify 
                                        the picture."),
                                      br(),
                                      p(strong("Version 1.1: November 21, 2021"))
                                  )
                              )),
                      # Second tab content
                      tabItem(tabName = "corplot",
                              pageWithSidebar(
                                  headerPanel('Premium/discount chart'),
                                  sidebarPanel(
                                      sliderInput("year",
                                                  "Years pictured:",
                                                  min = 2000,
                                                  max = 2022,
                                                  value = c(2021, 2022)),
                                      textInput("home_market",
                                                label = "Underlying Asset (i.e. 2330.TW)",
                                                value = "2330.TW",
                                                placeholder = "2330.TW"),
                                      textInput("us_adr",
                                                label = "U.S. ADR ticker (i.e. TSM)",
                                                value = "TSM",
                                                placeholder = "TSM"),
                                      textInput("curr_conv",
                                                label = "Currency conversion (i.e.USDTWD=X)",
                                                value = "USDTWD=X",
                                                placeholder = "USDTWD=X"),
                                      textInput("adr_shr",
                                                   label = "No of common shares per ADR (i.e. 5)",
                                                   value = 5,
                                                   placeholder = 5),
                                      textInput("days_smooth",
                                                label = "Number of days to compute lagged FV (i.e. 5)",
                                                value = 5,
                                                placeholder = 5),
                                      actionButton("calc","Submit")
                                  ),
                                  mainPanel(
                                      p("INSTRUCTIONS: Fill out the boxes on the left for an accurate comparison. 
                                        Ensure tickers for the underlying asset, U.S.-side ADR, and currency 
                                        conversion are accurate and return data by checking externally through 
                                        the ", tags$a(href = "http://www.finance.yahoo.com", "Yahoo! Finance"),
                                        " website. Any conversion rate in the number of common shares to the 
                                        ADR will also need to be supplied by the user. In the provided example 
                                        of TSM, this is 5 common shares to one ADR. The smoothing for FV 
                                        can be specified as desired to average out n days back. For n = 1, this 
                                        reduces to fair value as of most recent close in the home market data."),
                                      br(),
                                      p(strong("Click 'Submit' to generate the charts!")),
                                      p("Share price and fair value chart below:"),
                                      plotlyOutput("prem_disc_chart"),
                                      br(),
                                      p("Premium/discount by date:"),
                                      br(),
                                      plotlyOutput("margin_val_chart")
                                  )
                              )
                      ),
                      tabItem(tabName = "credit",
                              fluidPage(headerPanel('Credits'),
                                   mainPanel(
                                       p("Thanks to tidyquant package for integrated API for stock quotes."),
                                       p("Thanks to Yahoo Finance for API stock quote data."),
                                       p("Thanks to R and Shiny for making interactive apps possible!"),
                                       p("This software is provided as-is and with no guarantee of accuracy. 
                                          For futher details, see the ", tags$a(href = "https://github.com/Ccaginalp/adr-prem-disc-chk/blob/4be9667987ffb65de4aefbeb42ce6446792134c7/license.txt", "license"),
                                         ".")
                                   )
                                   )
                              )
                  )
              )
)