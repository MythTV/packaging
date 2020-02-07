
sinclude make.inc

ifeq ($(MODE),--arm64)
	ARM64 = 1
else ifeq ($(MODE),arm)
	ARM64 = 0
endif
ifeq ($(ARM64),1)
	SUFFIX := 64
	MODE_OPT := --arm64
else
	SUFFIX :=
	MODE_OPT := --arm
endif

.PHONY: all everything libs apk distclean clean
all: apk

everything: libs apk

libs: makelibs.sh
	./makelibs.sh $(MODE_OPT) all

apk: mythbuild.sh
	./mythbuild.sh $(MODE_OPT)

clean:
	rm -rf mythinstall$(SUFFIX)
	rm -rf build$(SUFFIX)

distclean:
	rm -rf libs$(SUFFIX) mythinstall$(SUFFIX) libsinstall$(SUFFIX) build$(SUFFIX)

.PHONY: qt mariadb fftw libxml2 libbluray
qt:
	./makelibs.sh $(MODE_OPT) qt5extras
mariadb:
	./makelibs.sh $(MODE_OPT) mariadb
fftw:
	./makelibs.sh $(MODE_OPT) fftw
libxml2:
	./makelibs.sh $(MODE_OPT) libxml2
libbluray:
	./makelibs.sh $(MODE_OPT) libbluray

