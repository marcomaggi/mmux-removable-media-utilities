## Process this file with automake to produce Makefile.in

ACLOCAL_AMFLAGS		= -I meta/autotools
EXTRA_DIST		= INSTALL configure.sh
dist_doc_DATA		= README COPYING

## --------------------------------------------------------------------

AM_MAKEINFOFLAGS	= --no-split

info_TEXINFOS		= doc/mmux-removable-media-utilities.texi
doc_mmux_removable_media_utilities_TEXINFOS	= \
	doc/fdl-1.3.texi			\
	doc/gpl-3.0.texi			\
	doc/macros.texi

## --------------------------------------------------------------------

sudoersdir		= $(sysconfdir)/sudoers.d
dist_sudoers_DATA	= src/etc/sudoers.d/mmux-removable-media-utilities.conf

## --------------------------------------------------------------------

completionsdir		= $(sysconfdir)/bash_completion.d
dist_completions_SCRIPTS= \
	src/completions/pendrive.bash		\
	src/completions/cdrom.bash		\
	src/completions/floppy-disk.bash

#page
#### scripts

EXTRA_DIST		+= \
	src/bin/pendrive.m4		\
	src/bin/cdrom.m4		\
	src/bin/floppy-disk.m4

dist_bin_SCRIPTS	= \
	src/bin/pendrive		\
	src/bin/cdrom			\
	src/bin/floppy-disk

MBFLPP_FLAGS		= --preserve-comments

src/bin/pendrive : src/bin/pendrive.m4
	test -d src/bin || $(MKDIR_P) src/bin
	$(MBFLPP) $(MBFLPP_FLAGS) <$< >$@

src/bin/cdrom : src/bin/cdrom.m4
	test -d src/bin || $(MKDIR_P) src/bin
	$(MBFLPP) $(MBFLPP_FLAGS) <$< >$@

src/bin/floppy-disk : src/bin/floppy-disk.m4
	test -d src/bin || $(MKDIR_P) src/bin
	$(MBFLPP) $(MBFLPP_FLAGS) <$< >$@

CLEANFILES		= src/bin/pendrive src/bin/cdrom src/bin/floppy-disk

### end of file
