# 🌍 ShinyApp – Visualisation Interactive des Conflits au sein de l’UEMOA
### _Un projet pour une meilleure compréhension des dynamiques sécuritaires en Afrique de l’Ouest, notamment au sein de l'UEMOA_
#### Hackathon du Bureau des Statistiques – ENSAE Dakar

---  

## 🧭 **Contexte & Enjeux**  
Depuis les années 1990, l’espace UEMOA est confronté à une instabilité croissante : rébellions armées, coups d’État, terrorisme…  
L’Union, initialement fondée pour renforcer l’intégration économique, fait désormais face à des défis sécuritaires majeurs qui mettent en péril sa cohésion.

📈 **+900 conflits entamés en 2023 contre 12 en 1989** selon les données du UCDP, soit une multiplication par 75 en 34 ans.
 
🌐 La création récente de l’**Alliance des États du Sahel (AES)** — regroupant le Mali, le Burkina Faso et le Niger — marque un tournant géopolitique majeur et reflète la défiance croissante de ces pays envers la CEDEAO et ses mécanismes, jugés inefficaces pour gérer les conflits sécuritaires grandissants (The Guardian, 8 juillet 2024, Ecowas warns of ‘disintegration’ as juntas split from west African bloc).

Dans ce contexte, plusieurs questions clés se posent :

- **Où et quand** ces conflits éclatent-ils ?  
- **Quels types** de violences prédominent ?  
- **Quels zones** sont les plus exposées ?  
- Et surtout, **quelles tendances** peut-on identifier sur le long terme ?

🔍 Notre application répond à ces questions via une exploration interactive et empirique des données de conflits armés dans l’UEMOA.

---

## 🗺️ Objectifs

- Visualiser l’évolution des conflits armés dans les 8 pays membres de l’UEMOA (1989–2023)  
- Fournir des outils interactifs pour explorer les données : carte, graphiques, timeline, ACP, clustering…  
- Comparer les tendances entre les pays membres afin de dégager des schémas spécifiques à chaque pays. 
- Faciliter la prise de décision pour les acteurs concernés et sensibiliser le public aux enjeux des conflits armés

---

## 📦 Technologies utilisées

| Domaine                   | Packages & outils                              |
|---------------------------|------------------------------------------------|
| **Langage & Web**         | R, Shiny, shinydashboard, shinyWidgets         |
| **Visualisation**         | Leaflet, plotly, ggplot2, DT, networkD3        |
| **Manipulation & Analyse**| dplyr, tidyr, lubridate, FactoMineR, factoextra|

---

## 📊 Données

- **Source :** [UCDP GED – Uppsala Conflict Data Program](https://ucdp.uu.se/)  
- **Format :** CSV avec géolocalisation  
- **Période couverte :** 1989 à 2023  
- **Zone géographique étudiée :** Pays membres de l’UEMOA (Benin, Burkina Faso, Cote d'Ivoire, Guinée-Bissau, Mali, Niger, Sénégal, Togo)

---

## ⚙️ Fonctionnalités principales

- Filtres interactifs par pays, dyade, type de violence et période  
- Cartes interactives des événements (zoom, filtre, info-bulle)  
- Graphiques descriptifs (barplots, pie charts, timelines)  
- Analyse en composantes principales (ACP) et clustering  
- Diagramme de Sankey des flux de violence entre différents acteurs
- Export des résultats filtrés (tableaux téléchargeable  

---

## 💡 **Justification du projet**

> “On ne peut pas résoudre un problème qu’on ne comprend pas.”

- 📌 Les décideurs peuvent mieux cibler leurs interventions  
- 🎓 Les chercheurs accèdent à un outil visuel d’exploration des données  
- 🧭 Le grand public comprend l’ampleur et la complexité des conflits au sein de l'UEMOA

---

## 👨‍💻 Contributeurs

- **Samba DIENG**  
  [GitHub → sambadieng122003](https://github.com/sambadieng122003)  
  _Responsable des données et des analyses avancées_  

- **Ahmadou NIASS**  
  [GitHub → ahmadouniass](https://github.com/ahmadouniass)  
  _Responsable du développement du frontend et de l’exploration interactive_  

- **Fogwoung Djoufack Sarah-Laure**  
  [GitHub → Sarahlaure](https://github.com/Sarahlaure)  
  _Responsable du nettoyage des données, de la documentation et des statistiques descriptives_

---

## 🤝 Remerciements

Ce projet a été encadré et soutenu par le **Bureau des Statistiques de l’AES ENSAE Dakar**, avec le soutien institutionnel de :

- **ENSAE Pierre Ndiaye**  
- **Amicale des Étudiants et Stagiaires de l'ENSAE**  
- **Bureau des Statistiques de l’AES**
