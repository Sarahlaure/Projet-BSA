library(shiny)
library(leaflet)
library(dplyr)
library(DT)
library(shinydashboard)
library(readxl)
library(factoextra)
library(networkD3)
library(stringr)
library(purrr)
library(lubridate)
library(tidyr)
library(igraph)
library(ggraph)
library(tidygraph)
library(plotly)
library(cluster)
library(FactoMineR)


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

# 🔄 Réactif central pour la page 3
# 🔄 Réactif central pour la page 3 avec filtres propres



server <- function(input, output, session) {
  
  data_page3 <- reactive({
    req(input$filtre_date)
    
    df <- data_events
    
    # Filtrage par pays si sélectionné
    if (!is.null(input$filtre_pays) && length(input$filtre_pays) > 0) {
      df <- df %>% filter(country %in% input$filtre_pays)
    }
    
    # Filtrage par date
    df <- df %>% filter(date_start >= input$filtre_date[1],
                        date_start <= input$filtre_date[2])
    
    validate(need(nrow(df) > 0, "Aucune donnée disponible pour les filtres sélectionnés."))
    return(df)
  })
  
  
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


observe({
  updateSelectInput(session, "filtre_pays",
                    choices = sort(unique(data_events$country)),
                    selected = "Mali")
})


observe({
  updateSelectInput(session, "filtre_pays",
                    choices = sort(unique(data_events$country)),
                    selected = "Mali")
})


# 🔹 Bloc 1 – Événements et morts par pays

# Labels explicites pour types de violence
violence_labels <- c(
  "1" = "Conflit entre État et groupes armés",
  "2" = "Conflit entre groupes armés",
  "3" = "Violence contre civils"
)

# Bloc dynamique mono/multi pays
output$bloc_pays_adaptatif <- renderUI({
  selected <- input$filtre_pays
  if (length(selected) == 1) {
    tagList(
      tags$div(style = "margin-bottom: 20px;"),
      tags$div(
        class = "card shadow-sm p-3 mb-4 bg-light rounded",
        tags$h4(
          tags$span(icon("magnifying-glass-location", lib = "font-awesome"),
                    style = "margin-right: 8px; color: #2c3e50;"),
          paste("Contexte sécuritaire :", selected)
        ),
        tags$p(textOutput("contexte_pays_unique"),
               style = "font-size: 16px; color: #333; font-style: italic; margin-top: 10px;")
      )
    )
  } else {
    fluidRow(
      column(6,
             plotlyOutput("plot_events_country"),
             tags$p(textOutput("comment_events_country"), style = "font-style: italic; color: #555;")
      ),
      column(6,
             plotlyOutput("plot_deaths_country"),
             tags$p(textOutput("comment_deaths_country"), style = "font-style: italic; color: #555;")
      )
    )
  }
})

output$contexte_pays_unique <- renderText({
  country <- input$filtre_pays
  if (is.null(country) || length(country) != 1) return(NULL)
  
  contextes <- list(
    "Mali" = paste(
      "Le Mali est confronté à une grave crise sécuritaire depuis 2012, marquée par l'insurrection de groupes djihadistes dans le nord.",
      "La région du Liptako-Gourma, partagée avec le Burkina Faso et le Niger, est particulièrement instable.",
      "Malgré la présence des forces internationales (MINUSMA, Barkhane), les attaques contre les civils et les forces armées persistent, notamment dans le centre du pays.",
      "Le Mali fait partie de l'Alliance des États du Sahel (AES), qui regroupe des pays en transition politique et en lutte commune contre le terrorisme."
    ),
    
    "Burkina Faso" = paste(
      "Depuis 2015, le Burkina Faso subit une intensification dramatique des violences liées à des groupes armés islamistes.",
      "Le nord et l’est du pays, notamment dans la région du Liptako-Gourma, sont devenus des zones de conflits ouverts.",
      "Les attaques contre les civils, les écoles et les forces de sécurité ont entraîné des déplacements massifs de population.",
      "Membre de l'Alliance des États du Sahel (AES), le Burkina Faso adopte une politique sécuritaire plus souveraine et coordonnée avec ses voisins Mali et Niger."
    ),
    
    "Niger" = paste(
      "Le Niger est confronté à une double menace sécuritaire : Boko Haram dans la région de Diffa (sud-est), et les groupes djihadistes affiliés à Al-Qaïda et à l’EI dans l’ouest et le nord.",
      "La région du Liptako-Gourma, frontalière avec le Mali et le Burkina Faso, est un épicentre de la violence.",
      "Les attaques contre les villages et les postes militaires y sont fréquentes.",
      "Le Niger est également membre de l'Alliance des États du Sahel (AES) et joue un rôle central dans la lutte régionale contre le terrorisme."
    ),
    
    "Senegal" = paste(
      "Le Sénégal demeure relativement stable sur le plan sécuritaire.",
      "Cependant, la région de la Casamance connaît un conflit séparatiste latent depuis plusieurs décennies.",
      "Le pays reste attentif aux risques d’expansion des groupes armés depuis le Sahel, notamment à travers ses frontières avec le Mali et la Mauritanie."
    ),
    
    "Togo" = paste(
      "Le Togo, historiquement stable, fait face depuis 2021 à une recrudescence d’incursions djihadistes dans sa région nord.",
      "Ces attaques proviennent principalement des groupes opérant au Burkina Faso.",
      "Le pays renforce sa présence militaire dans la région des Savanes pour contenir cette menace."
    ),
    
    "Ivory" = paste(
      "La Côte d’Ivoire reste relativement stable mais sous pression croissante dans le nord du pays.",
      "Depuis 2020, des attaques ont été enregistrées dans les zones frontalières avec le Burkina Faso, notamment contre des postes de sécurité.",
      "Les autorités ivoiriennes renforcent la sécurité dans le cadre d’une stratégie préventive contre l’expansion du terrorisme sahélien."
    ),
    
    "Benin" = paste(
      "Le nord du Bénin est touché depuis 2019 par des incursions de groupes armés en provenance du Burkina Faso et du Niger.",
      "Des attaques ont visé des parcs nationaux, des postes militaires et des villages.",
      "Le pays développe une coopération renforcée avec ses voisins pour contenir la menace et sécuriser ses frontières."
    ),
    
    "Guinea-Bissau" = paste(
      "La Guinée-Bissau n'est pas directement affectée par les conflits armés sahéliens.",
      "Cependant, elle reste exposée à des fragilités internes liées à des crises politiques récurrentes et à des réseaux de criminalité transnationale."
    )
  )
  
  contextes[[country]] %||% "Aucun contexte spécifique disponible pour ce pays."
})
output$plot_events_country <- renderPlotly({
  df <- data_page3() %>% count(country, name = "events")
  p <- ggplot(df, aes(x = reorder(country, -events), y = events)) +
    geom_bar(stat = "identity", fill = "#3498db") +
    labs(x = "Pays", y = "Nombre d'événements") +
    theme_minimal()
  ggplotly(p)
})

output$plot_deaths_country <- renderPlotly({
  df <- data_page3() %>%
    group_by(country) %>%
    summarise(deaths = sum(best_est, na.rm = TRUE))
  p <- ggplot(df, aes(x = reorder(country, -deaths), y = deaths)) +
    geom_bar(stat = "identity", fill = "#e74c3c") +
    labs(x = "Pays", y = "Morts estimés") +
    theme_minimal()
  ggplotly(p)
})


# 🔹 Bloc 2 – Type de violence et dyades
output$plot_violence_pie <- renderPlotly({
  df <- data_page3() %>%
    count(type_of_violence) %>%
    mutate(type_label = violence_labels[as.character(type_of_violence)])
  plot_ly(df, labels = ~type_label, values = ~n, type = "pie") %>%
    layout(title = "Répartition des types de violence")
})

output$plot_violence_dyade <- renderPlotly({
  df <- data_page3() %>%
    group_by(type_of_violence, dyad_name) %>%
    tally() %>%
    mutate(type_label = violence_labels[as.character(type_of_violence)]) %>%
    arrange(desc(n)) %>%
    slice_head(n = 10)
  ggplotly(
    ggplot(df, aes(x = reorder(dyad_name, -n), y = n, fill = type_label)) +
      geom_bar(stat = "identity") +
      coord_flip() +
      labs(x = "Dyade", y = "Nombre d'événements", fill = "Type de violence") +
      theme_minimal()
  )
})

output$comment_events_country <- renderText({
  df <- data_page3() %>% count(country, name = "events") %>% arrange(desc(events))
  total <- sum(df$events)
  top <- df[1, ]
  top3 <- head(df, 3)
  paste0("🔎 Le pays le plus affecté est ", top$country, ", avec ", top$events,
         " événements (", round(100 * top$events / total, 1), "% du total). ",
         "Les 3 premiers pays (", paste(top3$country, collapse = ", "), 
         ") concentrent ", round(100 * sum(top3$events) / total, 1), "% des violences.")
})

output$comment_deaths_country <- renderText({
  df <- data_page3() %>% group_by(country) %>%
    summarise(deaths = sum(best_est, na.rm = TRUE)) %>% arrange(desc(deaths))
  total <- sum(df$deaths)
  top <- df[1, ]
  paste0("💀 ", top$country, " enregistre le plus de morts estimées : ", top$deaths,
         " décès (", round(100 * top$deaths / total, 1), "% du total régional).")
})
output$comment_violence_type <- renderText({
  df <- data_page3() %>% count(type_of_violence)
  total <- sum(df$n)
  top <- df %>% arrange(desc(n)) %>% slice(1)
  paste0("📊 Le type de violence dominant est le type ", top$type_of_violence,
         " avec ", top$n, " cas, soit ", round(100 * top$n / total, 1), "% des événements recensés.")
})

output$comment_violence_dyade <- renderText({
  df <- data_page3() %>% group_by(dyad_name) %>%
    tally() %>% arrange(desc(n)) %>% slice(1:3)
  paste0("🤝 La dyade la plus active est « ", df$dyad_name[1], " » avec ", df$n[1], " événements. ",
         "Les 3 dyades principales représentent ", sum(df$n), " cas cumulés.")
})

# 🔹 Bloc 3 – Évolution temporelle
output$plot_timeline_events <- renderPlotly({
  df <- data_page3() %>%
    mutate(month = format(date_start, "%Y-%m")) %>%
    count(month)
  
  p <- ggplot(df, aes(x = as.Date(paste0(month, "-01")), y = n)) +
    geom_line(color = "#2c3e50") +
    scale_x_date(date_labels = "%b %Y", date_breaks = "3 months") +  # ✅ espacement clair
    labs(x = "Mois", y = "Nombre d'événements") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 9))
  
  ggplotly(p)
})


