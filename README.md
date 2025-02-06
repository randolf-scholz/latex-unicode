# `unicode-symbols` package

[Usage](#usage) | [Installation](#installation) | [Changelog](CHANGELOG.md) | [License](LICENSE)

This package provides a long list of Unicode symbols to be used with LaTeX.
It is designed to work both with `pdflatex` and `lualatex`. `xelatex` is not officially supported.

## Usage

To use the package, simply include it in your LaTeX document:

```tex
\documentclass{article}
\usepackage{unicode-symbols}
\begin{document}
$$ ϕ(x+∆x) ≈ ϕ(x) + ⟨∇ₓϕ(x) ∣ ∆x⟩ $$
\end{document}
```

## Installation

### 1. Global Installation

```bash
just install  # quick and dirty
```

```bash
./install.py --copy  # recommended
```

This will **copy** the files into your `$TEXMFHOME` directory (typically `~/texmf`), making them available to all your LaTeX projects.

### 2. Local Installation (e.g. for a specific project)

```bash
cd /path/to/your/project
git submodule add https://github.com/randolf-scholz/latex-unicode
./latex-unicode/install.py .  # creates texmf/ in your project directory
```

This will **symlink** the files into a local `texmf` directory of the current project,
so that you automatically get the latest version of the package when you update the submodule.

In order for $\LaTeX$ to use the local `texmf` directory, you need to set the `TEXMFHOME` environment variable to the correct path.

When compiling manually, use:

```bash
export TEXMFHOME=$PWD/texmf
pdflatex document.tex
```

When using `latexmk` / `OverLeaf`, simply add the following line to your `.latexmkrc` file:

```perl
use Cwd;
$ENV{'TEXMFHOME'}=getcwd.'/texmf/';
```

## Contents

- `unicode-symbols.sty`: The main package file.
  - `\circled{char}`: A command to create circled symbols.
  - `\romannumber{number}` and `\RomanNumber{number}`: Commands to create roman numerals.
- `unicode-subscripts.sty`: Provides the `\subscript` command, which enables the use of multiple subscripts.
- `unicode-superscripts.sty`: Provides the `\superscript` command, which enables the use of multiple superscripts.

## Changelog
