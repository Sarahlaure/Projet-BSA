library(shiny)
library(shinythemes)

# Chargement des pages
source("pages/page1_accueil.R", local = TRUE)
source("pages/page2_exploration.R", local = TRUE)
source("pages/page3_stats.R", local = TRUE)
source("pages/page4_analyses.R", local = TRUE)
source("pages/page5_docs.R", local = TRUE)

ui <- tagList(
  
  # 🧩 HEAD : Feuille de style et styles personnalisés
  tags$head(
    tags$style(HTML("
      html, body {
        height: 100%;
        margin: 0;
        display: flex;
        flex-direction: column;
      }

      #app-content {
        flex: 1;
      }

      .footer-static {
        background-color: #2c3e50;
        color: white;
        padding: 20px 30px;
        font-size: 14px;
        border-top: 3px solid #18bc9c;
      }

      .footer-static small {
        color: #ccc;
      }

      .footer-static strong {
        color: #ffffff;
      }

      .footer-static .fa, .footer-static i {
        color: #f1c40f;
      }
    ")),
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  ),
  
  # 🧱 Contenu principal avec ID pour le flex
  div(id = "app-content",
      navbarPage(
        title = "Tableau de bord UEMOA",
        theme = shinytheme("flatly"),
        
        tabPanel("Accueil / Introduction", page1_accueil_ui),
        tabPanel("Exploration interactive", page2_exploration_ui),
        tabPanel("Statistiques descriptives", page3_stats_ui),
        tabPanel("Analyses avancées", page4_analyses_ui),
        tabPanel("Documentation & crédits", page5_docs_ui)
      )
  ),
  
  # 🦶 Footer toujours en bas
  tags$footer(class = "footer-static",
              fluidRow(
                column(6,
                       HTML("📊 <strong>Visualisation des conflits et troubles dans l'UEMOA</strong><br/>
                            <small>Données UCDP – Projet BSA 2025</small>")
                ),
                column(6, align = "right",
                       HTML("💡 Réalisé par <strong>Samba – Ahmadou – Sarah-Laure</strong><br/>
                            <small>Gen - USB</small>")
                )
              )
  )
)
