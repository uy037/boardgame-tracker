import requests
import xml.etree.ElementTree as ET
import time
import json

class BGGClient:
    BASE_URL = "https://boardgamegeek.com/xmlapi2"

    HEADERS = {
        "User-Agent": "BGGClient/1.0 (contacto@ejemplo.com)"
    }

@staticmethod
def _get_with_retry(url, params, retries=5, delay=2):
    last_status = None

    for i in range(retries):
        r = requests.get(
            url,
            params=params,
            headers=BGGClient.HEADERS,
            timeout=15
        )

        last_status = r.status_code

        if r.status_code == 200:
            return r

        if r.status_code in (202, 401, 429):
            time.sleep(delay)
            continue

        # otros errores reales
        break

    raise Exception(f"BGG no respondió correctamente (último status {last_status})")
    @staticmethod
    def search_game(query):
        try:
            text = response.text.strip()

            if not text.startswith("<"):
                raise Exception("BGG devolvió HTML (error interno o Cloudflare)")
            url = f"{BGGClient.BASE_URL}/search"
            params = {"query": query, "type": "boardgame"}

            response = BGGClient._get_with_retry(url, params)

            if not response.text.strip().startswith("<"):
                raise Exception("Respuesta no XML")

            root = ET.fromstring(response.content)
            results = []

            for item in root.findall("item"):
                results.append({
                    "id": int(item.get("id")),
                    "name": item.find("name").get("value"),
                    "year": item.find("yearpublished").get("value") if item.find("yearpublished") is not None else None
                })

            return results

        except Exception as e:
            print(f"Error buscando en BGG: {e}")
            return []
    @staticmethod
    def get_game_details(bgg_id):
        try:
            text = response.text.strip()

            if not text.startswith("<"):
                raise Exception("BGG devolvió HTML (error interno o Cloudflare)")
            url = f"{BGGClient.BASE_URL}/thing"
            params = {"id": bgg_id, "stats": 1}

            response = BGGClient._get_with_retry(url, params)

            root = ET.fromstring(response.content)
            item = root.find("item")
            if item is None:
                return None

            name = item.find("name[@type='primary']").get("value")
            year = item.find("yearpublished")
            complexity = item.find("statistics/ratings/averageweight")

            return {
                "bgg_id": bgg_id,
                "name": name,
                "year_published": int(year.get("value")) if year is not None else None,
                "complexity": float(complexity.get("value")) if complexity is not None else None,
                "bgg_link": f"https://boardgamegeek.com/boardgame/{bgg_id}"
            }

        except Exception as e:
            print(f"Error obteniendo detalles: {e}")
            return None
