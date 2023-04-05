---
date: "2023-04-02"
title: Project Report
---

## Motivation

Providing profitable and high-impact loans to clients are the main business model of SuperLender. But it is necessary to predict the risks of providing loans to clients. Loan default can cause revenue damage.  On the contrary, the inaccurate prediction of the risks can also hurt the reputation of company.  Therefore, in this project, we focus on load default prediction which can help SuperLender grab the most revenue.

## Set the Scenario 

1.	SuperLender is a local digital lending company that can provide loans to clients, but if the company could not estimate the property background and do a wrong decision for the clients, it can cause revenue and reputation loss.

2.	Whether to provide loans to clients or not depends on several factors. To make accurate decisions, we need to use statistic tools and visualization tools which requires a bit of coding, such as R, tableau, and shiny. 

3.	Based on the huge amount of clients’ background data, we need to explore data and then build the prediction model of loading prediction, which can show us what type of clients fit our business. It can also help us to decide the amount of loan and the time period. 


## Problem

1.	The team needs to use statistical skills, data processing skills and data visualization skills to do the accurate and reliable data-wrangling of loan data and produce meaningful visualisations to draw useful insights that can reflect useful knowledge.

2.	Based on the historical clients’ loan data and demographical data, the team will focus on the user portrait, which will display the background information depending on the different loan-returning actions.

3.	The team needs to predict the client’s current loan performance, which is based on historical loan data. Here are two situations:  The client has returned the previous loan and the client still has the previous loan. The teams need to predict the potential risks and decide whether to allocate the loans, the return period, interest, and amount.

The team aims to build a free website which can be used easily. This website does not require uses to have too much background knowledge and they only need to input several factors, then the website can produce a great visualization and offer decision on loan providing.

## Solution

Using various R packages, the team extracted, analysed, and visualized clients’ performance and demographic data. And the team also built an interactive R shiny application that can directly deliver the insight whether the client can be provided the loan and the amount of the loan and the time period of return.

1. The team used EDA and clustering techniques to explore the background data of clients , which can help to display  the users’portraits.

2.	Firstly, the team explored how the previous defaulters looked like and to which groups they belonged: using demographic data and previous loans data to identify defaulters, then divided them into groups. Analysing birthday data to define age of applicant, different types of employment to explore the occupation of applicants, longitude and latitude to know the location of bank branch, highest education level to extract the education level of applicants. There is also data of the location of branch which will be used to analyse if there is possibility that loan from specific bank branch is more likely to defaulte.

3.	Secondly, the team merged the data above to explore the pattern and features of defaulted loans. As to the history loans recording, each will have a unique systemloanid which will be used to identify and locate. Date that loan application was created showed the creating period, date that loan was approved showed the approve time, data that loan was settled showed the settled time, data of first payment due in case where the term is longer than 30 to identify the amount of the loan, which showed the different loan value, total repayment required to settle. 

4.	Based on the historical loan data, the team trained a prediction model which used to predict the possibility of load defaulting, the amount of loan and the time period of return. There are 2 hypotheses: 

a)	If a client had historical loan data but he/she is applying for new loan, the model would predict whether his application would be approved based on the historical loan data(trainprevloans.csv). 

b)	If a client has applied loans before but hasn’t returned them all, the model also can predict the probability of defaulting base on the client’s data (Performance data and Demographic data ).

## Data

There are 3 datasets for train and another 3 for test.  

1.	Demographic data (traindemographics.csv) 

2.	Performance data (trainperf.csv) 

3.	Previous loans data (trainprevloans.csv) 

## Methodology and Analytical Approach 

### Exploratory Data Analysis (EDA) via Data Visualisation

In this project, Exploratory Data Analysis (EDA) in the form of visualization techniques will be applied to explore the customer pattern and demographic economic factors behind.

### Prediction Model Building 

Applied machine learning methods to train prediction models that can help the company to identify and decision-making.

Logistic Regression: Logistic regression is a statistical method used for binary classification problems, where the goal is to predict a binary outcome (e.g., true or false, yes or no, 0 or 1) based on one or more predictor variables. In this case, the final outcome could be seen as binary so we applied Logistic Regression. 

Random forest: Random forest is a supervised machine learning algorithm used for classification, regression, and other tasks that involve predicting an output variable based on several input variables or features. It is an ensemble learning technique that combines multiple decision trees to create a more robust and accurate model. In this case, it is ideal to apply random forest to forecast the loan result.

###	R Shiny & Quarto

The team applied R and Shiny to build up an interactive webpage which showed the relationship between different variables. The team also built machine learning model in Rstudio which was used to predict future loan repayment.

## Our Storyboard

After giving the detailed information of our clients in terms of education status, bank location, and loan terms, the team tried to integrate the information together to see the correlation between the client’s portrait and loan performance. The audience can use the select button to present their desired information in detail. 
 
In the graph of loan number & amount, the client’s education status, account type, and job are all set as filter sectors, and the audience would have a clear picture of the amount of loan and number of rough bar charts and line graph respectively. The change of graph by selecting different items can show a general relationship and give more insight to our users.
 
In the heat map and correlation plot, we tried to quantify the relationship of multi variants. As the wiliness to loan is an important factor, the heat map showed who were banks major clients in terms of occupation. The overview was presented in the first place and users could check for more information in the tool kit. In the correlation graph, each element was corresponded to others and the colour depth showed their relationship, which provided reference for our data model training.
