library(ggplot2)
library(plotly)
library(dplyr)
library(leaflet)

page3_stats_ui <- fluidPage(
  # 🎛️ Filtres en haut de la page
  # 🎛️ Filtres dynamiques avec design inspiré (encadré clair + icônes)
  wellPanel(
    fluidRow(
      column(6,
             tags$label(icon("globe-europe", lib = "font-awesome"), " Pays concernés", style = "font-weight: bold;"),
             selectInput("filtre_pays", NULL, choices = NULL, selected = NULL, multiple = TRUE)
      ),
      column(6,
             tags$label(icon("calendar-alt", lib = "font-awesome"), " Période analysée", style = "font-weight: bold;"),
             dateRangeInput("filtre_date", NULL,
                            start = "2015-01-01", end = "2024-12-31",
                            format = "yyyy-mm-dd", separator = " à ")
      )
    )
  )
  ,
  tags$hr(),
  div(class = "container-custom",
      
      tags$h2("📊 Statistiques descriptives"),
      tags$p("Cette page vous offre une vue d'ensemble interactive des événements violents enregistrés dans l'espace UEMOA. Vous pouvez explorer leur répartition par pays, type de violence, et période. Les filtres dynamiques permettent d’affiner l’analyse selon vos besoins."),
      
      # 🔹 Bloc 1 – Répartition par pays OU contexte
      tags$h3("🗺️ Répartition par pays"),
      uiOutput("bloc_pays_adaptatif"),
      
      tags$hr(),
      
      # 🔹 Bloc 2 – Répartition par type de violence

      
      tags$h3("💥 Répartition par type de violence"),
      tags$p(
        "Cette section analyse les différentes formes de violences (conflits entre États, violences non étatiques, violences contre civils). 
   Elle met en lumière les types les plus fréquents et les dyades les plus impliquées dans chaque catégorie.",
        style = "font-size: 16px; color: #333;"
      ),
      div(class = "row gy-4",
          div(class = "col-md-6",
              div(class = "card shadow-sm p-3",
                  plotlyOutput("plot_violence_pie"),
                  tags$p(textOutput("comment_violence_type"),
                         style = "font-style: italic; font-size: 14px; color: #555; margin-top: 10px;")
              )
          ),
          div(class = "col-md-6",
              div(class = "card shadow-sm p-3",
                  plotlyOutput("plot_violence_dyade"),
                  tags$p(textOutput("comment_violence_dyade"),
                         style = "font-style: italic; font-size: 14px; color: #555; margin-top: 10px;")
              )
          )
      ),
      
      tags$hr(),
      
      # 🔹 Bloc 3 – Évolution temporelle
      tags$h3("📈 Évolution temporelle"),
      tags$p(
        "Ce bloc explore la dynamique temporelle des conflits dans l’espace UEMOA. 
   Il permet de visualiser l’évolution mensuelle du nombre d’événements violents et des morts associées, 
   mettant en évidence les pics de violence ou les périodes d'accalmie.",
        style = "font-size: 16px; color: #333;"
      ),
      
      div(class = "row gy-4",
          div(class = "col-md-6",
              div(class = "card shadow-sm p-3",
                  plotlyOutput("plot_timeline_events"),
                  tags$p(textOutput("comment_timeline_events"),
                         style = "font-style: italic; font-size: 14px; color: #555; margin-top: 10px;")
              )
          ),
          div(class = "col-md-6",
              div(class = "card shadow-sm p-3",
                  plotlyOutput("plot_timeline_deaths"),
                  tags$p(textOutput("comment_timeline_deaths"),
                         style = "font-style: italic; font-size: 14px; color: #555; margin-top: 10px;")
              )
          )
      ),
      
      tags$hr(),
      
      # 🔹 Bloc 4 – Focus sur les violences contre civils
      tags$h3("🧍‍♂️ Focus : Violences contre civils"),
      tags$p(
        "Cette section met l'accent sur les violences dirigées contre les populations civiles. 
   Elle présente une cartographie des événements impliquant des civils ainsi qu'une analyse temporelle 
   de l'évolution des morts civiles estimées, afin d’identifier les zones et les périodes les plus critiques.",
        style = "font-size: 16px; color: #333;"
      ),
      
      div(class = "row gy-4",
          div(class = "col-md-6",
              div(class = "card shadow-sm p-3",
                  leafletOutput("map_civilians", height = "500px"),
                  tags$p(textOutput("comment_map_civilians"),
                         style = "font-style: italic; font-size: 14px; color: #555; margin-top: 10px;")
              )
          ),
          div(class = "col-md-6",
              div(class = "card shadow-sm p-3",
                  plotlyOutput("plot_civilians_timeline"),
                  tags$p(textOutput("comment_civilians_timeline"),
                         style = "font-style: italic; font-size: 14px; color: #555; margin-top: 10px;")
              )
          )
      )
  )
)
