# `unicode-symbols` package

[Usage](#usage) | [Installation](#installation) | [Changelog](#changelog) | [Contents](#contents) |

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

There are two options to install the package:

### 1. Global Installation

  ```bash
  ./install.py
  ```

This will copy the files into your `$TEXMFHOME` directory (usually `~/texmf`), making them available to all your LaTeX projects.

### 2. Local Installation

```bash
./install.py .  # creates texmf/ in the current directory
```

This will copy the files into a local `texmf` directory of the current project.
In order for LaTeX to use the local `texmf` directory, you need to set the `TEXMFHOME` environment variable to the correct path.

```bash
TEXMFHOME=$(pwd)/texmf pdlatex document.tex
```

Or, when using `latexmk` / `OverLeaf`, simply add the following line to your `.latexmkrc` file:

```perl
use Cwd;
$ENV{'TEXMFHOME'}=getcwd.'/texmf/';
```

### 3. Manual Installation

Copy the files from `src/` to your project directory.

## Contents

- `unicode-symbols.sty`: The main package file.
  - `\circled{char}`: A command to create circled symbols.
  - `\romannumber{number}` and `\RomanNumber{number}`: Commands to create roman numerals.
- `unicode-subscripts.sty`: Provides the `\subscript` command, which enables the use of multiple subscripts.
- `unicode-superscripts.sty`: Provides the `\superscript` command, which enables the use of multiple superscripts.

## Changelog
