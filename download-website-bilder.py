#!/usr/bin/env python3
"""
Automatisches Skript zum Herunterladen und Einbauen der Original-Bilder
von www.kanzlei-himmelsbach.de in die HTML-Datei
"""

import requests
from bs4 import BeautifulSoup
import base64
import re
import os
from urllib.parse import urljoin

# Konfiguration
WEBSITE_URL = "https://www.kanzlei-himmelsbach.de/"
HTML_FILE = "kanzlei-himmelsbach-mit-bildern.html"
OUTPUT_FILE = "kanzlei-himmelsbach-mit-original-bildern.html"

# User-Agent um 403-Fehler zu vermeiden
HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
    'Accept-Language': 'de,en-US;q=0.7,en;q=0.3',
    'Accept-Encoding': 'gzip, deflate',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1'
}

def download_website():
    """Website herunterladen"""
    print(f"📥 Lade Website: {WEBSITE_URL}")
    try:
        response = requests.get(WEBSITE_URL, headers=HEADERS, timeout=10)
        response.raise_for_status()
        print("✅ Website erfolgreich geladen")
        return response.content
    except requests.exceptions.RequestException as e:
        print(f"❌ Fehler beim Laden: {e}")
        return None

def extract_images(html_content):
    """Alle Bilder von der Website extrahieren"""
    print("\n🔍 Extrahiere Bilder...")
    soup = BeautifulSoup(html_content, 'html.parser')

    images = []

    # <img> Tags
    for img in soup.find_all('img'):
        src = img.get('src') or img.get('data-src')
        if src:
            full_url = urljoin(WEBSITE_URL, src)
            alt = img.get('alt', '')
            images.append({
                'url': full_url,
                'alt': alt,
                'type': 'img'
            })

    # CSS background-images
    for tag in soup.find_all(style=True):
        style = tag.get('style', '')
        urls = re.findall(r'url\([\'"]?([^\'"]+)[\'"]?\)', style)
        for url in urls:
            full_url = urljoin(WEBSITE_URL, url)
            images.append({
                'url': full_url,
                'alt': 'Background Image',
                'type': 'bg'
            })

    print(f"✅ {len(images)} Bilder gefunden")
    return images

def download_image(url):
    """Einzelnes Bild herunterladen"""
    try:
        response = requests.get(url, headers=HEADERS, timeout=10)
        response.raise_for_status()
        return response.content
    except Exception as e:
        print(f"❌ Fehler bei {url}: {e}")
        return None

def image_to_base64(image_data, url):
    """Bild zu Base64 konvertieren"""
    if not image_data:
        return None

    # MIME-Type bestimmen
    ext = os.path.splitext(url.lower())[1]
    mime_types = {
        '.jpg': 'image/jpeg',
        '.jpeg': 'image/jpeg',
        '.png': 'image/png',
        '.gif': 'image/gif',
        '.webp': 'image/webp',
        '.svg': 'image/svg+xml'
    }
    mime = mime_types.get(ext, 'image/jpeg')

    b64 = base64.b64encode(image_data).decode('utf-8')
    return f"data:{mime};base64,{b64}"

def download_all_images(images):
    """Alle Bilder herunterladen und konvertieren"""
    print("\n📥 Lade Bilder herunter...")

    results = []
    for i, img in enumerate(images):
        print(f"  [{i+1}/{len(images)}] {img['url']}")
        img_data = download_image(img['url'])

        if img_data:
            base64_data = image_to_base64(img_data, img['url'])
            results.append({
                'url': img['url'],
                'alt': img['alt'],
                'base64': base64_data,
                'size': len(img_data)
            })
            print(f"    ✅ {len(img_data) / 1024:.1f} KB")
        else:
            print(f"    ❌ Fehler")

    return results

def identify_image_roles(images):
    """Bilder nach Rolle kategorisieren"""
    categorized = {
        'logo': None,
        'team': [],
        'hero': None,
        'icons': [],
        'other': []
    }

    for img in images:
        url_lower = img['url'].lower()
        alt_lower = img['alt'].lower()

        # Logo
        if 'logo' in url_lower or 'logo' in alt_lower:
            categorized['logo'] = img

        # Team-Fotos
        elif any(name in url_lower or name in alt_lower for name in ['fritz', 'burkhard', 'stephan', 'team', 'anwalt']):
            categorized['team'].append(img)

        # Hero/Header
        elif any(word in url_lower or word in alt_lower for word in ['hero', 'header', 'banner']):
            categorized['hero'] = img

        # Icons
        elif 'icon' in url_lower or img['size'] < 50000:  # < 50KB = wahrscheinlich Icon
            categorized['icons'].append(img)

        else:
            categorized['other'].append(img)

    return categorized

