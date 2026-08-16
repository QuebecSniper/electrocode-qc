# Guide de test Android — ÉlectroCode QC

**Cycle 5.** Appareil physique obligatoire pour dictée, photo et lisibilité.  
Le moteur de calcul n’est pas retesté ici (déjà gelé / CI). On valide l’usage terrain.

Code : **C22.10:26** (Chapitre V Électricité seulement).

## 0. Préparer l’appareil

1. Téléphone Android (API 26+), USB débogage **ou** APK installé.
2. Langue / dictée : **français (Canada)** installé (Paramètres → Langues / Google Voice).
3. Autoriser **micro**, **caméra**, **photos** à la première demande.
4. Hors-ligne : après le premier lancement ML Kit, mode avion pour confirmer que ça marche sans réseau.

### Lancer depuis le PC

```powershell
$env:PATH = "$env:USERPROFILE\flutter\bin;$env:PATH"
cd "C:\Users\Win11\Desktop\projet\application électricien"
flutter devices
flutter run
```

### Ou installer un APK

```powershell
flutter build apk --debug
```

Fichier : `build/app/outputs/flutter-apk/app-debug.apk`  
Copier sur le téléphone et installer (source inconnue au besoin).

---

## 1. Scénarios obligatoires

Cocher **OK** ou **Problème**. Décrire tout écart.

### A — Installation / lancement

| # | Contrôle | OK | Problème + description |
|---|---|---|---|
| A1 | L’app s’ouvre, titre ÉlectroCode QC, C22.10:26 visible | | |
| A2 | Disclaimer lisible en bas, sans cacher le bouton Nouveau | | |
| A3 | Premier lancement : pas de crash | | |

### B — Dictée vocale fr_CA

Bouton **Dicter** sur l’écran de saisie. Parler naturellement, puis vérifier que des champs se remplissent.

Phrases à dire (une par essai) :

1. *« Bungalow 120 mètres carrés, 200 ampères cuivre, chauffage électrique 15 kilowatts, tiges, vingt-cinq mètres. »*
2. *« Studio 65 m², cuisinière 12 kilowatts, chauffe-eau 3 kilowatts, chauffage 6 kilowatts. »*
3. *« Duplex, un logement 90 mètres carrés, aluminium, prise de terre tiges. »*

| # | Contrôle | OK | Problème + description |
|---|---|---|---|
| B1 | Permission micro demandée / acceptée | | |
| B2 | Phrase 1 : superficie et/ou 200 A reconnus | | |
| B3 | Phrase 2 : charges ou notes dans la description | | |
| B4 | Phrase 3 : pas de crash ; message clair si rien n’est reconnu | | |
| B5 | Si dictée échoue : message + saisie manuelle toujours possible | | |

### C — Photo + OCR

Préparer une **feuille lisible** (imprimé ou écrit gros) :  
`Bungalow 120 m2 — 200 A — chauffage 15 kW — cuisinière 12 kW`

| # | Contrôle | OK | Problème + description |
|---|---|---|---|
| C1 | Photo / PDF → **Prendre une photo** ouvre la caméra | | |
| C2 | Texte lu (ou message clair si flou) | | |
| C3 | Image du dossier (galerie) fonctionne | | |
| C4 | Photo trop sombre / floue : message d’échec, **pas** de faux champs | | |
| C5 | PDF **avec** texte : import OK | | |
| C6 | PDF **scanné** (image) : message « prenez une photo / saisie manuelle » | | |

### D — Chantier résidentiel simple (saisie complète)

Saisir à la main (même si la dictée a marché) :

- Nom : `Test Android bungalow`
- Type : Résidentiel
- 120 m², 200 A, 120/240 V
- Chauffage électrique 15000 W
- Cuisinière 12000, sécheuse 5500, chauffe-eau 4500 (ou **Aucune**)
- Borne VÉ : **Aucune**
- Cuivre, 20 m, tiges
- **Dimensionner**

| # | Contrôle | OK | Problème + description |
|---|---|---|---|
| D1 | Questions seulement si une donnée manque | | |
| D2 | Résultat **CONFORME**, service 200 A lisible | | |
| D3 | Liste de matériel visible sans onglets cachés | | |
| D4 | Articles / tableaux repliables | | |

### E — Lisibilité une main / chantier

| # | Contrôle | OK | Problème + description |
|---|---|---|---|
| E1 | Contraste suffisant en lumière du jour | | |
| E2 | Bouton Dimensionner atteignable au pouce | | |
| E3 | Statut CONFORME / NON CONFORME lu à 40 cm | | |
| E4 | Disclaimer visible sans masquer le statut | | |

### F — Export

| # | Contrôle | OK | Problème + description |
|---|---|---|---|
| F1 | **PDF** s’ouvre / se partage | | |
| F2 | Menu **JSON** se partage ou se copie | | |
| F3 | PDF contient le disclaimer | | |

### G — Cas non conforme (rapide)

Calibre imposé `3` sur un visé 200 A, **ou** prise de terre « Eau municipale (interdit 2026) ».

| # | Contrôle | OK | Problème + description |
|---|---|---|---|
| G1 | Bannière **NON CONFORME** rouge, lisible | | |
| G2 | Avertissement expliquant pourquoi | | |
| G3 | Pas de surclassement silencieux du calibre imposé | | |

---

## 2. Synthèse (à remplir après la session)

| Date | Appareil / Android | Testeur | Verdict global |
|---|---|---|---|
| | | | OK / À corriger |

**Problèmes UX ou techniques rencontrés :**

1. …
2. …

---

## 3. Limites OCR (connues)

- PDF **scanné** (pages image, pas de calque texte) : pas d’OCR PDF. **Photo** du plan, ou saisie.
- Photo de **unifilaire complexe** : le texte lu n’est pas un schéma interprété. Relire les champs.
- ML Kit latin : accents généralement OK ; écriture trop petite ou de travers = échec volontaire + saisie manuelle.
- Premier téléchargement éventuel du modèle ML Kit : prévoir du réseau **une fois**, ensuite hors-ligne.

Ce qui est **automatisé** vs **manuel** : voir [TEST_AUTOMATION.md](TEST_AUTOMATION.md).