output$plot_timeline_deaths <- renderPlotly({
  df <- data_page3() %>%
    mutate(month = format(date_start, "%Y-%m")) %>%
    group_by(month) %>%
    summarise(deaths = sum(best_est, na.rm = TRUE))
  
  p <- ggplot(df, aes(x = as.Date(paste0(month, "-01")), y = deaths)) +
    geom_line(color = "#c0392b") +
    scale_x_date(date_labels = "%b %Y", date_breaks = "3 months") +
    labs(x = "Mois", y = "Morts estimés") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 9))
  
  ggplotly(p)
})


output$comment_timeline_events <- renderText({
  df <- data_page3() %>%
    mutate(month = format(date_start, "%Y-%m")) %>%
    count(month) %>% arrange(desc(n))
  paste0("📈 Le pic d’événements a été enregistré en ", df$month[1], " avec ", df$n[1], " événements.")
})

output$comment_timeline_deaths <- renderText({
  df <- data_page3() %>%
    mutate(month = format(date_start, "%Y-%m")) %>%
    group_by(month) %>% summarise(deaths = sum(best_est, na.rm = TRUE)) %>%
    arrange(desc(deaths))
  paste0("📉 Le mois le plus meurtrier est ", df$month[1], " avec ", df$deaths[1], " morts estimées.")
})

