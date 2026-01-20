# Anleitung: Original-Bilder von kanzlei-himmelsbach.de einbauen

## Problem
Die Website www.kanzlei-himmelsbach.de blockiert automatisierte Zugriffe (403-Fehler), daher können die Bilder nicht automatisch extrahiert werden.

## Lösung: Manuelle Extraktion

### Schritt 1: Bilder von der Website herunterladen

1. **Öffnen Sie die Website im Browser:**
   ```
   https://www.kanzlei-himmelsbach.de/
   ```

2. **Bilder herunterladen:**
   - **Option A: Rechtsklick auf Bild → "Bild speichern unter..."**
   - **Option B: Browser DevTools (F12):**
     - Öffnen Sie DevTools (F12)
     - Gehen Sie zum Tab "Network" (Netzwerk)
     - Filter auf "Img" (Bilder)
     - Laden Sie die Seite neu (Strg+R)
     - Rechtsklick auf jedes Bild → "Open in new tab" → Speichern

3. **Typische Bilder, die Sie finden sollten:**
   - Logo der Kanzlei
   - Fotos der Anwälte (Fritz, Burkhard, Stephan)
   - Header/Hero-Bild
   - Standort-Fotos (Bürogebäude)
   - Icons für Fachgebiete

### Schritt 2: Bilder konvertieren

#### Option A: Als Base64 einbetten (empfohlen für kleine Bilder)

```bash
# Im Terminal:
base64 -w 0 logo.jpg > logo-base64.txt
base64 -w 0 anwalt1.jpg > anwalt1-base64.txt
# usw.
```

#### Option B: Bilder im selben Ordner speichern

```
/ordner/
  ├── index.html
  └── images/
      ├── logo.jpg
      ├── anwalt1.jpg
      ├── anwalt2.jpg
      └── hero.jpg
```

### Schritt 3: HTML anpassen

#### Für Base64-Bilder:

```html
<!-- Logo im Header -->
<img src="data:image/jpeg;base64,/9j/4AAQSkZJRg..." alt="Kanzlei Logo">

<!-- Team-Fotos -->
<img class="team-photo" src="data:image/jpeg;base64,/9j/4AAQ..." alt="Fritz Himmelsbach">
```

#### Für lokale Bilder:

```html
<!-- Logo im Header -->
<img src="images/logo.jpg" alt="Kanzlei Logo">

<!-- Team-Fotos -->
<img class="team-photo" src="images/fritz-himmelsbach.jpg" alt="Fritz Himmelsbach">
```

### Schritt 4: Datei anpassen

Öffnen Sie `kanzlei-himmelsbach-mit-bildern.html` und ersetzen Sie:

1. **Logo-SVG ersetzen** (Zeile ~750):
```html
<!-- ALT (SVG): -->
<svg class="logo-icon" viewBox="0 0 100 100">...</svg>

<!-- NEU (Ihr Bild): -->
<img class="logo-icon" src="data:image/jpeg;base64,IHRE_BASE64_HIER" alt="Kanzlei Logo">
```

2. **Hero-Illustration ersetzen** (Zeile ~775):
```html
<!-- ALT (SVG): -->
<svg class="hero-illustration" viewBox="0 0 500 400">...</svg>

<!-- NEU (Ihr Bild): -->
<img class="hero-illustration" src="data:image/jpeg;base64,IHRE_BASE64_HIER" alt="Kanzlei Himmelsbach">
```

3. **Team-Fotos ersetzen** (Zeile ~1140):
```html
<!-- ALT (SVG): -->
<svg class="team-photo" viewBox="0 0 200 200">...</svg>

<!-- NEU (Ihr Bild): -->
<img class="team-photo" src="data:image/jpeg;base64,IHRE_BASE64_HIER" alt="Fritz Himmelsbach">
```

## Automatisches Skript

Erstellen Sie ein Python-Skript zum Konvertieren:

