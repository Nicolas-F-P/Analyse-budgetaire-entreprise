-- 1. Analyse budget vs réalisé par centre de coût
WITH realise_par_centre AS (
    SELECT
        mois,
        centre_cout,
        libelle_centre,
        direction,
        SUM(montant) AS realise
    FROM ecritures_finance_clean
    GROUP BY
        mois,
        centre_cout,
        libelle_centre,
        direction
)

SELECT
    r.mois,
    r.centre_cout,
    r.libelle_centre,
    r.direction,
    r.realise,
    b.budget,
    r.realise - b.budget AS ecart,
    ROUND(r.realise / b.budget * 100, 2) AS taux_consommation_budget
FROM realise_par_centre AS r
INNER JOIN budget_mensuel AS b
    ON r.mois = b.mois
    AND r.centre_cout = b.centre_cout
ORDER BY ecart DESC;

-- 2. Centres de coût en dépassement de budget
WITH realise_par_centre AS (
    SELECT
        mois,
        centre_cout,
        libelle_centre,
        direction,
        SUM(montant) AS realise
    FROM ecritures_finance_clean
    GROUP BY
        mois,
        centre_cout,
        libelle_centre,
        direction
)

SELECT
    r.mois,
    r.centre_cout,
    r.libelle_centre,
    r.direction,
    r.realise,
    b.budget,
    r.realise - b.budget AS depassement,
    ROUND(r.realise / b.budget * 100, 2) AS taux_consommation_budget
FROM realise_par_centre AS r
INNER JOIN budget_mensuel AS b
    ON r.mois = b.mois
    AND r.centre_cout = b.centre_cout
WHERE r.realise > b.budget
ORDER BY depassement DESC;

-- 3. KPI financiers globaux
WITH realise_total AS (
    SELECT
        SUM(montant) AS realise_total
    FROM ecritures_finance_clean
),

budget_total AS (
    SELECT
        SUM(budget) AS budget_total
    FROM budget_mensuel
),

analyse_centre AS (
    SELECT
        b.mois,
        b.centre_cout,
        COALESCE(SUM(e.montant), 0) AS realise,
        b.budget,
        COALESCE(SUM(e.montant), 0) - b.budget AS ecart
    FROM budget_mensuel AS b
    LEFT JOIN ecritures_finance_clean AS e
        ON b.mois = e.mois
        AND b.centre_cout = e.centre_cout
    GROUP BY
        b.mois,
        b.centre_cout,
        b.budget
)

SELECT
    bt.budget_total,
    rt.realise_total,
    rt.realise_total - bt.budget_total AS ecart_total,
    ROUND(rt.realise_total / bt.budget_total * 100, 2) AS taux_consommation_global,
    SUM(CASE WHEN ac.ecart > 0 THEN 1 ELSE 0 END) AS nb_centres_en_depassement,
    SUM(CASE WHEN ac.ecart > 0 THEN ac.ecart ELSE 0 END) AS montant_total_depassements
FROM budget_total AS bt
CROSS JOIN realise_total AS rt
CROSS JOIN analyse_centre AS ac
GROUP BY
    bt.budget_total,
    rt.realise_total;

-- 4. Analyse budget vs réalisé par direction
WITH realise_direction AS (
    SELECT
        mois,
        direction,
        SUM(montant) AS realise
    FROM ecritures_finance_clean
    GROUP BY
        mois,
        direction
),

budget_direction AS (
    SELECT
        b.mois,
        c.direction,
        SUM(b.budget) AS budget
    FROM budget_mensuel AS b
    INNER JOIN ref_centres AS c
        ON b.centre_cout = c.centre_cout
    GROUP BY
        b.mois,
        c.direction
)

SELECT
    r.mois,
    r.direction,
    r.realise,
    b.budget,
    r.realise - b.budget AS ecart,
    ROUND(r.realise / b.budget * 100, 2) AS taux_consommation_budget
FROM realise_direction AS r
INNER JOIN budget_direction AS b
    ON r.mois = b.mois
    AND r.direction = b.direction
ORDER BY ecart DESC;

-- 5. Top fournisseurs par montant dépensé
SELECT
    fournisseur,
    categorie_depense,
    COUNT(*) AS nb_ecritures,
    SUM(montant) AS montant_total,
    ROUND(AVG(montant), 2) AS montant_moyen
FROM ecritures_finance_clean
GROUP BY
    fournisseur,
    categorie_depense
ORDER BY montant_total DESC;

-- 6. Analyse des dépenses par site
SELECT
    ville,
    region,
    pays,
    COUNT(*) AS nb_ecritures,
    SUM(montant) AS montant_total,
    ROUND(AVG(montant), 2) AS montant_moyen
FROM ecritures_finance_clean
GROUP BY
    ville,
    region,
    pays
ORDER BY montant_total DESC;