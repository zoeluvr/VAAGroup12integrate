

#---------install and load packages-----------------

pacman::p_load(shiny, readxl, ggstatsplot, ggplot2, shinydashboard, plotly, lubridate, 
               ggcorrplot, corrplot, PMCMRplus, knitr, tidymodels, yardstick, ranger, tidyverse)

#---------import data---------------------------------

loandata <- read_xlsx("data/loan.xlsx")
Demographic <- read_csv("data/traindemographics.csv")
Previousloans <- read_csv("data/trainprevloans.csv")
merged_AC <- merge(Demographic, Previousloans, by = "customerid")
merged_AC$status <- ifelse(as.Date(merged_AC$firstrepaiddate) > as.Date(merged_AC$firstduedate), "overtime", "ontime")
#data edit for demographic analysis
loandata <- loandata %>%
  mutate(age_group = case_when(
    Age <= 30 ~ "<30",
    Age <= 40 ~ "30-40",
    Age <= 50 ~ "40-50",
    TRUE ~ "60+"
  )) %>% mutate(int_flag = ifelse(good_bad_flag == "Good", 1, 0)) %>% 
  mutate(Employment_ca = case_when(
    Employment == 6 ~ "Permanent",
    Employment == 5 ~ "Self-Employed",
    Employment == 4 ~ "Contract",
    Employment == 3 ~ "Retired",
    Employment == 2 ~ "Student",
    Employment == 1 ~ "Unemployed",
    Employment == 0 ~ NA_character_,
    TRUE ~ as.character(Employment)
  )) %>% 
  mutate(Education_ca = case_when(
    Education == 4 ~ "Post-Graduate",
    Education == 3 ~ "Graduate",
    Education == 2 ~ "Secondary",
    Education == 1 ~ "Primary",
    Education == 0 ~ NA_character_,
    TRUE ~ as.character(Education)
  ))
#new 
train_data <- read_xlsx("data/loan.xlsx")
train_data$good_bad_flag_number <- ifelse(train_data$good_bad_flag == "Good", 1, 0)

#previous loan data process:
#1
merged_AC <- merged_AC %>%
  mutate(age = interval(ymd(birthdate), Sys.Date()) %/% years(1)) %>% 
  filter(status %in% c("ontime", "overtime")) 
merged_AC_A <- merged_AC %>% 
  group_by(age, status) %>% 
  summarise(count = n())
#2
grouped_data_em <- merged_AC %>%
  group_by(employment_status_clients, status) %>%
  summarise(count = n()) %>% 
  filter(status == "overtime")
grouped_data_em$percentage <- grouped_data_em$count / sum(grouped_data_em$count) * 100
grouped_data_em$ymax = cumsum(grouped_data_em$percentage)
grouped_data_em$ymin = c(0, head(grouped_data_em$ymax, n=-1))

grouped_data_edu <- merged_AC %>%
  group_by(level_of_education_clients, status) %>%
  summarise(count = n()) %>% 
  filter(status == "overtime")

grouped_data_edu$percentage <- grouped_data_edu$count / sum(grouped_data_edu$count) * 100
grouped_data_edu$ymax = cumsum(grouped_data_edu$percentage)
grouped_data_edu$ymin = c(0, head(grouped_data_edu$ymax, n=-1))
#---------model input---------------------------------
loan_train <- read_xlsx("data/loan.xlsx")
loan_train$good_bad_flag <- factor(loan_train$good_bad_flag)
logistic_model <- logistic_reg() %>% 
  set_engine('glm') %>% 
  set_mode('classification')

logistic_fit <- logistic_model %>% 
  fit(good_bad_flag ~ Loanamount + Termdays + Total_loan + Employment,
      data = loan_train)
#---------dashboard structure [siderbar]-------------------------
header <- 
  dashboardHeader( title = HTML("Loan Default Prediction"))

siderbar <- 
  dashboardSidebar(
    sidebarMenu(id = 'sidebarmenu',
                menuItem("Introduction", tabName = "intro", icon = icon("info-circle")),
                menuItem("Loan Data Exploration", tabName = "eda", startExpanded = FALSE, icon = icon("search"),
                         menuSubItem("Demographic Analysis", tabName = "eda_1"),
                         menuSubItem("Previous Loan Analysis", tabName = "eda_2")),
                         
                menuItem("Correlation analysis", tabName = "cor_analysis", startExpanded = FALSE, icon = icon("cogs")
                ),
                menuItem("Loan Application Prediction", tabName = "pre", startExpanded = FALSE, icon = icon("dollar-sign")
                )
    )
  )

