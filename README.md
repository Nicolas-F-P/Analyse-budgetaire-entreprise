# Projet 2 - Analyse budgétaire d’entreprise

### Dashboard Power BI & analyse SQL d’un cas de pilotage budgétaire

![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![MySQL](https://img.shields.io/badge/MySQL-Base%20de%20donn%C3%A9es-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Analyse-F28C28?style=for-the-badge&logo=postgresql&logoColor=white)
![DAX](https://img.shields.io/badge/DAX-KPI%20%26%20Measures-742774?style=for-the-badge)
![Portfolio](https://img.shields.io/badge/Projet-Portfolio%20Data%20Analyst-7F8C8D?style=for-the-badge)


## Sommaire

- [Présentation du projet](#présentation-du-projet)
- [Objectifs business](#objectifs-business)
- [Dataset utilisé](#dataset-utilisé)
- [Outils utilisés](#outils-utilisés)
- [Structure du projet](#structure-du-projet)
- [Modèle de données](#modèle-de-données)
- [Dashboard Power BI](#dashboard-power-bi)
- [Analyse SQL](#analyse-sql)
- [KPI principaux](#kpi-principaux)
- [Insights principaux](#insights-principaux)
- [Recommandations business](#recommandations-business)
- [Compétences démontrées](#compétences-démontrées)
- [Limites et pistes d’amélioration](#limites-et-pistes-damélioration)


## Présentation du projet

Ce projet simule un cas d’entreprise orienté **pilotage budgétaire**.  
L’objectif est de comparer le **budget prévu** au **réalisé**, d’identifier les **centres en dépassement**, d’analyser l’origine des dépenses et de vérifier la **qualité des données** utilisées dans le reporting.

Le projet couvre l’ensemble de la chaîne analytique :

- import et structuration des données dans **MySQL** ;
- contrôle qualité et nettoyage des écritures ;
- analyses SQL pour reproduire les indicateurs principaux ;
- modélisation et visualisation dans **Power BI** ;
- restitution métier à travers un dashboard en 3 pages.


## Objectifs business

L’analyse cherche à répondre à plusieurs questions concrètes :

| Question business | Objectif analytique |
|---|---|
| L’entreprise respecte-t-elle son budget global ? | Comparer budget total et réalisé total |
| Quels centres de coût dépassent leur budget ? | Identifier les zones de risque budgétaire |
| Quelles directions concentrent les dépenses ? | Comprendre la répartition des coûts |
| Quels fournisseurs et sites génèrent les principaux montants ? | Identifier les principaux postes de dépense |
| Les données utilisées pour le reporting sont-elles fiables ? | Contrôler les anomalies et la qualité des données |


## Dataset utilisé

Le projet repose sur un dataset fictif de gestion budgétaire, structuré autour de plusieurs fichiers CSV.

| Table | Rôle dans l’analyse |
|---|---|
| `ecritures_erp` | Écritures comptables brutes issues du système source |
| `ref_centres` | Référentiel des centres de coût et directions |
| `ref_sites` | Référentiel des sites / villes |
| `budget_mensuel` | Budget prévu par mois et centre de coût |
| `ecritures_finance_clean` | Table propre utilisée pour l’analyse finale |


## Outils utilisés

| Outil | Utilisation |
|---|---|
| **Power BI Desktop** | Création du dashboard et des visualisations |
| **DAX** | Création des mesures KPI |
| **MySQL Workbench** | Création de la base, import des fichiers, requêtes SQL, vues |
| **CSV** | Format source des données |
| **VS Code** | Documentation et structuration du projet |
| **GitHub** | Présentation et diffusion du projet |


## Structure du projet

```text
Projet_2_Analyse_Budgetaire
│
├── data
│   ├── ecritures_erp.csv
│   ├── ref_centres.csv
│   ├── ref_sites.csv
│   └── budget_mensuel.csv
│
├── sql
│   ├── 00_creation_base_tables.sql
│   ├── 01_controle_qualite.sql
│   ├── 02_creation_table_clean.sql
│   ├── 03_analyse_budget.sql
│   ├── 04_vues_powerbi.sql
│   └── 05_vues_qualite_powerbi.sql
│
├── powerbi
│   └── dashboard_budget_vs_realise.pbix
│
├── screenshots
│   ├── powerbi_vue_direction.png
│   ├── powerbi_analyse_detaillee.png
│   └── powerbi_qualite_donnees.png
│
└── README.md
```


## Modèle de données

Le modèle repose sur une logique simple : relier les écritures propres au budget mensuel pour comparer le **prévu** et le **réalisé**.

```text
ref_centres
    │ centre_cout
    ▼
ecritures_erp
    │ nettoyage / contrôle qualité
    ▼
ecritures_finance_clean
    │ cle_budget = mois + centre_cout
    ▼
budget_mensuel

ref_sites
    │ code_site
    └────────────→ ecritures_erp / ecritures_finance_clean
```

### Relations principales

| Table source | Clé | Table cible | Clé | Rôle |
|---|---|---|---|---|
| `ref_centres` | `centre_cout` | `ecritures_erp` | `centre_cout` | Relier les écritures au centre et à la direction |
| `ref_sites` | `code_site` | `ecritures_erp` | `code_site` | Relier les écritures au site / à la ville |
| `budget_mensuel` | `mois` + `centre_cout` | `ecritures_finance_clean` | `mois` + `centre_cout` | Comparer budget et réalisé |
| `v_budget_powerbi` | `cle_budget` | `v_ecritures_clean_powerbi` | `cle_budget` | Relation Power BI entre budget et écritures propres |


## Dashboard Power BI

Le dashboard est composé de 3 pages principales.

### 1. Vue Direction

Objectif : obtenir une vision synthétique de la situation budgétaire.

Indicateurs présents :

- budget total ;
- réalisé total ;
- écart budgétaire ;
- taux de consommation ;
- centres en dépassement ;
- dépassements cumulés ;
- budget vs réalisé par direction ;
- écarts budgétaires par centre.

![Vue Direction](screenshots/powerbi_vue_direction.png)


### 2. Analyse détaillée des dépenses

Objectif : expliquer d’où viennent les dépenses.

Indicateurs présents :

- dépenses par centre ;
- top fournisseurs ;
- dépenses par site ;
- dépenses par catégorie ;
- tableau détaillé des écritures ;
- filtres par période, direction et centre.

![Analyse détaillée](screenshots/powerbi_analyse_detaillee.png)


### 3. Qualité des données

Objectif : vérifier la fiabilité des données utilisées pour le dashboard.

Indicateurs présents :

- écritures brutes ;
- écritures propres ;
- écritures exclues ;
- anomalies détectées ;
- écritures concernées ;
- taux de lignes exploitables ;
- anomalies par type ;
- anomalies par gravité ;
- détail des anomalies détectées.

![Qualité des données](screenshots/powerbi_qualite_donnees.png)


## Analyse SQL

Une partie SQL a été réalisée dans **MySQL Workbench** afin de contrôler les données, créer des vues pour Power BI et reproduire les principaux indicateurs du dashboard.

| Fichier SQL | Objectif |
|---|---|
| `00_creation_base_tables.sql` | Création de la base et des tables |
| `01_controle_qualite.sql` | Contrôle des anomalies dans les écritures brutes |
| `02_creation_table_clean.sql` | Création de la table propre `ecritures_finance_clean` |
| `03_analyse_budget.sql` | Analyses budgétaires principales |
| `04_vues_powerbi.sql` | Préparation des vues utilisées dans Power BI |
| `05_vues_qualite_powerbi.sql` | Création des vues dédiées à la page Qualité des données |

### Exemple de requête SQL

```sql
SELECT
    b.centre_cout,
    c.libelle_centre,
    c.direction,
    b.budget,
    SUM(e.montant) AS realise,
    SUM(e.montant) - b.budget AS ecart
FROM budget_mensuel AS b
INNER JOIN ref_centres AS c
    ON b.centre_cout = c.centre_cout
LEFT JOIN ecritures_finance_clean AS e
    ON b.centre_cout = e.centre_cout
    AND b.mois = e.mois
GROUP BY
    b.centre_cout,
    c.libelle_centre,
    c.direction,
    b.budget;
```

Cette requête permet de comparer le budget et le réalisé par centre de coût afin d’identifier les écarts budgétaires.


## KPI principaux

| Indicateur | Résultat observé |
|---|---:|
| Budget total | 60 500 € |
| Réalisé total | 59 950 € |
| Écart global | -550 € |
| Taux de consommation | 99,09 % |
| Centres en dépassement | 3 |
| Dépassements cumulés | 3 850 € |
| Écritures brutes | 30 |
| Écritures propres | 25 |
| Écritures exclues | 5 |
| Anomalies détectées | 10 |
| Écritures concernées | 9 |
| Taux de lignes exploitables | 83,33 % |


## Insights principaux

### Vue Direction

- Le budget global est presque totalement consommé avec un taux de consommation de **99,09 %**.
- L’entreprise reste légèrement sous le budget global avec un **écart favorable de -550 €**.
- Malgré cela, **3 centres** dépassent leur budget pour un montant cumulé de **3 850 €**.
- Une lecture globale du budget doit donc être complétée par une analyse plus fine au niveau des centres.

### Analyse détaillée des dépenses

- Les dépenses sont concentrées sur quelques centres de coût majeurs.
- Certains fournisseurs représentent une part significative des dépenses totales.
- Les sites ne contribuent pas tous de la même manière aux montants engagés.
- L’analyse détaillée permet de mieux comprendre les leviers qui expliquent les écarts budgétaires.

### Qualité des données

- La base brute contient **30 écritures**, dont **25** ont été conservées dans le dataset propre.
- **10 anomalies** ont été détectées sur **9 écritures distinctes**.
- Les principales anomalies concernent les **doublons potentiels**, les **statuts non valides**, les **budgets manquants** et les **référentiels incomplets**.
- Cette étape de contrôle sécurise le reporting en évitant d’analyser des lignes non fiables.


## Recommandations business

À partir de l’analyse, plusieurs actions peuvent être proposées :

1. **Suivre en priorité les centres en dépassement** afin d’anticiper les dérives budgétaires.
2. **Analyser les fournisseurs les plus coûteux** pour identifier des opportunités d’optimisation ou de négociation.
3. **Comparer les écarts par direction** pour repérer les zones budgétaires les plus sensibles.
4. **Renforcer les contrôles de qualité** sur les statuts, les référentiels et les budgets manquants.
5. **Mettre en place un suivi mensuel** pour détecter les dépassements plus tôt.
6. **Étendre le périmètre temporel** pour analyser l’évolution des dépenses sur plusieurs périodes.


## Compétences démontrées

Ce projet met en avant plusieurs compétences attendues chez un Data Analyst junior :

| Compétence | Mise en pratique dans le projet |
|---|---|
| Analyse business | Traduction d’un besoin de pilotage budgétaire en indicateurs |
| SQL | Contrôles qualité, jointures, agrégations, vues et analyses |
| Power BI | Création d’un dashboard multi-pages |
| DAX | Mesures budgétaires et KPI qualité |
| Modélisation | Construction d’un modèle budget / réalisé relié par clé technique |
| Data visualization | Graphiques adaptés à la lecture métier |
| Communication | Insights clairs et dashboard compréhensible |
| Qualité des données | Identification et documentation des anomalies |


## Limites et pistes d’amélioration

Ce projet peut être enrichi avec plusieurs améliorations :

- ajouter plusieurs mois de données pour une analyse temporelle ;
- créer une page dédiée aux fournisseurs ;
- ajouter une page de suivi mensuel des écarts ;
- enrichir les contrôles qualité avec de nouvelles règles ;
- intégrer des alertes visuelles sur les dépassements critiques ;
- publier le dashboard via Power BI Service si nécessaire.


## Conclusion

Ce projet montre comment construire une analyse budgétaire claire, structurée et orientée décision à partir de données brutes.

Il combine une approche technique avec **MySQL**, **SQL**, **DAX** et **Power BI**, une partie visuelle avec un dashboard en 3 pages, et une lecture métier à travers des **insights** et des **recommandations**.

L’objectif final est de fournir un support d’aide à la décision permettant de mieux comprendre la consommation budgétaire, l’origine des dépenses et la fiabilité des données utilisées.


**Projet réalisé dans le cadre d’un portfolio Data Analyst**
