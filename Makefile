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
  POPT = -g  -XS -Co -Ci -Cr -Ct -T$(UNAMELONG) -dPASCAL
  LOPT = -Fl$(LIBDIR)
  PCOPT =
else
  POPT = -g -T$(UNAMELONG) -DPASCAL
  POPT = -L$(LIBDIR)
  PCOPT = -c
endif
else
ifeq ($(PC), ppc386)
  POPT = -g -v0 -XS -Co -Ci -Cr -Ct -dPASCAL
  LOPT = -Fl$(LIBDIR)
  PCOPT =
else
  POPT = -DPASCAL
  LOPT = -L$(LIBDIR)
  PCOPT = -c
endif
endif


all: ffma$(EXE)

ifdef H2PAS
fconf.pas: $(INCDIR)/fidoconf/fidoconf.h
ifeq ($(PC), gpc)
	cat $(INCDIR)/fidoconf/fidoconf.h \
	 | grep -v "^#define " \
	 | grep -v "^ *extern " \
	 | awk 'BEGIN { cpp=0; } { if (($$1 == "#ifdef") && ($$2 == "__cplusplus")) { cpp=1; } else if (($$1 == "#endif") && (cpp == 1)) { cpp=0; } else if (cpp == 1) { printf "\n" } else { print; } }' > fidoconf.h
	h2pas -u fconf -p -l fidoconfig -s -d -o /dev/stdout \
	 fidoconf.h | sed -e 's/\^char/pchar/g' \
	 -e 's/\^Double;/\^Double; PFile = ^File; PPChar = ^PChar;/' \
	 | grep -v '^{$$include' \
	 | grep -v "^[^']*';$$" \
	 | grep -v "^ *var$$" \
	 | sed 's/cdecl;//g' \
	 > fconf.pas
else
	cat $(INCDIR)/fidoconf/fidoconf.h \
	 | grep -v "^#define " \
	 | grep -v "^ *extern " \
	 | awk 'BEGIN { cpp=0; } { if (($$1 == "#ifdef") && ($$2 == "__cplusplus")) { cpp=1; } else if (($$1 == "#endif") && (cpp == 1)) { cpp=0; } else if (cpp == 1) { printf "\n" } else { print; } }' > fidoconf.h
	h2pas -u fconf -p -l fidoconfig -s -d -o /dev/stdout \
	 fidoconf.h | sed -e 's/\^char/pchar/g' \
	 -e 's/\^Double;/\^Double; PFile = ^File; PPChar = ^PChar;/' \
	 | grep -v '^{$$include' \
	 | grep -v "^[^']*';$$" \
	 | grep -v "^ *var$$" \
	 > fconf.pas
endif
endif

%$(OBJ): %.pas
	$(PC) $(POPT) $(PCOPT) $*.pas

ifeq ($(PC), ppc386)
fidoconf2.pas: fconf$(OBJ)
else
fidoconf2.pas: gpcstrings$(OBJ) fconf$(OBJ)
endif

ifeq ($(PC), ppc386)
ffma$(EXE): fidoconf2$(OBJ) erweiter$(OBJ) fparser$(OBJ) memman$(OBJ) \
            utils$(OBJ) log$(OBJ) ini$(OBJ) match$(OBJ) fconf$(OBJ) \
            smapi$(OBJ) ffma.pas
	$(PC) $(POPT) $(LOPT) ffma.pas
else
ffma$(EXE): fidoconf2$(OBJ) erweiter$(OBJ) fparser$(OBJ) memman$(OBJ) \
            utils$(OBJ) log$(OBJ) ini$(OBJ) match$(OBJ) fconf$(OBJ) \
            gpcsmapi$(OBJ) ffma.pas
	$(PC) $(POPT) $(LOPT) ffma.pas
endif

ifeq ($(PC), ppc386)
utils.pas: smapi$(OBJ)
else
utils.pas: gpcsmapi$(OBJ)
endif

install: ffma$(EXE)
	$(INSTALL) $(IBOPT) ffma$(EXE) $(BINDIR)

uninstall:
	-$(RM) $(RMOPT) $(BINDIR)$(DIRSEP)ffma$(EXE)

clean:
	-$(RM) $(RMOPT) fconf.pas
	-$(RM) $(RMOPT) fidoconf.h
	-$(RM) $(RMOPT) *$(OBJ)
	-$(RM) $(RMOPT) *$(LIB)
	-$(RM) $(RMOPT) *$(TPU)
	-$(RM) $(RMOPT) *~

distclean: clean
	-$(RM) $(RMOPT) ffma$(EXE)

