# Projet IF36 - Pokémon

## Proposition des Datasets
Voici les differents datasets repérés, qui vont nous permettre de réaliser une exploration pertinente et cohérente de notre sujet :

### 1. The complete pokemon dataset ([dispo. ici](https://www.kaggle.com/datasets/mihirbindal/the-complete-pokemon-dataset))
Ce dataset sera notre jeu de donné principal. En effet, ce jeu de données contient les **noms**, **le numéro du Pokédex**, leur 
**génération**, leurs **capacités**, des statistiques physiques comme la **taille** et le **poids**, leur **type**, leur **multiplicateur de défense contre chaque type**, etc. Ces données incluent non seulement les 890 Pokémon, mais aussi **leurs méga-évolutions**, leurs **formes de Galar**, **d'Alola** ainsi que leurs **formes alternatives**.

Le dataset contient **1034** enregistrements.
<details open>
<summary>Voici la liste des 40 features du dataset :</summary>
<br>

- pokedex_number
- name
- generation
- classification
- abilities
- height_m
- weight_kg
- type1
- type2
- base_total
- hp
- attack
- defense
- sp_attack
- sp_defense
- speed
- against_bug
- against_dark
- against_dragon
- against_electric
- against_fairy
- against_fighting
- against_fire
- against_flying
- against_ghost
- against_grass
- against_ground
- against_ice
- against_normal
- against_poison
- against_psychic
- against_rock
- against_steel
- against_water
- capture_rate
- base_egg_steps
- base_happiness
- is_legendary
- is_mythical
- is_mega

</details>


### 2. Pokemon TCG All Cards 1999 - 2023 ([dispo. ici](https://www.kaggle.com/datasets/adampq/pokemon-tcg-all-cards-1999-2023?select=pokemon-tcg-data-master+1999-2023.csv))
Ce dataset est un jeu de donné agrégé compilant des informations complètes sur les sets et cartes du jeu de cartes à collectionner Pokémon (TCG) de 1999 à 2023, provenant de l'API Pokémon TCG. Ce jeu de données offre une vue d'ensemble détaillée des cartes Pokémon TCG, incluant leurs attributs, capacités, attaques et autres informations pertinentes. Il constitue une ressource précieuse relier chaque pokémon et ses statistiques dans le jeu vidéo, à ses équivalents dans le jeu de carte physique.

Ce dataset contient **17172** enregistrements.

<details>
<summary>Voici les 29 features du dataset : </summary>
  <br>
  
- id
- set
- series
- publisher
- generation
- release_date
- artist
- name
- set_num
- types
- supertype
- subtypes
- level
- hp
- evolvesFrom
- evolvesTo
- abilities
- attacks
- weaknesses
- retreatCost
- convertedRetreatCost
- rarity
- flavorText
- nationalPokedexNumbers
- legalities
- resistances
- rules
- regulationMark
- ancientTrait
- </details>

### 3. Pokémon Trading Cards ([dispo. ici](https://www.kaggle.com/datasets/jacklacey/pokemon-trading-cards))
Ce dataset pourra être utilisé en complément du précédent. Il permet de relier les cartes du jeu à leur prix de vente. Il contient des données détaillant les cartes Pokémon en vente sur chaoscards.co.uk. 

Ce dataset contient **25598** enregistrements.

Chaque enregistrement contient :
- le Pokémon
- son type de carte
- la génération
- son numéro de carte
- le prix de la carte

### 4. Limitless PTCGP All Data ([dispo. ici](https://www.kaggle.com/datasets/updatethisplz/limitless-ptcgp-all-data))
Ce dataset est similaire au numéro 2, mais se porte sur les cartes virtuelles (du jeu mobile sorti en 2024). Ainsi; il contient des informations sur les cartes des pokémons du jeu TCG Pocket.

Il contient **405** enregistrements.

<details>
<summary>Chaque enregistrement possède les features suivantes : </summary>
  <br>
  
- rarity
- card_name
- weakness
- energy_type
- expansion
- number
- illustration
- obtaining_method
- type
- retreat_cost
- hp
- description
- move1_name
- move1_energy_cost
- move1_power
- move1_effect
- move2_name
- move2_energy_cost
- move2_power
- move2_effect
- pull_rate_at_least_one
- card_number,full_card_name
</details>

