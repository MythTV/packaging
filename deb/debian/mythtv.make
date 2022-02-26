#Custom debian/rules snippet used for building MythTV packages that come from MythTV's github location

#Figure out what we're working with by parsing the project and debian changelog
#To make sense of these sed rules that are used:
#  Sample version string:
#                  Version: 1:0.25.0+master.20101129.a8acde8-0ubuntu1
#                           ^ ^^^^^^ ^^^^^^ ^^^^^^^^ ^^^^^^^ ^^^^^^^^
#  s/.*1:0.//   -> kill the epoch and Version bit and 0. leading the version
#  s/-.*//      -> kill everything after and including the -
#  s/[~+].*//   -> kill everything after and including the ~ or +
#  s/.*+//      -> kill everything before and including the +

include /usr/share/dpkg/pkg-info.mk
GIT_MAJOR_RELEASE:=$(shell echo $(DEB_VERSION_UPSTREAM) | sed 's/[~+].*//' | awk -F. '{print $$1}')
GIT_MINOR_RELEASE:=$(shell echo $(DEB_VERSION_UPSTREAM) | sed 's/[~+].*//' | awk -F. '{print $$2}')
GIT_TYPE:=$(shell echo $(DEB_VERSION_UPSTREAM) | sed 's/.*[~+]//' | awk -F. '{print $$1}')
DATE:=$(shell echo $(DEB_VERSION_UPSTREAM) | sed 's/.*[~+]//' | awk -F. '{print $$2}')
GIT_HASH:=$(shell echo $(DEB_VERSION_UPSTREAM) | sed 's/.*[~+]//' | awk -F. '{print $$3}')
LAST_GIT_HASH:=$(shell dpkg-parsechangelog --offset 1 --count 1 -SVersion | sed 's/.*[~+]//; s/-.*//' | awk -F. '{print $$3}')
DEBIAN_SUFFIX:=$(shell echo $(DEB_VERSION) | sed 's/.*-//')
AUTOBUILD=$(shell echo $(DEB_VERSION) | grep mythbuntu)
EPOCH:=$(shell echo $(DEB_VERSION) | sed 's/:.*//')

TODAY:=$(shell date +%Y%m%d)
CURRENT_GIT_HASH:=$(shell git rev-parse --short HEAD)

MAIN_GIT_URL=https://github.com/MythTV/mythtv.git
MYTHWEB_GIT_URL=https://github.com/MythTV/mythweb.git
MYTHBUNTU_THEME_GIT_URL=https://github.com/MythTV-Themes/Mythbuntu.git

ifeq "$(GIT_TYPE)" "master"
	GIT_BRANCH:=master
	GIT_BRANCH_FALLBACK=master
	DELIMITTER="~"
endif
ifeq "$(GIT_TYPE)" "fixes"
	GIT_BRANCH:=fixes/$(GIT_MAJOR_RELEASE)
	GIT_BRANCH_FALLBACK=master
	DELIMITTER="+"
endif
ifeq "$(GIT_TYPE)" "arbitrary"
	DELIMITTER="~"
endif

GIT_RELEASE=$(GIT_MAJOR_RELEASE).$(GIT_MINOR_RELEASE)
SUFFIX+=$(GIT_TYPE).$(DATE).$(GIT_HASH)

ABI:=$(shell awk  -F= '/^LIBVERSION/ { gsub(/[ \t]+/, ""); print $$2}' mythtv/settings.pro 2>/dev/null || echo $(GIT_MAJOR_RELEASE))

TARFILE:=mythtv_$(GIT_RELEASE)$(DELIMITTER)$(SUFFIX).orig.tar.gz

build-tarball:
	#build the tarball
	tar czf $(CURDIR)/../$(TARFILE) --exclude-vcs --exclude .pc --exclude-tag-all mythtv.make *


