library(shiny)
library(leaflet)
library(dplyr)
library(DT)
library(shinydashboard)
library(readxl)

# Chargement des données
data_events <- read_excel("www/fusionacled.xlsx") %>%
  mutate(
    date_start = as.Date(date_start, format = "%m/%d/%Y"),
    latitude = as.numeric(latitude),
    longitude = as.numeric(longitude),
    best_est = as.numeric(best_est),
    deaths_civilians = as.numeric(deaths_civilians),
    type_of_violence = as.numeric(type_of_violence)
  )


server <- function(input, output, session) {
  
  # 📌 Mise à jour dynamique des filtres (pays, dyades)
  observe({
    updateSelectInput(session, "pays",
                      choices = sort(unique(data_events$country)),
                      selected = NULL)
    
    updateSelectInput(session, "dyade",
                      choices = sort(unique(data_events$dyad_name)),
                      selected = NULL)
  })
  
  # 🔎 Données filtrées
  data_filtrée <- reactive({
    req(input$pays, input$violence_type, input$dates)
    
    df <- data_events %>%
      filter(
        country %in% input$pays,
        type_of_violence %in% input$violence_type,
        best_est >= input$mort_min,
        date_start >= input$dates[1],
        date_start <= input$dates[2]
      )
    
    if (!is.null(input$dyade) && length(input$dyade) > 0) {
      df <- df %>% filter(dyad_name %in% input$dyade)
    }
    
    return(df)
  })
  
  
  # 🗺️ Carte interactive
  output$map_events <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = 0, lat = 10, zoom = 4) %>%
      addProviderTiles(providers$CartoDB.Positron)
  })
  
  observe({
    df <- data_filtrée()
    
    leafletProxy("map_events", data = df) %>%
      clearMarkers() %>%
      addCircleMarkers(
        lng = ~longitude,
        lat = ~latitude,
        radius = ~sqrt(best_est + 1),
        color = "#e74c3c",
        fillOpacity = 0.5,
        stroke = FALSE,
        popup = ~paste0(
          "<b>Conflit :</b> ", conflict_name, "<br/>",
          "<b>Date :</b> ", date_start, "<br/>",
          "<b>Type :</b> ", type_of_violence, "<br/>",
          "<b>Dyade :</b> ", dyad_name, "<br/>",
          "<b>Morts estimées :</b> ", best_est
        )
      )
    if (nrow(df) > 0) {
      bounds <- df %>%
        summarise(
          lat_min = min(latitude, na.rm = TRUE),
          lat_max = max(latitude, na.rm = TRUE),
          lng_min = min(longitude, na.rm = TRUE),
          lng_max = max(longitude, na.rm = TRUE)
        )
      
      leafletProxy("map_events") %>%
        fitBounds(
          lng1 = bounds$lng_min,
          lat1 = bounds$lat_min,
          lng2 = bounds$lng_max,
          lat2 = bounds$lat_max
        )
    }
    
  })
  
  
  # 📊 Indicateur 1 : Nombre d’événements
  output$box_total_events <- renderText({
    format(nrow(data_filtrée()), big.mark = " ")
  })
  
  output$box_total_deaths <- renderText({
    total <- sum(data_filtrée()$best_est, na.rm = TRUE)
    format(total, big.mark = " ")
  })
  
  output$box_prop_civilians <- renderText({
    df <- data_filtrée()
    prop <- sum(df$deaths_civilians, na.rm = TRUE) / sum(df$best_est, na.rm = TRUE)
    pourcent <- ifelse(is.nan(prop), 0, round(100 * prop, 1))
    paste0(pourcent, " %")
  })
  
  # 📋 Tableau des événements
  output$table_events <- renderDT({
    df <- data_filtrée() %>%
      select(date_start, country, dyad_name, region, best_est, 
             deaths_a, deaths_b, deaths_civilians, type_of_violence)
    
    datatable(df, options = list(pageLength = 10), rownames = FALSE)
  })
  
  # ⬇️ Téléchargement des données
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("evenements_filtrés_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(data_filtrée(), file, row.names = FALSE)
    }
  )

dico_data <- data.frame(
  `Nom de la variable` = c(
    "active_year", "annee_end", "annee_start", "best_est", "code_status",
    "conflict_dset_id", "conflict_name", "conflict_new_id", "country", "country_id",
    "date_end", "date_prec", "date_start", "deaths_a", "deaths_b", "deaths_civilians",
    "deaths_unknown", "dyad_dset_id", "dyad_name", "dyad_new_id", "geom_wkt", "high_est",
    "id", "latitude", "low_est", "longitude", "mois_end", "mois_start", "priogrid_gid",
    "relid", "region", "type_of_violence"
  ),
  Description = c(
    "Booléen indiquant si l'année de l'événement est active dans la base",
    "Année de fin de l'événement",
    "Année de début de l'événement",
    "Estimation centrale du total de morts (moyenne la plus probable)",
    "Statut de l'inclusion de l'événement dans la base",
    "Identifiants numériques de conflits dans la base UCDP-PAR",
    "Nom du conflit",
    "Identifiants numériques de conflits (version actualisée)",
    "Nom du pays où l'événement s'est produit",
    "Code numérique du pays (codification Gleditsch & Ward)",
    "Date de fin de l'événement",
    "Précision de la date (codée de 0 à 5)",
    "Date de début de l'événement",
    "Morts pour l'acteur Side A",
    "Morts pour l'acteur Side B",
    "Civils tués dans l'événement",
    "Morts non attribués",
    "Identifiants uniques des dyades (version initiale)",
    "Nom de la dyade d'acteurs impliqués",
    "Identifiants uniques des dyades (version actualisée)",
    "Coordonnées géographiques au format WKT",
    "Estimation haute du nombre de morts",
    "Identifiant unique de l'événement",
    "Latitude géographique",
    "Estimation basse du nombre de morts",
    "Longitude géographique",
    "Mois de fin de l'événement",
    "Mois de début de l'événement",
    "Code unique de la cellule PRIO-GRID",
    "Identifiant de relation",
    "Région de regroupement géographique",
    "Code indiquant la nature de la violence"
  ),
  Type = c(
    "Booléen (TRUE/FALSE)", "Entier", "Entier", "Entier", "Texte",
    "Entier", "Texte", "Entier", "Texte", "Entier", "Date/texte", "Entier",
    "Date/texte", "Entier", "Entier", "Entier", "Entier", "Entier", "Texte",
    "Entier", "WKT (texte géographique)", "Entier", "Entier", "Décimal",
    "Entier", "Décimal", "Entier/texte", "Entier/texte", "Entier", "Entier",
    "Texte", "Entier"
  ),
  check.names = FALSE
)

