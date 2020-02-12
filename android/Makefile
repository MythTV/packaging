
sinclude buildrc
sinclude make.inc

ifeq ($(MODE),arm64)
	ARM64 = 1
else ifeq ($(MODE),arm)
	ARM64 = 0
else ifeq ($(MODE),)
else
$(error MODE=$(MODE) is invalid, please use arm or arm64)
endif
ifeq ($(ARM64),1)
	SUFFIX := 64
	MODE_OPT := --arm64
else
	SUFFIX :=
	MODE_OPT := --arm
endif

ifneq ($(SDK),)
	SDK_OPT := --sdk $(SDK)
endif

OPTS := $(MODE_OPT) $(SDK_OPT)

.PHONY: all everything libs apk distclean clean
all: apk

everything: libs apk

libs: makelibs.sh
	./makelibs.sh $(OPTS) all

apk: mythbuild.sh
	./mythbuild.sh $(OPTS)

clean:
	rm -rf mythinstall$(SUFFIX)
	rm -rf build$(SUFFIX)

distclean:
	rm -rf libs$(SUFFIX) mythinstall$(SUFFIX) libsinstall$(SUFFIX) build$(SUFFIX)

.PHONY: qt mariadb fftw libxml2 libbluray
qt:
	./makelibs.sh $(OPTS) qt5extras
mariadb:
	./makelibs.sh $(OPTS) mariadb
fftw:
	./makelibs.sh $(OPTS) fftw
libxml2:
	./makelibs.sh $(OPTS) libxml2
libbluray:
	./makelibs.sh $(OPTS) libbluray

