-- 1. Nombre total d'écritures ERP
SELECT
    COUNT(*) AS nb_ecritures_total
FROM ecritures_erp;

-- 2. Nombre d'écritures par statut
SELECT
    statut,
    COUNT(*) AS nb_ecritures,
    SUM(montant) AS montant_total
FROM ecritures_erp
GROUP BY statut
ORDER BY nb_ecritures DESC;

-- 3. Détection des montants négatifs
SELECT
    id_ecriture,
    date_ecriture,
    centre_cout,
    code_site,
    fournisseur,
    montant,
    statut
FROM ecritures_erp
WHERE montant < 0;

-- 4. Détection des centres de coût inconnus
SELECT
    e.id_ecriture,
    e.date_ecriture,
    e.centre_cout,
    e.code_site,
    e.fournisseur,
    e.montant,
    e.statut
FROM ecritures_erp AS e
LEFT JOIN ref_centres AS c
    ON e.centre_cout = c.centre_cout
WHERE c.centre_cout IS NULL;

-- 5. Détection des sites inconnus
SELECT 
    e.id_ecriture,
    e.date_ecriture,
    e.centre_cout,
    e.code_site,
    e.fournisseur,
    e.montant,
    e.statut
FROM ecritures_erp AS e
LEFT JOIN ref_sites AS s
    ON e.code_site = s.code_site
WHERE s.code_site IS NULL;

-- 6. Écritures non validées
SELECT 
    id_ecriture,
    date_ecriture,
    centre_cout,
    code_site,
    fournisseur,
    montant,
    statut
FROM ecritures_erp
WHERE statut <> 'VALIDE';

-- 7. Doublons potentiels
SELECT 
    centre_cout,
    code_site,
    fournisseur,
    montant,
    COUNT(*) AS nb_occurrences
FROM ecritures_erp
GROUP BY 
    centre_cout,
    code_site,
    fournisseur,
    montant
HAVING COUNT(*) > 1;

-- 8. Contrôle budget vs réalisé par centre de coût
SELECT 
    e.mois,
    e.centre_cout,
    c.libelle_centre,
    c.direction,
    SUM(e.montant) AS realise,
    b.budget,
    SUM(e.montant) - b.budget AS ecart,
    ROUND(SUM(e.montant) / b.budget * 100, 2) AS taux_consommation_budget
FROM ecritures_erp AS e
LEFT JOIN budget_mensuel AS b
    ON e.mois = b.mois
    AND e.centre_cout = b.centre_cout
LEFT JOIN ref_centres AS c
    ON e.centre_cout = c.centre_cout
WHERE e.statut = 'VALIDE'
GROUP BY 
    e.mois,
    e.centre_cout,
    c.libelle_centre,
    c.direction,
    b.budget
ORDER BY ecart DESC;