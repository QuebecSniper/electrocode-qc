#!/usr/bin/env python3
"""Valide un JSON ÉlectroCode QC avec le moteur JSON Schema (Draft 2020-12)."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCHEMA = ROOT / "schemas" / "electrocode-result.schema.json"


def _load_schema() -> dict:
    return json.loads(SCHEMA.read_text(encoding="utf-8-sig"))


def _validator():
    try:
        from jsonschema import Draft202012Validator, FormatChecker
    except ImportError as exc:  # pragma: no cover
        raise SystemExit(
            "Installer jsonschema : pip install jsonschema\n" + str(exc)
        ) from exc
    return Draft202012Validator(_load_schema(), format_checker=FormatChecker())


def main() -> int:
    if not SCHEMA.exists():
        print("schema manquant")
        return 1
    validator = _validator()
    paths = [Path(p) for p in sys.argv[1:]]
    if not paths:
        sample = ROOT / "schemas" / "examples"
        paths = list(sample.glob("*.json")) if sample.exists() else []
        if not paths:
            print("Aucun fichier JSON à valider (ok si aucun exemple).")
            return 0
    failed = 0
    for path in paths:
        data = json.loads(path.read_text(encoding="utf-8-sig"))
        errors = sorted(validator.iter_errors(data), key=lambda e: list(e.path))
        if errors:
            failed += 1
            print(f"FAIL {path}")
            for err in errors:
                loc = ".".join(str(p) for p in err.path) or "(racine)"
                print(f"  - {loc}: {err.message}")
        else:
            print(f"OK {path} (JSON Schema Draft 2020-12)")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
