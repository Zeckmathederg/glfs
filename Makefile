# Makefile for BLFS Book generation.
# By Tushar Teredesai <tushar@linuxfromscratch.org>
# 2004-01-31
# Adjust these to suit your installation
OUTPUTDIR = $(HOME)/public_html/blfs-book
INSTALL = install
JADE = openjade
DOCBOOK = /usr/share/sgml/docbook/dsssl-stylesheets-1.78

SRCDIR = $(PWD)

all: index.xml
	@if [ -z $(OUTPUTDIR) ]; then \
		echo "Envar OUTPUTDIR is not set!" ; \
		exit 1 ; \
		fi
	@echo "Generating HTML Version of BLFS Book..."
	@echo "  OUTPUTDIR = $(OUTPUTDIR)"
	@$(INSTALL) -d $(OUTPUTDIR)
	@cd $(OUTPUTDIR) && $(INSTALL) -d introduction postlfs general \
		connect basicnet server content x kde gnome xsoft \
		multimedia pst preface appendices other
	@cd $(OUTPUTDIR) && $(JADE) -t sgml -d $(DOCBOOK)/html/lfs.dsl \
		$(DOCBOOK)/dtds/decls/xml.dcl $(SRCDIR)/index.xml
