# ÉlectroCode QC — État du projet

**Source de vérité de la boucle autonome.** Tout le travail reste dans le dossier `application électricien`. Remote GitHub : **pas encore créé** (fichiers prêts — `docs/GITHUB_PREP.md`).

## Vision et objectifs

Application mobile hors-ligne **ÉlectroCode QC** pour électriciens du Québec : saisie texte/voix (français québécois), tensions/ampérages/charges, photo/PDF, questions manquantes, dimensionnement conforme au *Code de construction du Québec – Chapitre V Électricité* (C22.10:26), export PDF + JSON, traçabilité d’articles.

V1 : résidentiel complet. Commercial / institutionnel / industriel : structurés, calculs à venir.

## % d’avancement

**90 % de la V1 résidentielle — GELÉE** (2026-08-15, Cycle 3 accepté). Pas d’élargissement du moteur résidentiel tant que le gel n’est pas levé.

## Version du Code électrique intégrée + date de dernière vérification

| Champ | Valeur |
|---|---|
| Norme | CSA C22.10:26 (CCÉ 25e édition + modifications Québec) |
| En vigueur | 2026-03-26 |
| Transition 2018 | travaux débutés avant 2026-09-26 |
| Dernière vérification RBQ | 2026-08-15 |
| Recoupement tables | 2026-08-15 (concordances publiques ; livre officiel T9I/T10A encore à viser) |
| `code_version` JSON | `C22.10:26` |

## Architecture technique

- App Flutter (Android) à la racine, package Dart isolé `packages/electrocode_engine`
- Stockage local Hive (JSON de projets)
- STT `fr_CA`, OCR photo (ML Kit) + extraction calque texte PDF
- Export PDF en tableaux + JSON (JSON Schema Draft 2020-12)
- Calibre de service **imposé** : évalué, jamais surclassé silencieusement
- Pas de LLM pour le dimensionnement
- Dépôt local prêt (`.gitignore`, `.gitattributes`, workflows) — **aucun remote**

## Modules développés / restants

### Développés

- Moteur résidentiel : 8-200, 8-202 (100 % + 65 % par type de charge d’unité ; 8-106 sur le chauffage du bâtiment), service 100 A / 200 A, Cu/Al, T2/T4/T5A/T5C, canalisations T8–T10, liaison T16, GEC **10-812**, 8-102
- Refus de calibre imposé trop petit (ampacité et/ou chute de tension)
- Validateur JSON Schema réel (`jsonschema` Draft 2020-12)
- README mode d’emploi terrain
- Rapport PDF tabulaire
- Extraction texte PDF + OCR photo
- Recoupement Cycle 3 documenté (`docs/RECOUPEMENT_TABLES_C22.10-26.md`)
- Tests moteur (dont recoupement T2/T4/T16/10-812) + tests Flutter

### Restants (hors gel V1 — ne pas ouvrir maintenant)

- Lever le gel seulement pour viser T9I / T10A sur l’exemplaire officiel, ou pour un essai Android
- OCR de PDF scanné (image) : passer par une photo
- Validation dictée/OCR sur appareil Android
- Créer le remote GitHub et pousser (quand demandé)
- Modules commercial / institutionnel / industriel
- Transformateurs

## Limitations connues de la V1 (gelée à 90 %)

Ces 3 écarts sont **acceptés** pour la V1. Ils ne bloquent pas le dimensionnement résidentiel courant (service, T2/T4 colonne 75 °C, T5C, T8, T16, 10-812). Ils restent à traiter **après** levée du gel.

| ID | Tableau | Limitation V1 | Impact terrain |
|---|---|---|---|
| L-T5A | **T5A** | Seule la colonne **90 °C** est encodée. Les colonnes **60 °C** et **75 °C** sont absentes. | Correction ambiante trop généreuse si l’isolation / la colonne applicable n’est pas 90 °C. Cas V1 typique : RW90 + terminaisons 75 °C (4-006) — on part de T2/T4 75 °C, puis T5A 90 °C. |
| L-T9 | **T9** | Une seule série d’aires internes (EMT-like : 204, 366, 599… mm²). L’officiel C22.10:26 est **9A–9P** (EMT = 9I, PVC, rigide, HDPE, etc.). | Le commerce de canalisation peut différer de quelques % selon le type réel. Pas de distinction EMT / PVC / rigide. |
| L-T10 | **T10** | Une seule colonne d’aires de conducteur (approximation RW90). L’officiel est **10A–10D** (selon isolant). | Le remplissage peut faire choisir un commerce de trop ou de trop peu si l’isolant n’est pas RW90. |

## État des workflows CI/CD

| Workflow | Fichier | Rôle | État |
|---|---|---|---|
| CI | `.github/workflows/ci.yml` | analyze, tests, JSON Schema, STATE | créé (local) + `pip install jsonschema` |
| Conformité | `.github/workflows/code-compliance.yml` | `test/compliance` | créé (local) |
| STATE | `.github/workflows/update-state.yml` | sections obligatoires | créé (local) |
| Veille Code | `.github/workflows/code-watch.yml` | pages RBQ | créé (local) |

Pas de remote. Aucun push.