output$dico_table <- DT::renderDT({
  DT::datatable(
    dico_data,
    options = list(
      pageLength = 10,
      search = list(regex = TRUE, caseInsensitive = TRUE),
      language = list(
        search = "Rechercher par nom:",
        paginate = list(previous = 'Précédent', `next` = 'Suivant'),
        lengthMenu = "Afficher _MENU_ entrées"
      )
    ),
    rownames = FALSE,
    filter = 'top'
  )
})

output$dl_dico <- downloadHandler(
  filename = "dictionnaire_variables.csv",
  content = function(file) {
    write.csv(dico_data, file, row.names = FALSE, fileEncoding = "UTF-8")
  }
)
observeEvent(input$btn_samba, {
  showModal(modalDialog(
    title = "Réalisations de Samba DIENG",
    "Samba DIENG a assuré la collecte et l'intégration des bases de données, ce qui a constitué la première étape cruciale de notre projet. Il a ensuite appliqué des méthodes de regroupement avancées, notamment l'Analyse en Composantes Principales (ACP) et le clustering, afin de détecter des tendances et identifier des profils communs dans les données. Son expertise s'est matérialisée par la réalisation de visualisations graphiques complexes et intuitives qui offrent une lecture claire des résultats. Ces analyses avancées permettent d’informer efficacement les décideurs grâce à des représentations visuelles précises, transformant ainsi des données brutes en insights stratégiques.",
    easyClose = TRUE,
    footer = NULL
  ))
})

observeEvent(input$btn_ahmadou, {
  showModal(modalDialog(
    title = "Réalisations de Ahmadou NIASS",
    "Passionné par les interfaces utilisateur intuitives, Ahmadou NIASS a conçu l’interface interactive qui permet aux utilisateurs d’explorer les données de manière dynamique et personnalisée. Il a développé une série de filtres interactifs permettant de sélectionner un ou plusieurs pays, de définir une plage de dates, de choisir différents types de violence, de fixer un seuil minimum de morts estimées et même de sélectionner des dyades spécifiques. Grâce à son expertise, il a intégré une carte interactive qui géolocalise chaque événement, où la taille et la couleur des marqueurs varient selon le nombre de morts, avec des popups informatifs sur le conflit, la date, le type de violence, la dyade et les estimations de morts. En complément, il a implémenté des indicateurs synthétiques qui résument le nombre total d’événements, le total de morts estimées et la proportion de civils tués, ainsi qu’un tableau interactif permettant de consulter et d’exporter l’ensemble des données. Ce travail a permis d’offrir une expérience de navigation fluide et ergonomique à tous les utilisateurs, tout en assurant une visualisation claire et précise des informations.",
    easyClose = TRUE,
    footer = NULL
  ))
})

observeEvent(input$btn_sarah, {
  showModal(modalDialog(
    title = "Réalisations de Sarah-Laure",
    "Sarah-Laure a pris en charge le nettoyage et la préparation de la base de données, garantissant ainsi la qualité et la fiabilité des informations exploitées par l’équipe. Son rôle a été crucial pour s’assurer que les données brutes, issues de multiples sources, soient correctement traitées et prêtes à être analysées. En parallèle, elle a élaboré la documentation du projet avec soin, en détaillant la source des données, en décrivant précisément les variables utilisées et en expliquant l’ensemble des fonctionnalités de la plateforme. Elle a également réalisé des analyses descriptives qui permettent de contextualiser les résultats, en illustrant par exemple la répartition des événements, l’évolution temporelle et d’autres tendances pertinentes. Son travail a permis de rendre le projet non seulement techniquement solide, mais aussi accessible et compréhensible, tant pour les utilisateurs que pour toute personne souhaitant en apprendre davantage sur notre démarche.",
    easyClose = TRUE,
    footer = NULL
  ))
})

# Lorsqu'un utilisateur clique sur un lien pour afficher les explications
observeEvent(input$details_1, {
  
  toggle("explanation_1")  # Montre ou cache l'explication 1
})

observeEvent(input$details_2, {
  toggle("explanation_2")  # Montre ou cache l'explication 2
})

observeEvent(input$details_3, {
  toggle("explanation_3")  # Montre ou cache l'explication 3
})

observeEvent(input$details_4, {
  toggle("explanation_4")  # Montre ou cache l'explication 4
})

}
