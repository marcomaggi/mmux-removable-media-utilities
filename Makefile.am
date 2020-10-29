## Process this file with automake to produce Makefile.in

ACLOCAL_AMFLAGS		= -I meta/autotools
EXTRA_DIST		= INSTALL configure.sh
dist_doc_DATA		= README COPYING
CLEANFILES		=


#### documentation

AM_MAKEINFOFLAGS	= --no-split

info_TEXINFOS		= doc/mmux-removable-media-utilities.texi
doc_mmux_removable_media_utilities_TEXINFOS	= \
	doc/fdl-1.3.texi			\
	doc/gpl-3.0.texi			\
	doc/macros.texi

dist_man_MANS		=		\
	doc/cdrom.1			\
	doc/floppy-disk.1		\
	doc/memory-card.1		\
	doc/pendrive.1			\
	doc/phone.1


#### sudo interface

sudoersdir		= $(sysconfdir)/sudoers.d
dist_sudoers_DATA	= src/etc/sudoers.d/mmux-removable-media-utilities.conf


#### bash completions

completionsdir			= $(sysconfdir)/bash_completion.d
completions_SCRIPTS		=			\
	src/etc/bash_completion.d/cdrom.bash		\
	src/etc/bash_completion.d/floppy-disk.bash	\
	src/etc/bash_completion.d/memory-card.bash	\
	src/etc/bash_completion.d/pendrive.bash		\
	src/etc/bash_completion.d/phone.bash

CLEANFILES			+=			\
	src/etc/bash_completion.d/cdrom.bash		\
	src/etc/bash_completion.d/floppy-disk.bash	\
	src/etc/bash_completion.d/memory-card.bash	\
	src/etc/bash_completion.d/pendrive.bash		\
	src/etc/bash_completion.d/phone.bash		\
	src/etc/bash_completion.d/$(am__dirstamp)

completions_PREREQUISITES	=			\
	src/etc/bash_completion.d/$(am__dirstamp)

src/etc/bash_completion.d/$(am__dirstamp):
	@$(MKDIR_P) src/etc/bash_completion.d
	@: > src/etc/bash_completion.d/$(am__dirstamp)

src/etc/bash_completion.d/cdrom.bash: src/bin/cdrom $(completions_PREREQUISITES)
	$(BASH_PROGRAM) src/bin/cdrom help print-completions-script >$(@)

src/etc/bash_completion.d/floppy-disk.bash: src/bin/floppy-disk $(completions_PREREQUISITES)
	$(BASH_PROGRAM) src/bin/floppy-disk help print-completions-script >$(@)

src/etc/bash_completion.d/memory-card.bash: src/bin/memory-card $(completions_PREREQUISITES)
	$(BASH_PROGRAM) src/bin/memory-card help print-completions-script >$(@)

src/etc/bash_completion.d/pendrive.bash: src/bin/pendrive $(completions_PREREQUISITES)
	$(BASH_PROGRAM) src/bin/pendrive help print-completions-script >$(@)

src/etc/bash_completion.d/phone.bash: src/bin/phone $(completions_PREREQUISITES)
	$(BASH_PROGRAM) src/bin/phone help print-completions-script >$(@)


#### scripts

EXTRA_DIST		+=		\
	src/bin/common.m4

bin_SCRIPTS		=		\
	src/bin/cdrom			\
	src/bin/floppy-disk		\
	src/bin/memory-card		\
	src/bin/pendrive		\
	src/bin/phone

CLEANFILES		+=		\
	src/bin/cdrom			\
	src/bin/floppy-disk		\
	src/bin/memory-card		\
	src/bin/pendrive		\
	src/bin/phone			\
	src/bin/$(am__dirstamp)

MBFLPP_FLAGS		= --add-bash --include=$(top_srcdir)/src/bin

binscripts_PREREQUISITES =		\
	src/bin/common.m4		\
	src/bin/$(am__dirstamp)

src/bin/$(am__dirstamp):
	@$(MKDIR_P) src/bin/
	@: > src/bin/$(am__dirstamp)

src/bin/pendrive : src/bin/pendrive.m4 $(binscripts_PREREQUISITES)
	$(MBFLPP) $(MBFLPP_FLAGS) <$< >$@

src/bin/phone : src/bin/phone.m4 $(binscripts_PREREQUISITES)
	$(MBFLPP) $(MBFLPP_FLAGS) <$< >$@

src/bin/cdrom : src/bin/cdrom.m4 $(binscripts_PREREQUISITES)
	$(MBFLPP) $(MBFLPP_FLAGS) <$< >$@

src/bin/memory-card : src/bin/memory-card.m4 $(binscripts_PREREQUISITES)
	$(MBFLPP) $(MBFLPP_FLAGS) <$< >$@

src/bin/floppy-disk : src/bin/floppy-disk.m4 $(binscripts_PREREQUISITES)
	$(MBFLPP) $(MBFLPP_FLAGS) <$< >$@

### end of file