### 5. Sondage de popularité ([dispo. ici](https://pastebin.com/LvhaTx7w))
Ce dataset est le seul que nous avons trouvé pour obtenir des informations sur la popularité des pokémons. Il provient d'un sondage fait sur un forum de fans de la license (**52 725** votants).
Les données sont également disponibles [ici](https://docs.google.com/spreadsheets/d/1c16Wh4AawHGbTi3Eq1DGZQdM4FMUlJO1YwXJZ_ylRvg/edit?gid=557303698#gid=557303698), où elles sont un peu analysées

Le dataset contient **810** enregistrements.

Chaque enregistrement possède les features suivantes :
- Nom du pokémon
- Nombre de vote
- Place dans le classement


### 6. Pokemon TCG - All Tournaments Decks (2011-2023) ([dispo. ici](https://www.kaggle.com/datasets/enriccogemha/pokemon-tcg-all-tournaments-decks-2011-2023))
Ce dataset contient lui aussi des données sur les cartes physiques, mais se concentre sur leur utilisation en tounoi. Ainsi, on peut savoir quelles cartes sont les plus jouées, et dans quels combos (= combinées avec quelles autres cartes) celles-ci sont jouées.

Il contient **114 292** enregistrements.

<details>
<summary>Chaque enregistrement possède les features suivantes : </summary>
  <br>
  
- id_card
- name_card
- amount_card
- price_card
- energy_type_card
- type_card
- combo_type_id
- combo_type_name
- id_player
-	name_player
-	country_player
-	all_time_score
-	ranking_player_tournament
-	id_tournament
-	category_tournament
-	name_tournament
-	region_tournament
-	country_tournament
-	year_tournament
-	month_tournament
-	day_tournament
-	valid_rotation_at_tournament
-	rotation_name
-	year_begin
-	month_begin
- day_begin

</details>

### 7. Pokemon Image Dataset ([dispo. ici](https://www.kaggle.com/datasets/vishalsubbiah/pokemon-images-and-types))
Ce dataset contient des photos de pokémon. Il peut être utile pour un rapport.


### 8. Video Game Sales ([dispo. ici](https://www.kaggle.com/datasets/gregorut/videogamesales))
Ce dataset contient une liste des hjeux vidéos vendus à plus de 100 000 copies. Il Peut nous permettre de lier les ventes des jeux vidéos pokémons, à par exemple, la popularité de certain pokémons.

Il contient **16 599** enregistrements.

<details>
<summary>Chaque enregistrement possède les features suivantes : </summary>
  <br>
- Rank
- Name
-	Platform
-	Year
-	Genre
-	Publisher
-	NA_Sales
-	EU_Sales
-	JP_Sales
-	Other_Sales
-	Global_Sales
</details>

## Exemples de questionnements
En utilisant les datasets précédents, nous avons identifiés plusieurs questionnements / raisonnements qui pourraient servir de bases aux data-visualisations réalisées :

1. The complete pokemon dataset
- Les différents types de pokémons sont ils équitablements répartis ? Cette distribution change t'elle d'une génération à une autre ?
- Quelles combinaisons de type 1 / type 2 sont les plus courantes ? 
- Observe t'on une relation entre le poids et la taille ?
- Observe t'on une relation entre la taille, le poids et la vitesse des pokémons ?
- Quel est le nombre de pokémons introduits à chaque génération ?
- Quel est le nombvre / la répartition des pokémons légendaires parmis ceux introduits à chaque générations ?

2. Pokemon TCG All Cards 1999 - 2023 :
- Voir la répartition des types de Pokémon (Feu, Eau, Plante, etc..) par génération
- Comparaison des HP et attaques selon le type
- Comparaison des HP et attaques selon la rareté de la carte

3. Pokémon Trading Cards :
- Prix moyen des cartes selon la génération
- Quelles cartes Pokémon sont les plus chères (prendre un TOP 20)
- Corrélation entre prix et génération
- Comparaison du prix moyen entre les types de cartes
- Répartition des types de cartes

4. Limitless PTCGP All Data :
Raisonnement similaire au jeu de cartes physique, et comparaison avec celui-ci.

5. Sondage de popularité :

- Quels sont les Pokémons les plus populaires ?
- Est-ce qu'il y'a une corrélation entre la popularité et la génération ?
- Est-ce qu'il y'a une corrélation entre la popularité et le type ?
  
8. Video Game Sales :

- Evolution des ventes des jeux Pokémon 
- Analyse des ventes des jeux Pokémon par région
- Comparaison des ventes des jeux principaux (Pokémon Noir & Blanc, Rouge, etc..) contre les spin-offs (Mystery Dungeon, Snap)
- Montrer si il y'a une corrélation entre année de sortie et ventes

## Auteurs du projet
- Musset Aurélien
- Arulraj Sinthujan
- Schummer Lucas
- Khuu Sophie
