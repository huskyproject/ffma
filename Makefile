# include Husky-Makefile-Config
include ../huskymak.cfg

ifeq ($(DEBUG), 1)
#  POPT = -g  -XS -Co -Ci -Cr -Ct -ddebugit
  POPT = -g  -XS -Co -Ci -Cr -Ct
else
  POPT = -v0 -XS -Co -Ci -Cr -Ct
endif

LOPT = -Fl$(LIBDIR)

ifeq ($(UNAME), LNX)
  UNAMELONG = linux
else
  UNAMELONG = $(UNAME)
endif

all: ffma$(EXE)

ffma$(EXE): fidoconf2.pas erweiter.pas fparser.pas memman.pas utils.pas \
            log.pas ini.pas match.pas fidoconf.pas smapi.pas ffma.pas
	$(PC) $(POPT) $(LOPT) -T$(UNAMELONG) ffma.pas

fidoconf.pas: $(INCDIR)/fidoconf/fidoconf.h
	cat $(INCDIR)/fidoconf/fidoconf.h \
	 | awk 'BEGIN { cpp=0; } { if (($$1 == "#ifdef") && ($$2 == "__cplusplus")) { cpp=1; } else if (($$1 == "#endif") && (cpp == 1)) { cpp=0; } else if (cpp == 1) { printf "\n" } else { print; } }' > fidoconf.h
	h2pas -u fidoconf -p -l fidoconfig -s -d -o /dev/stdout \
	 fidoconf.h | sed -e 's/\^char/pchar/g' \
	 -e 's/\^Double;/\^Double; PFile = ^File;/' \
	 -e 's/function strend(str : longint) : longint;/function strend(str : pchar) : pchar;/' \
	 > fidoconf.pas

install: ffma$(EXE)
	$(INSTALL) $(IBOPT) ffma$(EXE) $(BINDIR)

clean:
	-$(RM) fidoconf.pas
	-$(RM) *$(OBJ)
	-$(RM) *$(LIB)
	-$(RM) *$(TPU)

distclean: clean
	-$(RM) ffma$(EXE)

