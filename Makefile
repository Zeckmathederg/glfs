# Makefile for BLFS Book generation.
# By Tushar Teredesai <tushar@linuxfromscratch.org>
# 2004-01-31
# $LastChangedBy$
# $Date$
# Adjust these to suit your installation
OUTPUTDIR = $(HOME)/public_html/blfs-book
DUMPDIR= $(HOME)/blfs-commands
INSTALL = install
JADE = openjade
DOCBOOK = /usr/share/sgml/docbook/dsssl-stylesheets-1.78
BASEDIR= $(HOME)/public_html/blfs-book-xsl
TEXBASEDIR= $(HOME)/public_html/blfs-book-tex
NOCHUNKS_OUTPUT=BLFS-BOOK.html
SRCDIR = $(PWD)

all: blfs

blfs:
	@if [ -z $(BASEDIR) ]; then \
		echo "Envar BASEDIR is not set!" ; \
		exit 1 ; \
	fi
	@echo "Generating XHTML Version of BLFS Book with xsltproc..."
	@echo "  BASEDIR = $(BASEDIR)"
	@$(INSTALL) -d $(BASEDIR)
	xsltproc --xinclude --nonet -stringparam base.dir $(BASEDIR)/ \
	  stylesheets/blfs-chunked.xsl index.xml
	if [ ! -e $(BASEDIR)/stylesheets ]; then \
	  mkdir -p $(BASEDIR)/stylesheets; \
	fi;
	cp stylesheets/*.css $(BASEDIR)/stylesheets
	if [ ! -e $(BASEDIR)/images ]; then \
	  mkdir -p $(BASEDIR)/images; \
	fi;
	cp images/*.png $(BASEDIR)/images
	cd $(BASEDIR); sed -i -e "s@../stylesheets@stylesheets@g" *.html
	cd $(BASEDIR); sed -i -e "s@../images@images@g" *.html

	for filename in `find $(BASEDIR) -name "*.html"`; do \
	  tidy -config tidy.conf $$filename; \
	  true; \
	  sh obfuscate.sh $$filename; \
	  sed -i -e "s@text/html@application/xhtml+xml@g" $$filename; \
	done;


nochunks:
	@echo "Generating nochunks version of BLFS..."
	xsltproc --xinclude --nonet -stringparam profile.condition html \
        --output $(BASEDIR)/$(NOCHUNKS_OUTPUT) \
        stylesheets/blfs-nochunks.xsl index.xml

	tidy -config tidy.conf $(BASEDIR)/$(NOCHUNKS_OUTPUT) || true

	sh obfuscate.sh $(BASEDIR)/$(NOCHUNKS_OUTPUT)

	sed -i -e "s@text/html@application/xhtml+xml@g"  \
          $(BASEDIR)/$(NOCHUNKS_OUTPUT)

pdf:
	xsltproc --xinclude --nonet --stringparam profile.condition pdf \
             --output blfs-pdf.xml stylesheets/blfs-profile.xsl index.xml
	xsltproc --xinclude --nonet --output blfs.fo \
	         stylesheets/blfs-pdf.xsl blfs-pdf.xml
	sed -i -e "s/inherit/all/" blfs.fo
	fop.sh blfs.fo blfs.pdf
	$(INSTALL) -d $(BASEDIR)/pdf
	rm blfs.fo
	mv blfs.pdf $(BASEDIR)/pdf

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
	xsltproc --nonet --output $(TEXBASEDIR)/index.xml \
    	--stringparam "profile.role" "book" \
	http://docbook.sourceforge.net/release/xsl/current/profiling/profile.xsl \
	    index.xml
	@cd $(TEXBASEDIR) && xsltproc --nonet -o blfs-book.tex \
	    $(SRCDIR)/stylesheets/blfs-tex.xsl index.xml

dump-commands:
	xsltproc --xinclude --nonet --output $(DUMPDIR)/ \
	   stylesheets/dump-commands.xsl index.xml

validate:
	xmllint --noout --nonet --xinclude --postvalid index.xml

validate-pdf:
	xsltproc --xinclude --nonet --stringparam profile.condition pdf \
             --output blfs-pdf.xml stylesheets/blfs-profile.xsl index.xml
	xmllint --noout --nonet --postvalid blfs-pdf.xml

blfs-patch-list:
	@echo "Generating blfs-patch-list..."
	xsltproc --xinclude --nonet \
             --output blfs-patch-list stylesheets/patcheslist.xsl index.xml
	sed -e "s|^.*/||" blfs-patch-list > blfs-patches
	sort blfs-patches > blfs-patch-list
	rm blfs-patches

wget-list:
	mkdir -p $(BASEDIR)
	xsltproc --xinclude --nonet stylesheets/wget-list.xsl index.xml > $(BASEDIR)/wget-list

test-links:
	mkdir -p $(BASEDIR)
	xsltproc --xinclude --nonet --stringparam list_mode full \
	    stylesheets/wget-list.xsl index.xml > $(BASEDIR)/test-links
	rm -f $(BASEDIR)/{good,bad,true_bad}_urls
	for URL in `cat $(BASEDIR)/test-links`; do \
	    wget --spider --tries=2 --timeout=60 $$URL >>/dev/null 2>&1; \
	    if test $$? -ne 0 ; then echo $$URL >> $(BASEDIR)/bad_urls ; \
	    else echo $$URL >> $(BASEDIR)/good_urls 2>&1; \
	    fi; \
	done
	for URL2 in `cat $(BASEDIR)/bad_urls`; do \
	    wget --spider --tries=2 --timeout=60 $$URL2 >>/dev/null 2>&1; \
	    if test $$? -ne 0 ; then echo $$URL2 >> $(BASEDIR)/true_bad_urls ; \
	    else echo $$URL2 >> $(BASEDIR)/good_urls 2>&1; \
	    fi; \
	done

.PHONY : blfs-patch-list wget-list test-links
