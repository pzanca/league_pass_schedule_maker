#Load libraries
library(shiny)
library(rsconnect)
library(tidyverse)
library(lubridate)
library(lpSolve)

#### UI ####

time_list <- list("12:00 pm ET", "12:30 pm ET", "1:00 pm ET", "1:30 pm ET", "2:00 pm ET", "2:30 pm ET",
                  "3:00 pm ET", "3:30 pm ET", "4:00 pm ET", "4:30 pm ET", "5:30 pm ET", "6:00 pm ET",
                  "6:30 pm ET", "7:00 pm ET", "7:30 pm ET", "8:00 pm ET", "8:30 pm ET", "9:00 pm ET",
                  "9:30 pm ET", "10:00 pm ET", "10:30 pm ET")

watch_list <- list("This is my team. Show me every one of their games. No joke.",
                   "This is one of my fav teams. Load up on them.",
                   "I'm cool with seeing this team a few times.",
                   "I need to take my medicine and watch this team at least once.",
                   "Never show me this team. Ever. Don't ask.")

ui <- fluidPage(
  
  tags$h1("NBA League Pass Schedule Maker"),
  tags$h5("Built by Peter Zanca"),
  tags$p("Every season, I tell myself I'm going to get my money's worth out of NBA League Pass and watch every team in the league on a regular basis. But after a week or two, I always end up coming back to my favorites over and over again. This year I'm using linear programming to plan out an optimal schedule of games that'll allow me to watch the teams I like while also forcing me to take my medicine on teams I'm less likely to watch."),
  tags$p("This Shiny app will allow you to build your own \"optimal\" schedule. Just plug in (A) when you watch games, (B) how many you watch on a given day, (C) what channels you're limited to, and (D) how often you want to watch each team. Happy viewing!"),
  tags$div(style='width: 1750px;',
           tags$div(style='float: left; width: 550px;',
                    tags$h4("When do you watch hoops?"),
                    tags$table(style = "table-layout: fixed; width: 500px;text-align: left; vertical-align: middle;",
                               tags$style(HTML(".radio-inline {padding-left: 47px;margin-right: 20px;vertical-align: top}")),
                               tags$tbody(
                                 tags$tr(
                                   tags$th(style = "width: 100px; text-align: center",
                                           "Day"),
                                   tags$th(style = "width: 75px;",
                                           "Include"),
                                   tags$th(style = "width: 135px;",
                                           "Earliest Start Time"),
                                   tags$th(style = "width: 135px;",
                                           "Latest Start Time"),
                                   tags$th(style = "width: 100px;",
                                           "Max Games")
                                 ),
                                 tags$tr(
                                   tags$td("Sunday", align = "center"),
                                   tags$td(
                                     style = "display: inline-block; margin-left: 15px;",
                                     checkboxInput(inputId = "Day_1", label = NULL, width = "15px", value = TRUE)
                                   ),
                                   tags$td(
                                     selectInput(inputId = "Early_1", label = NULL, width = "130px",
                                                 choices = time_list, selected = "12:00 pm ET")
                                   ),
                                   tags$td(
                                     selectInput(inputId = "Late_1", label = NULL, width = "130px",
                                                 choices = time_list, selected = "10:30 pm ET")
                                   ),
                                   tags$td(
                                     numericInput(inputId = "Max_1", label = NULL, width = "65px",
                                                  value = 1, min = 0, max = 5, step = 1)
                                   )
                                 ),
                                 tags$tr(
                                   tags$td("Monday", align = "center"),
                                   tags$td(
                                     style = "display: inline-block; margin-left: 15px;",
                                     checkboxInput(inputId = "Day_2", label = NULL, width = "15px", value = TRUE)
                                   ),
                                   tags$td(
                                     selectInput(inputId = "Early_2", label = NULL, width = "130px",
                                                 choices = time_list, selected = "12:00 pm ET")
                                   ),
                                   tags$td(
                                     selectInput(inputId = "Late_2", label = NULL, width = "130px",
                                                 choices = time_list, selected = "10:30 pm ET")
                                   ),
                                   tags$td(
                                     numericInput(inputId = "Max_2", label = NULL, width = "65px",
                                                  value = 1, min = 0, max = 5, step = 1)
                                   )
                                 ),
                                 tags$tr(
                                   tags$td("Tuesday", align = "center"),
                                   tags$td(
                                     style = "display: inline-block; margin-left: 15px;",
                                     checkboxInput(inputId = "Day_3", label = NULL, width = "15px", value = TRUE)
                                   ),
                                   tags$td(
                                     selectInput(inputId = "Early_3", label = NULL, width = "130px",
                                                 choices = time_list, selected = "12:00 pm ET")
                                   ),
                                   tags$td(
                                     selectInput(inputId = "Late_3", label = NULL, width = "130px",
                                                 choices = time_list, selected = "10:30 pm ET")
                                   ),
                                   tags$td(
                                     numericInput(inputId = "Max_3", label = NULL, width = "65px",
                                                  value = 1, min = 0, max = 5, step = 1)
                                   )
                                 ),
                                 tags$tr(
                                   tags$td("Wednesday", align = "center"),
                                   tags$td(
                                     style = "display: inline-block; margin-left: 15px;",
                                     checkboxInput(inputId = "Day_4", label = NULL, width = "15px", value = TRUE)
                                   ),
                                   tags$td(
                                     selectInput(inputId = "Early_4", label = NULL, width = "130px",
                                                 choices = time_list, selected = "12:00 pm ET")
                                   ),
                                   tags$td(
                                     selectInput(inputId = "Late_4", label = NULL, width = "130px",
                                                 choices = time_list, selected = "10:30 pm ET")
                                   ),
                                   tags$td(
                                     numericInput(inputId = "Max_4", label = NULL, width = "65px",
                                                  value = 1, min = 0, max = 5, step = 1)
                                   )
                                 ),
                                 tags$tr(
                                   tags$td("Thursday", align = "center"),
                                   tags$td(
                                     style = "display: inline-block; margin-left: 15px;",
                                     checkboxInput(inputId = "Day_5", label = NULL, width = "15px", value = TRUE)
                                   ),
                                   tags$td(
                                     selectInput(inputId = "Early_5", label = NULL, width = "130px",
                                                 choices = time_list, selected = "12:00 pm ET")
                                   ),
                                   tags$td(
                                     selectInput(inputId = "Late_5", label = NULL, width = "130px",
                                                 choices = time_list, selected = "10:30 pm ET")
                                   ),
                                   tags$td(
                                     numericInput(inputId = "Max_5", label = NULL, width = "65px",
                                                  value = 1, min = 0, max = 5, step = 1)
                                   )
                                 ),
                                 tags$tr(
                                   tags$td("Friday", align = "center"),
                                   tags$td(
                                     style = "display: inline-block; margin-left: 15px;",
                                     checkboxInput(inputId = "Day_6", label = NULL, width = "15px", value = TRUE)
                                   ),
                                   tags$td(
                                     selectInput(inputId = "Early_6", label = NULL, width = "130px",
                                                 choices = time_list, selected = "12:00 pm ET")
                                   ),
                                   tags$td(
                                     selectInput(inputId = "Late_6", label = NULL, width = "130px",
                                                 choices = time_list, selected = "10:30 pm ET")
                                   ),
                                   tags$td(
                                     numericInput(inputId = "Max_6", label = NULL, width = "65px",
                                                  value = 1, min = 0, max = 5, step = 1)
                                   )
                                 ),
                                 tags$tr(
                                   tags$td("Saturday", align = "center"),
                                   tags$td(
                                     style = "display: inline-block; margin-left: 15px;",
                                     checkboxInput(inputId = "Day_7", label = NULL, width = "15px", value = TRUE)
                                   ),
                                   tags$td(
                                     selectInput(inputId = "Early_7", label = NULL, width = "130px",
                                                 choices = time_list, selected = "12:00 pm ET")
                                   ),
                                   tags$td(
                                     selectInput(inputId = "Late_7", label = NULL, width = "130px",
                                                 choices = time_list, selected = "10:30 pm ET")
                                   ),
                                   tags$td(
                                     numericInput(inputId = "Max_7", label = NULL, width = "65px",
                                                  value = 1, min = 0, max = 5, step = 1)
                                   )
                                 )
                               )
                    ),
                    tags$h4("Any channel restrictions?"),
                    tags$table(style = "table-layout: fixed; width: 250px;text-align: left; vertical-align: middle;",
                               tags$tbody(
                                 tags$tr(
                                   tags$td(style = "width = 175px",
                                           "No ABC"),
                                   tags$td(style = "width = 75px",
                                     checkboxInput(inputId = "ABC", label = NULL, width = "15px")
                                   )
                                 ),
                                 tags$tr(
                                   tags$td("No ESPN"),
                                   tags$td(
                                     checkboxInput(inputId = "ESPN", label = NULL, width = "15px")
                                   )
                                 ),
                                 tags$tr(
                                   tags$td("No TNT"),
                                   tags$td(
                                     checkboxInput(inputId = "TNT", label = NULL, width = "15px")
                                   )
                                 ),
                                 tags$tr(
                                   tags$td("No NBA TV"),
                                   tags$td(
                                     checkboxInput(inputId = "NBA_TV", label = NULL, width = "15px")
                                   )
                                 ),
                                 tags$tr(
                                   tags$td("No League Pass"),
                                   tags$td(
                                     checkboxInput(inputId = "LP", label = NULL, width = "15px")
                                   )
                                 )
                               )
                    ),
                    textOutput(outputId = "No_LP")
                    ),
           tags$div(style='float: left; width: 1200px; overflow: auto',
                    tags$h4("How often do you want to watch each team?"),
                    tags$div(style='float: left; width: 600px;',
                             tags$table(style = "table-layout: fixed; width: 400px; text-align: left; vertical-align: top;",
                                        tags$style(HTML(".radio-inline {padding-left: 47px;margin-right: 20px;vertical-align: top}")),
                                        tags$tbody(
                                          tags$tr(style = "height: 25px",
                                                  tags$th(style = "width: 200px; text-align: center; vertical-align: middle;",
                                                          "Team"),
                                                  tags$th(style = "width: 80px; text-align: center; vertical-align: middle;",
                                                          "Always"),
                                                  tags$th(style = "width: 80px; text-align: center; vertical-align: middle;",
                                                          "Often"),
                                                  tags$th(style = "width: 80px; text-align: center; vertical-align: middle;",
                                                          "Sometimes"),
                                                  tags$th(style = "width: 80px; text-align: center; vertical-align: middle;",
                                                          "At Least Once"),
                                                  tags$th(style = "width: 80px; text-align: center; vertical-align: middle;",
                                                          "Never")
                                          ),
                                          tags$tr(style = "height: 10px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Atlanta Hawks"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_1", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                    )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Boston Celtics"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_2", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Brooklyn Nets"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_3", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Charlotte Hornets"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_4", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Chicago Bulls"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_5", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Cleveland Cavaliers"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_6", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Dallas Mavericks"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_7", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Denver Nuggets"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_8", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Detroit Pistons"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_9", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Golden State Warriors"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_10", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Houston Rockets"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_11", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Indiana Pacers"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_12", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Los Angeles Clippers"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_13", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Los Angeles Lakers"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_14", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Memphis Grizzlies"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_15", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          )
                                          )
                                        )
                             ),
                    tags$div(style='float: left; width: 400px;',
                             tags$table(style = "table-layout: fixed; width: 400px; text-align: left; vertical-align: middle;",
                                        tags$style(HTML(".radio-inline {padding-left: 47px;margin-right: 20px;}")),
                                        tags$tbody(
                                          tags$tr(style = "height: 25px",
                                                  tags$th(style = "width: 200px; text-align: center; vertical-align: middle;",
                                                          "Team"),
                                                  tags$th(style = "width: 80px; text-align: center; vertical-align: middle;",
                                                          "Always"),
                                                  tags$th(style = "width: 80px; text-align: center; vertical-align: middle;",
                                                          "Often"),
                                                  tags$th(style = "width: 80px; text-align: center; vertical-align: middle;",
                                                          "Sometimes"),
                                                  tags$th(style = "width: 80px; text-align: center; vertical-align: middle;",
                                                          "At Least Once"),
                                                  tags$th(style = "width: 80px; text-align: center; vertical-align: middle;",
                                                          "Never")
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Miami Heat"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_16", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Milwaukee Bucks"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_17", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Minnesota Timberwolves"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_18", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "New Orleans Pelicans"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_19", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "New York Knicks"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_20", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Oklahoma City Thunder"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_21", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Orlando Magic"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_22", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Philadelphia 76ers"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_23", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Phoenix Suns"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_24", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Portland Trail Blazers"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_25", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Sacramento Kings"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_26", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "San Antonio Spurs"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_27", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Toronto Raptors"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_28", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Utah Jazz"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_29", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          ),
                                          tags$tr(style = "height: 25px",
                                                  tags$td(align = "center", valign = "top",
                                                          "Washington Wizards"),
                                                  tags$td(colspan = 5,
                                                          radioButtons(inputId = "Team_30", label = NULL, inline = TRUE, width = '400px',
                                                                       choiceNames = list("", "", "", "", ""),
                                                                       choiceValues = list(4, 3, 2, 1, 0),
                                                                       selected = 2)
                                                  )
                                          )
                                          )
                                        )
                             ),
                    tags$div(style = "float: left",
                             tags$p(tags$u(tags$strong("Frequency Options")),
                                    tags$br(),
                                    tags$strong("Always: "), "This is my team. I want to watch literally every single one of their games. (Select no more than one \"Always\" team.)",
                                    tags$br(),
                                    tags$strong("Often: "), "This is one of my favorite teams. I want to watch them a lot.",
                                    tags$br(),
                                    tags$strong("Sometimes: "), "I don't mind watching this team every once and a while.",
                                    tags$br(),
                                    tags$strong("At Least Once: "), "I don't like watching this team, but I need to take my medicine and watch them at least once.",
                                    tags$br(),
                                    tags$strong("Never: "), "I never want to watch this team. Ever. Don't ask.")
                    )
                    )
           ),
  tags$div(
    style="float: left;clear:both;",
    div(style="display:inline-block",
        actionButton(inputId = "Action", label = "Build my schedule",
                     style="color: #fff; background-color: #337ab7; border-color: #2e6da4")
        ),
    div(style="display:inline-block",
        uiOutput("download_button"),
        tags$head(tags$style(".butt{background-color:#337ab7;} .butt{color: white;} .butt{border-color: #2e6da4;}"))
        ),
    conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                     tags$div("Creating your schedule. This will take a few seconds...", id = "loadmessage"))
    ),
  tags$div(
    style = "float:left; clear: both; width: 1200px",
    tags$div(
      style = "float:left; width: 700px",
      tableOutput(
        outputId = "Result"
        )
    ),
    tags$div(
      style = "float: right; width: 500px",
      tableOutput(
        outputId = "Recap"
      )
    )
  )
  
)


#### SERVER ####

server <- function(input, output) {
  
  output$No_LP <- renderText({
    if(input$LP){
      LP_message <- "Note: This schedule maker isn't very useful without a League Pass subscription."
    } else {
      LP_message <- ""
    }
    LP_message
  })
  
  
  schedule <- eventReactive(
    
    #When the actionButton changes, run the code below
    input$Action, 
    
    {
    
      #Set up day preferences
      day_pref <- tibble(
        WEEKDAY = c(1, 2, 3, 4, 5, 6, 7),
        INCLUDE = c(input$Day_1, input$Day_2, input$Day_3, input$Day_4, input$Day_5, input$Day_6, input$Day_7),
        EARLY = c(input$Early_1, input$Early_2, input$Early_3, input$Early_4, input$Early_5, input$Early_6, input$Early_7),
        LATE = c(input$Late_1, input$Late_2, input$Late_3, input$Late_4, input$Late_5, input$Late_6, input$Late_7),
        MAX = c(input$Max_1, input$Max_2, input$Max_3, input$Max_4, input$Max_5, input$Max_6, input$Max_7)
        ) %>%
        mutate_at(vars(EARLY, LATE),
                  ~as.numeric(factor(.,
                                     levels = c("12:00 pm ET", "12:30 pm ET", "1:00 pm ET", "1:30 pm ET", "2:00 pm ET", "2:30 pm ET",
                                                "3:00 pm ET", "3:30 pm ET", "4:00 pm ET", "4:30 pm ET", "5:30 pm ET", "6:00 pm ET",
                                                "6:30 pm ET", "7:00 pm ET", "7:30 pm ET", "8:00 pm ET", "8:30 pm ET", "9:00 pm ET",
                                                "9:30 pm ET", "10:00 pm ET", "10:30 pm ET"))))
      
      #Set up unavailable channels
      channels <- tibble(
        CHANNEL = c("ABC", "ESPN", "TNT", "NBA TV", "LP"),
        UNAVAIL = c(input$ABC, input$ESPN, input$TNT, input$NBA_TV, input$LP)
        ) %>%
        filter(!UNAVAIL) %>%
        select(CHANNEL)
      
      #Set up team preferences
      team_pref <- tibble(
        TEAM = c("Atlanta Hawks","Boston Celtics","Brooklyn Nets","Charlotte Hornets","Chicago Bulls",
                 "Cleveland Cavaliers","Dallas Mavericks","Denver Nuggets","Detroit Pistons","Golden State Warriors",
                 "Houston Rockets","Indiana Pacers","LA Clippers","Los Angeles Lakers","Memphis Grizzlies",
                 "Miami Heat","Milwaukee Bucks","Minnesota Timberwolves","New Orleans Pelicans","New York Knicks",
                 "Oklahoma City Thunder","Orlando Magic","Philadelphia 76ers","Phoenix Suns","Portland Trail Blazers",
                 "Sacramento Kings","San Antonio Spurs","Toronto Raptors","Utah Jazz","Washington Wizards"),
        PREF = c(input$Team_1,input$Team_2,input$Team_3,input$Team_4,input$Team_5,
                 input$Team_6,input$Team_7,input$Team_8,input$Team_9,input$Team_10,
                 input$Team_11,input$Team_12,input$Team_13,input$Team_14,input$Team_15,
                 input$Team_16,input$Team_17,input$Team_18,input$Team_19,input$Team_20,
                 input$Team_21,input$Team_22,input$Team_23,input$Team_24,input$Team_25,
                 input$Team_26,input$Team_27,input$Team_28,input$Team_29,input$Team_30)
      ) %>%
        mutate(PREF = as.numeric(PREF))
      
      #Read in the NBA schedule
      nba_schedule <- read_csv("NBA_Schedule_Final.csv")
      
      #Filter to eligible games based on channels, days, and team prefs
      elig_games <- nba_schedule %>%
        #Filter to games starting today
        filter(DATE >= Sys.Date()) %>%
        #Filter to games on available channels
        mutate(CHANNEL = if_else(is.na(NATL_TV), "LP", NATL_TV)) %>%
        inner_join(channels, by = "CHANNEL") %>%
        #Filter on day
        inner_join(day_pref %>%
                     filter(INCLUDE) %>%
                     select(WEEKDAY),
                   by = "WEEKDAY") %>%
        #Filter out "Never" teams
        inner_join(team_pref %>%
                     filter(PREF > 0) %>%
                     select(TEAM),
                   by = c("AWAY" = "TEAM")) %>%
        inner_join(team_pref %>%
                     filter(PREF > 0) %>%
                     select(TEAM),
                   by = c("HOME" = "TEAM")) %>%
        #Filter out times outside of viewing preference
        left_join(day_pref %>%
                    select(WEEKDAY, EARLY, LATE),
                  by = "WEEKDAY") %>%
        mutate(TIME_SLOT = as.numeric(factor(TIME,
                                             levels = c("12:00 pm ET", "12:30 pm ET", "1:00 pm ET", "1:30 pm ET", "2:00 pm ET", "2:30 pm ET",
                                                        "3:00 pm ET", "3:30 pm ET", "4:00 pm ET", "4:30 pm ET", "5:30 pm ET", "6:00 pm ET",
                                                        "6:30 pm ET", "7:00 pm ET", "7:30 pm ET", "8:00 pm ET", "8:30 pm ET", "9:00 pm ET",
                                                        "9:30 pm ET", "10:00 pm ET", "10:30 pm ET")))) %>%
        filter(EARLY <= TIME_SLOT & TIME_SLOT <= LATE) %>%
        #Add team pref 
        left_join(team_pref %>%
                    rename(AWAY = TEAM, AWAY_VALUE = PREF),
                  by = "AWAY") %>%
        left_join(team_pref %>%
                    rename(HOME = TEAM, HOME_VALUE = PREF),
                  by = "HOME") %>%
        mutate(GAME_VALUE = AWAY_VALUE + HOME_VALUE,
               MUST_WATCH = if_else(AWAY_VALUE == 4 | HOME_VALUE == 4, 1, 0)) %>%
        #Narrow down the columns to what's needed going forward
        select(GAME_ID, WEEKDAY, DATE, TIME, AWAY, HOME, LOCAL_TV_1, LOCAL_TV_2, NATL_TV, GAME_VALUE, MUST_WATCH)
      
      #Extract coefficients
      lp_coef <- elig_games %>%
        pull(GAME_VALUE)
      
      #Get number of games
      num_games <- nrow(elig_games)
      
      #Identify unique dates among games
      unique_dates <- distinct(elig_games, DATE)
      
      #Import timeslot matrix
      timeslots <- read_csv("Timeslots.csv")
      
      #Create timeslot constraint matrix: This ensures you don't get overlapping games
      time_prep <- elig_games %>%
        select(DATE, TIME) %>%
        left_join(timeslots,
                  by = "TIME")
      
      time_matrix <- matrix(nrow = 0, ncol = num_games)
      
      for (i in 1:nrow(unique_dates)) {
        for (j in 1:22) {
          time_row <- time_prep %>%
            select(DATE, eval(paste0("SLOT_", j))) %>%
            mutate_at(vars(-DATE), ~if_else(DATE == unique_dates$DATE[i],
                                            .,
                                            0)) %>%
            pull(eval(paste0("SLOT_", j)))
          
          time_matrix <- rbind(time_matrix,
                               time_row)
        }
      }
      
      #Create team matrix: This ensures you see every team (you want) at least once
      team_matrix <- matrix(nrow = 0, ncol = num_games)
      
      for (i in 1:nrow(team_pref)) {
        if (team_pref$PREF[i] == 0) {
          next
        }
        
        team_matrix <- rbind(team_matrix,
                             team_row = elig_games %>%
                               mutate(TEAM_FLAG = if_else(AWAY == team_pref$TEAM[i] | HOME == team_pref$TEAM[i], 1, 0)) %>%
                               pull(TEAM_FLAG))
      }
      
      #Create must-watch matrix: This ensures you see every game for "your team"
      must_watch_matrix <- elig_games %>%
        pull(MUST_WATCH) %>%
        as.matrix() %>%
        t()
      
      #Create day matrix: This ensures you get only the number of games you want on a given weekday
      date_matrix <- matrix(
        rep(pull(elig_games, DATE), each = num_games), 
        ncol = num_games, byrow = FALSE
      ) %>%
        as_tibble() %>%
        mutate_all(~as_date(.)) %>%
        bind_cols(DATE = select(elig_games, DATE)) %>%
        mutate_at(vars(-DATE), ~if_else(. == DATE, 1, 0)) %>%
        select(-DATE) %>%
        as.matrix()
      
      #Combine contraint matrices together
      lp_con <- rbind(
        time_matrix,
        team_matrix,
        must_watch_matrix,
        date_matrix
      )
      
      #Set up direction of constraint equations
      lp_dir <- c(rep("<=", nrow(time_matrix)), 
                  rep(">=", nrow(team_matrix)),
                  rep("==", nrow(must_watch_matrix)),
                  rep("<=", nrow(date_matrix)))
      
      #Set up right-hand side of constraint equations
      lp_rhs <- c(rep(1, nrow(time_matrix) + nrow(team_matrix)),
                  sum(elig_games$MUST_WATCH),
                  elig_games %>%
                    left_join(day_pref %>%
                                select(WEEKDAY, MAX),
                              by = "WEEKDAY") %>%
                    pull(MAX))
      
      #Run LP model
      lp_model <- lp(direction = "max",
                     objective.in = lp_coef,
                     const.mat = lp_con,
                     const.dir = lp_dir,
                     const.rhs = lp_rhs,
                     all.bin = TRUE)
      
      #Filter to the schedule generated by the model
      final_result <- elig_games %>%
        mutate(INCLUDE = lp_model$solution) %>%
        filter(INCLUDE == 1) %>%
        mutate(TV = if_else(is.na(NATL_TV), "League Pass", NATL_TV)) %>%
        mutate(DATE = as.character(DATE)) %>%
        select(DATE, TIME, AWAY, HOME, TV)
        
      
      if (lp_model$status == 0) {
          final_result
      } else if (lp_model$status == 2) {
        tibble(WARNING = "There is no feasible schedule given your settings. Try relaxing some of your constraints.")
      } else if (lp_model$status == -1) {
        tibble(WARNING = "There is no feasible schedule given your settings. Try relaxing some of your constraints.")
      }
      
      
    
    })
    
    output$Result <- renderTable(
      schedule(),
      caption = "<b> <span style='color:#000000'>Your Schedule</b>",
      caption.placement = getOption("xtable.caption.placement", "top")
    )
    
    output$Recap <- renderTable({
      
      games <- schedule()
      
      if (nrow(games) > 1) {
        
      recap <- tibble(
        TEAM = c("Atlanta Hawks","Boston Celtics","Brooklyn Nets","Charlotte Hornets","Chicago Bulls",
                 "Cleveland Cavaliers","Dallas Mavericks","Denver Nuggets","Detroit Pistons","Golden State Warriors",
                 "Houston Rockets","Indiana Pacers","LA Clippers","Los Angeles Lakers","Memphis Grizzlies",
                 "Miami Heat","Milwaukee Bucks","Minnesota Timberwolves","New Orleans Pelicans","New York Knicks",
                 "Oklahoma City Thunder","Orlando Magic","Philadelphia 76ers","Phoenix Suns","Portland Trail Blazers",
                 "Sacramento Kings","San Antonio Spurs","Toronto Raptors","Utah Jazz","Washington Wizards")
        ) %>%
        left_join(
          bind_rows(
            select(games, TEAM = AWAY, DATE),
            select(games, TEAM = HOME, DATE)
            ),
          by = "TEAM"
          ) %>% 
        mutate(VALUE = if_else(is.na(DATE), 0, 1)) %>%
        group_by(TEAM) %>%
        summarize(GAMES = sum(VALUE)) %>%
        ungroup() %>%
        arrange(desc(GAMES), TEAM)
      
      } else {
        recap <- tibble()
      }

    },
    digits = 0,
    caption = "<b> <span style='color:#000000'>Breakdown by Team</b>",
    caption.placement = getOption("xtable.caption.placement", "top")
    )

    output$downloadData <- downloadHandler(
      
      filename = "schedule.csv",
      
      content = function(file) {
        output <- schedule()
        write_csv(output, file)
      },
      
      contentType = "csv"
    )
    
    output$download_button <- renderUI({
      
      games <- schedule()
      
      if(nrow(games) > 1) {
        downloadButton(outputId = "downloadData", "Download Your Schedule", class = "butt")
      }
    })
  
}








#Run the app
shinyApp(ui = ui, server = server)
