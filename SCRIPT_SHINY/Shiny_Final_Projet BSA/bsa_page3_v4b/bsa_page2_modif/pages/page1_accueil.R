page1_accueil_ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      :root {
        --primary: #005f87;
        --accent: #dc3545;
        --light: #f8f9fa;
      }
      
      .header-container {
        display: grid;
        grid-template-columns: auto 1fr auto;
        align-items: center;
        gap: 20px;
        padding: 30px 0;
        background: linear-gradient(to right, var(--primary) 0%, #003350 100%);
        color: white;
      }
      
      .title-box {
        text-align: center;
        padding: 20px;
        background: rgba(255,255,255,0.1);
        border-radius: 15px;
        backdrop-filter: blur(5px);
      }
      
      .stats-row {
        display: flex;
        justify-content: space-between;
        margin: 20px 0;
      }
      
      .stat-card {
        background: white;
        border-radius: 15px;
        padding: 20px;
        margin: 15px 0;
        box-shadow: 0 4px 15px rgba(0,0,0,0.08);
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        border-left: 4px solid #005f87;
      }

      .stat-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 25px rgba(0,0,0,0.12);
      }

      .stat-content {
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
        min-height: auto;
        height: auto;
      }

      .stat-icon {
        font-size: 2.3em;
        color: #005f87;
        margin-bottom: 13px;
      }

      .emphasis-number {
        font-size: 2.8em;
        font-weight: 800;
        color: #003350;
        line-height: 1;
        margin: 8px 0;
      }

      .stat-label {
        font-size: 1.1em;
        font-weight: 600;
        color: #2c3e50;
        margin-bottom: 8px;
      }

      .stat-subtext {
        font-size: 0.9em;
        color: #7f8c8d;
      }

      .highlight-card {
        border-left: 5px solid #dc3545;
        background: linear-gradient(135deg, #fff 85%, #fff5f5 100%);
      }

      .highlight-card .stat-icon {
        color: #dc3545;
      }
      
      .map-wrapper {
        height: 600px;
        border-radius: 15px;
        overflow: hidden;
        margin-top: 20px;
      }
      
      .map-container {
        height: 100%;
        width: 100%;
        object-fit: contain;
      }
      
      .sources-panel {
        background: #f8f9fa;
        padding: 25px;
        border-radius: 12px;
        margin-top: 30px;
      }
      
      .objective-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 25px;
        margin-top: 30px;
      }
      
      .objective-card {
        background: white;
        padding: 25px;
        border-radius: 12px;
        border: 2px solid #005f87;
        position: relative;
        overflow: hidden;
      }
      
      .objective-card::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 0;
        width: 100%;
        height: 4px;
        background: #005f87;
        transition: height 0.3s ease;
      }
      
      .objective-card:hover::after {
        height: 8px;
      }
      
      .feature-section {
        margin-top: 40px;
        padding: 30px;
        background: #f8f9fa;
        border-radius: 15px;
      }
      
      .feature-card {
        background: white;
        border-radius: 12px;
        padding: 25px;
        margin: 15px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.05);
        transition: all 0.3s ease;
        border-left: 4px solid #005f87;
      }
    "))
  ),
  
  div(class = "container-fluid",
      
      # En-tête
      div(class = "header-container",
          tags$img(src = "uemoa_map_logo.png", style = "height: 80px; margin-left: 30px;"),
          div(class = "title-box",
              tags$h1("Observatoire Stratégique UEMOA", style = "margin: 0; letter-spacing: 1px;"),
              tags$h3("Cartographie dynamique des violences politiques", style = "margin: 10px 0; font-weight: 300;")
          ),
          tags$img(src = "uemoa_map_logo.png", style = "height: 80px; margin-right: 30px; opacity: 0.9;")
      ),
      
      # Statistiques
      fluidRow(
        column(3, 
               div(class = "stat-card",
                   div(class = "stat-content",
                       icon("chart-line", class = "stat-icon"),
                       div(class = "emphasis-number", "75x"),
                       div(class = "stat-label", "Augmentation des violences politiques"),
                       div(class = "stat-subtext", "Depuis 1989")
                   )
               )
        ),
        column(3,
               div(class = "stat-card",
                   div(class = "stat-content",
                       icon("fire", class = "stat-icon"),
                       div(class = "emphasis-number", "900+"),
                       div(class = "stat-label", "Violences politiques en 2023"),
                       div(class = "stat-subtext", "Nouveau record")
                   )
               )
        ),
        column(3,
               div(class = "stat-card",
                   div(class = "stat-content",
                       icon("users", class = "stat-icon"),
                       div(class = "emphasis-number", "34.952"),
                       div(class = "stat-label", "Personnes décédées"),
                       div(class = "stat-subtext", "Zone UEMOA")
                   )
               )
        ),
        column(3,
               div(class = "stat-card highlight-card",
                   div(class = "stat-content",
                       icon("exclamation-triangle", class = "stat-icon"),
                       div(class = "emphasis-number", "2023"),
                       div(class = "stat-label", "Nouvelle configuration"),
                       div(class = "stat-subtext", "Émergence de l'AES")
                   )
               )
        )
      ),
      
      # Carte
      div(class = "map-wrapper",
          tags$img(src = "carte_uemoa_anim.gif", class = "map-container")
      ),
      
      # Objectifs
      fluidRow(
        column(12,
               div(class = "feature-section",
                   tags$h3("Objectifs du projet ", style = "color: #005f87; margin-bottom: 30px; text-align: center;"),
                   div(class = "objective-grid",
                       div(class = "objective-card",
                           tags$h4(icon("crosshairs"), " Statistiques descriptives"),
                           tags$p("Analyse visuelle de l'évolution des violences politiques")
                       ),
                       div(class = "objective-card",
                           tags$h4(icon("globe-africa"), " Comparaison Régionale"),
                           tags$p("Identification des zones critiques")
                       ),
                       div(class = "objective-card",
                           tags$h4(icon("lightbulb"), " Aide à la Décision"),
                           tags$p("Support aux politiques publiques")
                       )
                   )
               )
        )
      ),
      # 🔷 Section Exploration Interactive
      fluidRow(
        column(12,
               div(class = "feature-section",
                   tags$h3("Exploration Interactive", style = "color: #005f87; margin-bottom: 30px; text-align: center;"),
                   div(class = "objective-grid",
                       div(class = "feature-card",
                           icon("sliders", class = "feature-icon"),
                           tags$h4("Personnalisation des données"),
                           tags$ul(
                             tags$li("Filtres temporels dynamiques"),
                             tags$li("Sélection multicritère"),
                             tags$li("Échelle d'analyse ajustable")
                           )
                       ),
                       div(class = "feature-card",
                           icon("map-location-dot", class = "feature-icon"),
                           tags$h4("Cartographie avancée"),
                           tags$ul(
                             tags$li("Visualisation heatmap"),
                             tags$li("Couches thématiques"),
                             tags$li("Géolocalisation précise")
                           )
                       ),
                       div(class = "feature-card",
                           icon("chart-line", class = "feature-icon"),
                           tags$h4("Analyse temporelle"),
                           tags$ul(
                             tags$li("Courbes d'évolution"),
                             tags$li("Comparaisons historiques"),
                             tags$li("Projections statistiques")
                           )
                       )
                   )
               
                )
        )
      )
  )
)