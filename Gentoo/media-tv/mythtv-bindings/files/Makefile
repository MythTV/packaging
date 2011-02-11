include ../config.mak

ifdef CONFIG_BINDINGS_PERL
	SUBDIRS = perl
endif

ifdef CONFIG_BINDINGS_PYTHON
	ifndef SUBDIRS
		SUBDIRS = python
	else
		SUBDIRS += python
	endif
endif

ifdef CONFIG_BINDINGS_PHP
	ifndef SUBDIRS
		SUBDIRS = php
	else
		SUBDIRS += php
	endif
endif

.PHONY: subdirs $(SUBDIRS)
	install $(addsuffix _install,$(SUBDIRS))

all: subdirs

install: $(addsuffix _install,$(SUBDIRS))

subdirs: $(SUBDIRS)

${SUBDIRS}: $(addsuffix /Makefile,$(SUBDIRS))
	$(MAKE) -C $@

$(addsuffix _install,$(SUBDIRS)): $(addsuffix /Makefile,$(SUBDIRS))
	$(MAKE) -C $(subst _install,,$@) install

