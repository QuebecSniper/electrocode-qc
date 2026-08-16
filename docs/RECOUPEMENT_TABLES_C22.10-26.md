# Recoupement des tables de travail — C22.10:26

**Date :** 2026-08-15 (Cycle 3)  
**Norme cible :** CSA C22.10:26 = CCÉ 25e édition (C22.1-21) + modifications Québec.  
**Limite légale :** le texte et les tableaux officiels CSA sont protégés. Ce document compare nos **données applicatives** à des **concordances publiques** (guides 25e édition, calculateurs CCÉ largement cités). **Vérification finale obligatoire** sur l’exemplaire papier/PDF C22.10:26 de l’électricien.

Sources publiques utilisées (pas le PDF CSA) :

- Guide Tables, 25e édition — Electrical Industry News Week (Bill Burr, 2023)
- Concordances T2/T4 publiées (electdesign.ca, vrielectrical, offsetnotes)
- IAEI / guides Section 10 — rôle de 10-812 et du Tableau 17
- Pages RBQ (modifications 2026, section 10)

## Synthèse

| Tableau | Verdict | Action Cycle 3 |
|---|---|---|
| T2 | **Écart corrigé** (petits calibres) | Colonnes 75/90 °C #14–#8 rétablies ; 14-104 reste un limiteur séparé |
| T4 | **Écart corrigé** (1000 kcmil Al + #12/#10) | Aligné sur concordances T4 |
| T5A | **Limitation V1 L-T5A** | Colonne 90 °C seulement ; colonnes 60/75 °C absentes (gel V1) |
| T5C | **Identique** (facteurs 4–6 / 7–24 / 25–42 / 43+) | Aucun changement de facteur |
| T8 | **Identique** (53 % / 31 % / 40 %) | Aucun changement |
| T9 | **Limitation V1 L-T9** | Une seule série d’aires (EMT-like) ; l’officiel est **9A–9P** (gel V1) |
| T10 | **Limitation V1 L-T10** | Une colonne d’aires RW90-like ; l’officiel est **10A–10D** (gel V1) |
| T16 | **Écart corrigé** (40 A) | 30–40 A → #12 Cu (plus #10) |
| T17 | **Écart de rôle — corrigé** | T17 ≠ calibre GEC en 25e éd. GEC = **10-812 (#6 Cu)** |

## Détail des écarts

### Tableau 2 (Cu, ≤ 3 conducteurs, 30 °C)

Concordance publique 75 °C / 90 °C vs **ancienne** table de travail :

| Calibre | Travail avant | Concordance T2 75/90 | Écart |
|---|---|---|---|
| 14 | 15 / 15 | 20 / 25 | Oui — on avait collé le 14-104 dans T2 |
| 12 | 20 / 20 | 25 / 30 | Oui |
| 10 | 30 / 30 | 35 / 40 | Oui |
| 8 | 45 / 55 | 50 / 55 | Oui (75 °C) |
| 6 à 1000 | identique | identique | Non |

**Après Cycle 3 :** T2 stocke les ampacités de concordance. L’art. **14-104** limite toujours #14/#12/#10 à 15/20/30 A pour la protection.

### Tableau 4 (Al, ≤ 3 conducteurs, 30 °C)

| Calibre | Travail avant | Concordance T4 75/90 | Écart |
|---|---|---|---|
| 12 | 15 / 15 | 20 / 25 | Oui (14-104 mélangé) |
| 10 | 25 / 25 | 30 / 35 | Oui |
| 8 à 750 | identique | identique | Non |
| 1000 | 445 / 500 | 520 / 585 | Oui |

**Après Cycle 3 :** #12, #10 et 1000 kcmil Al corrigés.

### Tableau 5A

- Facteurs 31–60 °C et 70 / 80 °C (colonne isolation 90 °C) : **alignés**.
- **Écart restant :** une seule colonne (90 °C). L’officiel a des colonnes 60 / 75 / 90 °C.
- **Écart corrigé :** paliers 65 °C (0,65) et 75 °C (0,50) manquaient.

### Tableau 5C

1–3 : 100 % · 4–6 : 80 % · 7–24 : 70 % · 25–42 : 60 % · 43+ : 50 %.  
**Identique** aux concordances 25e édition.

### Tableau 8

1 conducteur 53 % · 2 conducteurs 31 % · 3 ou plus 40 %.  
**Identique.**

### Tableau 9

- Officiel C22.10:26 / CCÉ 25e : **Tableaux 9A à 9P** (rigide, PVC, EMT 9I, HDPE, etc.).
- Travail : **une** liste d’aires internes (série type EMT / équivalent 204, 366, 599… mm²).
- **Écart de périmètre** : pas de distinction EMT vs PVC vs rigide. Les aires peuvent différer de quelques % selon 9I vs notre série. À recouper sur l’exemplaire officiel 9I si EMT.

### Tableau 10

- Officiel : **10A–10D** (et T6A–6K pour remplissages tout faits).
- Travail : une aire par calibre (approximation RW90).
- **Écart de périmètre** : l’aire réelle dépend du type d’isolant. Peut faire choisir un commerce de trop ou de trop peu.

### Tableau 16

Concordance : 20 A → #14 · 30–40 A → #12 · 60 A → #10 · 100 A → #8 · 200 A → #6, etc.

**Écart avant :** 31–40 A donnaient #10 (plus gros, conservateur).  
**Après Cycle 3 :** 30–40 A → #12 Cu.

### Tableau 17

**Écart de rôle (le plus important) :**

- En 25e édition, le **Tableau 17** = conditions d’alarme / mise hors tension des **systèmes mis à la terre par impédance** (art. 10-302).
- Il **n’est plus** le tableau de calibre du conducteur d’électrode.
- Le GEC (tiges, plaque, béton) relève de **10-812** : typiquement **#6 Cu**, sans obligation d’être plus gros.

L’ancienne table de travail (GEC selon calibre de phase, ex. #4 pour 3/0) était un **modèle d’édition antérieure**.  
**Après Cycle 3 :** GEC = #6 Cu. QC 2026 : pas d’eau municipale comme **nouvelle** électrode.

## Ce qui n’a pas été recopié

Aucune reproduction intégrale des tableaux CSA. Les valeurs numériques du moteur sont des **données de travail** à valider sur C22.10:26.
