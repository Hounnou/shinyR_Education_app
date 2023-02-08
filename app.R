#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/

# Imort the libraries

library(shiny)
library(tidyverse)
library(caret)
library(nnet)
library(shinydashboard)

# Import Machine Learning models

model_oral <- readRDS("C:\\Users\\hleon\\OneDrive\\Desktop\\apps\\MLA_app\\Models\\model2.rds")

model_comp <- readRDS("C:\\Users\\hleon\\OneDrive\\Desktop\\apps\\MLA_app\\Models\\model3.rds")


# Define the user interface

## Here is the dashboard hearder

header <- dashboardHeader(
  title = "Developing a System Implementation for Early Graders’ Reading Performance in South Africa",
  titleWidth = 950,
  tags$li(class="dropdown",tags$a(href="https://github.com/Hounnou/shinyR_Education_app", icon("github"), "Source Code", target="_blank"))
  )

## Here is the dashboard sidebar

sidebar <- dashboardSidebar(
  
  sidebarMenu(
  
  # First sidebar item
  menuItem("Oral Fluency Score",tabName = "oral_tab",icon = icon("snowflake")),
  
  # Second sidebar item
  menuItem("Composition Score",tabName = "comp_tab",icon = icon("th"))
  
  )
)

## Here is the dashboard body

