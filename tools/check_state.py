#!/usr/bin/env python3
"""Vérifie les sections obligatoires de ELECTROCODE_QC_STATE.md."""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STATE = ROOT / "ELECTROCODE_QC_STATE.md"

REQUIRED = [
    "Vision et objectifs",
    "% d’avancement",
    "Version du Code électrique",
    "Architecture technique",
    "Modules développés",
    "État des workflows CI/CD",
    "Décisions techniques",
    "Problèmes ouverts",
    "Prochaine action exacte",
    "Historique des cycles",
]


def main() -> int:
    if not STATE.exists():
        print("ELECTROCODE_QC_STATE.md introuvable")
        return 1
    text = STATE.read_text(encoding="utf-8")
    missing = [s for s in REQUIRED if s not in text]
    # Apostrophe ASCII fallback
    if "% d’avancement" in missing and "% d'avancement" in text:
        missing = [s for s in missing if s != "% d’avancement"]
    if missing:
        print("Sections manquantes:", missing)
        return 1
    print("STATE.md sections OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
