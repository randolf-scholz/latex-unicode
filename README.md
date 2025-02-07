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

## Pre-commit Hooks

This package comes with a number of pre-commit hooks that can be used to enforce the use of Unicode symbols in $\LaTeX$ documents.

- [`latex-unicode-base`](docs/hooks.md#unicode-base): Checks that Unicode is used for basic $\LaTeX$ symbols, like `∇` instead of `\nabla`.
- [`latex-unicode-greek`](docs/hooks.md#unicode-greek): Checks that Unicode Greek letters are used.
- [`latex-unicode-subscripts`](docs/hooks.md#unicode-subscripts): Checks that Unicode subscripts are used.
- [`latex-unicode-superscripts`](docs/hooks.md#unicode-superscripts): Checks that Unicode superscripts are used.
- [`latex-unicode-integrals`](docs/hooks.md#unicode-integrals): Checks that Unicode integrals are used.
- [`latex-unicode-quotes`](docs/hooks.md#unicode-quotes): Checks that Unicode quotes are used.
- [`latex-unicode-transpose`](docs/hooks.md#unicode-transpose): Checks that `𞁀` (modifier letter cyrillic small te (U+1E040)) is used for transpose
- [`latex-unicode-hermitian`](docs/hooks.md#unicode-hermitian): Checks that `ᵸ` (modifier letter cyrillic en (U+1D78)) is used for hermitian

## Contents

- `unicode-symbols.sty`: The main package file.
  - `\circled{char}`: A command to create circled symbols.
  - `\romannumber{number}` and `\RomanNumber{number}`: Commands to create roman numerals.
- `unicode-subscripts.sty`: Provides the `\subscript` command, which enables the use of multiple subscripts.
- `unicode-superscripts.sty`: Provides the `\superscript` command, which enables the use of multiple superscripts.

## Changelog
