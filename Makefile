# include Husky-Makefile-Config
include ../huskymak.cfg

ifeq ($(UNAME), LNX)
  UNAMELONG = linux
else
  UNAMELONG = $(UNAME)
endif

ifeq ($(DEBUG), 1)
#  POPT = -g  -XS -Co -Ci -Cr -Ct -ddebugit
ifeq ($(PC), ppc386)
  POPT = -g  -XS -Co -Ci -Cr -Ct -T$(UNAMELONG) 
  LOPT = -Fl$(LIBDIR)
else
  POPT = -g -T$(UNAMELONG) 
  POPT = -L$(LIBDIR)
endif
else
ifeq ($(PC), ppc386)
  POPT = -v0 -XS -Co -Ci -Cr -Ct
  LOPT = -Fl$(LIBDIR)
else
  POPT =
  LOPT = -L$(LIBDIR)
endif
endif


all: ffma$(EXE)

%$(OBJ): %.pas
	$(PC) $(POPT) -c $*.pas

fidoconf2.pas: gpcstrings$(OBJ) fidoconf$(OBJ)

ffma$(EXE): fidoconf2$(OBJ) erweiter$(OBJ) fparser$(OBJ) memman$(OBJ) \
            utils$(OBJ) log$(OBJ) ini$(OBJ) match$(OBJ) fidoconf$(OBJ) \
            smapi$(OBJ) ffma.pas
	$(PC) $(POPT) $(LOPT) ffma.pas

ifdef H2PAS
fidoconf.pas: $(INCDIR)/fidoconf/fidoconf.h
	cat $(INCDIR)/fidoconf/fidoconf.h \
	 | awk 'BEGIN { cpp=0; } { if (($$1 == "#ifdef") && ($$2 == "__cplusplus")) { cpp=1; } else if (($$1 == "#endif") && (cpp == 1)) { cpp=0; } else if (cpp == 1) { printf "\n" } else { print; } }' > fidoconf.h
	h2pas -u fidoconf -p -l fidoconfig -s -d -o /dev/stdout \
	 fidoconf.h | sed -e 's/\^char/pchar/g' \
	 -e 's/\^Double;/\^Double; PFile = ^File;/' \
	 -e 's/function strend(str : longint) : longint;/function strend(str : pchar) : pchar;/' \
	| grep -v "^\{$include" \ 
	> fidoconf.pas
endif

install: ffma$(EXE)
	$(INSTALL) $(IBOPT) ffma$(EXE) $(BINDIR)

clean:
	-$(RM) fidoconf.pas
	-$(RM) *$(OBJ)
	-$(RM) *$(LIB)
	-$(RM) *$(TPU)

distclean: clean
	-$(RM) ffma$(EXE)

