# ÉlectroCode QC

Outil **hors-ligne** de dimensionnement électrique pour **électriciens du Québec** (licence CCQ / RBQ).

Code intégré : **C22.10:26** (Chapitre V – Électricité, CCÉ 25e édition + modifications Québec).  
V1 : **résidentiel**. Commercial / institutionnel / industriel : à venir.

> Ce dimensionnement est un outil d'aide. La responsabilité finale appartient à l'électricien titulaire de la licence.

Lire aussi [docs/DISCLAIMER.md](docs/DISCLAIMER.md).

---

## Mode d’emploi terrain

1. **Nouveau projet** — nommez le chantier (ex. « Bungalow Laval, panneau 200 A »).
2. **Type de bâtiment** — choisissez *residential*. Les autres types posent une question « module à venir ».
3. **Décrivez le travail** — texte ou bouton **Dicter** (français québécois). Exemple :  
   *« Bungalow 120 m², 200 ampères cuivre, chauffage électrique 15 kW, borne 60 A sans EMS, 25 m, tiges. »*
4. **Complétez les charges** — superficie, tension 120/240 V, chauffage, cuisinière, sécheuse, chauffe-eau, borne VÉ, longueur de parcours, Cu ou Al, prise de terre.
5. **Photo ou PDF** — importez un plan. L’app extrait le **texte** (photo via OCR ; PDF texte natif). Ce n’est pas une lecture de unifilaire.
6. **Questions** — si une donnée manque, l’app la demande avant de calculer.
7. **Calibre imposé (optionnel)** — si vous voulez *vérifier* un calibre existant (ex. `#3 Cu`), inscrivez-le. S’il est trop petit ou si la chute dépasse 3 %, le résultat est **non_conforme**. L’app **ne surclasse pas** un calibre que vous avez imposé.
8. **Dimensionner** — lisez le statut (`conforme` / `non_conforme` / `questions_en_attente`), les ampères calculés, les conducteurs, la terre, la chute de tension et les **articles / tableaux** cités.
9. **Exporter** — JSON (dossier / archives) ou PDF (remise au client ou au dossier de chantier).

### Ce que le moteur calcule (résidentiel)

| Sujet | Règles citées |
|---|---|
| Charge de logement | 8-200, 8-106 |
| Plusieurs logements | 8-202 (100 % + 65 %) |
| Minimum de service | 8-200(2) : 60 A si ≤ 80 m², sinon 100 A |
| Conducteurs Cu/Al | 4-004 / 4-006, T2 ou T4, T5A, T5C |
| Chute de tension | 8-102 (3 % / 5 %) |
| Canalisations | T8, T9, T10 |
| Mise à la terre | Section 10, T16 (liaison) + **10-812** (GEC #6) — **pas** d’eau municipale comme *nouvelle* prise de terre |

### Période transitoire

L’édition **2018** peut encore s’appliquer aux travaux **débutés avant le 26 septembre 2026**. L’app calcule selon **C22.10:26**. Si le chantier est encore en 2018, validez sur votre Code papier.

---

## Développeur

Flutter 3.5+ (sur cette machine : `%USERPROFILE%\flutter`). Android prioritaire.

```powershell
$env:PATH = "$env:USERPROFILE\flutter\bin;$env:PATH"
flutter pub get
dart test packages/electrocode_engine
flutter test
flutter run
pip install jsonschema
python tools/validate_json.py
python tools/check_state.py
```

```
ELECTROCODE_QC_STATE.md     Source de vérité de la boucle
docs/                       Disclaimer, traçabilité, veille Code
schemas/                    JSON Schema du résultat
packages/electrocode_engine Moteur Dart isolé + tests
lib/                        Application Flutter
.github/workflows/          CI prêts à pousser plus tard
docs/GITHUB_PREP.md         Premier commit / push (remote pas encore créé)
docs/RECOUPEMENT_TABLES_C22.10-26.md  Recoupement Cycle 3
```

Remote GitHub : **pas encore créé**. Voir [docs/GITHUB_PREP.md](docs/GITHUB_PREP.md).
