library(shiny)
library(shinydashboard)
library(plotly)

ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(title = "IF36 - Pokémon"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Tournois", tabName = "tournois", icon = icon("chart-line")),
      menuItem("Aide au combats de cartes", tabName = "aide_combats",  icon = icon("hand-fist")),
      menuItem("Popularité", tabName = "popularity",  icon = icon("star"))
    ),
    sliderInput("nb_decks", "Nombre de decks :", min = 20, max = 100, value = 70),
    checkboxGroupInput(
      inputId = "filtre_generation",
      label = "Sélectionnez les générations à inclure :",
      choices = c(1, 2, 3, 4, 5, 6, 7, 8),
      selected = c(1, 2, 3, 4, 5, 6, 7, 8)
    )
  ),
  dashboardBody(
    
    tabItems(
      
      tabItem(tabName = "aide_combats",
              fluidRow(
                box(
                  width = 12,
                  plotlyOutput("heatmap", height = "500px")
                )
              )
              
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
      ),
      
      tabItem(tabName = "popularity",
              fluidRow(
                box(
                  width = 12,
                  plotOutput("plot_popularity", height = "500px")
                )
              )
              
      )
  )
)
)
