# ui.R

source("pages/page1_accueil.R", local = TRUE)
source("pages/page2_exploration.R", local = TRUE)
source("pages/page3_stats.R", local = TRUE)
source("pages/page4_analyses.R", local = TRUE)
source("pages/page5_docs.R", local = TRUE)

ui <- navbarPage(
  title = "Tableau de bord UEMOA",
  theme = shinytheme("flatly"),
  
  # Onglets
  tabPanel("Accueil / Introduction", page1_accueil_ui),
  tabPanel("Exploration interactive", page2_exploration_ui),
  tabPanel("Statistiques descriptives", page3_stats_ui),
  tabPanel("Analyses avancées", page4_analyses_ui),
  tabPanel("Documentation & crédits", page5_docs_ui),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
   )
)

