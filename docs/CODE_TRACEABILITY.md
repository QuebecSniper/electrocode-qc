# Traçabilité Code — ÉlectroCode QC

Dernière vérification des sources publiques RBQ : **2026-08-15**.

Code intégré : **CSA C22.10:26** (Code canadien de l’électricité, 25e édition, + modifications du Québec).  
En vigueur : **26 mars 2026**. Transition 2018 jusqu’au **26 septembre 2026**.

Les modules du moteur citent des **numéros** d’articles et de tableaux. Recoupement Cycle 3 (2026-08-15) : voir [RECOUPEMENT_TABLES_C22.10-26.md](RECOUPEMENT_TABLES_C22.10-26.md).

### Recoupement tables (Cycle 3)

| Tableau | Verdict | Notes |
|---|---|---|
| T2 | Écart corrigé | #14–#8 : ampacités T2 rétablies ; 14-104 séparé |
| T4 | Écart corrigé | #12, #10, 1000 kcmil Al |
| T5A | Écart partiel | Colonne 90 °C seulement ; paliers 65/75 °C ajoutés |
| T5C | Identique | 80 / 70 / 60 / 50 % |
| T8 | Identique | 53 / 31 / 40 % |
| T9 | Écart de périmètre | Une série EMT-like vs officiel **9A–9P** |
| T10 | Écart de périmètre | Une colonne vs officiel **10A–10D** |
| T16 | Écart corrigé | 40 A → #12 Cu |
| T17 | Écart de rôle corrigé | T17 = impédance (10-302). GEC = **10-812 #6 Cu** |

## Limitations connues de la V1 (gelée à 90 %)

Acceptées le **2026-08-15**. Ne pas les traiter comme des régressions tant que le gel V1 n’est pas levé. Détail numérique : [RECOUPEMENT_TABLES_C22.10-26.md](RECOUPEMENT_TABLES_C22.10-26.md).

### L-T5A — Tableau 5A, colonnes 60 °C et 75 °C absentes

- **Encodé :** facteurs ambiants de la colonne **90 °C** seulement (paliers 31–80 °C, y compris 65 °C = 0,65 et 75 °C = 0,50).
- **Manquant :** colonnes officielles **60 °C** et **75 °C**.
- **Conséquence :** si la colonne applicable n’est pas 90 °C, le facteur T5A du moteur peut être trop élevé (moins de déclassement).
- **Usage V1 :** dimensionnement résidentiel par défaut = T2/T4 colonne **75 °C** (4-006) ; T5A 90 °C sert aux corrections ambiantes sur isolation 90 °C.

### L-T9 — Tableaux 9A à 9P non distingués

- **Encodé :** une série d’aires internes type EMT (16 → 204 mm², 21 → 366, 27 → 599, …).
- **Officiel C22.10:26 :** **9A–9P** selon le type de canalisation (EMT = **9I**, PVC, rigide, HDPE, etc.).
- **Conséquence :** pas de choix EMT vs PVC vs rigide ; le commerce suggéré peut différer de l’aire 9I/9x réelle.

### L-T10 — Tableaux 10A à 10D non distingués

- **Encodé :** une colonne d’aires de conducteur (approximation **RW90**).
- **Officiel C22.10:26 :** **10A–10D** selon le type d’isolant (plus T6A–6K pour remplissages tout faits).
- **Conséquence :** le % de remplissage (avec T8) peut faire choisir un commerce trop petit ou trop grand si l’isolant n’est pas celui de la colonne encodée.

## Modules V1 (résidentiel)

| Module moteur | Articles / tableaux cibles | Notes 2026 Québec |
|---|---|---|
| Demande / facteurs | Section 8, 8-106, 8-200, 8-202, 8-104 | Charge VÉ + système de gestion d’énergie (EMS) ; ancienne méthode QC éliminée |
| Service / branchement | Sections 6 et 8, 8-200(2) | Coffret hors niveau de crue ; coffret extérieur permis ; branchement VÉ supplémentaire permis |
| Panneaux | Sections 6 et 14 | Espace EMS / surveillance de courant (6-212 2)) |
| Disjoncteurs | Section 14, 14-104, 8-104 | AFCI circuits existants ; DDFT là où exigé |
| Conducteurs Cu/Al | Section 4, 4-004, 4-006, T2, T4, T5A, T5C | Colonne 75 °C par défaut (terminaisons) |
| Canalisations | Section 12, T6, T8, T9, T10 | Remplissage 40 % si ≥ 3 conducteurs |
| Mise à la terre | Section 10 (révisée 2026), T16, **10-812** (GEC #6). T17 = impédance 10-302, pas le GEC | **Interdiction** de la conduite d’eau municipale comme **nouvelle** prise de terre |
| Chute de tension | 8-102 | 3 % dérivation ou feeder ; 5 % total service → dernier appareil |
| VÉ / infrastructure | Section 86, déclaration de travaux | Infrastructure élémentaire dès la construction (logements) |
| Prises | 26-7xx | Prises à obturateurs où des enfants peuvent être présents |

## Hors V1 (structuré, à venir)

| Type de bâtiment | Sections typiques | Statut |
|---|---|---|
| Commercial | 8-210, moteurs 28, éclairage | `questions_en_attente` |
| Institutionnel | 8-210 / 8-212 selon usage | `questions_en_attente` |
| Industriel | 8-210, 28, 36, transformateurs 26 | `questions_en_attente` |

## Sources de veille (pas le texte CSA)

- https://www.rbq.gouv.qc.ca/domaines-dintervention/electricite/la-rbq-et-lelectricite/reglementation/ce-qui-sapplique
- https://www.rbq.gouv.qc.ca/domaines-dintervention/electricite/la-rbq-et-lelectricite/reglementation/modifications-reglementaires/
- https://www.rbq.gouv.qc.ca/lois-reglements-et-codes/par-domaine/electricite/

Le workflow `code-watch.yml` surveille ces URL.
