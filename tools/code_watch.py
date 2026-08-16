#!/usr/bin/env python3
"""Veille des pages publiques RBQ (pas le texte CSA)."""
from __future__ import annotations

import hashlib
import json
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCES = ROOT / "docs" / "code-watch" / "sources.json"
BASELINE = ROOT / "docs" / "code-watch" / "baseline.json"


def fetch(url: str) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": "ElectroCodeQC/0.1"})
    with urllib.request.urlopen(req, timeout=45) as resp:
        return resp.read().decode("utf-8", errors="replace")


def main() -> int:
    spec = json.loads(SOURCES.read_text(encoding="utf-8"))
    current = {"code_version": spec.get("code_version"), "hashes": {}}
    for src in spec["sources"]:
        try:
            body = fetch(src["url"])
            digest = hashlib.sha256(body.encode("utf-8")).hexdigest()
            current["hashes"][src["id"]] = digest
            print(f"OK {src['id']} {digest[:12]}")
        except Exception as exc:  # noqa: BLE001
            print(f"WARN {src['id']}: {exc}")
            current["hashes"][src["id"]] = f"error:{exc}"

    if not BASELINE.exists():
        BASELINE.write_text(json.dumps(current, indent=2), encoding="utf-8")
        print("Baseline créée. Relancer le cycle STATE si le Code change.")
        return 0

    baseline = json.loads(BASELINE.read_text(encoding="utf-8"))
    changed = []
    for key, digest in current["hashes"].items():
        if baseline.get("hashes", {}).get(key) != digest:
            changed.append(key)
    if changed:
        print("CHANGEMENTS détectés:", ", ".join(changed))
        print("Mettre à jour ELECTROCODE_QC_STATE.md et recouper C22.10:26.")
        BASELINE.write_text(json.dumps(current, indent=2), encoding="utf-8")
        return 1
    print("Aucune modification des pages de veille.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