get-git-source:
	#checkout mythtv
	if [ -d .git ]; then \
		git fetch ;\
		git checkout $(GIT_BRANCH) || git checkout $(GIT_BRANCH_FALLBACK);\
		git pull --rebase; \
		git clean -f -d -X -e Mythbuntu/ -e mythplugins/mythweb/;\
	else \
		git clone $(MAIN_GIT_URL) tmp ;\
		mv tmp/.[!.]* tmp/* . ;\
		rm -rf tmp ;\
		git checkout $(GIT_BRANCH) || git checkout $(GIT_BRANCH_FALLBACK);\
	fi

	#checkout mythweb
	if [ -d mythplugins/mythweb/.git ]; then \
		cd mythplugins/mythweb; \
		git fetch ;\
		git checkout $(GIT_BRANCH) || git checkout $(GIT_BRANCH_FALLBACK);\
		git pull --rebase ;\
		git clean -f -d -X;\
	else \
		mkdir -p mythplugins/mythweb ;\
		git clone $(MYTHWEB_GIT_URL) tmp ;\
		mv tmp/.[!.]* tmp/* mythplugins/mythweb ;\
		rm -rf tmp ;\
		cd mythplugins/mythweb ;\
		git checkout $(GIT_BRANCH) || git checkout $(GIT_BRANCH_FALLBACK);\
	fi

	#checkout mythbuntu theme
	if [ -d Mythbuntu/.git ]; then \
		cd Mythbuntu; \
		git fetch ;\
		git checkout $(GIT_BRANCH) || git checkout $(GIT_BRANCH_FALLBACK);\
		git pull --rebase ;\
		git clean -f -d -X;\
	else \
		mkdir -p Mythbuntu ;\
		git clone $(MYTHBUNTU_THEME_GIT_URL) tmp ;\
		mv tmp/.[!.]* tmp/* Mythbuntu ;\
		rm -rf tmp ;\
		cd Mythbuntu ;\
		git checkout $(GIT_BRANCH) || git checkout $(GIT_BRANCH_FALLBACK);\
	fi

	#fixup --version
	DESCRIBE=`git describe` ;\
	echo "BRANCH=\"$(GIT_BRANCH)\"" > debian/DESCRIBE ;\
	echo "SOURCE_VERSION=\"$$DESCRIBE\"" >> debian/DESCRIBE ;\

	#fixup changelog
	#1) Check if the hash in the changelog (GIT_HASH) matches what the tree has
	#   ->If not, then set the new HASH we are diffing to as the one from the tree
	#     and the old HASH we are diffing from as the one from the changelog
	#   ->If so , then set the current HASH to the one from the tree
	#2) Check for autobuild.
	#   ->If not, do nothing
	#   ->If so,  then query the PPA for a revision number
	#3) Check for an empty last git hash, and fill if empty

	echo "Current hash: $(CURRENT_GIT_HASH)" ;\
	if [ "$(GIT_HASH)" != "$(CURRENT_GIT_HASH)" ]; then \
		GIT_HASH=$(CURRENT_GIT_HASH) ;\
		LAST_GIT_HASH=$(GIT_HASH) ;\
		if [ -n "$(AUTOBUILD)" ]; then \
			LAST_GIT_HASH=`python debian/PPA-published-git-checker.py $(GIT_MAJOR_RELEASE)` ;\
			AUTOBUILD="Automated Build: " ;\
		fi ;\
		dch -b -v $(EPOCH):$(GIT_RELEASE)$(DELIMITTER)$(GIT_TYPE).$(TODAY).$$GIT_HASH-$(DEBIAN_SUFFIX) "$${AUTOBUILD}New upstream checkout ($$GIT_HASH)";\
	else \
		GIT_HASH=$(GIT_HASH) ;\
	fi ;\
	[ -n "$$LAST_GIT_HASH" ] || LAST_GIT_HASH=$(LAST_GIT_HASH) ;\
	if [ -n "$$LAST_GIT_HASH" ] && [ "$$GIT_HASH" != "$$LAST_GIT_HASH" ]; then \
		echo "Appending upstream changes between $$LAST_GIT_HASH and $$GIT_HASH" ;\
		dch -a ">>Upstream changes since last upload ($$LAST_GIT_HASH):" ;\
		if [ -d .git ]; then \
			git log --oneline $$LAST_GIT_HASH..$$GIT_HASH | sed 's,^,[,; s, ,] ,; s,Version,version,' > .gitout ;\
			while read -r line; do \
				dch -a "$$line"; \
			done < .gitout ;\
			rm -f .gitout ;\
		fi \
	fi

get-orig-source:
	python debian/LP-get-orig-source.py $(GIT_RELEASE)$(DELIMITTER)$(SUFFIX) $(CURDIR)/../$(TARFILE)

info:
	@echo    "--Upstream Project--\n" \
		"ABI: $(ABI)\n" \
		"--From CURRENT changelog entry in debian--\n" \
		"Epoch: $(EPOCH)\n" \
		"Type: $(GIT_TYPE)\n" \
		"Major Release: $(GIT_MAJOR_RELEASE)\n" \
		"Minor Release: $(GIT_MINOR_RELEASE)\n" \
		"Total Release: $(GIT_RELEASE)\n" \
		"Hash: $(GIT_HASH)\n" \
		"Date: $(DATE)\n" \
		"--Calculated Data--\n" \
		"Branch: $(GIT_BRANCH)\n" \
		"Suffix: $(SUFFIX)\n" \
		"Tarfile: $(TARFILE)\n" \
		"--Other info--\n" \
		"OLD Hash: $(LAST_GIT_HASH)\n" \
		"Current branch hash: $(CURRENT_GIT_HASH)\n" \
		"Current date: $(TODAY)\n" \
