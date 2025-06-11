library(shiny)
library(dplyr)
library(readr)
library(plotly)
library(ggplot2)

df_raw <- read_csv("../data/tournaments.csv")
df_general <- read.csv("../data/Pokemon_data.csv", sep = ",")
df_popularity <- tibble(read.table("../data/popularity.txt", header = TRUE, sep = ","))



server <- function(input, output) {
  aide_combats <- reactive({
    df <- df_general %>%
      select(generation, name, type1, against_bug, against_dark, against_dragon,
             against_electric, against_fairy, against_fighting, against_fire,
             against_flying, against_ghost, against_grass, against_ground,
             against_ice, against_normal, against_poison, against_psychic,
             against_rock, against_steel, against_water)

    #On filtre les types selon les générations sélectionnées
    df <- df %>%
      filter(generation %in% req(input$filtre_generation)) %>%
      select(-generation)

    #On calcule la moyenne des coefficients "against" par type
    mean_against_by_type <- df %>%
      group_by(type1) %>%
      summarise(
        mean_against_bug = mean(against_bug, na.rm = TRUE),
        mean_against_dark = mean(against_dark, na.rm = TRUE),
        mean_against_dragon = mean(against_dragon, na.rm = TRUE),
        mean_against_electric = mean(against_electric, na.rm = TRUE),
        mean_against_fairy = mean(against_fairy, na.rm = TRUE),
        mean_against_fighting = mean(against_fighting, na.rm = TRUE),
        mean_against_fire = mean(against_fire, na.rm = TRUE),
        mean_against_flying = mean(against_flying, na.rm = TRUE),
        mean_against_ghost = mean(against_ghost, na.rm = TRUE),
        mean_against_grass = mean(against_grass, na.rm = TRUE),
        mean_against_ground = mean(against_ground, na.rm = TRUE),
        mean_against_ice = mean(against_ice, na.rm = TRUE),
        mean_against_normal = mean(against_normal, na.rm = TRUE),
        mean_against_poison = mean(against_poison, na.rm = TRUE),
        mean_against_psychic = mean(against_psychic, na.rm = TRUE),
        mean_against_rock = mean(against_rock, na.rm = TRUE),
        mean_against_steel = mean(against_steel, na.rm = TRUE),
        mean_against_water = mean(against_water, na.rm = TRUE)
      )

    # Transformation des données pour la heatmap
    heatmap_data <- mean_against_by_type %>%
      pivot_longer(
        cols = starts_with("mean_against"),
        names_to = "against_type",
        values_to = "mean_value"
      ) %>%
      mutate(against_type = gsub("mean_against_", "", against_type))
    
    return(heatmap_data)

  })

  output$heatmap <- renderPlotly({
    data <- aide_combats()
    ggplot(data, aes(x = type1, y = against_type, fill = mean_value)) +
      geom_tile(color = "white") +
      geom_text(aes(label = round(mean_value, 2)), color = "black", size = 3) + # Ajout des labels
      scale_fill_gradient2(
        low = "blue",    # Couleur pour les valeurs basses (proche de 0)
        mid = "white",   # Couleur neutre pour la valeur 1
        high = "red",    # Couleur pour les valeurs hautes (proche de 2)
        midpoint = 1,    # Point central du dégradé
        name = "Moyenne" # Légende de l'échelle
      ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    labs(
      title = "Heatmap des moyennes des coefficients de dégâts infligés par type d'attaque pour chaque type principal du pokémon adverse",
      x = "Type principal du Pokémon attaqué",
      y = "Type de l'attaque"
    )  

  })


  #-----------------------------------------------------------------------------------------
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
  
  #--------------------------------------------
  
  pok_data_filtered <- reactive({
    
    #On filtre les types selon les générations sélectionnées
    df <- df_general %>%
      filter(generation %in% req(input$filtre_generation)) %>%
      select(-generation)
    
    return(df)
    
  })
  
  
  output$plot_popularity <- renderPlot({
    
    merged <- df_popularity %>% left_join(pok_data_filtered() %>% select(name, type1), by = c("Pokemon" = "name"))
    
    # Create aggregated data by Pokemon type
    type_summary <- merged %>%
      filter(!is.na(type1)) %>%
      group_by(type1) %>%
      summarise(TotalVotes = sum(Number.of.votes), Count = n()) %>%
      mutate(AvgVotes = TotalVotes / Count) %>%
      arrange(desc(AvgVotes)) %>%
      left_join(
        # Select the most popular Pokemon for each type
        merged %>%
          filter(!is.na(type1)) %>%
          group_by(type1) %>%
          slice_max(Number.of.votes, n = 1) %>%
          select(type1, Pokemon, Number.of.votes), 
        by = "type1"
      ) %>%
      mutate(img_path = paste0("../data/images/", tolower(Pokemon), ".png"))
    
    # Define colors of each type for graphical purpose
    type_colors <-c(
      'Normal'= '#A8A77A',
      'Fire' = '#EE8130',
      'Water' = '#6390F0',
      'Electric' = '#F7D02C',
      'Grass' = '#7AC74C',
      'Ice' = '#96D9D6',
      'Fighting' = '#C22E28',
      'Poison' = '#A33EA1',
      'Ground' = '#E2BF65',
      'Flying' = '#A98FF3',
      'Psychic' = '#F95587',
      'Bug' = '#A6B91A',
      'Rock' = '#B6A136',
      'Ghost' = '#735797',
      'Dragon' = '#6F35FC',
      'Dark' = '#705746',
      'Steel' = '#B7B7CE',
      'Fairy' = '#D685AD'
    )
    
    # Compute the average number of votes
    avg_votes <- mean(type_summary$TotalVotes) / sum(type_summary$TotalVotes) * 100
    
    # Draw graph
    p_pop <- type_summary %>%
      ggplot(aes(x = reorder(type1, -TotalVotes), 
                 y = TotalVotes / sum(TotalVotes) * 100, 
                 fill=type1)) +
      # Colored bars
      geom_col(show.legend = FALSE) +
      geom_hline(yintercept = avg_votes, linetype = "dashed", color = "red", linewidth = 1, alpha=.5) +
      
      # Black bars
      geom_col(aes(y = Count / sum(Count) * 100, fill = "Nombre de Pokémons"), alpha = 0.3, width = 0.6) +
      
      # Fake invisible layer to create "Nombre de Votes" legend
      geom_col(aes(y = 0, fill = "Nombre de Votes"), show.legend = TRUE) +
      
      scale_fill_manual(
        name = NULL,
        values = c(type_colors, "Nombre de Pokémons" = "black", "Nombre de Votes" = "#6390F0"),
        breaks = c("Nombre de Votes", "Nombre de Pokémons")
      ) +
      guides(fill = guide_legend(override.aes = list(alpha = c(1, 0.3)))) +
      
      annotate("text", x = 14, y = avg_votes + 1, label = "Popularité moyenne", color = "red", size = 4, hjust = 0) +
      labs(title = "Popularité des types de Pokemon", subtitle = "Nombre de votes par type", x = "Type", y = "%") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = c(0.85, 0.85)) +
      
      geom_image(aes(image=img_path, y = TotalVotes / sum(TotalVotes) * 100 + 1), size=.2)
    
    print(p_pop)
    
    
  })
  
  
  
}
