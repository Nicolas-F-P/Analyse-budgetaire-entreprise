DROP VIEW IF EXISTS v_ecritures_clean_powerbi;
DROP VIEW IF EXISTS v_budget_powerbi;

CREATE VIEW v_ecritures_clean_powerbi AS
SELECT
    id_ecriture,
    date_ecriture,
    mois,
    centre_cout,
    CONCAT(mois, '_', centre_cout) AS cle_budget,
    libelle_centre,
    direction,
    code_site,
    ville,
    pays,
    region,
    compte_comptable,
    categorie_depense,
    fournisseur,
    montant,
    statut
FROM ecritures_finance_clean;

CREATE VIEW v_budget_powerbi AS
SELECT
    mois,
    centre_cout,
    CONCAT(mois, '_', centre_cout) AS cle_budget,
    budget
FROM budget_mensuel;