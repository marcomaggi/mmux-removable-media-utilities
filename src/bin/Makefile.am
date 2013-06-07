## Process this file with automake to produce Makefile.in

EXTRA_DIST		= pendrive.m4 cdrom.m4 floppy-disk.m4
dist_bin_SCRIPTS	= $(builddir)/pendrive $(builddir)/cdrom $(builddir)/floppy-disk

MBFLPP_FLAGS		= --preserve-comments

$(builddir)/pendrive : $(srcdir)/pendrive.m4
	$(MBFLPP) $(MBFLPP_FLAGS) <$< >$@

$(builddir)/cdrom : $(srcdir)/cdrom.m4
	$(MBFLPP) $(MBFLPP_FLAGS) <$< >$@

$(builddir)/floppy-disk : $(srcdir)/floppy-disk.m4
	$(MBFLPP) $(MBFLPP_FLAGS) <$< >$@

CLEANFILES		= pendrive cdrom floppy-disk

### end of file
