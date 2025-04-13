page4_analyses_ui <- fluidPage(
  
  titlePanel("📊 Analyses avancées des conflits dans l’espace UEMOA"),
  br(),
  
  ## 🔹 Filtres globaux pour la page
  fluidRow(
    column(4,
           selectInput("pays4", "🌍 Pays :", choices = NULL, multiple = FALSE)
    ),
    column(4,
           selectInput("violence_type4", "💥 Type de violence :",
                       choices = c("Tout" = "all",
                                   "Conflit entre État et groupes armés" = "1",
                                   "Conflit entre groupes armés" = "2",
                                   "Violence contre civils" = "3"),
                       selected = "all", multiple = FALSE)
    ),
    column(4,
           sliderInput("periode4", "📅 Période (année) :", min = 2000, max = 2025,
                       value = c(2000, 2025), step = 1, sep = "")
    )
  ),
  
  br(), tags$hr(),
  
  ## 🔸 Bloc 1 – Graphiques temporels
  tags$h3("📈 Évolution temporelle"),
  tags$p("Ce bloc permet de visualiser l’évolution annuelle ou mensuelle des violences dans le pays sélectionné. 
         À gauche, la courbe lissée présente la tendance de l’indicateur. Il est possible de filter suivant l'indicateur que nous voulons 
         visualiser mais aussi filtrer suivant une visualisation annuelle ou mensuelle
         À droite, on peut visualiser la corrélation (droite de régression) entre la variable du filtre de gauche et celle du filtre de droite."),
  
  fluidRow(
    column(4,
           selectInput("var_spline", "📌 Variable à visualiser :",
                       choices = c("Nombre d'événements" = "n",
                                   "Décès estimés (best_est)" = "best_est",
                                   "Morts civils (deaths_civilians)" = "deaths_civilians"),
                       selected = "n")
    ),
    column(4,
           selectInput("gran_spline", "⏳ Granularité temporelle :",
                       choices = c("Annuelle" = "annee", "Mensuelle" = "mois"),
                       selected = "annee")
    ),
    column(4,
           selectInput("var_spline2", "📎 Variable à corréler :",
                       choices = c("Nombre d'événements" = "n",
                                   "Décès estimés (best_est)" = "best_est",
                                   "Morts civils (deaths_civilians)" = "deaths_civilians"),
                       selected = "best_est")
    )
  ),
  
  fluidRow(
    column(6,
           tags$h4("Variable visualisée (courbe d'évolution + sa courbe lissée (tendance) )"),
           withSpinner(plotOutput("plot_spline"), type = 6, color = "#0072B2")
    ),
    column(6,
           tags$h4("Corrélation victimes vs événements"),
           withSpinner(plotOutput("plot_correlation"), type = 6, color = "#2c3e50")
    )
  ),
  
  br(), tags$hr(),
  
  ## 🔸 Bloc 2 – ACP + Clustering
  tags$h3("🔍 Clustering des conflits (ACP + K-means)"),
  tags$p("Cette section regroupe les événements violents selon leurs caractéristiques statistiques : nombre de morts (best_est), morts par camp (deaths_a, deaths_b), civils tués, type de violence. 
         Une Analyse en Composantes Principales (ACP) est suivie d’un clustering (K-means) pour détecter des profils types.
         Important: Pour avoir des informations sur un cluster, veuillez positionner votre souris sur un des points de votre cluster et vous saurez à quel groupe il correspond"),
  
  fluidRow(
    column(12,
           withSpinner(plotlyOutput("plot_clustering4", height = "500px"), type = 6, color = "#1abc9c")
           
    )
  ),
  
  br(), tags$hr(),
  
  ## 🔸 Bloc 3 – Sankey + Graphe réseau
  tags$h3("🔄 Visualisation des interactions entre acteurs"),
  tags$p("Ces graphiques permettent de représenter les dyades de conflit, c’est-à-dire les paires d’acteurs impliqués dans un affrontement. 
         Le diagramme de Sankey (à gauche) illustre les flux de violence entre les acteurs. Chaque rectangle représente un acteur (groupe armé, 
         force de sécurité, acteur non étatique, etc.), et chaque liaison (flux) indique une interaction violente. L’épaisseur du flux reflète l’intensité 
         du conflit, mesurée par le nombre estimé de morts (best_est). Ce graphique permet ainsi de visualiser qui attaque qui, et d’identifier les principaux agresseurs ou groupes ciblés.
         Le graphe réseau (à droite) le graphe réseau propose une autre lecture des dyades de conflit. Chaque nœud est un acteur, et chaque arête orientée représente un affrontement avec un autre.
         L’orientation de la flèche indique le sens de l’agression, tandis que l’épaisseur traduit l’intensité des affrontements. Ce graphique met en évidence les groupes centraux dans le réseau de violence (souvent impliqués dans plusieurs conflits), mais aussi ceux qui sont plus isolés."),
  
  fluidRow(
    column(6,
           tags$h4("Diagramme Sankey des conflits"),
           withSpinner(sankeyNetworkOutput("plot_sankey4", height = "500px"), type = 6, color = "#8e44ad")
    ),
    column(6,
           tags$h4("Graphe réseau des dyades"),
           withSpinner(plotOutput("plot_network4", height = "600px"), type = 6, color = "#16a085")
    )
  ),
  
  br(), tags$hr(),
  
  ## 🔸 Bloc 4 – Heatmap temporelle
  tags$h3("🗓️ Carte thermique des conflits dans le temps"),
  tags$p("Ce graphique permet de visualiser la saisonnalité des violences dans le pays choisi. 
         Chaque case indique le nombre de morts estimées pour un mois donné. Se régérer à l'échelle pour voir le nombre de morts."),
  
  fluidRow(
    column(12,
           withSpinner(plotOutput("plot_heatmap4", height = "500px"), type = 6, color = "#d35400")
    )
  ),
  
  br(), tags$hr(),
  
  ## 🔸 Note finale
  tags$p("Les analyses ci-dessus sont interactives et varient selon les filtres appliqués (pays, type de violence, période). 
         Elles offrent une vue analytique avancée pour mieux comprendre les dynamiques sécuritaires dans la région.",
         style = "font-size: 0.9em; color: gray;")
)


