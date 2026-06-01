DROP VIEW IF EXISTS v_anomalies_qualite_powerbi;
DROP VIEW IF EXISTS v_synthese_qualite_powerbi;
DROP VIEW IF EXISTS v_kpi_qualite_powerbi;

CREATE VIEW v_anomalies_qualite_powerbi AS

-- 1. Écritures non validées
SELECT
    'Statut non valide' AS type_anomalie,
    'Moyenne' AS niveau_gravite,
    id_ecriture,
    date_ecriture,
    mois,
    centre_cout,
    code_site,
    fournisseur,
    montant,
    statut,
    'Écriture non validée : à exclure ou à vérifier avant reporting' AS commentaire
FROM ecritures_erp
WHERE statut <> 'VALIDE'

UNION ALL

-- 2. Montants négatifs
SELECT
    'Montant négatif' AS type_anomalie,
    'Élevée' AS niveau_gravite,
    id_ecriture,
    date_ecriture,
    mois,
    centre_cout,
    code_site,
    fournisseur,
    montant,
    statut,
    'Montant négatif détecté : possible avoir, correction ou erreur de saisie' AS commentaire
FROM ecritures_erp
WHERE montant < 0

UNION ALL

-- 3. Centres de coût inconnus
SELECT
    'Centre de coût inconnu' AS type_anomalie,
    'Élevée' AS niveau_gravite,
    e.id_ecriture,
    e.date_ecriture,
    e.mois,
    e.centre_cout,
    e.code_site,
    e.fournisseur,
    e.montant,
    e.statut,
    'Centre de coût absent du référentiel ref_centres' AS commentaire
FROM ecritures_erp AS e
LEFT JOIN ref_centres AS c
    ON e.centre_cout = c.centre_cout
WHERE c.centre_cout IS NULL

UNION ALL

-- 4. Sites inconnus
SELECT
    'Site inconnu' AS type_anomalie,
    'Élevée' AS niveau_gravite,
    e.id_ecriture,
    e.date_ecriture,
    e.mois,
    e.centre_cout,
    e.code_site,
    e.fournisseur,
    e.montant,
    e.statut,
    'Site absent du référentiel ref_sites' AS commentaire
FROM ecritures_erp AS e
LEFT JOIN ref_sites AS s
    ON e.code_site = s.code_site
WHERE s.code_site IS NULL

UNION ALL

-- 5. Budget manquant
SELECT
    'Budget manquant' AS type_anomalie,
    'Élevée' AS niveau_gravite,
    e.id_ecriture,
    e.date_ecriture,
    e.mois,
    e.centre_cout,
    e.code_site,
    e.fournisseur,
    e.montant,
    e.statut,
    'Aucun budget trouvé pour ce mois et ce centre de coût' AS commentaire
FROM ecritures_erp AS e
LEFT JOIN budget_mensuel AS b
    ON e.mois = b.mois
    AND e.centre_cout = b.centre_cout
WHERE b.centre_cout IS NULL

UNION ALL

-- 6. Doublons potentiels
SELECT
    'Doublon potentiel' AS type_anomalie,
    'Faible' AS niveau_gravite,
    e.id_ecriture,
    e.date_ecriture,
    e.mois,
    e.centre_cout,
    e.code_site,
    e.fournisseur,
    e.montant,
    e.statut,
    'Même centre, même site, même fournisseur et même montant détectés plusieurs fois' AS commentaire
FROM ecritures_erp AS e
INNER JOIN (
    SELECT
        centre_cout,
        code_site,
        fournisseur,
        montant
    FROM ecritures_erp
    GROUP BY
        centre_cout,
        code_site,
        fournisseur,
        montant
    HAVING COUNT(*) > 1
) AS d
    ON e.centre_cout = d.centre_cout
    AND e.code_site = d.code_site
    AND e.fournisseur = d.fournisseur
    AND e.montant = d.montant;


CREATE VIEW v_synthese_qualite_powerbi AS
SELECT
    type_anomalie,
    niveau_gravite,
    COUNT(*) AS nb_anomalies,
    COUNT(DISTINCT id_ecriture) AS nb_ecritures_concernees
FROM v_anomalies_qualite_powerbi
GROUP BY
    type_anomalie,
    niveau_gravite;


CREATE VIEW v_kpi_qualite_powerbi AS
SELECT
    'Écritures brutes' AS kpi,
    COUNT(*) AS valeur
FROM ecritures_erp

UNION ALL

SELECT
    'Écritures propres' AS kpi,
    COUNT(*) AS valeur
FROM ecritures_finance_clean

UNION ALL

SELECT
    'Écritures exclues du dataset clean' AS kpi,
    (
        SELECT COUNT(*) FROM ecritures_erp
    ) - (
        SELECT COUNT(*) FROM ecritures_finance_clean
    ) AS valeur

UNION ALL

SELECT
    'Anomalies détectées' AS kpi,
    COUNT(*) AS valeur
FROM v_anomalies_qualite_powerbi

UNION ALL

SELECT
    'Écritures concernées par anomalie' AS kpi,
    COUNT(DISTINCT id_ecriture) AS valeur
FROM v_anomalies_qualite_powerbi;