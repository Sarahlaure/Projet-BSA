page5_docs_ui <- fluidPage(
  div(class = "container-custom",
      h2("Documentation & Crédits", style = "text-align: center; margin-bottom: 30px;"),
      tabsetPanel(
        id = "doc_tabs",
        selected = "Dictionnaire des variables",
        
        # ONGLET 1 : SOURCES
        tabPanel(
          title = "Sources",
          icon = icon("database"),
          div(class = "source-container",
              h3("Présentation de la source des données", class = "section-title"),
              br(),
              p(style = "text-align: justify; font-size: 16px;",
                "Le ", tags$b("Uppsala Conflict Data Program (UCDP)"), 
                " est un programme de recherche internationalement reconnu, basé à l’Université d’Uppsala en Suède. 
                Il constitue l’une des bases de données les plus complètes et les plus fréquemment utilisées pour l’étude des conflits armés à l’échelle mondiale. 
                Depuis les années 1980, le UCDP collecte, vérifie et structure des informations relatives aux événements violents impliquant des États, 
                des groupes armés ou des acteurs non étatiques."
              ),
              br(),
              p(style = "text-align: justify; font-size: 16px;",
                "Dans le cadre de ce projet, les données exploitées proviennent spécifiquement de la base de données ", 
                tags$b("UCDP GED (Georeferenced Event Dataset)"), ", qui se distingue par la précision géographique des événements qu’elle recense. 
                Chaque observation correspond à un événement conflictuel unique, géolocalisé, avec des métadonnées complètes telles que la date, 
                le lieu, les acteurs impliqués, le type de conflit et les pertes humaines estimées."
              ),
              br(),
              p(style = "text-align: justify; font-size: 16px;",
                "Nous avons téléchargé la version la plus récente de cette base de données directement depuis le site officiel du UCDP : ", 
                tags$a(href = "https://ucdp.uu.se/", "https://ucdp.uu.se/", target = "_blank"), ". Les données sont fournies au format CSV, 
                ce qui facilite leur traitement à l’aide d’outils statistiques et de visualisation. L’équipe a ensuite procédé à un nettoyage rigoureux de la base, 
                à la sélection de variables pertinentes pour l’analyse, et à l’adaptation du format pour un usage interactif dans une application développée sous ", 
                tags$b("R Shiny"), "."
              ),
              br(),
              p(style = "text-align: justify; font-size: 16px;",
                "Cette base constitue une source précieuse pour l’analyse des dynamiques de conflit en Afrique de l’Ouest, car elle permet non seulement de suivre 
                l’évolution des violences dans le temps, mais aussi de cartographier leur distribution spatiale."
              )
          )
        ),
        
        # ONGLET 2 : DICTIONNAIRE
        tabPanel(
          title = "Dictionnaire des variables",
          icon = icon("table"),
          div(class = "dico-container",
              h3("Dictionnaire des variables", class = "section-title"),
              p("Utilisez la barre de recherche pour filtrer les variables par nom."),
              DT::dataTableOutput("dico_table"),
              downloadButton("dl_dico", "Télécharger le dictionnaire", class = "btn-download")
          )
        ),
        
        # ONGLET 3 : METHODOLOGIE
        tabPanel(
          title = "Méthodologie",
          icon = icon("flask"),
          div(class = "methodology-container",
              h2("Approche méthodologique", class = "section-title-main"),
              
              # Section NETTOYAGE DES DONNÉES
              div(class = "methodology-section",
                  h3("Nettoyage des données", class = "subsection-title"),
                  div(class = "step-container",
                      lapply(
                        list(  # Début de la liste des étapes
                          list(
                            id = "step1",
                            title = "Problématique initiale des données",
                            content = paste0(
                              "Initialement, les données étaient organisées dans un format où les informations étaient séparées par des virgules. ",
                              "Cependant, ce format a rapidement posé plusieurs problèmes lors de l’importation dans des outils comme Excel.",
                              
                              "<br/><br/>",
                              "<strong>Usage ambigu de la virgule</strong> – la virgule servait à la fois de délimiteur global pour séparer les colonnes ",
                              "et de séparateur interne pour certaines valeursdans des colonnes spécifiques. Ce problème était particulièrement marqué pour les événements comportant plusieurs sources, où les sources étaient séparées par des virgules. Cette double utilisation de la virgule créait une confusion, car Excel interprétait toutes les virgules comme des délimiteurs de colonnes, risquant ainsi de mal organiser les données et de fragmenter des informations essentielles, voire de les perdre.",
                              
                              "<br/><br/>",
                              "<strong>Autre problème majeur</strong> – les informations n’étaient pas séparées correctement par des virgules. Par exemple, certaines données étaient simplement ajoutées dans la colonne suivante. Cela pouvait provoquer des colonnes vides pour certains événements ou, pire, des colonnes contenant des informations non pertinentes, non liées aux mêmes données.",
                              "Cette mauvaise organisation compliquait considérablement l'importation et la gestion des données, car elle perturbait la structure attendue et risquait de fausser les analyses ultérieures.",
                              
                              "<br/><br/>",
                              "Lors de l'importation dans Excel, la fonctionnalité <strong>Convertir</strong> d’Excel était susceptible de mal gérer cette séparation des colonnes, ",
                              "ce qui aurait abouti à une mauvaise répartition des informations ou, pire encore, à l’écrasement des données contenues dans d’autres colonnes.",
                              
                              "<br/><br/>",
                              "Pour éviter ces problèmes, il a été décidé de ne pas utiliser Excel, mais de nettoyer les données directement dans R, ",
                              "où un meilleur contrôle pouvait être exercé sur l’importation et le traitement."
                            )
                          ),
                          list(
                            id = "step2", 
                            title = "Regroupement des informations",
                            content = paste0("La première étape du nettoyage a consisté à <strong>regrouper toutes les informations dans une seule colonne</strong>.",
                            "<br/><br/>",
                            "Pour ce faire, l'astérisque (*) a été choisi comme délimiteur temporaire, car il n'apparaissait dans aucune des données originales. Ce choix a permis de regrouper toutes les informations sans risque de confusion avec les séparateurs de colonnes, préservant ainsi l'intégrité des données."
                            )
                            ),
                          list(
                            id = "step3", 
                            title = "Filtrage des lignes inutiles",
                            content = paste0("La deuxième étape a été <strong>d’éliminer les lignes qui ne contenaient pas d’informations pertinentes</strong>.",
                            "<br/><br/>",
                            "Certaines lignes étaient purement textuelles ou servaient d’en-têtes de sections, et ne représentaient pas des événements concrets. Ces lignes, contenant souvent des noms de communes ou des descriptions générales sans lien direct avec les événements, ont été filtrées.", 
                            "<br/>",
                            "Le <strong>critère de filtrage</strong> était simple : éliminer les lignes qui ne commençaient pas par un chiffre, car elles correspondaient à des informations supplémentaires ou des titres, et non à des données d'événements."
                            )
                            ),
                          list(
                            id = "step4", 
                            title = "Restructuration des données",
                            content = paste0("Après le filtrage, les données restantes ont été restructurées. La colonne initiale contenant des données textuelles complexes a été scindée en plusieurs colonnes pour séparer les différentes informations contenues dans chaque ligne.",
                                             "<br/><br/>",
                                             "Le mot-clé <strong>POINT</strong> a servi de référence pour diviser les données en deux parties :",
"<br/>",
"Avant POINT, se trouvaient des informations supplémentaires, telles que l'identifiant de l'événement, l'année, le type de violence, etc.",
"<br/>",
"Après POINT, se trouvaient les informations géographiques essentielles, telles que les coordonnées géographiques de l'événement.
"
                          )
                          ),
                          list(
                            id = "step5", 
                            title = "Extraction des coordonnées",
                            content = paste0("Les quatre dernières valeurs de la partie après <strong>POINT</strong> ont été extraites pour isoler les coordonnées géographiques (latitude et longitude). Ces coordonnées ont été ensuite séparées en deux colonnes distinctes : latitude et longitude."
                            )
                                             ),
                          list(
                            id = "step6", 
                            title = "Élimination des lignes non géolocalisées",
                            content = paste0("Les lignes sans coordonnées géographiques ont été supprimées, car elles étaient inutilisables pour l’analyse spatiale.", 
                                             "<br/><br/>",
                                             "Cela a permis de se concentrer sur les événements pertinents et exploitables."
                            )
                                             ),
                          list(
                            id = "step7", 
                            title = "Séparation des autres informations",
                            content = paste0("La colonne contenant les informations après <strong>POINT</strong> a été éclatée en plusieurs colonnes supplémentaires, créant des variables telles que <strong>geom_wkt</strong>, <strong>priogrid_gid</strong>, <strong>country</strong>, <strong>region</strong>, et d’autres informations liées aux événements",
                                             "<br/><br/>",
                            "Cette étape a permis de transformer une chaîne de texte en un tableau structuré et plus facile à analyser."
                            )
                                             ),
list(
  id = "step8", 
  title = "Vérification des doublons ",
  content = paste0("Après restructuration, une vérification des doublons a été effectuée sur les variables clés : latitude, longitude, id et geom_wkt, qui servent d’identifiants uniques pour chaque événement.",
                   "<br/><br/>",
                   "<strong>Aucun doublon n’a été trouvé</strong>, confirmant que chaque ligne représentait bien un événement unique."
  )
),
list(
  id = "step9", 
  title = "Conversion des variables numériques ",
  content = paste0("Certaines variables, telles que les identifiants (id, priogrid_gid) et les chiffres associés aux événementsont été converties en format numérique pour permettre des calculs et analyses statistiques ultérieurs ",
                   "<br/><br/>",
                   "Par exemple, <em>deaths_a</em>, <em>deaths_b</em>."
  )
),
list(
  id = "step10", 
  title = "Suppression des colonnes inutiles ",
  content = paste0("Enfin, les colonnes qui ne contenaient pas d'informations pertinentes pour l'analyse ont été supprimées.",
                   "<br/><br/>",
                   "Celles-ci étaient soit redondantes, soit non nécessaires au traitement des données."
  )
)
                        ),  # Fin de la liste des étapes
                        function(step) {  # Fonction de traitement
                          tagList(
                            div(class = "step-header",
                                tags$span(class = "step-icon", icon("caret-right")),
                                h4(step$title, class = "step-title", id = paste0("header-", step$id))
                            ),
                            div(class = "step-content", id = step$id,
                                p(style = "text-align: justify; font-size: 16px;", 
                                  HTML(step$content))
                            )
                          )
                        }  # Fin de la fonction
                      )  # Fin de lapply
                  ),  # Fin step-container
div(class = "summary-container",
    p(style = "text-align: justify; font-size: 18px;",
      HTML(
        paste0("<strong>Fusion des bases des données des différents pays en une seule base finale:</strong> Une fois les étapes de nettoyage et de structuration effectuées pour chaque pays, les bases de données ont été fusionnées en une seule base consolidée. Cette base unique a été utilisée pour effectuer une analyse globale des événements, permettant ainsi une exploitation complète et cohérente des données.",
               "<br/><br/>",
               "Elle comprend un total de <strong>trente-deux (32) variables</strong>."))))
              ),# Fin methodology-section
              
              # Section FONCTIONNALITÉS
              div(class = "methodology-section",
                  h3("Fonctionnalités de l'application", class = "subsection-title"),
                  div(class = "step-container",
                      lapply(list(
                        list(
                          id = "feature1",
                          title = "Exploration interactive",
                          content = HTML("
    <p>
      L'onglet <strong>Exploration interactive</strong> de l'application offre une analyse personnalisée et dynamique des événements violents à travers une interface hautement paramétrable. Il permet à l'utilisateur d'ajuster les critères de recherche selon ses besoins pour explorer les données de manière ciblée et approfondie.
    </p>

    <h4>Filtres personnalisables</h4>
    <p>
      L’utilisateur peut affiner ses recherches en sélectionnant plusieurs paramètres : un ou plusieurs pays, une plage de dates, le type de violence (<em>conflit entre États</em>, <em>violence non étatique</em> ou <em>violence contre les civils</em>), un seuil minimum de morts estimées, ainsi qu’une dyade spécifique (<code>group A vs. group B</code>). Ces filtres sont implémentés à l’aide des composants <code>selectInput()</code>, <code>dateRangeInput()</code> et <code>sliderInput()</code> de Shiny, permettant une interaction fluide et réactive. Chaque ajustement des filtres entraîne une mise à jour instantanée de la carte, des indicateurs et du tableau de données.
    </p>

    <h4>Carte interactive des événements</h4>
    <p>
      Une carte interactive constitue le cœur visuel de cet onglet. Les événements filtrés sont géolocalisés grâce au package <code>leaflet</code>. Chaque point affiché sur la carte représente un événement violent, dont la <strong>taille</strong> et la <strong>couleur</strong> varient en fonction du nombre de morts estimées, offrant ainsi une visualisation intuitive de leur gravité. Les événements sont ajoutés via la fonction <code>addCircleMarkers()</code>, et lorsqu’un utilisateur clique sur un point, une info-bulle générée avec <code>popup()</code> affiche des détails tels que la date, le pays, la dyade impliquée, le type de violence, et le nombre de morts.
    </p>

    <h4>Indicateurs clés en un coup d'œil</h4>
    <p>
      Pour une lecture rapide de l’information, trois <strong>indicateurs visuels</strong> sont affichés en haut de l’onglet : le nombre total d’événements, le total de morts estimées, et la proportion de morts civiles. Ces éléments, créés à l’aide du package <code>shinydashboard</code> et de la fonction <code>valueBox()</code>, offrent une synthèse instantanée de la situation selon les filtres choisis.
    </p>

    <h4>Tableau interactif des événements filtrés</h4>
    <p>
      Un tableau interactif présente les données détaillées correspondant aux critères de filtrage. Il comprend les colonnes suivantes : <em>date</em>, <em>pays</em>, <em>dyade</em>, <em>région</em>, <em>nombre de morts</em>, <em>nombre de victimes civiles</em> et <em>type de violence</em>. Ce tableau, construit avec le package <code>DT</code> et la fonction <code>datatable()</code>, permet de trier, rechercher et exporter les données. Un bouton intégré permet de télécharger les résultats au format CSV pour une analyse externe.
    </p>

    <p>
      <strong>En résumé</strong>, l’onglet Exploration interactive constitue un espace d’analyse flexible, combinant efficacement les packages <code>Shiny</code>, <code>leaflet</code>, <code>DT</code> et <code>shinydashboard</code>. Il permet à l’utilisateur d’explorer de façon ciblée les événements violents selon ses propres critères, avec une mise à jour en temps réel des résultats affichés à la fois sous forme cartographique, tabulaire et synthétique.
    </p>
  ")
                        ),
                        list(
                          id = "feature2",
                          title = "Statistiques descriptives",
                          content = HTML("
    <p>
      L'onglet <strong>Statistiques descriptives</strong> de l'application permet une exploration visuelle et agrégée des événements sécuritaires, offrant une vue d'ensemble claire et dynamique des données. L’objectif principal de cet onglet est de permettre à l'utilisateur d'analyser les données sous plusieurs angles : la fréquence des événements, la répartition par type de violence, l'évolution temporelle des incidents et l'impact spécifique sur les populations civiles. L'onglet utilise des graphiques interactifs pour présenter les données de manière intuitive et accessible, permettant ainsi une compréhension approfondie des tendances et des relations entre les variables.
    </p>

    <h4>Répartition par pays</h4>
    <p>
      Le premier bloc de l'onglet Statistiques descriptives offre une vue d'ensemble des événements par pays, permettant à l'utilisateur de comparer les nations en termes de fréquence et de gravité des événements violents. Pour cela, deux graphiques à barres sont utilisés. Le premier montre le nombre d’événements par pays, et le second représente le nombre total de morts estimées (<code>best_est</code>) par pays. Ces graphiques permettent à l'utilisateur de repérer rapidement quels pays sont les plus affectés, tant en termes de fréquence que de gravité des événements. Les composants utilisés pour ces visualisations sont <code>ggplot()</code>, et les variables associées incluent <code>country</code> et <code>best_est</code>.
    </p>

    <h4>Répartition par type de violence</h4>
    <p>
      Le second bloc se concentre sur la répartition des événements en fonction du type de violence. Ce bloc propose deux types de visualisation. Le premier est un diagramme circulaire (<code>pie chart</code>) qui montre la proportion des événements selon les trois types de violence : conflit entre États, conflit entre un État et un groupe organisé, et violence contre les civils. Le deuxième graphique est un <code>barplot</code> des types de violence par dyade, affichant les 10 dyades les plus fréquentes. Ces graphiques permettent à l'utilisateur de mieux comprendre quel type de violence est le plus courant et comment les dyades influent sur la répartition des événements violents. Les visualisations sont générées à l'aide de <code>plotly</code> pour le pie chart et <code>ggplot</code> pour le barplot. Les variables prises en compte sont <code>type_of_violence</code> et <code>dyad_name</code>.
    </p>

    <h4>Évolution temporelle des événements</h4>
    <p>
      Le troisième bloc met en évidence l'évolution des événements au fil du temps. Ce bloc comprend deux graphiques en ligne (<code>line charts</code>) interactifs. Le premier montre l’évolution du nombre d’événements dans le temps, et le second illustre l’évolution du nombre total de morts estimées. Ces graphiques permettent à l'utilisateur de détecter des périodes de crise intense ou des phases d’accalmie, en analysant les fluctuations temporelles des événements violents. L’objectif est de permettre une analyse longitudinale des données pour repérer des tendances ou des anomalies dans le temps. Ces graphiques sont créés à l’aide des packages <code>plotly</code> et <code>ggplot</code>, avec les variables <code>date_start</code> et <code>best_est</code>.
    </p>

    <h4>Focus sur la violence contre les civils</h4>
    <p>
      Enfin, le dernier bloc se concentre spécifiquement sur les violences contre les civils, un aspect crucial pour évaluer l'impact humanitaire des conflits. Ce bloc propose une carte interactive montrant la géolocalisation des événements de violence contre les civils (identifiés par <code>type_of_violence == 3</code>), ainsi qu’une timeline dédiée aux événements ayant entraîné des morts civiles. Ces visualisations permettent à l'utilisateur de visualiser l’étendue géographique et temporelle des violences contre les civils, et d’analyser l’impact de ces événements sur les populations non combattantes. La carte est générée grâce au package <code>leaflet</code>, tandis que la timeline est produite avec <code>ggplot</code>. Les variables utilisées dans ce bloc sont <code>deaths_civilians</code>, <code>type_of_violence</code>, <code>latitude</code>, et <code>longitude</code>.
    </p>

    <p>
      <strong>En résumé</strong>, l'onglet Statistiques descriptives offre une exploration visuelle et interactive des données liées aux événements sécuritaires. À travers des graphiques clairs et dynamiques, cet onglet permet de mieux comprendre les tendances des conflits en fonction de différents critères tels que la répartition par pays, le type de violence, l’évolution temporelle des événements, et l'impact sur les civils.
    </p>
  ")
                        ),
                        list(
                          id = "feature3",
                          title = "Analyses avancées",
                          content = HTML(
                              "<p>L'onglet <strong>Analyses avancées</strong> est dédié à l'exploration des relations multivariées, à la mise en évidence de profils statistiques et à la production de visualisations complexes. Il s'adresse aux utilisateurs qui souhaitent approfondir l’analyse des dynamiques des conflits à l'aide de techniques telles que la réduction de dimension, le clustering, la visualisation des flux ou l’analyse temporelle. L’objectif est d’identifier des schémas récurrents, de regrouper des entités similaires et d’interpréter les relations complexes entre variables.</p>",
                              
                              "<h4>ACP (Analyse en Composantes Principales)</h4>",
                              "<p>Ce premier bloc propose une <strong>Analyse en Composantes Principales (ACP)</strong> pour explorer les relations entre plusieurs variables quantitatives. Elle vise à réduire la dimensionnalité des données tout en conservant l’essentiel de l’information. L’ACP est appliquée après une standardisation des variables telles que <code>best_est</code>, <code>deaths_a</code>, <code>deaths_b</code>, <code>deaths_civilians</code> et <code>type_of_violence</code>, à l’aide de la fonction <code>prcomp()</code>. Elle permet de positionner pays, régions ou dyades selon leur profil de violence, facilitant l’identification de groupes présentant des caractéristiques communes.</p>",
                              
                              "<h4>Clustering</h4>",
                              "<p>Le second bloc utilise le <strong>clustering K-means</strong> pour regrouper les entités (pays, régions ou dyades) selon leur similarité. Les données sont préalablement standardisées via <code>scale()</code>, puis le nombre optimal de clusters est déterminé par la méthode du coude (<em>Elbow method</em>), avec <code>fviz_nbclust()</code> du package <code>factoextra</code>. L’algorithme <code>kmeans()</code> est ensuite appliqué pour segmenter les entités selon leur profil de violence. Cette approche permet de classifier les zones géographiques ou les dyades selon leur gravité ou leur intensité de conflit.</p>",
                              
                              "<h4>Diagramme de Sankey</h4>",
                              "<p>Le troisième bloc propose un <strong>diagramme de Sankey</strong> afin de visualiser les <strong>flux de violence</strong> entre types de violence, dyades et nombre de morts. Il est généré via la fonction <code>sankeyNetwork()</code> du package <code>networkD3</code>, après agrégation des données pour chaque dyade. Chaque flux représente la gravité du conflit à travers le volume de morts estimées. Cette visualisation dynamique permet de mieux comprendre les enchaînements entre types de violence et les interactions entre acteurs.</p>",
                              
                              "<h4>Carte de chaleur temporelle</h4>",
                              "<p>Enfin, une <strong>heatmap temporelle</strong> des événements permet d’analyser l’évolution des conflits dans le temps. Les données sont agrégées par mois ou année à l’aide de <code>summarise()</code> de <code>dplyr</code>, et visualisées avec <code>ggplot2</code>. L’utilisateur peut filtrer par pays (par exemple le Mali ou le Burkina Faso) pour identifier les périodes les plus violentes. Cette analyse met en lumière d’éventuelles régularités saisonnières ou pics spécifiques d’activité violente.</p>",
                              
                              "<p>Dans l’ensemble, cet onglet permet des <strong>analyses statistiques poussées</strong> pour mieux comprendre les dynamiques des conflits. Il offre des outils de segmentation, d'exploration des flux et de visualisation temporelle, qui peuvent contribuer à la prise de décision, à l'interprétation fine des données et à une gestion plus éclairée des crises.</p>"
                            )
                          )
                       
                        # Ajouter d'autres fonctionnalités ici
                      ), function(feat) {
                        tagList(
                          div(class = "step-header",
                              tags$span(class = "step-icon", icon("caret-right")),
                              h4(feat$title, class = "step-title", id = paste0("header-", feat$id))
                          ),
                          div(class = "step-content", id = feat$id,
                              HTML(feat$content)
                          )
                        )
                      })
                  ),  # Fin step-container
                  tags$script(HTML("
            $(document).on('click', '.step-title', function() {
              const targetId = $(this).attr('id').replace('header-', '');
              const content = $('#' + targetId);
              const icon = $(this).prev('.step-icon');
              
              content.slideToggle(300);
              icon.toggleClass('fa-rotate-90');
              
              $('html, body').animate({
                scrollTop: content.offset().top - 50
              }, 300);
            });
          "))
              )  # Fin methodology-section
          )  # Fin methodology-container
        ),  # Fin tabPanel Méthodologie

        # ONGLET 4 : CREDITS
        tabPanel(
          title = "Crédits",
          icon = icon("users"),
          
          # Section Équipe Projet
          div(class = "credits-container",
              h3("Contributeurs", class = "section-title"),
              p(style = "text-align: justify; font-size: 16px;",
                "Nous sommes trois étudiants de la classe ISEP3 de l’ENSAE Dakar, réunis par une ambition commune : 
                mettre en œuvre nos connaissances académiques afin de contribuer à la prévention des conflits en Afrique de l’Ouest. 
                Ce projet s’inscrit dans la continuité des enseignements en ",
                tags$b("statistiques exploratoires spatiales"), " et en ", tags$b("développement web"),
                " suivis au premier semestre, qui nous ont initiés aux outils d’analyse géographique et aux principes 
                de conception d’applications interactives."
              ),
              
              p(style = "text-align: justify; font-size: 16px;",
                "L’expérience acquise avec ", tags$b("R Shiny"), " lors du cours de ", tags$i("traitements statistiques avec R"),
                " en deuxième année s’est révélée essentielle pour concevoir et structurer cette plateforme. 
                Ce projet représente ainsi une concrétisation de nos apprentissages théoriques autour d’un enjeu sociétal majeur."
              ),
              
              br(),
              h4("Présentation des membres", class = "text-center mb-4"),
              br(), br(),
              
              fluidRow(
                column(
                  width = 4,
                  div(class = "team-card text-center",
                      tags$img(src = "photos/SAMBA.jpg", class = "team-photo img-fluid rounded-circle",
                               style = "width: 150px; height: 150px; object-fit: cover; margin-bottom: 15px;"),
                      h4("Samba DIENG", class = "member-name"),
                      p(tags$b("GitHub :"), tags$a(href = "https://github.com/sambadieng122003", "sambadieng122003", target = "_blank")),
                      p(tags$b("Rôle :"), "Responsable de la collecte des données et des analyses avancées"),
                      actionButton("btn_samba", "En savoir plus", class = "btn-details")
                  )
                ),
                
                column(
                  width = 4,
                  div(class = "team-card text-center",
                      tags$img(src = "photos/NIASS.jpg", class = "team-photo img-fluid rounded-circle",
                               style = "width: 150px; height: 150px; object-fit: cover; margin-bottom: 15px;"),
                      h4("Ahmadou NIASS", class = "member-name"),
                      p(tags$b("GitHub :"), tags$a(href = "https://github.com/ahmadouniass", "ahmadouniass", target = "_blank")),
                      p(tags$b("Rôle :"), "Responsable du développement de l’exploration interactive"),
                      actionButton("btn_ahmadou", "En savoir plus", class = "btn-details")
                  )
                ),
                
                column(
                  width = 4,
                  div(class = "team-card text-center",
                      tags$img(src = "photos/SARAH.jpg", class = "team-photo img-fluid rounded-circle",
                               style = "width: 150px; height: 150px; object-fit: cover; margin-bottom: 15px;"),
                      h4("Fogwoung Djoufack Sarah-Laure", class = "member-name"),
                      p(tags$b("GitHub :"), tags$a(href = "https://github.com/Sarahlaure", "Sarahlaure", target = "_blank")),
                      p(tags$b("Rôle :"), "Responsable du nettoyage des données et de la documentation"),
                      actionButton("btn_sarah", "En savoir plus", class = "btn-details")
                  )
                )
              ),
              
              
              h3("Partenaires Institutionnels", class = "section-title partners-title", style = "margin-top: 20px;"),
              
              fluidRow(
                class = "partners-row justify-content-center",
                
                column(
                  width = 4,
                  div(class = "partner-logo text-center",
                      tags$img(
                        src = "logos/ensae.jpg", 
                        style = "max-width: 100%; height: 90px; object-fit: contain; margin-bottom: 15px;"
                      ),
                      p("ENSAE Pierre Ndiaye", style = "font-weight: bold;")
                  )
                ),
                
                column(
                  width = 4,
                  div(class = "partner-logo text-center",
                      tags$img(
                        src = "logos/AES_ENSAE.jpg", 
                        style = "max-width: 100%; height: 90px; object-fit: contain; margin-bottom: 15px;"
                      ),
                      p("Amicale des Etudiants et Stagiaires de l'ENSAE", style = "font-weight: bold;")
                  )
                ),
                
                column(
                  width = 4,
                  div(class = "partner-logo text-center",
                      tags$img(
                        src = "logos/BSA.jpg", 
                        style = "max-width: 100%; height: 90px; object-fit: contain; margin-bottom: 15px;"
                      ),
                      p("Bureau des Statistiques de l’AES", style = "font-weight: bold;")
                  )
                )
              )
          )
)
)
)
)