body <- dashboardBody(
  tabItems(
    
    # First tab element
    tabItem(
      
      tabName = "oral_tab",
      
      # Rows for fluency score and Grade input
        box(title = "Predicting Oral Fluency Score", width = 12, background = "light-blue",
                  "This project seeks to design a digital learning system in local languages in south Africa.
                  Using machine learning algorithms we want
                  to predict learners literacy levels based on some of their characteristics: sex, languages, school names... 
                  The data used to train the models came from a longitudinal study in low-performimg rural primary schools
                  in South Africa. Many Machine Learning Alogrithms (Multinomial logitistic regresssion model,
                   Naive Bayes model, Tree based models,  K-Nearest Neighbors model, Extreme gradient boosting model...)
                   have been tested to select the best performing model in terms of accurary. Please change some of the characteristics
            of the learner to see how the model will predict his/her Oral Fluency Score. "),
      fluidRow(
        box(infoBoxOutput("oral_prediction" ), title = "Your Oral Fluency Score is:",
            status = "warning", solidHeader = TRUE),
        box(selectInput("v_grade", label = "Grade", 
                            choices = c("First grade"= "1", "Second grade"= "2", "Third grade"= "3")),status = "warning") 
      ),
      
      # Box for age input
      
      box(selectInput("v_age", label = "Age", 
                      
                      choices = c("Under 8"="0", "8 and over"="1")),status = "warning"),
      
      # Box for treatment input
      
      box(selectInput("v_treat", label = "Treatment",
                      choices = c("Yes"="1", "No"="0")),status = "warning"),

      box(selectInput("v_sex", label = "Sex",
                      choices = c("male"="0", "female"="1")),status = "warning"),
      box(selectInput("v_lang", label = "Language",
                      choices = c("Sepedi", "Tshivenda", "Xitsonga")),status = "warning"),
      box(selectInput("v_schul", label = "School name",
                      choices = c("Bombeleni", "Dududu", "Folovhodwe",
                                  "Maniini","Maribe","Matshumu","Mauluma",
                                  "Mogologolo","Mponegele","Muratho","Nanga",
                                  "Ninakhulu","Ntji-Mothapo","Phishoana",
                                  "Ritavi","Samson Shiviti")),status = "warning"),
      box(selectInput("v_quint", label = "School Quintile",
                      choices = c("Low"="1", "Average"="2", "High"="3")),status = "warning")
    ), # tabItem1 closing parenthesis
    
  
    
    # Second tab element
    
    tabItem(
      
      tabName = "comp_tab",
      
      # Rows for fluency score and Grade input
      box(title = "Predicting Composition Score", width = 12, background = "light-blue",
          "This project seeks to design a digital learning system in local languages in south Africa.
                  Using machine learning algorithms we want
                  to predict learners literacy levels based on some of their characteristics: sex, languages, school names... 
                  The data used to train the models came from a longitudinal study in low-performimg rural primary schools
                  in South Africa. Many Machine Learning Alogrithms (Multinomial logitistic regresssion model,
                   Naive Bayes model, Tree based models,  K-Nearest Neighbors model, Extreme gradient boosting model...)
                   have been tested to select the best performing model in terms of accurary. Please change some of the characteristics
            of the learner to see how the model will predict his/her Composition Score. "),
      
      fluidRow(
        box(infoBoxOutput("comp_prediction"),title = "Your Composition Score is:", 
            status = "success", solidHeader = TRUE),  
        box(selectInput("v_grade2", label = "Grade", 
                        choices = c("First grade"= "1", "Second grade"= "2", "Third grade"= "3")), status="success") 
      ),
      
      # Box for age input
      
      box(selectInput("v_age2", label = "Age", 
                      
                      choices = c("Under 8"="0", "8 and over"="1")), status="success"),
      
      # Box for treatment input
      
      box(selectInput("v_treat2", label = "Treatment",
                      choices = c("Yes"="1", "No"="0")), status="success"),
      
      box(selectInput("v_sex2", label = "Sex",
                      choices = c("male"="0", "female"="1")), status="success"),
      box(selectInput("v_lang2", label = "Language",
                      choices = c("Sepedi", "Tshivenda", "Xitsonga")), status="success"),
      box(selectInput("v_schul2", label = "School name",
                      choices = c("Bombeleni", "Dududu", "Folovhodwe",
                                  "Maniini","Maribe","Matshumu","Mauluma",
                                  "Mogologolo","Mponegele","Muratho","Nanga",
                                  "Ninakhulu","Ntji-Mothapo","Phishoana",
                                  "Ritavi","Samson Shiviti")), status="success"),
      box(selectInput("v_quint2", label = "School Quintile",
                      choices = c("Low"="1", "Average"="2", "High"="3")), status="success")
    )
    
    
  ) # tabItems closing parenthesis
  
) # dashboard body closing parenthesis

## The user interface is the combination of header, sidebar and body

ui <- dashboardPage(header, sidebar, body)




# Define server logic required to evaluate the two models

server <- function(input, output) { 
  
  output$oral_prediction <- renderInfoBox({
    
    prediction <- predict(
      model_oral,
      tibble("grade" = input$v_grade,
             "female" = input$v_sex,
             "treatment" = input$v_treat,
             "language_name" = input$v_lang,
             "school_name" = input$v_schul,
             "school_quint" = input$v_quint,
             "age_c"=input$v_age)
    )
    
    prediction_color <- if_else(prediction[1] == "2", "blue", 
                                if_else(prediction[1] == "0", "red", "yellow"))
    
    prediction_symbol <- if_else(prediction[1] == "2", "High", 
                                 if_else(prediction[1] == "0", "Low", "Average"))
    infoBox(
      title = "", 
      paste0(prediction_symbol),
      color = prediction_color,
      icon = icon("list")
    )
    
  })
  
  ## Output for second tab
  
  output$comp_prediction <- renderInfoBox({
    
    prediction2 <- predict(
      model_comp,
      tibble("grade" = input$v_grade2,
             "female" = input$v_sex2,
             "treatment" = input$v_treat2,
             "language_name" = input$v_lang2,
             "school_name" = input$v_schul2,
             "school_quint" = input$v_quint2,
             "age_c"=input$v_age2)
    )
    
    prediction_color2 <- if_else(prediction2[1] == "2", "blue", 
                                 if_else(prediction2[1] == "0", "red", "yellow"))
    
    prediction_symbol2 <- if_else(prediction2[1] == "2", "High", 
                                  if_else(prediction2[1] == "0", "Low", "Average"))
    infoBox(
      title = "", 
      paste0(prediction_symbol2),
      color = prediction_color2,
      icon = icon("list")
    )
    
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
