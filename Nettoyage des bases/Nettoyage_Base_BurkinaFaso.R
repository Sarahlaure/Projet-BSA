library(readr)
library(dplyr)
library(stringr)
library(tidyr)
library(writexl)

# Lire le fichier en spécifiant qu'il n'y a qu'une seule colonne
data <- read_delim("E:/ISEP 2/MON DOSSIER/APPRENTISSAGE DES VACANCES/ISEP3/Projet BSA/BASES DE DONNEES INITIALES/Burkina.csv",
                   delim = "*", escape_double = FALSE, trim_ws = TRUE, col_names = FALSE)

# Supprimer toutes les lignes incohérentes c a d celle ne commencant pas par un nombre 
# Renommer la colonne pour plus de clarté (optionnel)
colnames(data) <- "ligne"
# Filtrer les lignes dont le contenu commence par un chiffre
filtered_data_BF <- data %>% filter(grepl("^[0-9]", ligne))
# Afficher un aperçu du data frame filtré
head(filtered_data_BF)

# Extraire à partir de POINT car la suite est bien definie
## Extraire la partie à partir de "POINT" et la partie avant "POINT"
filtered_data_BF <- filtered_data_BF %>%
  mutate(
    avant_POINT = str_replace(ligne, "POINT.*", ""),
    a_partir_de_POINT = str_extract(ligne, "POINT.*")
  )
## Supprimer toutes les données qui n'ont pas de coordonnées
filtered_data_BF <- filtered_data_BF %>% drop_na(a_partir_de_POINT)

# Éclater la colonne `a_partir_de_POINT` en plusieurs colonnes après chaque virgule
filtered_data_BF <- filtered_data_BF %>%
  separate(a_partir_de_POINT, into = c("geom_wkt", "priogrid_gid",
                                       "country", "country_id", "region", "event_clarity",
                                       "date_prec", "date_start", "date_end",
                                       "deaths_a", "deaths_b", "deaths_civilians", "deaths_unknown",
                                       "best_est", "high_est", "low_est"), 
           sep = ",", fill = "right", extra = "drop")

# Supprimer la virgule finale de `avant_POINT` s'il y en a une
filtered_data_BF <- filtered_data_BF %>%
  mutate(avant_POINT = str_replace(avant_POINT, ",$", ""))

# EXTRACTION de la dernière et avant-dernière valeur de `avant_POINT` pour les coordonnées
filtered_data_BF <- filtered_data_BF %>%
  mutate(
    latitude_longitude = str_extract(avant_POINT, "[^,]+,[^,]+,[^,]+,[^,]+$"),  # Capture les quatre dernières valeurs
    avant_POINT_sans_coord = str_replace(avant_POINT, "[^,]+,[^,]+,[^,]+,[^,]+$", "")  # Supprime les quatre dernières valeurs
  )

# Séparer les premières valeurs en 12 colonnes + une colonne intermédiaire `autres_infos`
filtered_data_BF <- filtered_data_BF %>%
  separate(avant_POINT_sans_coord, into = c("id", "relid", "year", "active_year", "code_status",
                                            "type_of_violence", "conflict_dset_id", "conflict_new_id",
                                            "conflict_name", "dyad_dset_id", "dyad_new_id", "dyad_name", 
                                            "autres_infos"), 
           sep = ",", fill = "right", extra = "merge")

# Séparer la colonne `latitude_longitude` en adm_1, adm_2, latitude et longitude
filtered_data_BF <- filtered_data_BF %>%
  separate(latitude_longitude, into = c("adm_1", "adm_2", "latitude", "longitude"), sep = ",", fill = "right", extra = "drop")

# Filtrer et supprimer les lignes où l'id des caracteres 
filtered_data_BF <- filtered_data_BF %>%
  filter(!str_detect(id, "[A-Za-z]"))

#On observe que les observations qui ont les na sur la lattitude sont les meme que celles ayant des na sur adm_1, adm_2, longitude
#Enfaite c'est parce que pour elles le decoupage n'a pas bien été fait.

# Pour les lignes où latitude est NA, extraire les valeurs de 'autres_infos'
filtered_data_BF <- filtered_data_BF %>%
  mutate(
    # Extraire la longitude (dernière valeur après la dernière virgule dans autres_infos)
    longitude = ifelse(is.na(longitude), 
                       str_extract(autres_infos, "(?<=,)[^,]+$"), 
                       longitude),
    
    # Extraire la latitude (avant-dernière valeur avant la dernière virgule dans autres_infos)
    latitude = ifelse(is.na(latitude), 
                      str_extract(autres_infos, "(?<=,)[^,]+(?=,[^,]+$)"), 
                      latitude)
  )

# Nombre de valeurs manquantes pour chacune des variables 
# Calculer le nombre de valeurs manquantes pour chaque variable
missing_values <- sapply(filtered_data_BF, function(x) sum(is.na(x)))

# Afficher le nombre de valeurs manquantes pour chaque variable
missing_values

# Quelques verifications

# Vérifier les doublons sur les variables 'latitude', 'id', 'longitude', 'geom_wkt'
duplicates <- filtered_data_BF %>%
  filter(duplicated(select(., latitude, id, longitude, geom_wkt)) | duplicated(select(., latitude, id, longitude, geom_wkt), fromLast = TRUE))

# Afficher les doublons
duplicates

# Conversion en numérique de certaines variables 
filtered_data_BF <- filtered_data_BF %>%
  mutate(across(c(id,priogrid_gid,country_id,event_clarity,date_prec,deaths_a,deaths_b,deaths_civilians,deaths_unknown,best_est,high_est,low_est,type_of_violence,conflict_dset_id,conflict_new_id,dyad_dset_id,dyad_new_id, year, latitude, longitude), as.numeric))

# Suppression de variables pas utiles
filtered_data_BF <- filtered_data_BF %>%
  select(-ligne, -avant_POINT, -autres_infos, -adm_1, -adm_2  )

# Enregistrer 
write_xlsx(filtered_data_BF, "E:/ISEP 2/MON DOSSIER/APPRENTISSAGE DES VACANCES/ISEP3/Projet BSA/BASES DE DONNEES CORRIGEES/Base_BurkinaFaso_Nettoyee.xlsx")

