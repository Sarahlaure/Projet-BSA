# Charger les données
fusionacled <- read_excel("www/fusionacled.xlsx")
Base_CoteIvoire_Nettoyee <- read_excel("E:/ISEP 2/MON DOSSIER/APPRENTISSAGE DES VACANCES/ISEP3/Projet BSA/GITHUB/Projet-BSA/BASES DE DONNEES CORRIGEES/Base_CoteIvoire_Nettoyee.xlsx")

# Afficher les structures des données
str(fusionacled)
str(Base_CoteIvoire_Nettoyee)

# Comparer les colonnes entre les deux bases
cols_in_uemoa_not_in_ivory_coast <- setdiff(names(fusionacled), names(Base_CoteIvoire_Nettoyee))
cols_in_ivory_coast_not_in_uemoa <- setdiff(names(Base_CoteIvoire_Nettoyee), names(fusionacled))

# Afficher les colonnes manquantes
cat("Colonnes dans fusionacled mais pas dans Base_CoteIvoire_Nettoyee:\n")
print(cols_in_uemoa_not_in_ivory_coast)

cat("\nColonnes dans Base_CoteIvoire_Nettoyee mais pas dans fusionacled:\n")
print(cols_in_ivory_coast_not_in_uemoa)

# Convertir date_start en Date en extrayant uniquement la partie "MM/DD/YYYY"
Base_CoteIvoire_Nettoyee$date_start <- as.Date(sub(" .*", "", Base_CoteIvoire_Nettoyee$date_start), format="%m/%d/%Y")

# Vérification du format de date_start après conversion
cat("\nVérification du format de date_start après conversion :\n")
str(Base_CoteIvoire_Nettoyee$date_start)

# Extraire l'année et le mois de "date_start"
Base_CoteIvoire_Nettoyee$annee_start <- format(Base_CoteIvoire_Nettoyee$date_start, "%Y")
Base_CoteIvoire_Nettoyee$mois_start <- format(Base_CoteIvoire_Nettoyee$date_start, "%m")

# Répéter le même processus pour date_end
Base_CoteIvoire_Nettoyee$date_end <- as.Date(sub(" .*", "", Base_CoteIvoire_Nettoyee$date_end), format="%m/%d/%Y")

# Extraire l'année et le mois de "date_end"
Base_CoteIvoire_Nettoyee$annee_end <- format(Base_CoteIvoire_Nettoyee$date_end, "%Y")
Base_CoteIvoire_Nettoyee$mois_end <- format(Base_CoteIvoire_Nettoyee$date_end, "%m")

# Vérification des nouvelles colonnes ajoutées
head(Base_CoteIvoire_Nettoyee)

# Fusionner les bases après avoir ajouté les colonnes manquantes
fusionacled2 <- rbind(Base_CoteIvoire_Nettoyee, fusionacled)

# Vérifier la structure de la base fusionnée
str(fusionacled2)

# Compter le nombre de conflits par année (en fonction de 'annee_start')
conflits_par_annee <- fusionacled2 %>%
  group_by(annee_start) %>%
  summarise(n_conflits = n())  # n() compte le nombre d'entrées (conflits) par année

# Vérifier les résultats
head(conflits_par_annee)

# Créer un graphique avec ggplot2
ggplot(conflits_par_annee, aes(x = annee_start, y = n_conflits)) +
  geom_line(color = "red", size = 1) +  # Ligne pour l'évolution
  geom_point(color = "blue", size = 3) +   # Points pour chaque année
  labs(title = "Évolution du nombre de conflits dans le temps",
       x = "Année",
       y = "Nombre de conflits") +
  theme_minimal()+  # Utiliser un thème minimal pour une meilleure lisibilité
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Utiliser un thème minimal pour une meilleure lisibilité

# Compter la fréquence des types de violence
violence_types <- table(fusionacled2$type_of_violence)

# Graphique en barres des types de violence
ggplot(data = as.data.frame(violence_types), aes(x = Var1, y = Freq)) +
  geom_bar(stat = "identity", fill = "lightblue") +
  labs(title = "Répartition des types de violence dans les conflits",
       x = "Type de violence",
       y = "Fréquence") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Résumer le nombre total de décès pour chaque type
deces_par_type <- fusionacled2 %>%
  summarise(deaths_a_total = sum(deaths_a, na.rm = TRUE),
            deaths_b_total = sum(deaths_b, na.rm = TRUE),
            deaths_civilians_total = sum(deaths_civilians, na.rm = TRUE),
            deaths_unknown_total = sum(deaths_unknown, na.rm = TRUE))

