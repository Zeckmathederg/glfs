# Makefile for BLFS Book generation.
# By Tushar Teredesai <tushar@linuxfromscratch.org>
# 2004-01-31
# $LastChangedBy$
# $Date$

# Adjust these to suit your installation
BASEDIR= $(HOME)/public_html/blfs-book-xsl
DUMPDIR= $(HOME)/blfs-commands
CHUNK_QUIET=1
ROOT_ID=""
PDF_OUTPUT=BLFS-BOOK.pdf
NOCHUNKS_OUTPUT=BLFS-BOOK.html

ifdef V
  Q =
else
  Q = @
endif

blfs: validxml profile-html
	@echo "Generating chunked XHTML files..."
	$(Q)xsltproc --nonet -stringparam chunk.quietly $(CHUNK_QUIET) \
	  -stringparam rootid $(ROOT_ID) -stringparam base.dir $(BASEDIR)/ \
	  stylesheets/blfs-chunked.xsl /tmp/blfs-html.xml

	@echo "Copying CSS code and images..."
	$(Q)if [ ! -e $(BASEDIR)/stylesheets ]; then \
	  mkdir -p $(BASEDIR)/stylesheets; \
	fi;
	$(Q)cp stylesheets/lfs-xsl/*.css $(BASEDIR)/stylesheets
	$(Q)if [ ! -e $(BASEDIR)/images ]; then \
	  mkdir -p $(BASEDIR)/images; \
	fi;
	$(Q)cp images/*.png $(BASEDIR)/images
	$(Q)cd $(BASEDIR)/; sed -i -e "s@../stylesheets@stylesheets@g" *.html
	$(Q)cd $(BASEDIR)/; sed -i -e "s@../images@images@g" *.html

	@echo "Running Tidy and obfuscate.sh..."
	$(Q)for filename in `find $(BASEDIR) -name "*.html"`; do \
	  tidy -config tidy.conf $$filename; \
	  true; \
	  sh obfuscate.sh $$filename; \
	  sed -i -e "s@text/html@application/xhtml+xml@g" $$filename; \
	done;

pdf: validxml
	@echo "Generating profiled XML for PDF..."
	$(Q)xsltproc --nonet --stringparam profile.condition pdf \
	  --output /tmp/blfs-pdf.xml stylesheets/lfs-xsl/profile.xsl \
	  /tmp/blfs-full.xml

	@echo "Generating FO file..."
	$(Q)xsltproc --nonet -stringparam rootid $(ROOT_ID) \
	  --output /tmp/blfs-pdf.fo stylesheets/blfs-pdf.xsl /tmp/blfs-pdf.xml
	$(Q)sed -i -e 's/span="inherit"/span="all"/' /tmp/blfs-pdf.fo

	@echo "Generating PDF file..."
	$(Q)if [ ! -e $(BASEDIR) ]; then \
	  mkdir -p $(BASEDIR); \
	fi;
	$(Q)fop /tmp/blfs-pdf.fo $(BASEDIR)/$(PDF_OUTPUT)

nochunks: validxml profile-html
	@echo "Generating non chunked XHTML file..."
	$(Q)xsltproc --nonet -stringparam profile.condition html \
	  -stringparam rootid $(ROOT_ID) --output $(BASEDIR)/$(NOCHUNKS_OUTPUT) \
	  stylesheets/blfs-nochunks.xsl /tmp/blfs-html.xml

	@echo "Running Tidy..."
	$(Q)tidy -config tidy.conf $(BASEDIR)/$(NOCHUNKS_OUTPUT) || true
	@echo "Running obfuscate.sh..."
	$(Q)sh obfuscate.sh $(BASEDIR)/$(NOCHUNKS_OUTPUT)
	$(Q)sed -i -e "s@text/html@application/xhtml+xml@g"  \
	  $(BASEDIR)/$(NOCHUNKS_OUTPUT)

validxml:
	@echo "Validating the book..."
	$(Q)xmllint --nonet --noent --xinclude --postvalid \
	  -o /tmp/blfs-full.xml index.xml

profile-html: validxml
	@echo "Generating profiled XML for XHTML..."
	$(Q)xsltproc --nonet --stringparam profile.condition html \
	  --output /tmp/blfs-html.xml stylesheets/lfs-xsl/profile.xsl \
	  /tmp/blfs-full.xml

blfs-patch-list: validxml
	@echo "Generating blfs-patch-list..."
	$(Q)xsltproc --nonet --output /tmp/blfs-patch-list \
	  stylesheets/patcheslist.xsl /tmp/blfs-full.xml
	$(Q)sed -e "s|^.*/||" /tmp/blfs-patch-list > /tmp/blfs-patches
	$(Q)sort /tmp/blfs-patches > blfs-patch-list

wget-list: validxml
	@echo "Generating wget list..."
	$(Q)mkdir -p $(BASEDIR)
	$(Q)xsltproc --nonet --output $(BASEDIR)/wget-list \
	  stylesheets/wget-list.xsl /tmp/blfs-full.xml

test-links: validxml
	@echo "Generating test-links file..."
	$(Q)mkdir -p $(BASEDIR)
	$(Q)xsltproc --nonet --stringparam list_mode full \
	  --output $(BASEDIR)/test-links stylesheets/wget-list.xsl \
	  /tmp/blfs-full.xml

	@echo "Checking URLs, first pass..."
	$(Q)rm -f $(BASEDIR)/{good,bad,true_bad}_urls
	$(Q)for URL in `cat $(BASEDIR)/test-links`; do \
	    wget --spider --tries=2 --timeout=60 $$URL >>/dev/null 2>&1; \
	    if test $$? -ne 0 ; then echo $$URL >> $(BASEDIR)/bad_urls ; \
	    else echo $$URL >> $(BASEDIR)/good_urls 2>&1; \
	    fi; \
	done

	@echo "Checking URLs, second pass..."
	$(Q)for URL2 in `cat $(BASEDIR)/bad_urls`; do \
	    wget --spider --tries=2 --timeout=60 $$URL2 >>/dev/null 2>&1; \
	    if test $$? -ne 0 ; then echo $$URL2 >> $(BASEDIR)/true_bad_urls ; \
	    else echo $$URL2 >> $(BASEDIR)/good_urls 2>&1; \
	    fi; \
	done

dump-commands: validxml
	@echo "Dumping book commands..."
	$(Q)xsltproc --output $(DUMPDIR)/ \
	   stylesheets/dump-commands.xsl /tmp/blfs-full.xml

validate:
	@echo "Validating the book..."
	$(Q)xmllint --noout --nonet --xinclude --postvalid index.xml

all: blfs nochunks pdf

world: all blfs-patch-list dump-commands wget-list test-links

.PHONY : all blfs blfs-patch-list dump-commands nochunks pdf profile-html \
	 test-links validate validxml wget-list world
