from __future__ import annotations

import json
import sys
from pathlib import Path


def main() -> None:
    p = Path(sys.argv[1])
    data = p.read_bytes()
    payload = {
        "path": str(p),
        "first_bytes": list(data[:4]),
        "has_utf8_bom": data.startswith(bytes([0xEF, 0xBB, 0xBF])),
        "text": p.read_text(encoding="utf-8"),
    }
    print(json.dumps(payload, ensure_ascii=False))


if __name__ == "__main__":
    main()
