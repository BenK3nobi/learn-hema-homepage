# Shop-Designs

Ablage für die Spreadshop-Motive. Je Motiv ein Unterordner mit Quelldatei und Export:

```
designs/
  posta-di-donna/
    posta-di-donna.svg       # Quelle (Vektor), hier wird geändert
    posta-di-donna-4000.png  # Export für Spreadshop: transparent, 4000 px Kantenlänge
    NOTIZ.md                 # Produkttypen, Designpreis, Datum des Uploads, Quelle der Abbildung
```

Vorgaben (beim Anlegen des Shops gegen die aktuellen Spreadshop-Regeln prüfen):

- PNG mit transparentem Hintergrund oder SVG; Vektor bevorzugt.
- Rastergrafik mindestens 4000 px auf der längeren Seite, 200 dpi.
- Keine Marken, keine fremden Logos, keine Abbildungen aus geschützten Büchern.
  Manuskriptabbildungen nur aus gemeinfreien Digitalisaten, Quelle in `NOTIZ.md`.
- Dunkle und helle Variante je Motiv, wenn es auf hellen und dunklen Textilien angeboten wird.

Große Binärdateien (> 5 MB) nicht committen, sondern auf dem Server oder in einer Cloud ablegen
und in `NOTIZ.md` verlinken. `.gitignore` schließt `*.psd`, `*.afdesign` und `*.ai` aus.
