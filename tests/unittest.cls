% Description: Class for unit tests
%   Essentially a wrapper around the standalone class
%   Adds some default configurations

\ProvidesClass{unittest}[2024-12-13 Unit test class]
\tracinglostchars=3% error if a glyph is missing
\errorcontextlines=5% <-- useful for debugging
\LoadClass{standalone}

% load newunicodechar package with verbose
\RequirePackage[verbose]{newunicodechar}
