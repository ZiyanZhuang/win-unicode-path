from __future__ import annotations

import argparse
import json
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser(description="Write JSON with explicit UTF-8 encoding.")
    parser.add_argument("--output", required=True)
    parser.add_argument("--ensure-ascii", action="store_true")
    parser.add_argument("--indent", type=int, default=2)
    parser.add_argument("--payload", help="JSON payload string")
    parser.add_argument("--payload-file", help="Path to a UTF-8 or UTF-8-SIG JSON payload file")
    args = parser.parse_args()

    if bool(args.payload) == bool(args.payload_file):
        raise SystemExit("Provide exactly one of --payload or --payload-file.")

    if args.payload_file:
        payload_text = Path(args.payload_file).read_text(encoding="utf-8-sig")
    else:
        payload_text = args.payload

    payload = json.loads(payload_text)
    out_path = Path(args.output)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(
        json.dumps(payload, ensure_ascii=args.ensure_ascii, indent=args.indent),
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
