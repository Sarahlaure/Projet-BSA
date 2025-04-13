# ui.R

source("pages/page1_accueil.R", local = TRUE)
source("pages/page2_exploration.R", local = TRUE)
source("pages/page3_stats.R", local = TRUE)
source("pages/page4_analyses.R", local = TRUE)
source("pages/page5_docs.R", local = TRUE)


ui <- navbarPage(
  title = "Tableau de bord UEMOA",
  theme = shinytheme("flatly"),
  
  # CSS pour le footer non fixe
  tags$head(
    tags$style(HTML("
      .footer-static {
        background-color: #2c3e50;
        color: white;
        padding: 20px 30px;
        font-size: 14px;
        border-top: 3px solid #18bc9c;
        margin-top: 50px;
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
  
  # Onglets
  tabPanel("Accueil / Introduction", page1_accueil_ui),
  tabPanel("Exploration interactive", page2_exploration_ui),
  tabPanel("Statistiques descriptives", page3_stats_ui),
  tabPanel("Analyses avancées", page4_analyses_ui),
  tabPanel("Documentation & crédits", page5_docs_ui),
  
  # Footer (non sticky)
  footer = tags$footer(class = "footer-static",
                       fluidRow(
                         column(6,
                                HTML("📊 <strong>Visualisation des conflits et troubles dans l'UEMOA</strong><br/>
                  <small>Données  UCDP – Projet BSA 2025</small>")
                         ),
                         column(6, align = "right",
                                HTML("💡 Réalisé par <strong>Samba – Ahmadou – Sarah-Laure</strong><br/>
                  <small>Gen - USB</small>")
                         )
                       )
  )
)