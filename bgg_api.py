import os
import json
import html
import requests
import xml.etree.ElementTree as ET
import time


class BGGClient:
    BASE_URL = "https://boardgamegeek.com/xmlapi2"

    @staticmethod
    def _headers():
        headers = {
            "User-Agent": "BGGClient/1.0 (contacto@ejemplo.com)"
        }
        token = os.getenv("BGG_API_TOKEN")
        if token:
            headers["Authorization"] = f"Bearer {token}"
        return headers

    @staticmethod
    def _get_with_retry(url, params, retries=5, delay=2):
        last_status = None

        for i in range(retries):
            r = requests.get(
                url,
                params=params,
                headers=BGGClient._headers(),
                timeout=15
            )

            last_status = r.status_code

            if r.status_code == 200:
                return r

            if r.status_code == 401:
                # Token ausente, invalido o app aun no aprobada por BGG.
                # No tiene sentido reintentar, va a seguir fallando igual.
                raise Exception(
                    "BGG rechazo la autenticacion (401). Verifica que BGG_API_TOKEN "
                    "este configurado y que tu aplicacion ya haya sido aprobada."
                )

            if r.status_code in (202, 429):
                # 202: BGG esta procesando la solicitud en background, reintentar
                # 429: rate limiting, reintentar con espera
                time.sleep(delay)
                continue

            # otros errores reales, no vale la pena reintentar
            break

        raise Exception(f"BGG no respondio correctamente (ultimo status {last_status})")

    @staticmethod
    def search_game(query):
        try:
            url = f"{BGGClient.BASE_URL}/search"
            params = {"query": query, "type": "boardgame"}

            response = BGGClient._get_with_retry(url, params)

            if not response.text.strip().startswith("<"):
                raise Exception("BGG devolvio HTML en vez de XML (posible error interno o bloqueo de Cloudflare)")

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
            url = f"{BGGClient.BASE_URL}/thing"
            params = {"id": bgg_id, "stats": 1}

            response = BGGClient._get_with_retry(url, params)

            if not response.text.strip().startswith("<"):
                raise Exception("BGG devolvio HTML en vez de XML (posible error interno o bloqueo de Cloudflare)")

            root = ET.fromstring(response.content)
            item = root.find("item")
            if item is None:
                return None

            def _text(path):
                el = item.find(path)
                if el is None or not el.text:
                    return None
                # BGG codifica las descripciones con entidades dobles
                # (ej: "&amp;#10;" en vez de un salto de linea real).
                # html.unescape() las convierte a texto plano legible.
                return html.unescape(el.text).strip()

            def _attr_int(path, attr="value"):
                el = item.find(path)
                if el is None or el.get(attr) is None:
                    return None
                try:
                    return int(el.get(attr))
                except ValueError:
                    return None

            def _attr_float(path, attr="value"):
                el = item.find(path)
                if el is None or el.get(attr) is None:
                    return None
                try:
                    return float(el.get(attr))
                except ValueError:
                    return None

            def _links_by_type(link_type):
                values = [
                    link.get("value")
                    for link in item.findall("link")
                    if link.get("type") == link_type and link.get("value")
                ]
                return json.dumps(values)

            name = item.find("name[@type='primary']").get("value")

            return {
                "bgg_id": bgg_id,
                "name": name,
                "description": _text("description"),
                "year_published": _attr_int("yearpublished"),
                "image_url": _text("image"),
                "thumbnail_url": _text("thumbnail"),
                "min_players": _attr_int("minplayers"),
                "max_players": _attr_int("maxplayers"),
                "playing_time": _attr_int("playingtime"),
                "min_age": _attr_int("minage"),
                "complexity": _attr_float("statistics/ratings/averageweight"),
                "categories": _links_by_type("boardgamecategory"),
                "mechanics": _links_by_type("boardgamemechanic"),
                "designers": _links_by_type("boardgamedesigner"),
                "publishers": _links_by_type("boardgamepublisher"),
                "bgg_link": f"https://boardgamegeek.com/boardgame/{bgg_id}"
            }

        except Exception as e:
            print(f"Error obteniendo detalles: {e}")
            return None