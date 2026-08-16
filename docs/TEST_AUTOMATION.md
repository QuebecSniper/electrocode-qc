# Automatisation des tests — ÉlectroCode QC

## Ce qui est automatisé (CI)

Workflows : `.github/workflows/ci.yml` et `code-compliance.yml`.

| Couche | Où | Quoi |
|---|---|---|
| Moteur unitaire | `packages/electrocode_engine/test/unit` | Intake, schéma JSON, tables Cycle 3, demande |
| Conformité Code | `packages/electrocode_engine/test/compliance` | 100 A, 200 A, 8-202, calibre imposé, Al, VD, terre, VÉ |
| JSON Schema | `tools/validate_json.py` | Draft 2020-12 sur les exemples |
| STATE.md | `tools/check_state.py` | Sections obligatoires |
| Flutter / widget | `test/` | Accueil + disclaimer, flux questions → résultat, CONFORME / NON CONFORME, OCR PDF |

`ci.yml` : analyze moteur + `dart test test/unit` + analyze app + `flutter test` + JSON Schema + STATE.  
`code-compliance.yml` : `dart test test/compliance` (inchangé, toujours valide).

Les tests Flutter **n’utilisent pas** Hive, micro, caméra ni ML Kit réel (fichiers PDF / images vides en mémoire).

## Ce qui reste manuel (appareil Android)

Voir [ANDROID_DEVICE_TEST.md](ANDROID_DEVICE_TEST.md).

- Permission micro / dictée **fr_CA**
- Caméra, galerie, lumière réelle
- Lisibilité une main, contraste soleil
- Partage PDF / JSON vers une autre app
- Premier lancement ML Kit sur le téléphone

Ne pas remplacer ces essais par la CI.
