
INSTBINDIR = /usr/local/bin
pathtoFIDOCONF_PAS = ../fidoconfig

###################################################
######                                       ######
######   End of user-configurable settings   ######
######                                       ######
###################################################
 
PASCAL   = ppc386
#COPT = -v0 -XS -Cx
COPT = -v0 

nothing-specified:
	@echo "You must specify the system which you want to compile for:"
	@echo ""
	@echo "Linux"
	@echo "     make linux          make the binary using FPC (highly recommend)"
	@echo "     make linux-gpc      make the binary using GPC (does not work at the Moment)"
	@echo "     make linux-install  install the binary in $(INSTBINDIR)"
	@echo ""
	@echo ""

linux: ffma.pas
	make -f makefile.fpc

linux-install: linux
	install -s ffma $(INSTBINDIR)

linux-gpc:
	make -f makefile.gpc

clean:
	rm -f *.o
	rm -f *.a
	rm -f *.ppu
	rm -f *~
	rm -f *.bak
	rm -f *.gpi

distclean:	clean
	rm -f ffma	