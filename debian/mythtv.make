#Custom debian/rules snippet used for building MythTV packages that come from svn.mythtv.org

#                 #
# get-orig-source #
#                 #
SVN_PACKAGE+=$(shell dpkg-parsechangelog | sed -rne 's/^Source: *(.*)/\1/p')
SVN_TYPE+=$(shell dpkg-parsechangelog | sed -rne 's/1://;s/^Version: *.......(.*).....-.*/\1/p')
SVN_MAJOR_RELEASE+=$(shell dpkg-parsechangelog | sed -rne 's/1://;s/^Version: *..(.*).............-.*/\1/p')
SVN_MINOR_RELEASE+=$(shell dpkg-parsechangelog | sed -rne 's/1://;s/^Version: *.....(.*)...........-.*/\1/p')
SVN_REVISION:=$(shell dpkg-parsechangelog | sed -rne 's/1://;s/^Version: *............(.*)-.*/\1/p')
DELIMITTER+=$(shell dpkg-parsechangelog | sed -rne 's/1://;s/^Version: *......(.*)..........-.*/\1/p')

ifeq "$(SVN_TYPE)" "trunk"
	SVN_BRANCH+= http://svn.mythtv.org/svn/$(SVN_TYPE)/$(SVN_PACKAGE)
else
	SVN_BRANCH+= http://svn.mythtv.org/svn/branches/release-0-$(SVN_MAJOR_RELEASE)-$(SVN_TYPE)/$(SVN_PACKAGE)
endif

SVN_RELEASE=0.$(SVN_MAJOR_RELEASE).$(SVN_MINOR_RELEASE)
SUFFIX+="$(DELIMITTER)$(SVN_TYPE)$(SVN_REVISION)"
TARFILE+=$(SVN_PACKAGE)_$(SVN_RELEASE)$(SUFFIX).orig.tar.gz

get-orig-source:
	svn export -r $(SVN_REVISION) $(SVN_BRANCH) $(SVN_PACKAGE)-$(SVN_RELEASE)$(SUFFIX)
	tar czf $(CURDIR)/../$(TARFILE) $(SVN_PACKAGE)-$(SVN_RELEASE)$(SUFFIX)
	rm -rf $(CURDIR)/$(SVN_PACKAGE)-$(SVN_RELEASE)$(SUFFIX)

info:
	echo "Package: $(SVN_PACKAGE)" \
		"Type: $(SVN_TYPE)" \
		"Major Release: $(SVN_MAJOR_RELEASE)" \
		"Minor Release: $(SVN_MINOR_RELEASE)" \
		"Total Release: $(SVN_RELEASE)" \
		"Rev: $(SVN_REVISION)" \
		"Delimitter: $(DELIMITTER)" \
		"Branch: $(SVN_BRANCH)" \
		"Suffix: $(SUFFIX)" \
		"Tarfile: $(TARFILE)"

newest-revision:
	svn info $(SVN_BRANCH) | grep "Last Changed Rev" | awk '{ print $$4 }'

