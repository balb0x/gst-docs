all:

install:

clean:

HOTDOC ?= hotdoc
prefix ?= /usr
datadir ?= ${prefix}/share
devhelpdir ?= ${datadir}/devhelp/books
docdir ?= ${datadir}/doc/${PACKAGE}
htmldir ?= ${docdir}

# emulate Automake well enough for hotdoc.mk
AM_V_GEN ?=
AMTAR ?= tar
mkinstalldirs ?= install -d
srcdir = $(CURDIR)
top_srcdir = $(CURDIR)
builddir = $(CURDIR)
top_builddir = $(CURDIR)

HOTDOC_PROJECTS = gst-docs

gst_docs_HOTDOC_FLAGS = \
	--conf-file hotdoc.json \
	$(NULL)

theme/theme.stamp: theme/less/variables.less
	+make -C theme/hotdoc_bootstrap_theme LESS_INCLUDE_PATH=$$PWD/theme/less
	@rm -rf hotdoc-private*
	@touch theme/theme.stamp

clean_theme:
	rm -f theme/theme.stamp
	+make -C theme/hotdoc_bootstrap_theme clean

clean: clean_theme

gst_docs_HOTDOC_EXTRA_DEPS = theme/theme.stamp

.PHONY: all install clean

-include $(shell $(HOTDOC) --makefile-path)

# These variables define the location of the online docs
#
# If your local username and your fdo username differ, you
# will need to add an entry for gstreamer.freedesktop.org
# in your ~/.ssh/config with the right username for the server.
#
# DOC_SERVER = people.freedesktop.org
# DOC_BASE = public_html/gst-docs
DOC_SERVER = gstreamer.freedesktop.org
DOC_BASE = /srv/gstreamer.freedesktop.org/public_html/documentation2

# The local build directory with the generated HTML output
BUILT_DOC_DIR = $(builddir)/built_doc/html/

upload: all
	rsync -rvaz -e ssh --links --delete $(BUILT_DOC_DIR) $(DOC_SERVER):$(DOC_BASE)
	ssh $(DOC_SERVER) "chmod -R g+w $(DOC_BASE); chgrp -R gstreamer $(DOC_BASE)"