```python
#!/usr/bin/env python3
import base64
import os

def image_to_base64(image_path):
    with open(image_path, "rb") as img_file:
        b64_string = base64.b64encode(img_file.read()).decode()

    # Dateiendung erkennen
    ext = os.path.splitext(image_path)[1].lower()
    mime_types = {
        '.jpg': 'image/jpeg',
        '.jpeg': 'image/jpeg',
        '.png': 'image/png',
        '.gif': 'image/gif',
        '.webp': 'image/webp'
    }
    mime = mime_types.get(ext, 'image/jpeg')

    return f"data:{mime};base64,{b64_string}"

# Verwendung:
logo_base64 = image_to_base64("logo.jpg")
print(f'<img src="{logo_base64}" alt="Logo">')
```

## Alternative: Bilder-Scraper

Falls Sie Python installiert haben:

```python
#!/usr/bin/env python3
import requests
from bs4 import BeautifulSoup
import base64
from urllib.parse import urljoin

def scrape_images(url):
    # Mit User-Agent, um 403 zu vermeiden
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }

    response = requests.get(url, headers=headers)
    soup = BeautifulSoup(response.content, 'html.parser')

    # Alle Bilder finden
    images = soup.find_all('img')

    for img in images:
        img_url = img.get('src')
        if img_url:
            full_url = urljoin(url, img_url)
            print(f"Gefunden: {full_url}")

            # Bild herunterladen
            img_response = requests.get(full_url, headers=headers)
            filename = img_url.split('/')[-1]

            with open(filename, 'wb') as f:
                f.write(img_response.content)

            # Als Base64
            b64 = base64.b64encode(img_response.content).decode()
            print(f"Base64 (erste 100 Zeichen): {b64[:100]}...")

scrape_images('https://www.kanzlei-himmelsbach.de/')
```

Speichern als `scrape_images.py` und ausführen:
```bash
pip install requests beautifulsoup4
python3 scrape_images.py
```

## Typische Bildpositionen im HTML

Suchen Sie nach diesen Klassen in `kanzlei-himmelsbach-mit-bildern.html`:

- `.logo-icon` (Zeile ~750) - Kanzlei-Logo
- `.hero-illustration` (Zeile ~775) - Hero-Bild
- `.location-icon` (Zeile ~800, ~820) - Standort-Icons
- `.fachgebiet-icon` (Zeile ~850ff) - Fachgebiete-Icons (6x)
- `.team-photo` (Zeile ~1140ff) - Team-Fotos (3x)

## Schnell-Ersetzung mit sed (Linux/Mac)

```bash
# Logo ersetzen
LOGO_BASE64=$(base64 -w 0 logo.jpg)
sed -i "s|<svg class=\"logo-icon\"[^>]*>.*</svg>|<img class=\"logo-icon\" src=\"data:image/jpeg;base64,$LOGO_BASE64\" alt=\"Logo\">|" kanzlei-himmelsbach-mit-bildern.html

# Team-Foto 1 ersetzen
TEAM1_BASE64=$(base64 -w 0 fritz-himmelsbach.jpg)
sed -i "0,/<svg class=\"team-photo\"/s||<img class=\"team-photo\" src=\"data:image/jpeg;base64,$TEAM1_BASE64\"|" kanzlei-himmelsbach-mit-bildern.html
```

## Fertig!

Nach dem Einbau der Bilder:
1. Öffnen Sie die HTML-Datei im Browser
2. Überprüfen Sie, ob alle Bilder korrekt angezeigt werden
3. Testen Sie die Responsive-Darstellung (Browser-DevTools → Device Toolbar)

## Support

Bei Problemen:
- Prüfen Sie die Browser-Konsole (F12 → Console)
- Stellen Sie sicher, dass Base64-Strings korrekt sind (kein Whitespace)
- Überprüfen Sie die MIME-Types (jpg → image/jpeg, png → image/png)
