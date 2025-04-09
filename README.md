# Application Shiny – Visualisation des Conflits dans l’UEMOA _(Projet BSA)_

Ce projet a été réalisé dans le cadre de l’hackathon organisé par le **Bureau des Statistiques** de l’[ENSAE Dakar](https://ensae.sn).  
Il consiste en une application interactive développée avec **R Shiny**, permettant d'explorer et d’analyser les conflits armés dans l’espace UEMOA à partir des données géoréférencées du **UCDP GED**.

---

## 🗺️ Objectifs

- Expliquer les dynamiques sécuritaires dans la région de l’UEMOA à partir de données empiriques fiables.  
- Fournir des visualisations interactives et intuitives pour explorer les événements violents de manière dynamique.  
- Comparer les tendances entre les pays membres afin de dégager des schémas régionaux ou spécifiques.  
- Faciliter la prise de décision pour les acteurs concernés et sensibiliser le public aux enjeux des conflits armés.

---

## 📦 Technologies utilisées

- **R** – langage principal  
- **Shiny** – framework pour application web  
- **Leaflet** – cartographie interactive  
- **DT** – tableaux dynamiques  
- **ggplot2 / plotly** – visualisation de données  
- **shinydashboard / shinyWidgets** – UI & design  
- **networkD3** – diagrammes de Sankey  
- **dplyr / tidyr / lubridate** – manipulation des données

---

## 📊 Données

- **Source :** [UCDP GED – Uppsala Conflict Data Program](https://ucdp.uu.se/)  
- **Format :** CSV avec géolocalisation  
- **Période couverte :** 1989 à 2023  
- **Zone étudiée :** Pays membres de l’UEMOA

---

## 🧪 Fonctionnalités principales

- Filtres interactifs par pays, dyade, type de violence et période  
- Carte dynamique des conflits  
- Graphiques descriptifs (barplots, pie charts, timelines)  
- Analyse en composantes principales (ACP) et clustering  
- Diagramme de Sankey des flux de violence  
- Téléchargement de résultats filtrés  

---

## 👨‍💻 Contributeurs

- **Samba DIENG**  
  [GitHub → sambadieng122003](https://github.com/sambadieng122003)  
  _Responsable des données et des analyses avancées_  

- **Ahmadou NIASS**  
  [GitHub → ahmadouniass](https://github.com/ahmadouniass)  
  _Développeur de la section exploration interactive_  

- **Fogwoung Djoufack Sarah-Laure**  
  [GitHub → Sarahlaure](https://github.com/Sarahlaure)  
  _Responsable du nettoyage des données, de la documentation et des statistiques descriptives_

---

## 🤝 Remerciements

Ce projet a été encadré et soutenu par le **Bureau des Statistiques de l’AES ENSAE Dakar**, avec le soutien institutionnel de :

- **ENSAE Pierre Ndiaye**  
- **Amicale des Étudiants et Stagiaires de l'ENSAE**  
- **Bureau des Statistiques de l’AES**
