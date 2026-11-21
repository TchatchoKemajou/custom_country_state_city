## 1.1.1

- README : fix la 1ère ligne du tableau Screenshots qui avait un `|git` fautif en bout de ligne et cassait le rendu markdown sur pub.dev (les 3 tableaux apparaissaient comme du texte brut `[image info]` au lieu des images). Alt text amélioré par descriptif.

## 1.1.0

- Dialog theme-aware : couleurs, texte et bordures tirés de `Theme.of(context).colorScheme` au lieu de valeurs blanches forcées (fonctionne en dark et light mode).
- Flag emoji (🇨🇦 🇨🇲 🇫🇷…) affiché devant chaque pays.
- Highlight de l'élément sélectionné avec la couleur primaire + icône check.
- Search field modernisée (fond filled, bordure arrondie, placeholder cliquable).
- Full-width `OutlinedButton` pour fermer le dialog.
- Nouvelles props i18n : `inputSearchHintText` et `closeTextButton` pour que l'appelant puisse passer ses propres strings traduits.
- Cascade auto au mount : si `country.text` est déjà pré-rempli (mode édition), la liste des régions est hydratée tout de suite. Avant il fallait re-sélectionner Pays pour que l'élément Région apparaisse.

## 1.0.0

### Platforms:
This widget has been successfully tested on iOS, Android and Chrome.
