
INSTBINDIR = /usr/local/bin
pathtoFIDOCONF_PAS = ../fidoconfig

###################################################
######                                       ######
######   End of user-configurable settings   ######
######                                       ######
###################################################
 
PASCAL   = ppc386
COPT = -v0 -XS -Cx -Co -Ci -Cr -Ct -Cs1000000 -Ch5000000

#COPT = -v0 

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
	rm -f *.o *.a *.ppu *~ *.bak *.gpi ffma.uid *.s
	rm -f h2pas/*.o h2pas/*.a h2pas/*.ppu h2pas/*~ h2pas/*.bak h2pas/*.gpi h2pas/ffma.uid

distclean:	clean
	rm -f ffma h2pas/h2pas