def replace_images_in_html(html_file, categorized_images):
    """Bilder in HTML-Datei ersetzen"""
    print(f"\n📝 Lese HTML-Datei: {html_file}")

    try:
        with open(html_file, 'r', encoding='utf-8') as f:
            html_content = f.read()
    except FileNotFoundError:
        print(f"❌ Datei nicht gefunden: {html_file}")
        return None

    print("🔄 Ersetze Bilder...")

    # Logo ersetzen
    if categorized_images['logo']:
        logo = categorized_images['logo']
        print(f"  → Logo: {logo['alt']}")
        # SVG Logo ersetzen
        pattern = r'<svg class="logo-icon"[^>]*>.*?</svg>'
        replacement = f'<img class="logo-icon" src="{logo["base64"]}" alt="{logo["alt"]}" style="width: 50px; height: 50px;">'
        html_content = re.sub(pattern, replacement, html_content, flags=re.DOTALL)

    # Hero-Bild ersetzen
    if categorized_images['hero']:
        hero = categorized_images['hero']
        print(f"  → Hero: {hero['alt']}")
        pattern = r'<svg class="hero-illustration"[^>]*>.*?</svg>'
        replacement = f'<img class="hero-illustration" src="{hero["base64"]}" alt="{hero["alt"]}">'
        html_content = re.sub(pattern, replacement, html_content, flags=re.DOTALL)

    # Team-Fotos ersetzen
    for i, team_img in enumerate(categorized_images['team'][:3]):  # Max 3
        print(f"  → Team {i+1}: {team_img['alt']}")
        # Ersten/Nächsten SVG team-photo ersetzen
        pattern = r'<svg class="team-photo"[^>]*>.*?</svg>'
        replacement = f'<img class="team-photo" src="{team_img["base64"]}" alt="{team_img["alt"]}">'
        html_content = re.sub(pattern, replacement, html_content, count=1, flags=re.DOTALL)

    return html_content

def save_html(content, output_file):
    """HTML-Datei speichern"""
    print(f"\n💾 Speichere: {output_file}")
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ Erfolgreich gespeichert!")

        # Dateigröße anzeigen
        size = os.path.getsize(output_file)
        print(f"📊 Dateigröße: {size / 1024:.1f} KB")

        return True
    except Exception as e:
        print(f"❌ Fehler beim Speichern: {e}")
        return False

def main():
    """Hauptfunktion"""
    print("=" * 60)
    print("🚀 Original-Bilder Downloader für Kanzlei Himmelsbach")
    print("=" * 60)

    # Website laden
    html_content = download_website()
    if not html_content:
        print("\n⚠️  HINWEIS: Website blockiert Zugriff (403-Fehler)")
        print("    Bitte folgen Sie der manuellen Anleitung in:")
        print("    ANLEITUNG-Bilder-einbauen.md")
        return

    # Bilder extrahieren
    images = extract_images(html_content)
    if not images:
        print("❌ Keine Bilder gefunden")
        return

    # Bilder herunterladen
    downloaded_images = download_all_images(images)
    if not downloaded_images:
        print("❌ Konnte keine Bilder herunterladen")
        return

    # Bilder kategorisieren
    categorized = identify_image_roles(downloaded_images)

    print("\n📊 Gefundene Bilder:")
    print(f"  • Logo: {'✅' if categorized['logo'] else '❌'}")
    print(f"  • Hero: {'✅' if categorized['hero'] else '❌'}")
    print(f"  • Team: {len(categorized['team'])} Fotos")
    print(f"  • Icons: {len(categorized['icons'])} Stück")
    print(f"  • Sonstige: {len(categorized['other'])} Stück")

    # HTML-Datei bearbeiten
    if not os.path.exists(HTML_FILE):
        print(f"\n❌ HTML-Datei nicht gefunden: {HTML_FILE}")
        return

    modified_html = replace_images_in_html(HTML_FILE, categorized)
    if not modified_html:
        return

    # Speichern
    if save_html(modified_html, OUTPUT_FILE):
        print("\n" + "=" * 60)
        print("✅ FERTIG!")
        print(f"📁 Ausgabe-Datei: {OUTPUT_FILE}")
        print("🌐 Öffnen Sie die Datei im Browser:")
        print(f"   open {OUTPUT_FILE}")
        print("=" * 60)

if __name__ == "__main__":
    main()