## Décisions techniques

- Calibre imposé (`forced_service_conductor`) : pas de surclassement ; `non_conforme` + message T2/T4 ou 8-102
- Sans calibre imposé : surclassement VD conservé (aide à la conception)
- 8-202 : diversité 100 %+65 % sur base, cuisinières, sécheuses, chauffe-eau ; chauffage 8-106 sur le total raccordé
- T2/T4 stockent les **ampacités de tableau** ; **14-104** limite #14/#12/#10 à part
- GEC (tiges/plaque/béton) : **10-812 → #6 Cu**. Le Tableau 17 n’est plus un tableau de calibre GEC (impédance, 10-302)
- `code_references.table` rempli seulement s’il existe un tableau (T2, T4, T5A, T5C, T8, T9, T10, T16)
- JSON Schema Draft 2020-12 via Python `jsonschema`
- Recoupement Cycle 3 : concordances publiques (electdesign, vrielectrical, guides 25e éd.). Pas de reproduction du texte CSA

## Recoupement tables C22.10:26 (Cycle 3)

Détail : [docs/RECOUPEMENT_TABLES_C22.10-26.md](docs/RECOUPEMENT_TABLES_C22.10-26.md) et [docs/CODE_TRACEABILITY.md](docs/CODE_TRACEABILITY.md).

| Tableau | Verdict | Écarts |
|---|---|---|
| T2 | **Écart corrigé** | Avant : #14/#12/#10/#8 collés sur 14-104 (15/15, 20/20, 30/30, 45/55). Concordance 75/90 : **20/25, 25/30, 35/40, 50/55**. #6 et plus : identique |
| T4 | **Écart corrigé** | #12/#10 Al étaient 14-104 (15/15, 25/25) vs **20/25, 30/35**. **1000 kcmil Al** 445/500 vs **520/585**. #8–750 : identique |
| T5A | **Écart partiel (reste)** | Colonne **90 °C seulement** (il manque 60/75 °C). Paliers 65 °C (0,65) et 75 °C (0,50) ajoutés |
| T5C | **Identique** | 1–3 : 100 % · 4–6 : 80 % · 7–24 : 70 % · 25–42 : 60 % · 43+ : 50 % |
| T8 | **Identique** | 1 cond. 53 % · 2 : 31 % · ≥3 : 40 % |
| T9 | **Écart de périmètre (reste)** | Officiel = **9A–9P** (EMT = 9I). Moteur : une série d’aires EMT-like (204, 366, 599…) |
| T10 | **Écart de périmètre (reste)** | Officiel = **10A–10D**. Moteur : une colonne d’aires RW90-like |
| T16 | **Écart corrigé** | 40 A donnait #10 ; concordance : 30 **et 40** → **#12** Cu |
| T17 | **Écart de rôle corrigé** | T17 = alarmes systèmes à **impédance** (10-302), **pas** le GEC. GEC = **10-812 #6 Cu** |

## Problèmes ouverts

- **Limitations V1 gelées** : L-T5A (colonnes 60/75 °C), L-T9 (9A–9P), L-T10 (10A–10D) — voir section dédiée
- Flutter pas dans le PATH machine (`%USERPROFILE%\flutter`)
- Dictée / OCR photo non validées sur appareil
- PDF scanné sans calque texte : photo requise
- `DropdownButtonFormField.value` déprécié (Flutter 3.33+)
- Remote GitHub pas encore créé (commit local prêt)

## Prochaine action exacte

Créer le remote GitHub et pousser **quand demandé**. V1 gelée à 90 %. **Ne pas** ouvrir commercial / institutionnel / industriel. **Ne pas** lancer les essais Android tant que ce n’est pas demandé.

## Historique des cycles

### Cycle 3 — 2026-08-15 — recoupement tables + GitHub local

- Recoupement T2, T4, T5A, T5C, T8, T9, T10, T16, T17 vs concordances C22.10:26 / CCÉ 25e
- Corrections moteur : T2 #14–#8, T4 #12/#10/1000 Al, T5A 65/75 °C, T16 40 A → #12, GEC #6 (10-812)
- Docs : `RECOUPEMENT_TABLES_C22.10-26.md`, traçabilité, STATE
- Préparation GitHub : `.gitignore`, `.gitattributes`, `docs/GITHUB_PREP.md` — **pas de remote**
- Interdictions respectées : pas de module non résidentiel, pas d’essai Android
- V1 gelée à 90 % ; L-T5A / L-T9 / L-T10 documentées comme limitations connues

### Cycle 2 — 2026-08-15 — fermeture des Partiel

- Cas A 65 m² → 100 A ; Cas B duplex 90 m² → 100 A
- Cas C #3 Cu forcé / 200 A → non_conforme sans surclassement
- Cas D #3 Cu / 60 m / 100 A → VD > 3 % non_conforme
- 8-202 moins simplifié ; tables citées quand elles existent
- JSON Schema réel ; README électricien ; PDF tableaux ; texte PDF

### Cycle 1 — 2026-08-15 — fondation V1 résidentielle

- Dossier vide → app + moteur + tests + CI
- Code cible figé : C22.10:26
