"""Manage the optional Moonraker zeroconf section without taking over user settings."""

import os
import stat
import sys
import tempfile
from pathlib import Path

from moonraker.confighelper import FileSourceWrapper


HEADER = b"[zeroconf] # Creality Helper Script: slicer discovery"


def configure(action, path):
    original = path.read_bytes()
    lines = original.splitlines(keepends=True)
    changed_service = True
    if action == "enable":
        # Use Moonraker's parser so nested includes and wildcards are respected.
        source = FileSourceWrapper(None)
        source.read_file(path)
        if source.get_parser().has_section("zeroconf"):
            return
        newline = b"\r\n" if b"\r\n" in original else b"\n"
        lines.insert(0, HEADER + newline)
    else:
        for index, line in enumerate(lines):
            if line.rstrip(b"\r\n") == HEADER:
                break
        else:
            return
        # A user may have added settings to the section after enabling discovery.
        following = (line.strip() for line in lines[index + 1:])
        first = next((line for line in following if line and not line.startswith((b"#", b";"))), b"")
        if first and not first.startswith(b"["):
            lines[index] = lines[index].replace(HEADER, b"[zeroconf]", 1)
            changed_service = False
        else:
            del lines[index]

    info = path.stat()
    with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as tmp:
        try:
            tmp.write(b"".join(lines))
            tmp.flush()
            os.fchown(tmp.fileno(), info.st_uid, info.st_gid)
            os.fchmod(tmp.fileno(), stat.S_IMODE(info.st_mode))
            os.fsync(tmp.fileno())
            if path.read_bytes() != original:
                raise RuntimeError(f"{path} changed during configuration. Please retry.")
            os.replace(tmp.name, path)
        finally:
            if os.path.exists(tmp.name):
                os.unlink(tmp.name)
    if changed_service:
        print("restart")


if __name__ == "__main__":
    action, config = sys.argv[1:]
    if action not in ("enable", "disable"):
        sys.exit("Expected enable or disable")
    configure(action, Path(config).resolve(strict=True))
