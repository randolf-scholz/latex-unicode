#!/usr/bin/env python
# /// script
# requires-python = ">=3.11"
# ///
"""Install the latex package."""

import argparse
import hashlib
import os
from pathlib import Path

SOURCE_DIRECTORY = "src"
"""The source directory where the files are located."""
SOURCE_PATTERN = {".sty", ".tex", ".cls"}
"""The extension of the files to be copied to the target directory."""
TARGET_DIR: str = "tex/latex/"
r"""The target directory in the TEXMFHOME tree where the files are copied to."""
TEXMFHOME_PATH: Path = Path(os.environ.get("TEXMFHOME", Path.home() / "texmf"))
"""Location of the TEXMFHOME directory."""
CWD = Path.cwd()
"""The current working directory."""


def get_source_path() -> Path:
    """Return the source directory (existence guaranteed)."""
    source_dir = Path(__file__).resolve().parent / SOURCE_DIRECTORY
    if source_dir.exists():
        return source_dir
    raise FileNotFoundError(f"Could not find the source directory {source_dir}.")


def ask_for_overwrite(file: Path, *, default: bool = True) -> bool:
    """Ask the user whether to overwrite an existing file."""
    msg = f"Overwrite {file}? {'[Y/n]' if default else '[y/N]'}"
    max_retries = 3

    for _ in range(max_retries):
        overwrite = input(msg).strip().lower()
        if overwrite in {"y", "yes"}:
            return True
        if overwrite in {"n", "no"}:
            return False
        if not overwrite:
            return default
        print("Invalid input. Please enter 'y' or 'n'.")

    raise ValueError("Too many retries.")


def make_file(
    source: Path,
    target: Path,
    *,
    copy: bool = True,
    overwrite: bool = False,
) -> None:
    """Copy a file from the source to the target directory."""
    source_fmt = str(source.relative_to(CWD))

    if target.exists():
        # check if the files are identical via hash
        source_hash = hashlib.sha256(source.read_bytes()).hexdigest()
        target_hash = hashlib.sha256(target.read_bytes()).hexdigest()
        same_kind = target.is_symlink() == (not copy)
        same_hash = source_hash == target_hash

        if same_kind and same_hash:
            # get relative path of source to install.py
            print(f"Skipping {source_fmt:<64} (binary identical file exists).")
            return

        # ask for permission to overwrite
        if not overwrite and not ask_for_overwrite(target):
            print(f"Skipping {source_fmt:<64}.")
            return

    # cleanup target; ensure parent directory exists
    target.unlink(missing_ok=True)
    target.parent.mkdir(parents=True, exist_ok=True)

    # perform the transfer
    if copy:
        print(f"Copying {source_fmt:<64} -> {target}.")
        target.write_text(source.read_text())
    else:
        print(f"Symlinking {source_fmt:<64} -> {target}.")
        target.symlink_to(source)


def get_target_path(target_dir: str | Path) -> Path:
    """Returns path to some texmf directory.

    Ensures:
        - target path exists
        - target path is a directory
        - target path is of the form `*/texmf/tex/latex/target_dir`
    """
    target = Path(target_dir).expanduser().resolve()
    if not target.is_dir() or not target.exists():
        raise FileNotFoundError(f"Could not find the target directory {target}.")
    # check that path is a texmf directory
    if target.name != "texmf":
        target /= "texmf"
    target /= TARGET_DIR
    target.mkdir(parents=True, exist_ok=True)
    return target


def install(target: str | Path, *, copy: bool, overwrite: bool) -> None:
    """Install the latex package."""
    source_path = get_source_path().resolve()
    target_path = get_target_path(target)

    # check if source and target are the same
    if source_path == target_path:
        print("Source and target directory are the same. Aborting installation.")
        return

    print(
        f"Installing files ..."
        f"\n\t{source_path=!s}"
        f"\n\t{target_path=!s}"
        f"\n\t{copy=}"
        f"\n\t{overwrite=}\n",
    )

    # iterate over all files in the source directory
    for file in source_path.rglob("*"):
        if file.suffix in SOURCE_PATTERN:
            source = file
            target = target_path / file.relative_to(source_path)

            try:
                make_file(
                    source=file,
                    target=target,
                    copy=copy,
                    overwrite=overwrite,
                )
            except Exception as exc:
                print(f"Error while copying {source} to {target}:\n\t{exc}")
                print("Aborting installation.")
                return

    print("\nInstallation complete.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=(
            "Install the latex package. "
            "Copies relevant files from the source directory to the target directory."
        ),
    )
    parser.add_argument(
        "-o",
        "--overwrite",
        action=argparse.BooleanOptionalAction,
        default=False,
        help="Overwrite existing files.",
    )
    parser.add_argument(
        "-c",
        "--copy",
        action=argparse.BooleanOptionalAction,
        default=False,
        help="Whether to copy the files (otherwise, creates symbolic link).",
    )
    parser.add_argument(
        "target",
        type=str,
        nargs="?",
        default=TEXMFHOME_PATH,
        help="The directory to install the files to (default: ~/texmf or $TEXMFHOME).",
    )
    args = parser.parse_args()
    install(args.target, overwrite=args.overwrite, copy=args.copy)
