# pages/page1_accueil.R

page1_accueil_ui <- fluidPage(
  div(class = "container-custom",
      
      # 🔹 Bloc 1 – Présentation générale
      div(class = "centered",
          tags$h1("Tableau de bord sur les troubles sécuritaires dans l’espace UEMOA"),
          tags$h3("Une analyse géographique et temporelle des événements de sécurité"),
          tags$p("Cette application a pour objectif de mieux comprendre les problématiques sécuritaires qui affectent les pays membres de l’UEMOA.
Face à la montée des violences armées, des attaques terroristes et des conflits communautaires dans la région, elle propose des visualisations interactives basées sur des données fiables pour analyser les tendances, comparer les situations entre pays, et appuyer la réflexion stratégique des acteurs publics, chercheurs et partenaires au développement.

"),
          tags$img(src = "uemoa_map_logo.png", class = "logo-uemoa")
      ),
      
      tags$hr(),
      
      # 🔹 Bloc 2 – Contexte géopolitique
      fluidRow(
        column(
          width = 6,
          tags$div(class = "section-title", "Le rôle de la CEDEAO"),
          tags$p("La Communauté Économique des États de l’Afrique de l’Ouest (CEDEAO) est une organisation régionale visant à promouvoir l’intégration économique, 
                 politique et sécuritaire entre ses États membres. Elle regroupe 15 pays d’Afrique de l’Ouest, dont 8 composent l’UEMOA (Union Économique et Monétaire Ouest Africaine) : 
                 Bénin, Burkina Faso, Côte d’Ivoire, Guinée-Bissau, Mali, Niger, Sénégal, et Togo.
                 Cependant, l’espace UEMOA est confronté à des défis sécuritaires croissants, liés notamment au terrorisme, aux conflits intercommunautaires et à l’instabilité politique. 
                 Ces troubles freinent les efforts d’intégration et affectent la stabilité socio-économique des États membres.")
        ),
        column(
          width = 6,
          tags$div(class = "section-title", "Carte des pays de l’UEMOA"),
          tags$img(src = "uemoa_static_map.jpg", class = "map-static")
        )
      ),
      
      tags$hr(),
      
      # 🔹 Bloc 3 – Sources & Objectifs
      fluidRow(
        column(
          width = 6,
          tags$div(class = "section-title", "Objectifs de l’application"),
          tags$ul(
            tags$li("Expliquer les dynamiques de sécurité dans la région."),
            tags$li("Fournir des visualisations interactives des données."),
            tags$li("Comparer les tendances entre pays membres."),
            tags$li("Faciliter la prise de décision et la sensibilisation.")
          )
        ),
        column(
          width = 6,
          tags$div(class = "section-title", "Sources de données"),
          tags$ul(
            tags$li(tags$a(href = "https://acleddata.com/", "ACLED – Armed Conflict Location & Event Data Project", target = "_blank")),
            tags$li(tags$a(href = "https://ucdp.uu.se/", "UCDP – Uppsala Conflict Data Program", target = "_blank")),
            tags$li(tags$a(href = "https://data.humdata.org/", "HDX – Humanitarian Data Exchange", target = "_blank"))
          )
        )
      )
  )
)