# 🔹 Bloc 4 – Focus sur les civils
output$map_civilians <- renderLeaflet({
  df <- data_page3() %>% filter(type_of_violence == 3, !is.na(latitude), !is.na(longitude))
  leaflet(df) %>%
    addProviderTiles("CartoDB.Positron") %>%
    addCircleMarkers(
      lng = ~longitude,
      lat = ~latitude,
      radius = ~sqrt(deaths_civilians + 1),
      color = "#e67e22",
      fillOpacity = 0.6,
      popup = ~paste0("<b>Dyade :</b> ", dyad_name,
                      "<br/><b>Date :</b> ", date_start,
                      "<br/><b>Morts civils :</b> ", deaths_civilians)
    )
})

# 🧍‍♂️ Courbe évolution morts civils estimés
output$plot_civilians_timeline <- renderPlotly({
  df <- data_page3() %>%
    filter(type_of_violence == 3) %>%
    mutate(month = format(date_start, "%Y-%m")) %>%
    group_by(month) %>%
    summarise(civ_deaths = sum(deaths_civilians, na.rm = TRUE), .groups = "drop")
  
  p <- ggplot(df, aes(x = as.Date(paste0(month, "-01")), y = civ_deaths)) +
    geom_line(color = "#f39c12") +
    scale_x_date(date_labels = "%b %Y", date_breaks = "3 months") +
    labs(x = "Mois", y = "Morts civils estimés") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 9))
  
  ggplotly(p)
})

output$comment_map_civilians <- renderText({
  df <- data_page3() %>% filter(type_of_violence == 3)
  top <- df %>% group_by(country) %>%
    summarise(civ_deaths = sum(deaths_civilians, na.rm = TRUE)) %>%
    arrange(desc(civ_deaths)) %>% slice(1)
  paste0("🧍‍♂️ ", top$country, " concentre le plus de morts civiles avec ", top$civ_deaths, " décès estimés.")
})

output$comment_civilians_timeline <- renderText({
  df <- data_page3() %>%
    filter(type_of_violence == 3) %>%
    mutate(month = format(date_start, "%Y-%m")) %>%
    group_by(month) %>%
    summarise(civ_deaths = sum(deaths_civilians, na.rm = TRUE)) %>%
    arrange(desc(civ_deaths)) %>% slice(1)
  paste0("🗓️ Le mois le plus critique pour les civils est ", df$month[1],
         " avec ", df$civ_deaths[1], " morts civiles estimées.")
})



# 🔹 Bloc 1 – Événements et morts par pays

# Labels explicites pour types de violence
violence_labels <- c(
  "1" = "Conflit entre État et groupes armés",
  "2" = "Conflit entre groupes armés",
  "3" = "Violence contre civils"
)

