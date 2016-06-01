# Makefile for BLFS Book generation.
# By Tushar Teredesai <tushar@linuxfromscratch.org>
# 2004-01-31
# $LastChangedBy$
# $Date$

# Adjust these to suit your installation
RENDERTMP   ?= $(HOME)/tmp
CHUNK_QUIET  = 1
ROOT_ID      =
SHELL        = /bin/bash

ALLXML := $(filter-out $(RENDERTMP)/%, \
	$(wildcard *.xml */*.xml */*/*.xml */*/*/*.xml */*/*/*/*.xml))
ALLXSL := $(filter-out $(RENDERTMP)/%, \
	$(wildcard *.xsl */*.xsl */*/*.xsl */*/*/*.xsl */*/*/*/*.xsl))

ifdef V
  Q =
else
  Q = @
endif

ifndef REV
  REV = sysv
endif

ifneq ($(REV), sysv)
  ifneq ($(REV), systemd)
    $(error REV must be 'sysv' (default) or 'systemd'.)
  endif
endif

ifeq ($(REV), sysv)
  BASEDIR         ?= $(HOME)/public_html/blfs-book
  NOCHUNKS_OUTPUT ?= blfs-book.html
  DUMPDIR         ?= ~/blfs-commands
else
  BASEDIR         ?= $(HOME)/public_html/blfs-systemd
  NOCHUNKS_OUTPUT ?= blfs-sysd-book.html
  DUMPDIR         ?= ~/blfs-sysd-commands
endif


blfs: html wget-list

all: blfs nochunks
world: all blfs-patch-list dump-commands test-links

