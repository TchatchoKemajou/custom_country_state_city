## 1.1.3

- Boost pub.dev score (target 160/160):
  - Added dartdoc comments on the library + the `CustomCountryStateCityPicker` class and all its public parameters (was 2.9% documented, now ~60%).
  - Replaced all deprecated `Color.withOpacity(x)` calls by `Color.withValues(alpha: x)` (Flutter 3.27+).
  - Replaced deprecated `ThemeData.dialogBackgroundColor` by `DialogTheme.backgroundColor`.
  - Added missing `const` on default value instances to satisfy `prefer_const_constructors`.
- Maintainer section translated to English.

## 1.1.2

- README: redesigned Maintainer section — full name, LinkedIn, GitHub, Jov's Inc. (`/blog`), email.

## 1.1.1

- README: fixed the first row of the Screenshots table which had a stray `|git` at the end of the line breaking markdown rendering on pub.dev (the 3 tables showed as raw text `[image info]` instead of the images). Improved alt text with descriptive labels.

## 1.1.0

- Theme-aware dialog: colors, text and borders now pulled from `Theme.of(context).colorScheme` instead of forced white values (works in both dark and light mode).
- Flag emoji (🇨🇦 🇨🇲 🇫🇷…) displayed in front of each country.
- Selected item highlight with the primary color + check icon.
- Modern search field (filled background, rounded border, clickable placeholder).
- Full-width `OutlinedButton` to close the dialog.
- New i18n props: `inputSearchHintText` and `closeTextButton` so the caller can pass their own translated strings.
- Auto cascade on mount: if `country.text` is already pre-filled (edit mode), the state list is hydrated right away. Before, you had to re-select the country for the state item to appear.

## 1.0.0

### Platforms:
This widget has been successfully tested on iOS, Android and Chrome.
