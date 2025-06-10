library(shiny)
library(shinydashboard)
library(plotly)

ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(title = "IF36 - Pokémon"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Tournois", tabName = "tournois", icon = icon("chart-line")),
      menuItem("Carte", tabName = "carte")
    ),
    sliderInput("nb_decks", "Nombre de decks :", min = 20, max = 100, value = 70)
  ),
  dashboardBody(
    
    tabItems(
      
      tabItem(tabName = "carte",
    
              
      ),
      
      tabItem(tabName = "tournois",
              
              fluidRow(
                box(
                  title = "Classement des joueurs selon le rang de leur deck en terme de prix (par tournoi)",
                  width = 12,
                  status = "primary",
                  solidHeader = TRUE,
                  plotlyOutput("plot_classement", height = "500px")
                )
              ),
              fluidRow(
                box(
                  title = "Prix total des decks selon leur rang en terme de prix (par tournoi)",
                  width = 12,
                  status = "info",
                  solidHeader = TRUE,
                  plotlyOutput("plot_prix_deck", height = "500px")
                )
              )
      )
  )
)
)