#--------dashboardbody--------------------------------
eda_tab_3 <- 
  fluidRow(
    box(
      title = "Loan Amount Distribution",
      status = "primary",
      solidHeader = TRUE,
      selectInput(inputId = "y_var",
                  label = "Select y variable:",
                  choices = c("Default_ratio", "Total_loan", "Total_due"),
                  selected = "Default_ratio"),
      plotOutput(outputId = "tween")
    ),
    box( #add a new graph
      title = "Interest Rate Trend",
      status = "primary",
      solidHeader = TRUE,
      plotOutput(outputId = "interest_rate_trend")
    )
  )
eda_tab_1 <-
  fluidPage(
    radioButtons(
      inputId = "demo_x_var",
      label = "Select demographic input:",
      choices = c("Employment" = "Employment_ca", "Education" = "Education_ca", "Age Group" = "age_group"),
      selected = "Employment_ca"
    ),
    selectInput(
      inputId = "demo_y_var",
      label = "Select y-axis variable for violin plot:",
      choices = c("Loannumber", "Loanamount", "Term days" = "Termdays", "Totaldue", "Total loanamount" = "Total_loan"),
      selected = "Loannumber"
    ),
    plotOutput("demo_plot1"),
    plotOutput("demo_plot2")
  )


eda_tab_2 <-
  fluidRow(
    tabBox(
      title = "Previous Loan Analysis",
      id = "tabset1",
      selected = "Overview",
      width = 30,
      height = "50px",
      tabPanel("Overview",
               fluidRow(
                 column(width = 3,
                        selectInput("x", "Select variable to see amount relationship",
                                    choices = c("status" = "status", "Term days" = "termdays" , "Loan number" = "loannumber",
                                                "Employment" = "employment_status_clients", "Education" = "level_of_education_clients"),
                                    selected = "status")
                 ),
                 column(width = 9,
                        mainPanel(
                          plotOutput("preloan_1_1"),
                          DT::dataTableOutput("preloan_1_2")
                        )
                 )
               )),
      # Another graph
      tabPanel("Tab 1",
               fluidRow(
                 column(width = 12,
                        box(
                          title = NULL,
                          status = "primary",
                          solidHeader = TRUE,
                          plotOutput(outputId = "preloan_2")
                        )
                   
                 ),
                 column(width = 12, box(
                   title = NULL,
                   status = "primary",
                   solidHeader = TRUE,
                   plotOutput(outputId = "preloan_2_1")
                 )),
                 column(width = 12, box(
                   title = NULL,
                   status = "primary",
                   solidHeader = TRUE,
                   plotOutput(outputId = "preloan_2_2")
                 ))
               )
              ),
      tabPanel("Tab 2",
               fluidPage(
                 radioButtons(
                   "fill_var", "Select fill variable:",
                   choices = c("employment_status_clients", "level_of_education_clients"),
                   selected = "employment_status_clients"),
                 plotOutput("preloan_3")
                 )
               ),
      tabPanel("Tab 3",
              fluidPage(selectInput(inputId = "preloan_4_bar",
                                    label = "Select y variable:",
                                    choices = c("Total overtime number" = "Total_bad", "Total loan amount" = "Total_loan", "Total due amount" = "Total_due"),
                                    selected = "Total_bad"),
                        plotOutput(outputId = "preloan_4")
                
              ))
    )
  )