# Bloc dynamique mono/multi pays
output$bloc_pays_adaptatif <- renderUI({
  selected <- input$filtre_pays
  if (length(selected) == 1) {
    tagList(
      tags$div(style = "margin-bottom: 20px;"),
      tags$div(
        class = "card shadow-sm p-3 mb-4 bg-light rounded",
        tags$h4(
          tags$span(icon("magnifying-glass-location", lib = "font-awesome"),
                    style = "margin-right: 8px; color: #2c3e50;"),
          paste("Contexte sécuritaire :", selected)
        ),
        tags$p(textOutput("contexte_pays_unique"),
               style = "font-size: 16px; color: #333; font-style: italic; margin-top: 10px;")
      )
    )
  } else {
    fluidRow(
      column(6,
             plotlyOutput("plot_events_country"),
             tags$p(textOutput("comment_events_country"), style = "font-style: italic; color: #555;")
      ),
      column(6,
             plotlyOutput("plot_deaths_country"),
             tags$p(textOutput("comment_deaths_country"), style = "font-style: italic; color: #555;")
      )
    )
  }
})

output$contexte_pays_unique <- renderText({
  country <- input$filtre_pays
  if (is.null(country) || length(country) != 1) return(NULL)
  
  contextes <- list(
    "Mali" = paste(
      "Le Mali est confronté à une grave crise sécuritaire depuis 2012, marquée par l'insurrection de groupes djihadistes dans le nord.",
      "La région du Liptako-Gourma, partagée avec le Burkina Faso et le Niger, est particulièrement instable.",
      "Malgré la présence des forces internationales (MINUSMA, Barkhane), les attaques contre les civils et les forces armées persistent, notamment dans le centre du pays.",
      "Le Mali fait partie de l'Alliance des États du Sahel (AES), qui regroupe des pays en transition politique et en lutte commune contre le terrorisme."
    ),
    
    "Burkina Faso" = paste(
      "Depuis 2015, le Burkina Faso subit une intensification dramatique des violences liées à des groupes armés islamistes.",
      "Le nord et l’est du pays, notamment dans la région du Liptako-Gourma, sont devenus des zones de conflits ouverts.",
      "Les attaques contre les civils, les écoles et les forces de sécurité ont entraîné des déplacements massifs de population.",
      "Membre de l'Alliance des États du Sahel (AES), le Burkina Faso adopte une politique sécuritaire plus souveraine et coordonnée avec ses voisins Mali et Niger."
    ),
    
    "Niger" = paste(
      "Le Niger est confronté à une double menace sécuritaire : Boko Haram dans la région de Diffa (sud-est), et les groupes djihadistes affiliés à Al-Qaïda et à l’EI dans l’ouest et le nord.",
      "La région du Liptako-Gourma, frontalière avec le Mali et le Burkina Faso, est un épicentre de la violence.",
      "Les attaques contre les villages et les postes militaires y sont fréquentes.",
      "Le Niger est également membre de l'Alliance des États du Sahel (AES) et joue un rôle central dans la lutte régionale contre le terrorisme."
    ),
    
    "Senegal" = paste(
      "Le Sénégal demeure relativement stable sur le plan sécuritaire.",
      "Cependant, la région de la Casamance connaît un conflit séparatiste latent depuis plusieurs décennies.",
      "Le pays reste attentif aux risques d’expansion des groupes armés depuis le Sahel, notamment à travers ses frontières avec le Mali et la Mauritanie."
    ),
    
    "Togo" = paste(
      "Le Togo, historiquement stable, fait face depuis 2021 à une recrudescence d’incursions djihadistes dans sa région nord.",
      "Ces attaques proviennent principalement des groupes opérant au Burkina Faso.",
      "Le pays renforce sa présence militaire dans la région des Savanes pour contenir cette menace."
    ),
    
    "Ivory" = paste(
      "La Côte d’Ivoire reste relativement stable mais sous pression croissante dans le nord du pays.",
      "Depuis 2020, des attaques ont été enregistrées dans les zones frontalières avec le Burkina Faso, notamment contre des postes de sécurité.",
      "Les autorités ivoiriennes renforcent la sécurité dans le cadre d’une stratégie préventive contre l’expansion du terrorisme sahélien."
    ),
    
    "Benin" = paste(
      "Le nord du Bénin est touché depuis 2019 par des incursions de groupes armés en provenance du Burkina Faso et du Niger.",
      "Des attaques ont visé des parcs nationaux, des postes militaires et des villages.",
      "Le pays développe une coopération renforcée avec ses voisins pour contenir la menace et sécuriser ses frontières."
    ),
    
    "Guinea-Bissau" = paste(
      "La Guinée-Bissau n'est pas directement affectée par les conflits armés sahéliens.",
      "Cependant, elle reste exposée à des fragilités internes liées à des crises politiques récurrentes et à des réseaux de criminalité transnationale."
    )
  )
  
  contextes[[country]] %||% "Aucun contexte spécifique disponible pour ce pays."
})
output$plot_events_country <- renderPlotly({
  df <- data_page3() %>% count(country, name = "events")
  p <- ggplot(df, aes(x = reorder(country, -events), y = events)) +
    geom_bar(stat = "identity", fill = "#3498db") +
    labs(x = "Pays", y = "Nombre d'événements") +
    theme_minimal()
  ggplotly(p)
})

