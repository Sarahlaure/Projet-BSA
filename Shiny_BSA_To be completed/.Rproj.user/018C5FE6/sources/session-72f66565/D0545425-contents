# pages/page2_exploration.R

library(leaflet)
library(shinydashboard)
library(DT)

page2_exploration_ui <- fluidPage(
  div(class = "container-custom",
      
      # 🔹 Bloc 1 – Filtres interactifs
      tags$h3("🎛️ Filtres de sélection"),
      tags$p("Affinez votre recherche en sélectionnant des critères spécifiques :"),
      
      div(class = "filtre-panel",
          fluidRow(
            column(6,
                   tags$label("🌍 Pays concernés"),
                   selectInput("pays", NULL,
                               choices = NULL, selected = NULL, multiple = TRUE,
                               width = "100%")
            ),
            column(6,
                   tags$label("🗓️ Période analysée"),
                   dateRangeInput("dates", NULL, 
                                  start = "2010-01-01", end = Sys.Date(),
                                  format = "yyyy-mm-dd", separator = " à ",
                                  width = "100%")
            )
          ),
          
          fluidRow(
            column(6,
                   tags$label("⚔️ Type de violence"),
                   selectInput("violence_type", NULL,
                               choices = c("Conflit entre États" = 1,
                                           "Violence non étatique" = 2,
                                           "Violence contre civils" = 3),
                               selected = c(1,2,3), multiple = TRUE,
                               width = "100%")
            ),
            column(6,
                   tags$label("📉 Seuil minimum de morts estimées"),
                   sliderInput("mort_min", NULL, min = 0, max = 500, value = 0, width = "100%")
            )
          ),
          
          fluidRow(
            column(12,
                   tags$label("👥 Dyade spécifique"),
                   selectInput("dyade", NULL,
                               choices = NULL, selected = NULL, multiple = TRUE,
                               width = "100%")
            )
          )
      ),
      
      
      # 🔹 Bloc 2 – Carte interactive
      tags$h3("🗺️ Carte des événements sécuritaires"),
      tags$p("Chaque point correspond à un événement. Cliquez dessus pour voir les détails."),
      
      fluidRow(
        column(12,
               leafletOutput("map_events", height = "600px")
        )
      ),
      
      tags$hr()
      ,
      
      # 🔹 Bloc 3 – Indicateurs clés
      tags$h3("Indicateurs clés"),
      fluidRow(
        column(4,
               div(class = "indicator-card",
                   tags$h4("📌 Nombre total d'événements"),
                   textOutput("box_total_events")
               )
        ),
        column(4,
               div(class = "indicator-card",
                   tags$h4("☠️ Morts estimées totales"),
                   textOutput("box_total_deaths")
               )
        ),
        column(4,
               div(class = "indicator-card",
                   tags$h4("🧍‍♂️ Proportion de morts civils"),
                   textOutput("box_prop_civilians")
               )
        )),
      
      tags$hr(),
      
      # 🔹 Bloc 4 – Tableau des événements
      tags$h3("📋 Détail des événements filtrés"),
      fluidRow(
        column(12,
               downloadButton("downloadData", "Télécharger les données filtrées"),
               br(), br(),
               DTOutput("table_events")
        )
      )
  )
)
