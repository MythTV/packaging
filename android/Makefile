
sinclude make.inc

ifeq ($(ARM64),1)
	SUFFIX := 64
else
	SUFFIX :=
endif

.PHONY: all everything libs apk distclean clean
all: apk

everything: libs apk

libs: makelibs.sh
	./makelibs.sh all

apk: mythbuild.sh
	./mythbuild.sh

clean:
	./mythbuild distclean
	rm -rf build$(SUFFIX)

distclean:
	rm -rf libs$(SUFFIX) mythinstall$(SUFFIX) build$(SUFFIX)

.PHONY: qt
qt:
	./makelibs.sh qt5extras