corre_1 <-
  fluidRow(
    box(
      title = "Linear Correlation Exploration",
      status = "primary",
      solidHeader = TRUE,
    checkboxGroupInput(
      inputId = "corr_plot1_var",
      label = "Select variables as follows:",
      choices = c("Loan amount" = "loanamount", "Termdays" = "termdays", "Loan number" = "loannumber", "Total due" = "totaldue"),
      selected = c("loanamount", "termdays"),
      inline = TRUE
    ),
    plotOutput("corrplot_1"),
    
    selectInput(
      inputId = "corr_plot2_xvar",
      label = "Select X variable for the scatter plot:",
      choices = c("Loan amount" = "loanamount", "Termdays" = "termdays", "Loan number" = "loannumber", "Total due" = "totaldue"),
      selected = "loanamount"
    ),
    selectInput(
      inputId = "corr_plot2_yvar",
      label = "Select Y variable for the scatter plot:",
      choices = c("Loan amount" = "loanamount", "Termdays" = "termdays", "Loan number" = "loannumber", "Total due" = "totaldue"),
      selected = "totaldue"
    ),
    plotOutput("corrplot_2")
  ),
  box(
    title = "Non_linear Correlation Exploration",
    status = "primary",
    solidHeader = TRUE,
    selectInput(
      inputId = "corr3_xvar",
      label = "Select X variable:",
      choices = c("Loan amount" = "Loanamount", "Total Due" = "Totaldue", "Loan Number" = "Loannumber", "Termdays", 
                  "Total overtime number" = "Total_bad", "Total number of loans" = "Total_loan_number",
                  "Total due amount" = "Total_due", "Total loan amount" = "Total_loan", "Age", "Employment", "Education")),
      selectInput(
        inputId = "corr3_yvar",
        label = "Select Y variable:",
        choices = c("Loan amount" = "Loanamount", "Total Due" = "Totaldue", "Loan Number" = "Loannumber", "Termdays", 
                    "Total overtime number" = "Total_bad", "Total number of loans" = "Total_loan_number",
                    "Total due amount" = "Total_due", "Total loan amount" = "Total_loan", "Age", "Employment", "Education")
      ),
    plotOutput("corrplot_3")
  )
  )

pre_1 <-
  ui <-
  fluidPage(
    titlePanel("Loan Application Prediction"),
    fluidRow(
      column(width = 6,
             sliderInput(inputId = "Loan_amount",
                         label = "Loan amount",
                         min = min(loan_train$Loanamount),
                         max = max(loan_train$Loanamount),
                         value = mean(loan_train$Loanamount)),
             selectInput(inputId = "Termdays",
                         label = "Termdays",
                         choices = unique(loan_train$Termdays),
                         selected = "Termdays"), 
             sliderInput(inputId = "Total_loan",
                         label = "Previous total loan amount",
                         min = min(loan_train$Total_loan),
                         max = max(loan_train$Total_loan),
                         value = mean(loan_train$Total_loan)),
             selectInput(inputId = "Employment",
                         label = "Employment",
                         choices = c("Permanent" = 6, "Self-Employed" = 5, "Contract" = 4, "Retired" = 3, 
                                    "Student" = 2, "Unemployed" = 1, "NA" = 0),
                         selected = "Employment")),
      column(width = 6,
             mainPanel(
               h3("Predicted Good/Bad Flag"),
               verbatimTextOutput("prediction"))
      )
    )
  )
      
#--------------------------------------------------------      

boardbody <- 
  dashboardBody(
    tabItems(
      tabItem("intro", 
              h2("Welcome to our Loan Default Prediction APP"),
              p(class = "intro-paragraph", "Loan defaulters description: In the first part of this shiny app, we will give you a description of the customers' historical records, including the loan amount, education situation, and employment pattern."),
              p(class = "intro-paragraph", "Correlation exploration: The second part will explore the correlation between different factors to see if there are linear or non-linear correlations, as well as the strength and direction of the relationship."),
              p(class = "intro-paragraph", "Prediction model: In the last part, we built a prediction model to forecast the loan repayment results based on different input information.")
      ),
      tabItem("eda_1", eda_tab_1),
      tabItem("eda_2", eda_tab_2),
      tabItem("cor_analysis", corre_1),
      tabItem("pre", pre_1)
    )
  )

ui <- dashboardPage(skin = "yellow",
                    header, 
                    siderbar,
                    boardbody)

