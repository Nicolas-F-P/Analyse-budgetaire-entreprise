DROP TABLE IF EXISTS ecritures_finance_clean;

CREATE TABLE ecritures_finance_clean AS
SELECT
    e.id_ecriture,
    e.date_ecriture,
    e.mois,
    e.centre_cout,
    c.libelle_centre,
    c.direction,
    e.code_site,
    s.ville,
    s.pays,
    s.region,
    e.compte_comptable,
    e.categorie_depense,
    e.fournisseur,
    e.montant,
    e.statut
FROM ecritures_erp AS e
INNER JOIN ref_centres AS c
    ON e.centre_cout = c.centre_cout
INNER JOIN ref_site AS s
    ON e.code_site = s.code_site
INNER JOIN busget_mensuel AS b
    ON e.mois = b.mois
    AND e.centre_cout = b.centre_cout
WHERE e.statut = 'VALIDE'
    AND e.montant > 0;

ALTER TABLE ecritures_finance_clean
MODIFY id_ecriture INT NOT NULL,
ADD PRIMARY KEY (id_ecriture);

CREATE INDEX idx_clean_mois_centre
ON ecritures_finance_clean (mois, centre_cout);

CREATE INDEX idx_clean_site
ON ecritures_finance_clean (code_site);