# Nombre de conflits par région
conflits_par_region <- fusionacled2 %>%
  group_by(country) %>%
  summarise(n_conflits_region = n())

# Graphique en barres des conflits par région
ggplot(conflits_par_region, aes(x = reorder(country, n_conflits_region), y = n_conflits_region)) +
  geom_bar(stat = "identity", fill = "purple") +
  labs(title = "Nombre de conflits par région",
       x = "Région",
       y = "Nombre de conflits") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# Résumer les décès civils et militaires par année
deces_par_annee <- fusionacled2 %>%
  group_by(annee_start) %>%
  summarise(total_deces_civils = sum(deaths_civilians, na.rm = TRUE),
            total_deces_militaires = sum(deaths_a, na.rm = TRUE) + sum(deaths_b, na.rm = TRUE))

# Graphique des décès civils et militaires par année
ggplot(deces_par_annee, aes(x = annee_start)) +
  geom_line(aes(y = total_deces_civils, color = "Décès civils"), size = 1) +
  geom_line(aes(y = total_deces_militaires, color = "Décès militaires"), size = 1) +
  labs(title = "Évolution des décès civils et militaires dans le temps",
       x = "Année",
       y = "Nombre de décès") +
  scale_color_manual(values = c("Décès civils" = "blue", "Décès militaires" = "red")) +
  theme_minimal()

## Pour ressortir le gif 

library(tidyverse)
library(sf)
library(rnaturalearth)
library(gganimate)
library(ggspatial)
library(viridis) # Pour de meilleures couleurs

# 1. Préparation des données
uemoa_countries <- c("Benin", "Burkina Faso", "Ivory Coast", "Guinea-Bissau",
                     "Mali", "Niger", "Senegal", "Togo")

conflits_agg <- fusionacled2 %>%
  filter(country %in% uemoa_countries) %>%
  mutate(year = as.integer(year)) %>% 
  count(country, year, name = "n_conflits") %>% 
  complete(country, year = full_seq(year, 1), fill = list(n_conflits = 0))

# 2. Préparation de la carte
africa <- ne_countries(scale = "medium", returnclass = "sf")
uemoa_sf <- africa %>%
  mutate(
    country = recode(name_en, "Côte d'Ivoire" = "Ivory Coast"),
    name_en = ifelse(country == "Ivory Coast", "IVORY COAST", toupper(name_en))
  ) %>%
  filter(country %in% uemoa_countries) %>%
  left_join(conflits_agg, by = "country") %>%
  mutate(centroid = st_centroid(geometry))

# 3. Design amélioré
animation <- ggplot(uemoa_sf) +
  geom_sf(aes(fill = n_conflits), color = "white", size = 0.4, alpha = 0.9) +
  
  # Étiquettes stylisées
  geom_sf_text(
    aes(label = name_en, geometry = centroid),
    color = "#2d3436",
    size = 4,
    fontface = "bold",
    family = "Arial Narrow"
  ) +
  
  # Palette moderne
  scale_fill_viridis(
    name = "Nombre de conflits",
    option = "magma",
    direction = -1,
    limits = c(0, max(conflits_agg$n_conflits)),
    guide = guide_colorbar(
      barwidth = unit(100, "mm"),
      title.position = "top"
    )
  ) +
  
  # Éléments cartographiques
  annotation_scale(
    location = "bl",
    style = "ticks",
    line_col = "#2d3436",
    text_col = "#2d3436"
  ) +
  annotation_north_arrow(
    location = "tr",
    height = unit(1.5, "cm"),
    width = unit(1.5, "cm"),
    style = north_arrow_fancy_orienteering(
      fill = c("#2d3436", "white"),
      line_col = "#2d3436"
    )
  ) +
  
  # Titrage élégant
  labs(
    title = "Année : {current_frame}",
    caption = "Source : UCDP | Visualisation : UEMOA"
  ) +
  
  # Thème minimaliste
  theme_void() +
  theme(
    plot.background = element_rect(fill = "#f5f6fa", color = NA),
    plot.title = element_text(
      size = 26,
      face = "bold",
      hjust = 0.5,
      margin = margin(b = 8),
      color = "#2d3436"
    ),
    
    legend.position = "bottom",
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 10),
    plot.caption = element_text(
      color = "#636e72",
      hjust = 0.98,
      size = 10,
      margin = margin(t = 15)
    )
  ) +
  
  transition_manual(year)

# 4. Export optimisé
animate(
  animation,
  duration = 15,
  fps = 10,
  width = 1600,
  height = 1200,
  res = 200,
  renderer = gifski_renderer("conflits_uemoa_final.gif"),
  device = "ragg_png",
  start_pause = 5,
  end_pause = 10
)