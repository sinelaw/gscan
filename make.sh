lhs2TeX $1.lhs  -o $1.tex && pdflatex -halt-on-error -file-line-error $1.tex ; bibtex $1 && pdflatex $1.tex ; pdflatex $1.tex ; 
