# Makefile for BLFS Book generation.
# By Tushar Teredesai <tushar@linuxfromscratch.org>
# 2004-01-31
# Adjust these to suit your installation
OUTPUTDIR = $(HOME)/public_html/blfs-book
INSTALL = install
JADE = openjade
DOCBOOK = /usr/share/sgml/docbook/dsssl-stylesheets-1.78
BASEDIR= $(HOME)/public_html/blfs-book-xsl/
TEXBASEDIR= $(HOME)/public_html/blfs-book-tex/

SRCDIR = $(PWD)

all: blfs

blfs-old: index.xml
	@if [ -z $(OUTPUTDIR) ]; then \
		echo "Envar OUTPUTDIR is not set!" ; \
		exit 1 ; \
		fi
	@echo "Generating HTML Version of BLFS Book with $(JADE)..."
	@echo "  OUTPUTDIR = $(OUTPUTDIR)"
	@$(INSTALL) -d $(OUTPUTDIR)
	@cd $(OUTPUTDIR) && $(INSTALL) -d introduction postlfs general \
		connect basicnet server content x kde gnome xsoft \
		multimedia pst preface appendices other
	@cd $(OUTPUTDIR) && $(JADE) -t sgml -D $(DOCBOOK)/html \
		-d $(SRCDIR)/blfs.dsl $(DOCBOOK)/dtds/decls/xml.dcl \
		$(SRCDIR)/index.xml

blfs:
	@if [ -z $(BASEDIR) ]; then \
		echo "Envar BASEDIR is not set!" ; \
		exit 1 ; \
		fi
	@echo "Generating XHTML Version of BLFS Book with xsltproc..."
	@echo "  BASEDIR = $(BASEDIR)"
	@$(INSTALL) -d $(BASEDIR)
	xsltproc --xinclude --nonet -stringparam base.dir $(BASEDIR) \
	  stylesheets/blfs-chunked.xsl index.xml
	if [ ! -e $(BASEDIR)stylesheets ]; then \
	  mkdir -p $(BASEDIR)stylesheets; \
	fi;
	cp stylesheets/*.css $(BASEDIR)stylesheets
	if [ ! -e $(BASEDIR)images ]; then \
	  mkdir -p $(BASEDIR)images; \
	fi;
	cp images/*.png $(BASEDIR)/images
	cd $(BASEDIR); sed -i -e "s@../stylesheets@stylesheets@" \
	  index.html 
	cd $(BASEDIR); sed -i -e "s@../images@images@g" \
	  index.html 
	sh goTidy $(BASEDIR)/  

pdf:
	xsltproc --xinclude --nonet --output blfs.fo \
	stylesheets/blfs-pdf.xsl \
	  index.xml
	sed -i -e "s/inherit/all/" blfs.fo
	/opt/fop/fop.sh blfs.fo blfs.pdf
	$(INSTALL) -d $(BASEDIR)pdf
	rm blfs.fo
	mv blfs.pdf $(BASEDIR)pdf

print:
	xsltproc --xinclude --nonet --output blfs-print.fo \
	stylesheets/blfs-print.xsl index.xml
	sed -i -e "s/inherit/all/" blfs-print.fo
	/opt/fop/fop.sh blfs-print.fo blfs-print.pdf
	$(INSTALL) -d $(BASEDIR)print
	rm blfs-print.fo
	mv blfs-print.pdf $(BASEDIR)print

tex:
	@if [ -z $(TEXBASEDIR) ]; then \
                echo "Envar TEXBASEDIR is not set!" ; \
                exit 1 ; \
                fi
	@echo "Generating TeX Version of BLFS Book with xsltproc..."
	@echo "  TEXBASEDIR = $(TEXBASEDIR)"
	@$(INSTALL) -d $(TEXBASEDIR)
# Using profiles in book source to exclude parts of the book from TeX
# i.e., Changelog
	xsltproc --nonet --output $(TEXBASEDIR)index.xml \
	--stringparam "profile.role" "book" \
	http://docbook.sourceforge.net/release/xsl/current/profiling/profile.xsl \
	index.xml
	@cd $(TEXBASEDIR) && xsltproc --nonet -o blfs-book.tex \
	$(SRCDIR)/stylesheets/blfs-tex.xsl index.xml

validate:
# --noent prevents resolving linkend (remove when xinclude fully
# implemented)
	xmllint --noout --nonet --noent --xinclude --postvalid index.xml
