library(shiny)
library(shinythemes)

ui <- fluidPage(
  theme = shinytheme("flatly"),
  
  # 🅰️ PAGE 1 – Accueil / Introduction
  titlePanel(""),
  
  ## 🔹 Bloc 1 – Présentation générale
  fluidRow(
    column(
      width = 12,
      tags$h1("Tableau de bord sur les troubles sécuritaires dans l’espace UEMOA", style = "text-align: center; font-weight: bold;"),
      tags$h3("Une analyse géographique et temporelle des événements de sécurité", style = "text-align: center;"),
      tags$p(
        "Cette application vise à explorer, comprendre et comparer les dynamiques des événements de sécurité dans les pays membres de l’UEMOA. 
        Elle s’appuie sur des données fiables pour fournir des visualisations interactives utiles aux chercheurs, décideurs et citoyens.",
        style = "text-align: center; font-size: 16px; padding: 10px;"
      ),
      tags$div(
        style = "text-align: center;",
        tags$img(src = "uemoa_map_logo.png", height = "250px")
      )
    )
  ),
  
  tags$hr(),
  
  ## 🔹 Bloc 2 – Contexte géopolitique
  fluidRow(
    column(
      width = 6,
      tags$h4("Le rôle de la CEDEAO"),
      tags$p(
        "La Communauté Économique des États de l’Afrique de l’Ouest (CEDEAO) est une organisation régionale visant à promouvoir l’intégration économique, 
        politique et sécuritaire entre ses États membres. Elle regroupe 15 pays d’Afrique de l’Ouest, dont 8 composent l’UEMOA (Union Économique et Monétaire Ouest Africaine) : 
        Bénin, Burkina Faso, Côte d’Ivoire, Guinée-Bissau, Mali, Niger, Sénégal, et Togo."
      )
    ),
    column(
      width = 6,
      tags$h4("Carte des pays de l’UEMOA"),
      tags$img(src = "uemoa_static_map.png", width = "100%", style = "border: 1px solid #ccc;")
    )
  ),
  
  tags$hr(),
  
  ## 🔹 Bloc 3 – Sources & Objectifs
  fluidRow(
    column(
      width = 6,
      tags$h4("Objectifs de l’application"),
      tags$ul(
        tags$li("Expliquer les dynamiques de sécurité dans la région."),
        tags$li("Fournir des visualisations interactives des données."),
        tags$li("Comparer les tendances entre pays membres."),
        tags$li("Faciliter la prise de décision et la sensibilisation.")
      )
    ),
    column(
      width = 6,
      tags$h4("Sources de données"),
      tags$ul(
        tags$li(tags$a(href = "https://acleddata.com/", "ACLED – Armed Conflict Location & Event Data Project", target = "_blank")),
        tags$li(tags$a(href = "https://ucdp.uu.se/", "UCDP – Uppsala Conflict Data Program", target = "_blank")),
        tags$li(tags$a(href = "https://data.humdata.org/", "HDX – Humanitarian Data Exchange", target = "_blank"))
      )
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui, server)
