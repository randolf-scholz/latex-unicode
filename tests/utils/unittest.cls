% Description: Class for unit tests
%   Essentially a wrapper around the standalone class
%   Adds some default configurations

\ProvidesClass{unittest}[2024-12-13 Unit test class]
\tracinglostchars=3% error if a glyph is missing
\errorcontextlines=5% <-- useful for debugging
\LoadClass{standalone}
% load newunicodechar package with verbose
\RequirePackage[verbose]{newunicodechar}
\RequirePackage{booktabs}
\RequirePackage{multicol}
\usepackage{arydshln}

\AtBeginDocument{%
%
\ProvideDocumentCommand\textbb{m}{--}
\ProvideDocumentCommand\textcal{m}{--}
\ProvideDocumentCommand\textscr{m}{--}
\ProvideDocumentCommand\textbfscr{m}{--}
\ProvideDocumentCommand\textfrak{m}{--}
\ProvideDocumentCommand\textbffrak{m}{--}

\ProvideDocumentCommand\textbfit{m}{\textbf{\textit{#1}}}
\ProvideDocumentCommand\textsfit{m}{\textsf{\textit{#1}}}
\ProvideDocumentCommand\textbfsf{m}{\textbf{\textsf{#1}}}
\ProvideDocumentCommand\textbfsfit{m}{\textbf{\textsf{\textit{#1}}}}
\ProvideDocumentCommand\textcirc{m}{\textcircled{\footnotesize #1}}

\ProvideDocumentCommand\mathcirc{m}{\text{\textcirc{#1}}}
\ProvideDocumentCommand\mathbffrak{m}{\bm{\mathfrak{#1}}}
\ProvideDocumentCommand\mathbfscr{m}{\bm{\mathscr{#1}}}
\ProvideDocumentCommand\mathbfsf{m}{\bm{\mathsf{#1}}}
\ProvideDocumentCommand\mathbfsfit{m}{\bm{\mathsfit{#1}}}
\ProvideDocumentCommand\mathbfit{m}{\bm{\mathit{}}}

% Serif modifiers
\ProvideDocumentCommand\RM{m}{\ifmmode\mathrm{#1}\else\textrm{#1}\fi}
\ProvideDocumentCommand\IT{m}{\ifmmode\mathit{#1}\else\textit{#1}\fi}
\ProvideDocumentCommand\BF{m}{\ifmmode\mathbf{#1}\else\textbf{#1}\fi}
\ProvideDocumentCommand\BI{m}{\ifmmode\mathbfit{#1}\else\textbfit{#1}\fi}
% Sans-variants
\ProvideDocumentCommand\SF{m}{\ifmmode\mathsf{#1}\else\textsf{#1}\fi}
\ProvideDocumentCommand\ISF{m}{\ifmmode\mathsfit{#1}\else\textsfit{#1}\fi}
\ProvideDocumentCommand\BSF{m}{\ifmmode\mathbfsf{#1}\else\textbfsf{#1}\fi}
\ProvideDocumentCommand\BISF{m}{\ifmmode\mathbfsfit{#1}\else\textbfsfit{#1}\fi}
%
\ProvideDocumentCommand\NORMAL{m}{\ifmmode\mathnormal{#1}\else\textnormal{#1}\fi}
\ProvideDocumentCommand\TT{m}{\ifmmode\mathtt{#1}\else\texttt{#1}\fi}
\ProvideDocumentCommand\BB{m}{\ifmmode\mathbb{#1}\else\textbb{#1}\fi}
\ProvideDocumentCommand\CIRC{m}{\ifmmode\mathcirc{#1}\else\textcirc{#1}\fi}
%
\ProvideDocumentCommand\CAL{m}{\ifmmode\mathcal{#1}\else\textcal{#1}\fi}
\ProvideDocumentCommand\SCR{m}{\ifmmode\mathscr{#1}\else\textscr{#1}\fi}
\ProvideDocumentCommand\FRAK{m}{\ifmmode\mathfrak{#1}\else\textfrak{#1}\fi}
\ProvideDocumentCommand\BFRAK{m}{\ifmmode\mathbffrak{#1}\else\textbffrak{#1}\fi}
%
}




\RequirePackage{pgfkeys}
% SEE: https://en.wikipedia.org/wiki/Mathematical_Alphanumeric_Symbols
\DeclareKeys[variants]{%
	% text/math
	text.store=\rowTEXT,
	math.store=\rowMATH,
	% serif
	rm.store=\rowRM,
	bf.store=\rowBF,
	it.store=\rowIT,
	bi.store=\rowBI,
	% sans
	sf.store=\rowSF,
	bsf.store=\rowBSF,
	isf.store=\rowISF,
	bisf.store=\rowBISF,
	% fraktur
	frak.store=\rowFRAK,
	bfrak.store=\rowBFRAK,
	% scriptur
	scr.store=\rowSCR,
	cal.store=\rowCAL,
	% misc
	normal.store=\rowNORMAL,
	tt.store=\rowTT,
	bb.store=\rowBB,
	circ.store=\rowCIRC,
	% roman
	roman.store=\rowRoman,
	Roman.store=\rowROMAN,
	% sup- and superscript
	sub.store=\rowSUB,
	sup.store=\rowSUP,
}

\pgfkeys{%
/variants/.is family, /variants,
%
% NOTE: use gdef to allow usage in creating rows for tables
%
% text/math
text/.code={\gdef\rowTEXT{#1}},
math/.code={\gdef\rowMATH{#1}},
% serif
rm/.code={\gdef\rowRM{#1}},
bf/.code={\gdef\rowBF{#1}},
it/.code={\gdef\rowIT{#1}},
bi/.code={\gdef\rowBI{#1}},
% sans
sf/.code={\gdef\rowSF{#1}},
bsf/.code={\gdef\rowBSF{#1}},
isf/.code={\gdef\rowISF{#1}},
bisf/.code={\gdef\rowBISF{#1}},
% fraktur
frak/.code={\gdef\rowFRAK{#1}},
bfrak/.code={\gdef\rowBFRAK{#1}},
% scriptur
scr/.code={\gdef\rowSCR{#1}},
cal/.code={\gdef\rowCAL{#1}},
% misc
normal/.code={\gdef\rowNORMAL{#1}},
tt/.code={\gdef\rowTT{#1}},
bb/.code={\gdef\rowBB{#1}},
circ/.code={\gdef\rowCIRC{#1}},
% roman
roman/.code={\gdef\rowRoman{#1}},
Roman/.code={\gdef\rowROMAN{#1}},
% sup- and superscript
sub/.code={\gdef\rowSUB{#1}},
sup/.code={\gdef\rowSUP{#1}},
%
% Set the default values
%
default/.style={
	% text/math
	text=-,
	math=-,
	normal=-,
	% serif
	rm=-,
	bf=-,
	it=-,
	bi=-,
	% sans
	sf=-,
	bsf=-,
	isf=-,
	bisf=-,
	% scriptur
	scr=-,
	cal=-,
	% fraktur
	frak=-,
	bfrak=-,
	% misc
	tt=-,
	bb=-,
	circ=-,
	% roman
	roman=-,
	Roman=-
	% sub- and superscript
	sub=-,
	sup=-,
}%
}