server <- function(input, output) {
  
  output$demo_plot1 <- renderPlot({
    ggbetweenstats(
      data = loandata,
      x = !!sym(input$demo_x_var),
      y = !!sym(input$demo_y_var),
      type = "p",
      mean.ci = TRUE,
      pairwise.comparisons = TRUE,
      pairwise.display = "s",
      p.adjust.method = "fdr",
      messages = FALSE
    )
  })
  #newadd plot2
  output$demo_plot2 <- renderPlot({
    ggbarstats(
      data = loandata,
      x = good_bad_flag,
      y = !!sym(input$demo_x_var)
    )
  })
  
 
  # previous loan begins

  output$preloan_1_1 <- renderPlot({
    ggplot(merged_AC, aes(x = get(input$x), y = loanamount, fill = status)) +
      geom_bar(stat = "identity") +
      labs(title = "Relationship between Loan Status and Amount",
           x = input$x,
           y = "Total Loan Amount",
           fill = "Status")
  })
  
  # Render the data table
  output$preloan_1_2 <- DT::renderDataTable({
    DT::datatable(merged_AC, options = list(pageLength = 10, searching = TRUE, scrollX = TRUE))
  })
  
  output$preloan_2 <- renderPlot({
    ggplot(merged_AC_A, aes(x = age, y = count, color = status)) +
      geom_point() +
      labs(color = "Status")
    
  })
  
  output$preloan_2_1 <- renderPlot({
    ggplot(grouped_data_em, aes(ymax=ymax, ymin=ymin, xmax=4, xmin=3, fill=employment_status_clients)) +
      geom_rect() +
      coord_polar(theta="y") + 
      xlim(c(2, 4)) 
    
  })
  
  output$preloan_2_2 <- renderPlot({
    ggplot(grouped_data_edu, aes(ymax=ymax, ymin=ymin, xmax=4, xmin=3, fill=level_of_education_clients)) +
      geom_rect() +
      coord_polar(theta="y") + 
      xlim(c(2, 4)) 
    
  })
  
  output$preloan_3 <- renderPlot({
    ggplot(merged_AC, aes(x = age, y = loanamount, fill = !!sym(input$fill_var))) +
      geom_col(position = "stack")
    
  })
  
  output$preloan_4 <- renderPlot({
    ggbetweenstats(
      data = loandata,
      x = good_bad_flag,
      y = !!sym(input$preloan_4_bar),
      type = "p",
      mean.ci = TRUE,
      pairwise.comparisons = TRUE,
      pairwise.display = "s",
      p.adjust.method = "fdr",
      messages = FALSE
    )
  }) 
  
  corr_data_1 <- reactive({
    merged_AC[, input$corr_plot1_var, drop = FALSE]
  })
  output$corrplot_1 <- renderPlot({
    ggstatsplot::ggcorrmat(
      data = corr_data_1(), 
      ggcorrplot.args = list(outline.color = "black", 
                             hc.order = TRUE,
                             tl.cex = 10),
      title    = "Correlogram for numerical factors"
    )
  })
  
  
  output$corrplot_2 <- renderPlot({
      ggscatterstats(
        data = merged_AC,
        x = !!sym(input$corr_plot2_xvar),
        y = !!sym(input$corr_plot2_yvar),
        marginal = FALSE
      )
  })
  
  
  output$corrplot_3 <- renderPlot({
    df_loanamountGB <- data.frame(x = train_data[[input$corr3_xvar]],
                                  y = train_data[[input$corr3_yvar]])
    ggplot(df_loanamountGB, aes(x = x, y = y)) +
      geom_line(color = 'steelblue') +
      theme_minimal()
  })
  
  create_newdata <- function() {
    data.frame(
      Loanamount = input$Loan_amount,
      Termdays = input$Termdays,
      Total_loan = input$Total_loan,
      Education_Type1 = ifelse(input$Education == "1", 1, 0),
      Education_Type2 = ifelse(input$Education == "2", 1, 0),
      Education_Type3 = ifelse(input$Education == "3", 1, 0),
      Education_Type4 = ifelse(input$Education == "4", 1, 0),
      Education_Type5 = ifelse(input$Education == "0", 1, 0),
      Employment_Type1= ifelse(input$Employment == "1", 1, 0),
      Employment_Type2 = ifelse(input$Employment == "2", 1, 0),
      Employment_Type3 = ifelse(input$Employment == "3", 1, 0),
      Employment_Type4 = ifelse(input$Employment == "4", 1, 0),
      Employment_Type5 = ifelse(input$Employment == "5", 1, 0),
      Employment_Type6 = ifelse(input$Employment == "6", 1, 0),
    )
  }
  output$prediction <- renderText({
    newdata <- create_newdata()
    prediction <- predict(logistic_fit, newdata,  type = 'prob')
  })
}

shinyApp(ui, server)


