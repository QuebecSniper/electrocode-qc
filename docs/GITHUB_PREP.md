# Préparation GitHub — ÉlectroCode QC

Le remote **n’est pas créé**. Le **premier commit local** est fait.

## Ce qui est prêt

- Dépôt Git local (branche `main`)
- `.gitignore` : build, `.dart_tool`, `local.properties`, keystores, `.env`
- `.gitattributes`
- Workflows : `.github/workflows/*.yml`
- Pas de secrets dans le dépôt (`android/local.properties` ignoré)

## Création du remote (quand tu le demanderas — ne pas le faire avant)

1. Créer le dépôt vide sur GitHub (sans README, sans `.gitignore`).
2. Puis, en local :

```powershell
cd "C:\Users\Win11\Desktop\projet\application électricien"
git remote add origin https://github.com/COMPTE/electrocode-qc.git
git branch -M main
git push -u origin main
```

Ne pas committer : `android/local.properties`, `*.jks`, `.env`, clés API.
