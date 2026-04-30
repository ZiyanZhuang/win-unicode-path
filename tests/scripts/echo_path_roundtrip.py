from __future__ import annotations

import json
import sys
from pathlib import Path


def main() -> None:
    input_path = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    text = input_path.read_text(encoding="utf-8")
    payload = {
        "input_path": str(input_path),
        "output_path": str(output_path),
        "text": text,
    }
    output_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(payload, ensure_ascii=False))


if __name__ == "__main__":
    main()