output$plot_deaths_country <- renderPlotly({
  df <- data_page3() %>%
    group_by(country) %>%
    summarise(deaths = sum(best_est, na.rm = TRUE))
  p <- ggplot(df, aes(x = reorder(country, -deaths), y = deaths)) +
    geom_bar(stat = "identity", fill = "#e74c3c") +
    labs(x = "Pays", y = "Morts estimés") +
    theme_minimal()
  ggplotly(p)
})


# 🔹 Bloc 2 – Type de violence et dyades
output$plot_violence_pie <- renderPlotly({
  df <- data_page3() %>%
    count(type_of_violence) %>%
    mutate(type_label = violence_labels[as.character(type_of_violence)])
  plot_ly(df, labels = ~type_label, values = ~n, type = "pie") %>%
    layout(title = "Répartition des types de violence")
})

output$plot_violence_dyade <- renderPlotly({
  df <- data_page3() %>%
    group_by(type_of_violence, dyad_name) %>%
    tally() %>%
    mutate(type_label = violence_labels[as.character(type_of_violence)]) %>%
    arrange(desc(n)) %>%
    slice_head(n = 10)
  ggplotly(
    ggplot(df, aes(x = reorder(dyad_name, -n), y = n, fill = type_label)) +
      geom_bar(stat = "identity") +
      coord_flip() +
      labs(x = "Dyade", y = "Nombre d'événements", fill = "Type de violence") +
      theme_minimal()
  )
})

output$comment_events_country <- renderText({
  df <- data_page3() %>% count(country, name = "events") %>% arrange(desc(events))
  total <- sum(df$events)
  top <- df[1, ]
  top3 <- head(df, 3)
  paste0("🔎 Le pays le plus affecté est ", top$country, ", avec ", top$events,
         " événements (", round(100 * top$events / total, 1), "% du total). ",
         "Les 3 premiers pays (", paste(top3$country, collapse = ", "), 
         ") concentrent ", round(100 * sum(top3$events) / total, 1), "% des violences.")
})

output$comment_deaths_country <- renderText({
  df <- data_page3() %>% group_by(country) %>%
    summarise(deaths = sum(best_est, na.rm = TRUE)) %>% arrange(desc(deaths))
  total <- sum(df$deaths)
  top <- df[1, ]
  paste0("💀 ", top$country, " enregistre le plus de morts estimées : ", top$deaths,
         " décès (", round(100 * top$deaths / total, 1), "% du total régional).")
})
output$comment_violence_type <- renderText({
  df <- data_page3() %>% count(type_of_violence)
  total <- sum(df$n)
  top <- df %>% arrange(desc(n)) %>% slice(1)
  paste0("📊 Le type de violence dominant est le type ", top$type_of_violence,
         " avec ", top$n, " cas, soit ", round(100 * top$n / total, 1), "% des événements recensés.")
})

output$comment_violence_dyade <- renderText({
  df <- data_page3() %>% group_by(dyad_name) %>%
    tally() %>% arrange(desc(n)) %>% slice(1:3)
  paste0("🤝 La dyade la plus active est « ", df$dyad_name[1], " » avec ", df$n[1], " événements. ",
         "Les 3 dyades principales représentent ", sum(df$n), " cas cumulés.")
})

# 🔹 Bloc 3 – Évolution temporelle
output$plot_timeline_events <- renderPlotly({
  df <- data_page3() %>%
    mutate(month = format(date_start, "%Y-%m")) %>%
    count(month)
  
  p <- ggplot(df, aes(x = as.Date(paste0(month, "-01")), y = n)) +
    geom_line(color = "#2c3e50") +
    scale_x_date(date_labels = "%b %Y", date_breaks = "3 months") +  # ✅ espacement clair
    labs(x = "Mois", y = "Nombre d'événements") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 9))
  
  ggplotly(p)
})


output$plot_timeline_deaths <- renderPlotly({
  df <- data_page3() %>%
    mutate(month = format(date_start, "%Y-%m")) %>%
    group_by(month) %>%
    summarise(deaths = sum(best_est, na.rm = TRUE))
  
  p <- ggplot(df, aes(x = as.Date(paste0(month, "-01")), y = deaths)) +
    geom_line(color = "#c0392b") +
    scale_x_date(date_labels = "%b %Y", date_breaks = "3 months") +
    labs(x = "Mois", y = "Morts estimés") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 9))
  
  ggplotly(p)
})


output$comment_timeline_events <- renderText({
  df <- data_page3() %>%
    mutate(month = format(date_start, "%Y-%m")) %>%
    count(month) %>% arrange(desc(n))
  paste0("📈 Le pic d’événements a été enregistré en ", df$month[1], " avec ", df$n[1], " événements.")
})

