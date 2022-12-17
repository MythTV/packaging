
sinclude buildrc
sinclude make.inc

ifneq ($(CONFIG),)
	CONFIG_OPT := --config $(CONFIG)
	MODE_LINE = $(strip $(shell grep -E "MODE=" android-utilities/config/$(CONFIG)))
	ifneq ($(MODE_LINE),)
		MODE = $(lastword $(subst =, ,$(MODE_LINE)))
	else
$(error Configs available are: $(shell ls -1 android-utilities/config))
	endif
endif

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

ifneq ($(CONFIG),)
	CONFIG_OPT := --config $(CONFIG)
endif

ifneq ($(SDK),)
	SDK_OPT = --sdk $(SDK)
endif
ifneq ($(TARGET_SDK),)
	SDK_OPT += --target-sdk $(TARGET_SDK)
endif
ifneq ($(MIN_SDK),)
	SDK_OPT += --min-sdk $(MIN_SDK)
endif

OPTS := $(MODE_OPT) $(SDK_OPT) $(CONFIG_OPT)

.PHONY: all everything libs apk distclean clean
all: apk

everything: libs apk

libs: makelibs.sh
	./makelibs.sh $(OPTS) all

apk: mythbuild.sh
	./mythbuild.sh $(OPTS)

reconfig: mythbuild.sh
	./mythbuild.sh reconfig_only $(OPTS)

clean:
	rm -rf mythinstall$(SUFFIX)
	rm -rf build$(SUFFIX)

distclean:
	rm -rf libs$(SUFFIX) mythinstall$(SUFFIX) libsinstall$(SUFFIX) build$(SUFFIX)

LIBS_TO_BUILD = mariadb fftw libxml2 libbluray flac iconv icu ogg vorbis fontconfig libsamplerate libsoundtouch ass harfbuzz freetype
.PHONY: qt $(LIBS_TO_BUILD)
qt:
	./makelibs.sh $(OPTS) qt5extras
$(LIBS_TO_BUILD):
	./makelibs.sh $(OPTS) $@
