library(shiny)
library(dplyr)
library(readr)
library(plotly)
library(ggplot2)

df_raw <- read_csv("data/tournaments.csv")

server <- function(input, output) {
  
  deck_analysis <- reactive({
    nb_decks <- input$nb_decks
    
    df <- df_raw %>%
      mutate(
        amount_card = suppressWarnings(as.numeric(amount_card)),
        price_card = suppressWarnings(as.numeric(price_card)),
        ranking_player_tournament = suppressWarnings(as.numeric(ranking_player_tournament))
      ) %>%
      filter(!is.na(amount_card), !is.na(price_card), !is.na(ranking_player_tournament)) %>%
      mutate(total_card_price = amount_card * price_card)
    
    participants_par_tournoi <- df %>%
      distinct(id_tournament, id_player) %>%
      count(id_tournament, name = "nb_participants") %>%
      filter(nb_participants >= 10)
    
    df <- df %>%
      semi_join(participants_par_tournoi, by = "id_tournament")
    
    deck_price <- df %>%
      group_by(id_player, id_tournament) %>%
      summarise(total_deck_price = sum(total_card_price, na.rm = TRUE), .groups = "drop")
    
    ranking_info <- df %>%
      select(id_player, id_tournament, ranking_player_tournament) %>%
      distinct()
    
    merged_df <- left_join(deck_price, ranking_info, by = c("id_player", "id_tournament")) %>%
      group_by(id_tournament) %>%
      mutate(rank_price_deck = rank(-total_deck_price, ties.method = "min")) %>%
      ungroup()
    
    top10_df <- merged_df %>%
      filter(rank_price_deck <= nb_decks)
    
    median_df <- top10_df %>%
      group_by(rank_price_deck) %>%
      summarise(median_rank = median(ranking_player_tournament), .groups = "drop") %>%
      mutate(rank_price_deck_num = as.numeric(rank_price_deck))
    
    mean_no_outliers_df <- top10_df %>%
      group_by(rank_price_deck) %>%
      summarise(
        Q1 = quantile(ranking_player_tournament, 0.25),
        Q3 = quantile(ranking_player_tournament, 0.75),
        IQR = Q3 - Q1,
        mean_no_outliers = mean(ranking_player_tournament[ranking_player_tournament >= (Q1 - 1.5*IQR) & ranking_player_tournament <= (Q3 + 1.5*IQR)]),
        .groups = "drop"
      ) %>%
      mutate(rank_price_deck_num = as.numeric(rank_price_deck))
    
    diag_df <- data.frame(
      rank_price_deck = factor(1:nb_decks, levels = as.character(1:nb_decks)),
      ranking_player_tournament = 1:nb_decks
    )
    
    mean_price_df <- top10_df %>%
      group_by(rank_price_deck) %>%
      summarise(mean_price = mean(total_deck_price, na.rm = TRUE), .groups = "drop")
    
    list(
      top10_df = top10_df,
      median_df = median_df,
      mean_no_outliers_df = mean_no_outliers_df,
      diag_df = diag_df,
      mean_price_df = mean_price_df
    )
  })
  
  output$plot_classement <- renderPlotly({
    data <- deck_analysis()
    
    p1 <-ggplot(data$top10_df, aes(x = as.factor(rank_price_deck), y = ranking_player_tournament, fill = as.numeric(rank_price_deck))) +
      geom_boxplot(color = "black", outlier.size = 0.8, alpha = 0.9) +
      geom_line(data = data$diag_df,
                aes(x = rank_price_deck, y = ranking_player_tournament, group = 1,
                    color = "Référence y = x", fill = NULL), linetype = "solid", size = 1.5, inherit.aes = FALSE) +
      geom_smooth(data = data$median_df,
                  aes(x = rank_price_deck_num, y = median_rank, group = 1, color = "Médiane"),
                  method = "loess", size = 1.5, se = FALSE) +
      geom_smooth(data = data$mean_no_outliers_df,
                  aes(x = rank_price_deck_num, y = mean_no_outliers, group = 1, color = "Moyenne sans outliers"),
                  method = "loess", size = 1.5, se = FALSE) +
      scale_fill_gradient(name = "Rang du deck", low = "navy", high = "turquoise") +
      scale_color_manual(
        name = "Courbes",
        values = c("Médiane" = "purple3", "Moyenne sans outliers" = "chartreuse3", "Référence y = x" = "firebrick")
      ) +
      
      labs(
        title = paste("Distribution du classement des joueurs pour les", input$nb_decks, "decks les plus chers (par tournoi)"),
        x = "Rang du deck en terme de prix (1 = le plus cher)", y = "Classement du joueur"
      ) +
      scale_x_discrete(breaks = as.character(c(1, seq(10, input$nb_decks, by = 10))))+
      theme_light(base_size = 13)
    
    # Calculer les limites de l'axe Y pour l'inversion
    y_min <- min(data$top10_df$ranking_player_tournament, na.rm = TRUE)
    y_max <- max(data$top10_df$ranking_player_tournament, na.rm = TRUE)
    
    custom_breaks <- c(1, seq(10, y_max, by = 10))
    
    ggplotly(p1, tooltip = c("x", "y")) %>%
      layout(
        title = list(text = paste("Distribution du classement des joueurs pour les", input$nb_decks, "decks les plus chers (par tournoi)"), 
                     font = list(size = 16)),
        hovermode = "closest",
        yaxis = list(
          title = "Classement du joueur",
          range = c(y_max , y_min ),  # Ajouter une marge et inverser
          tickvals = custom_breaks,
          ticktext = custom_breaks,
          tickmode = "array",
          autorange = FALSE,  # Important : désactiver l'auto-range
          fixedrange = FALSE,
          type = "linear"
        )
      ) %>%
      config(displayModeBar = TRUE, displaylogo = FALSE)
  })
  
  output$plot_prix_deck <- renderPlotly({
    data <- deck_analysis()
    
    p2 <- ggplot(data$top10_df, aes(x = as.factor(rank_price_deck), y = total_deck_price, fill = as.numeric(rank_price_deck))) +
      geom_boxplot(color = "black", outlier.size = 0.8, alpha = 0.9) +
      geom_line(data = data$mean_price_df,
                aes(x = as.factor(rank_price_deck), y = mean_price, group = 1, color = "Moyenne"),
                size = 1.5, inherit.aes = FALSE) +
      scale_fill_gradient(name = "Rang du decks", low = "navy", high = "turquoise") +
      scale_color_manual(name = "Courbes", values = c("Moyenne" = "darkorange")) +
      labs(
        title = paste("Distribution des prix des decks pour les", input$nb_decks, "decks les plus chers (par tournoi)"),
        x = "Rang du deck", y = "Prix total ($)"
      ) +
      scale_x_discrete(breaks = as.character(c(1, seq(10, input$nb_decks, by = 10)))) +
      theme_light(base_size = 13)
    
    ggplotly(p2, tooltip = c("x", "y", "fill")) %>%
      layout(
        title = list(text = paste("Distribution des prix des decks pour les", input$nb_decks, "decks les plus chers (par tournoi)"), 
                     font = list(size = 16)),
        hovermode = "closest",
        yaxis = list(title = "Prix total ($)", tickformat = "$,.0f")
      ) %>%
      config(displayModeBar = TRUE, displaylogo = FALSE)
  })
  
  
  
}
