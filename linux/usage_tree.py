#!/usr/bin/env python3

# Usage Example: python3 usage_tree.py /home --depth 3 

import os
import shutil
import argparse
import logging
from typing import Tuple
from rich.tree import Tree
from rich.console import Console
from rich.progress import Progress

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
console = Console()


def get_dir_size(path: str) -> int:
    total_size = 0
    try:
        if os.path.isfile(path):
            total_size = os.path.getsize(path)
        else:
            for dirpath, dirnames, filenames in os.walk(path, onerror=None):
                for f in filenames:
                    fp = os.path.join(dirpath, f)
                    if not os.path.islink(fp):
                        try:
                            total_size += os.path.getsize(fp)
                        except OSError:
                            logging.warning(f"Failed to access {fp}")
    except Exception as e:
        logging.error(f"Error while scanning {path}: {e}")
    return total_size


def add_to_tree(tree: Tree, path: str, max_depth: int, current_depth: int = 0) -> Tuple[Tree, int]:
    total_size = 0
    try:
        entries = os.listdir(path)
    except PermissionError:
        tree.add(f"[red]{path} [Permission Denied][/red]")
        return tree, 0

    for entry in sorted(entries):
        entry_path = os.path.join(path, entry)
        try:
            if os.path.isdir(entry_path) and not os.path.islink(entry_path):
                if current_depth < max_depth:
                    subtree = tree.add(f"[bold cyan]{entry}/[/bold cyan]")
                    _, dir_size = add_to_tree(subtree, entry_path, max_depth, current_depth + 1)
                    subtree.label = f"[bold cyan]{entry}/[/bold cyan] [green]({human_readable_size(dir_size)})[/green]"
                    total_size += dir_size
            else:
                size = os.path.getsize(entry_path)
                total_size += size
                tree.add(f"{entry} [yellow]({human_readable_size(size)})[/yellow]")
        except Exception as e:
            logging.warning(f"Skipping {entry_path}: {e}")
    return tree, total_size


def human_readable_size(size: int) -> str:
    for unit in ["B", "KB", "MB", "GB", "TB"]:
        if size < 1024:
            return f"{size:.1f}{unit}"
        size /= 1024
    return f"{size:.1f}PB"


def main():
    parser = argparse.ArgumentParser(description="Disk Usage Visualizer")
    parser.add_argument("directory", nargs="?", default=".", help="Directory to scan (default: current dir)")
    parser.add_argument("--depth", type=int, default=2, help="Max depth of tree (default: 2)")
    args = parser.parse_args()

    root_dir = os.path.abspath(args.directory)

    if not os.path.exists(root_dir):
        logging.error("Directory does not exist.")
        return

    root_tree = Tree(f"[bold blue]{os.path.basename(root_dir)}/[/bold blue]")
    with console.status("[bold green]Scanning...[/bold green]"):
        _, total = add_to_tree(root_tree, root_dir, args.depth)

    root_tree.label = f"[bold blue]{os.path.basename(root_dir)}/[/bold blue] [green]({human_readable_size(total)})[/green]"
    console.print(root_tree)


if __name__ == "__main__":
    main()