html: $(BASEDIR)/index.html
$(BASEDIR)/index.html: $(RENDERTMP)/blfs-html.xml
	@echo "Generating chunked XHTML files..."
	$(Q)xsltproc --nonet                                    \
                --stringparam chunk.quietly $(CHUNK_QUIET) \
                --stringparam rootid "$(ROOT_ID)"          \
                --stringparam base.dir $(BASEDIR)/         \
                stylesheets/blfs-chunked.xsl               \
                $(RENDERTMP)/blfs-html.xml

	@echo "Copying CSS code and images..."
	$(Q)if [ ! -e $(BASEDIR)/stylesheets ]; then \
      mkdir -p $(BASEDIR)/stylesheets;          \
   fi;

	$(Q)cp stylesheets/lfs-xsl/*.css $(BASEDIR)/stylesheets

	$(Q)if [ ! -e $(BASEDIR)/images ]; then \
      mkdir -p $(BASEDIR)/images;          \
   fi;
	$(Q)cp images/*.png $(BASEDIR)/images

	$(Q)cd $(BASEDIR)/; sed -e "s@../stylesheets@stylesheets@g" \
                           -e "s@../images@images@g"           \
                           -i *.html

	@echo "Running Tidy and obfuscate.sh on chunked XHTML..."
	$(Q)for filename in `find $(BASEDIR) -name "*.html"`; do       \
      tidy -config tidy.conf $$filename;                          \
      true;                                                       \
      bash obfuscate.sh $$filename;                               \
      sed -i -e "s@text/html@application/xhtml+xml@g" $$filename; \
   done;

nochunks: $(BASEDIR)/$(NOCHUNKS_OUTPUT)
$(BASEDIR)/$(NOCHUNKS_OUTPUT): $(RENDERTMP)/blfs-html.xml
	@echo "Generating non-chunked XHTML file..."
	$(Q)xsltproc --nonet                                \
                --stringparam rootid "$(ROOT_ID)"      \
                --output $(BASEDIR)/$(NOCHUNKS_OUTPUT) \
                stylesheets/blfs-nochunks.xsl          \
                $(RENDERTMP)/blfs-html.xml

	@echo "Running Tidy and obfuscate.sh on non-chunked XHTML..."
	$(Q)tidy -config tidy.conf $(BASEDIR)/$(NOCHUNKS_OUTPUT) || true
	$(Q)bash obfuscate.sh $(BASEDIR)/$(NOCHUNKS_OUTPUT)
	$(Q)sed -i -e "s@text/html@application/xhtml+xml@g" $(BASEDIR)/$(NOCHUNKS_OUTPUT)

tmpdir: $(RENDERTMP)
$(RENDERTMP):
	@echo "Creating $(RENDERTMP)"
	$(Q)[ -d $(RENDERTMP) ] || mkdir -p $(RENDERTMP)

clean:
	@echo "Cleaning $(RENDERTMP)"
	$(Q)rm -f $(RENDERTMP)/blfs-{full,html}.xml
	$(Q)rm -f $(RENDERTMP)/blfs-{patch-list,patches}

validate: $(RENDERTMP)/blfs-full.xml
$(RENDERTMP)/blfs-full.xml: general.ent $(ALLXML) $(ALLXSL)
	$(Q)[ -d $(RENDERTMP) ] || mkdir -p $(RENDERTMP)

	@echo "Adjusting for revision $(REV)..."
	$(Q)xsltproc --nonet                               \
                --xinclude                            \
                --output $(RENDERTMP)/blfs-html2.xml  \
                --stringparam profile.revision $(REV) \
                stylesheets/lfs-xsl/profile.xsl       \
                index.xml

	@echo "Validating the book..."
	$(Q)xmllint --nonet                             \
               --noent                             \
               --postvalid                         \
               --output $(RENDERTMP)/blfs-full.xml \
               $(RENDERTMP)/blfs-html2.xml

profile-html: $(RENDERTMP)/blfs-html.xml
$(RENDERTMP)/blfs-html.xml: $(RENDERTMP)/blfs-full.xml
	@echo "Generating profiled XML for XHTML..."
	$(Q)xsltproc --nonet                              \
                --stringparam profile.condition html \
                --output $(RENDERTMP)/blfs-html.xml  \
                stylesheets/lfs-xsl/profile.xsl      \
                $(RENDERTMP)/blfs-full.xml

blfs-patch-list: blfs-patches.sh
	@echo "Generating blfs patch list..."
	$(Q)awk '{if ($$1 == "copy") {sub(/.*\//, "", $$2); print $$2}}' \
	  blfs-patches.sh > blfs-patch-list

blfs-patches.sh: $(RENDERTMP)/blfs-full.xml
	@echo "Generating blfs patch script..."
	$(Q)xsltproc --nonet                     \
                --output blfs-patches.sh    \
                stylesheets/patcheslist.xsl \
                $(RENDERTMP)/blfs-full.xml

wget-list: $(BASEDIR)/wget-list
$(BASEDIR)/wget-list: $(RENDERTMP)/blfs-full.xml
	@echo "Generating wget list for $(REV) at $(BASEDIR)/wget-list ..."
	$(Q)mkdir -p $(BASEDIR)
	$(Q)xsltproc --nonet                       \
                --output $(BASEDIR)/wget-list \
                stylesheets/wget-list.xsl     \
                $(RENDERTMP)/blfs-full.xml

test-links: $(BASEDIR)/test-links
$(BASEDIR)/test-links: $(RENDERTMP)/blfs-full.xml
	@echo "Generating test-links file..."
	$(Q)mkdir -p $(BASEDIR)
	$(Q)xsltproc --nonet                        \
                --stringparam list_mode full   \
                --output $(BASEDIR)/test-links \
                stylesheets/wget-list.xsl      \
                $(RENDERTMP)/blfs-full.xml

	@echo "Checking URLs, first pass..."
	$(Q)rm -f $(BASEDIR)/{good,bad,true_bad}_urls
	$(Q)for URL in `cat $(BASEDIR)/test-links`; do                     \
         wget --spider --tries=2 --timeout=60 $$URL >>/dev/null 2>&1; \
         if test $$? -ne 0 ; then                                     \
            echo $$URL >> $(BASEDIR)/bad_urls ;                       \
         else                                                         \
            echo $$URL >> $(BASEDIR)/good_urls 2>&1;                  \
         fi;                                                          \
   done

	@echo "Checking URLs, second pass..."
	$(Q)for URL2 in `cat $(BASEDIR)/bad_urls`; do                       \
         wget --spider --tries=2 --timeout=60 $$URL2 >>/dev/null 2>&1; \
         if test $$? -ne 0 ; then                                      \
           echo $$URL2 >> $(BASEDIR)/true_bad_urls ;                   \
         else                                                          \
           echo $$URL2 >> $(BASEDIR)/good_urls 2>&1;                   \
         fi; \
   done

bootscripts:
	@VERSION=`grep "bootscripts-version " general.ent | cut -d\" -f2`; \
   BOOTSCRIPTS="blfs-bootscripts-$$VERSION";                          \
   if [ ! -e $$BOOTSCRIPTS.tar.xz ]; then                             \
     rm -rf $(RENDERTMP)/$$BOOTSCRIPTS;                               \
     mkdir $(RENDERTMP)/$$BOOTSCRIPTS;                                \
     cp -a ../bootscripts/* $(RENDERTMP)/$$BOOTSCRIPTS;               \
     rm -rf ../bootscripts/archive;                                   \
     tar  -cJhf $$BOOTSCRIPTS.tar.xz -C $(RENDERTMP) $$BOOTSCRIPTS;   \
   fi

dump-commands: $(DUMPDIR)
$(DUMPDIR): $(RENDERTMP)/blfs-full.xml
	@echo "Dumping book commands..."
	$(Q)xsltproc --output $(DUMPDIR)/          \
                stylesheets/dump-commands.xsl \
                $(RENDERTMP)/blfs-full.xml
	$(Q)touch $(DUMPDIR)

.PHONY: blfs all world html nochunks tmpdir clean  \
   validate profile-html blfs-patch-list wget-list test-links \
   dump-commands  bootscripts