output$comment_timeline_deaths <- renderText({
  df <- data_page3() %>%
    mutate(month = format(date_start, "%Y-%m")) %>%
    group_by(month) %>% summarise(deaths = sum(best_est, na.rm = TRUE)) %>%
    arrange(desc(deaths))
  paste0("📉 Le mois le plus meurtrier est ", df$month[1], " avec ", df$deaths[1], " morts estimées.")
})

# 🔹 Bloc 4 – Focus sur les civils
output$map_civilians <- renderLeaflet({
  df <- data_page3() %>% filter(type_of_violence == 3, !is.na(latitude), !is.na(longitude))
  leaflet(df) %>%
    addProviderTiles("CartoDB.Positron") %>%
    addCircleMarkers(
      lng = ~longitude,
      lat = ~latitude,
      radius = ~sqrt(deaths_civilians + 1),
      color = "#e67e22",
      fillOpacity = 0.6,
      popup = ~paste0("<b>Dyade :</b> ", dyad_name,
                      "<br/><b>Date :</b> ", date_start,
                      "<br/><b>Morts civils :</b> ", deaths_civilians)
    )
})

# 🧍‍♂️ Courbe évolution morts civils estimés
output$plot_civilians_timeline <- renderPlotly({
  df <- data_page3() %>%
    filter(type_of_violence == 3) %>%
    mutate(month = format(date_start, "%Y-%m")) %>%
    group_by(month) %>%
    summarise(civ_deaths = sum(deaths_civilians, na.rm = TRUE), .groups = "drop")
  
  p <- ggplot(df, aes(x = as.Date(paste0(month, "-01")), y = civ_deaths)) +
    geom_line(color = "#f39c12") +
    scale_x_date(date_labels = "%b %Y", date_breaks = "3 months") +
    labs(x = "Mois", y = "Morts civils estimés") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 9))
  
  ggplotly(p)
})

output$comment_map_civilians <- renderText({
  df <- data_page3() %>% filter(type_of_violence == 3)
  top <- df %>% group_by(country) %>%
    summarise(civ_deaths = sum(deaths_civilians, na.rm = TRUE)) %>%
    arrange(desc(civ_deaths)) %>% slice(1)
  paste0("🧍‍♂️ ", top$country, " concentre le plus de morts civiles avec ", top$civ_deaths, " décès estimés.")
})

output$comment_civilians_timeline <- renderText({
  df <- data_page3() %>%
    filter(type_of_violence == 3) %>%
    mutate(month = format(date_start, "%Y-%m")) %>%
    group_by(month) %>%
    summarise(civ_deaths = sum(deaths_civilians, na.rm = TRUE)) %>%
    arrange(desc(civ_deaths)) %>% slice(1)
  paste0("🗓️ Le mois le plus critique pour les civils est ", df$month[1],
         " avec ", df$civ_deaths[1], " morts civiles estimées.")
})



# 📌 Mise à jour dynamique des filtres de la page 4
observe({
  updateSelectInput(session, "pays4",
                    choices = sort(unique(data_events$country)),
                    selected = unique(data_events$country)[1])
})

observeEvent(input$pays4, {
  df_pays <- data_events %>% filter(country == input$pays4)
  
  annees_dispo <- lubridate::year(df_pays$date_start)
  min_an <- min(annees_dispo, na.rm = TRUE)
  max_an <- max(annees_dispo, na.rm = TRUE)
  
  updateSliderInput(session, "periode4",
                    min = min_an,
                    max = max_an,
                    value = c(min_an, max_an),
                    step = 1)
})


data_filtrée4 <- reactive({
  req(input$pays4, input$periode4)
  
  df <- data_events %>%
    mutate(annee = lubridate::year(date_start)) %>%
    filter(
      country == input$pays4,
      annee >= input$periode4[1],
      annee <= input$periode4[2]
    )
  
  # Cas : si utilisateur ne choisit PAS "Tout"
  if (input$violence_type4 != "all") {
    df <- df %>% filter(type_of_violence == as.numeric(input$violence_type4))
  }
  
  return(df)
})



# 📈 Bloc 4A – Tendance temporelle dynamique
output$plot_spline <- renderPlot({
  df <- data_filtrée4()
  req(input$var_spline, input$gran_spline)
  
  var <- input$var_spline
  gran <- input$gran_spline
  
  df <- df %>%
    mutate(
      year = lubridate::year(date_start),
      month = lubridate::month(date_start),
      time = if (gran == "annee") year else as.Date(paste0(year, "-", month, "-01"))
    )
  
  df_grouped <- df %>%
    group_by(time) %>%
    summarise(
      val = if (var == "n") n() else sum(.data[[var]], na.rm = TRUE),
      .groups = "drop"
    )
  
  gg <- ggplot(df_grouped, aes(x = time, y = val)) +
    geom_line(color = "#0072B2", linewidth = 1) +
    geom_smooth(se = FALSE, method = "loess", color = "black") +
    labs(
      title = "📈 Tendance temporelle",
      x = if (gran == "annee") "Année" else "Mois",
      y = names(which(c(n = "Nombre d’événements", best_est = "Décès estimés", deaths_civils = "Morts civils") == var))
    ) +
    theme_minimal()
  
  if (gran == "mois") {
    gg <- gg +
      scale_x_date(date_labels = "%b %Y", date_breaks = "6 months") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  }
  
  gg
})




