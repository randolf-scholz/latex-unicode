# latexmkrc - Project-specific configuration file
use Cwd;
print "Loading .latexmkrc from ".getcwd."\n";

# Set the TEXMFHOME environment variable to the project's texmf folder
$ENV{'TEXMFHOME'}=getcwd.'/texmf/';
print "TEXMFHOME: ".$ENV{'TEXMFHOME'}."\n";

# # Set output and auxiliary directories
# $out_dir = getcwd.'/.build/';   # Output directory relative to the project root
# $aux_dir = getcwd.'/.build/';   # Auxiliary directory relative to the project root

# print "Output directory: $out_dir\n";

# # change to the project root directory
# $do_cd = 1;

# # Use pdflatex with specific options
# $pdf_mode = 1;

# # Use biber for bibliography
# $bibtex_use = 1;

# # summary of warnings
# $silence_logfile_warnings=0;
