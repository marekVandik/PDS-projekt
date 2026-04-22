# Author: Marek Vandík
# 13. 4. 2026


doc: doc.ps
	ps2pdf -sPAPERSIZE=a4 $^ doc.pdf

doc.ps: doc.dvi
	dvips -t a4 $^ -o doc.ps

doc.dvi: doc.tex
	latex  doc
	bibtex doc
	latex  doc
	latex  doc

clean:
	rm doc.ps doc.dvi doc.aux doc.log doc.out doc.toc doc.blg doc.bbl