# 📉 Bloc 4B – Corrélation dynamique (toujours en ANNUEL)
output$plot_correlation <- renderPlot({
  df <- data_filtrée4()
  var_x <- input$var_spline
  var_y <- input$var_spline2
  
  df <- df %>%
    mutate(year = lubridate::year(date_start)) %>%
    filter(year >= input$periode4[1], year <= input$periode4[2]) %>%
    group_by(year) %>%
    summarise(
      xval = if (var_x == "n") n() else sum(.data[[var_x]], na.rm = TRUE),
      yval = if (var_y == "n") n() else sum(.data[[var_y]], na.rm = TRUE),
      .groups = "drop"
    )
  
  ggplot(df, aes(x = xval, y = yval)) +
    geom_point(color = "#e67e22", alpha = 0.6) +
    geom_smooth(method = "lm", se = FALSE, color = "#2c3e50") +
    labs(
      title = "📉 Corrélation victimes vs événements",
      x = names(which(c(n = "Nombre d’événements", best_est = "Décès estimés", deaths_civils = "Morts civils") == var_x)),
      y = names(which(c(n = "Nombre d’événements", best_est = "Décès estimés", deaths_civils = "Morts civils") == var_y))
    ) +
    theme_minimal()
})




# 📦 Nécessite factoextra, stats, scales

# 🔁 Fonction dédiée pour clustering (ACP + K-means)
output$plot_clustering4 <- renderPlotly({
  df <- data_filtrée4()
  
  # Étape 1 – Filtrage et sélection
  df_clust <- df %>%
    select(best_est, deaths_a, deaths_b, deaths_civilians, type_of_violence) %>%
    na.omit()
  
  # Retirer colonnes constantes
  df_clust <- df_clust[, apply(df_clust, 2, sd, na.rm = TRUE) > 0]
  
  validate(
    need(nrow(df_clust) >= 5, "Pas assez d'observations pour appliquer le clustering."),
    need(ncol(df_clust) >= 2, "Il faut au moins deux variables non constantes.")
  )
  
  # Étape 2 – ACP
  df_std <- scale(df_clust)
  res_pca <- prcomp(df_std)
  df_pca <- as.data.frame(res_pca$x[, 1:2])
  colnames(df_pca) <- c("Dim1", "Dim2")
  
  # Étape 3 – K-means
  set.seed(123)
  res_km <- kmeans(df_std, centers = 3, nstart = 25)
  df_pca$cluster <- as.factor(res_km$cluster)
  
  # Étape 4 – Fusion avec les données originales
  df_pca <- cbind(df_pca, df_clust)
  colnames(df_pca) <- c("Dim1", "Dim2", "cluster",
                        "Décès estimés", "Morts camp A", "Morts camp B", "Morts civils", "Type de violence")
  
  # Fonction de mapping du type
  label_type <- function(t) {
    dplyr::case_when(
      t == 1 ~ "Conflit entre État et groupes armés",
      t == 2 ~ "Conflit entre groupes armés",
      t == 3 ~ "Violence contre civils",
      TRUE ~ "Inconnu"
    )
  }
  
  # Interpréteur
  interpreter <- function(cluster_data) {
    means <- round(colMeans(cluster_data[, c("Décès estimés", "Morts camp A", "Morts camp B", "Morts civils")]), 1)
    dominant_type_code <- names(sort(table(cluster_data[["Type de violence"]]), decreasing = TRUE))[1]
    dominant_type_label <- label_type(as.numeric(dominant_type_code))
    
    paste0(
      "🧾 Caractéristiques du groupe :<br>",
      "🔸 Morts estimés moyens : ", means[1], "<br>",
      "🔸 Morts camp A : ", means[2], "<br>",
      "🔸 Morts camp B : ", means[3], "<br>",
      "🔸 Morts civils : ", means[4], "<br>",
      "🔸 Type dominant : ", dominant_type_label, "<br><br>",
      "🧠 Ce groupe se caractérise par des événements avec ", dominant_type_label,
      " et une mortalité moyenne modérée."
    )
  }
  
  # Générer les tooltips
  df_pca$tooltip <- unlist(lapply(df_pca$cluster, function(cl) {
    interpreter(df_pca[df_pca$cluster == cl, ])
  }))
  
  # Palette personnalisée
  palette <- c("#1f77b4", "#ff7f0e", "#2ca02c")
  names(palette) <- levels(df_pca$cluster)
  
  # Graphique plotly avec enveloppes
  p <- plot_ly()
  
  for (cl in levels(df_pca$cluster)) {
    cluster_data <- df_pca[df_pca$cluster == cl, ]
    
    # Ajout des points
    p <- add_trace(
      p,
      data = cluster_data,
      x = ~Dim1,
      y = ~Dim2,
      type = "scatter",
      mode = "markers",
      color = I(palette[cl]),
      marker = list(size = 10, opacity = 0.85, line = list(color = '#FFFFFF', width = 1)),
      hoverinfo = "text",
      text = ~tooltip,
      name = paste("Cluster", cl)
    )
    
    # Calcul de l'enveloppe convexe (triangle ou forme)
    if (nrow(cluster_data) >= 3) {
      hull_indices <- chull(cluster_data$Dim1, cluster_data$Dim2)
      hull_indices <- c(hull_indices, hull_indices[1])  # Fermer le polygone
      
      p <- add_trace(
        p,
        x = cluster_data$Dim1[hull_indices],
        y = cluster_data$Dim2[hull_indices],
        type = "scatter",
        mode = "lines",
        fill = "toself",
        fillcolor = toRGB(palette[cl], alpha = 0.15),
        line = list(color = palette[cl], width = 2),
        name = paste("Contour", cl),
        hoverinfo = "none",
        showlegend = FALSE
      )
    }
  }
  
  p %>% layout(
    title = "Résultat du clustering sur l’ACP",
    xaxis = list(title = "Composante principale 1", zeroline = FALSE),
    yaxis = list(title = "Composante principale 2", zeroline = FALSE)
  )
})





output$plot_sankey4 <- renderSankeyNetwork({
  df <- data_filtrée4()
  
  validate(
    need(!is.null(df$dyad_name), "Aucune dyade détectée dans les filtres actuels."),
    need(nrow(df) > 0, "Aucun événement correspondant.")
  )
  
  df_links <- df %>%
    filter(str_detect(dyad_name, " - ")) %>%
    mutate(
      source_actor = str_split(dyad_name, " - ") %>% map_chr(1),
      target_actor = str_split(dyad_name, " - ") %>% map_chr(2)
    ) %>%
    group_by(source_actor, target_actor) %>%
    summarise(value = sum(best_est, na.rm = TRUE), .groups = "drop") %>%
    filter(value > 0)
  
  # Créer les noeuds
  actors <- unique(c(df_links$source_actor, df_links$target_actor))
  nodes <- data.frame(name = actors)
  
  # Mapper les noms sur les index
  df_links <- df_links %>%
    mutate(
      source = match(source_actor, nodes$name) - 1,
      target = match(target_actor, nodes$name) - 1
    )
  
  sankeyNetwork(Links = df_links,
                Nodes = nodes,
                Source = "source",
                Target = "target",
                Value = "value",
                NodeID = "name",
                fontSize = 13,
                nodeWidth = 30,
                sinksRight = TRUE)
})

# 🔁 Graphe réseau interactif basé sur les dyades
output$plot_network4 <- renderPlot({
  df <- data_filtrée4()
  
  # Vérifications
  validate(
    need(nrow(df) > 0, "Aucun événement avec dyade disponible dans les filtres actuels."),
    need(!is.null(df$dyad_name), "Les données filtrées ne contiennent pas de dyades.")
  )
  
  # Extraire les acteurs source / cible
  df_graph <- df %>%
    filter(str_detect(dyad_name, " - ")) %>%
    mutate(
      dyad_split = str_split(dyad_name, " - "),
      source_actor = map_chr(dyad_split, 1),
      target_actor = map_chr(dyad_split, 2)
    ) %>%
    group_by(source_actor, target_actor) %>%
    summarise(weight = sum(best_est, na.rm = TRUE), .groups = "drop") %>%
    filter(weight > 0)
  
  # Construire le graphe
  g <- tbl_graph(edges = df_graph, directed = TRUE)
  
  # Visualiser
  ggraph(g, layout = "fr") +
    geom_edge_fan(aes(width = weight), color = "#95a5a6", alpha = 0.5) +
    geom_node_point(size = 8, color = "#2c3e50") +
    geom_node_text(aes(label = name), repel = TRUE, size = 4) +
    scale_edge_width(range = c(0.5, 4)) +
    theme_void() +
    labs(title = "Réseau des dyades – conflits armés")
})


output$plot_heatmap4 <- renderPlot({
  df <- data_filtrée4() %>%
    mutate(
      year = lubridate::year(date_start),
      month = lubridate::month(date_start)
    ) %>%
    group_by(year, month) %>%
    summarise(
      total_morts = sum(best_est, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    tidyr::complete(
      year = full_seq(year, 1),
      month = 1:12,
      fill = list(total_morts = 0)
    ) %>%
    mutate(
      month = factor(month, levels = 1:12, labels = month.abb)
    )
  
  ggplot(df, aes(x = month, y = factor(year), fill = total_morts)) +
    geom_tile(color = "white") +
    scale_fill_gradient(low = "white", high = "steelblue", name = "Décès estimés") +
    labs(
      title = paste("Heatmap des conflits –", input$pays4),
      x = "Mois", y = "Année"
    ) +
    theme_minimal(base_size = 14)
})


}
