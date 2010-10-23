#Custom debian/rules snippet used for building MythTV packages that come from svn.mythtv.org

#                 #
# get-orig-source #
#                 #
SVN_TYPE+=$(shell dpkg-parsechangelog | sed -rne 's/1://;s/^Version: *.......(.*).....-.*/\1/p')
SVN_MAJOR_RELEASE+=$(shell dpkg-parsechangelog | sed -rne 's/1://;s/^Version: *..(.*).............-.*/\1/p')
SVN_MINOR_RELEASE+=$(shell dpkg-parsechangelog | sed -rne 's/1://;s/^Version: *.....(.*)...........-.*/\1/p')
SVN_REVISION:=$(shell dpkg-parsechangelog | sed -rne 's/1://;s/^Version: *............(.*)-.*/\1/p')
DELIMITTER+=$(shell dpkg-parsechangelog | sed -rne 's/1://;s/^Version: *......(.*)..........-.*/\1/p')
THEMES=$(shell ls myththemes --full-time -l | grep '^d' | awk '{ print $$9 }' )

ifeq "$(SVN_TYPE)" "trunk"
	SVN_BRANCH+= http://svn.mythtv.org/svn/$(SVN_TYPE)
else
	SVN_BRANCH+= http://svn.mythtv.org/svn/branches/release-0-$(SVN_MAJOR_RELEASE)-$(SVN_TYPE)
endif

SVN_RELEASE=0.$(SVN_MAJOR_RELEASE).$(SVN_MINOR_RELEASE)
SUFFIX+="$(DELIMITTER)$(SVN_TYPE)$(SVN_REVISION)"
TARFILE+=mythtv_$(SVN_RELEASE)$(SUFFIX).orig.tar.gz

get-orig-source:
	mkdir -p $(CURDIR)/tmp
	svn export -r $(SVN_REVISION) $(SVN_BRANCH)/mythtv tmp/mythtv
	svn export -r $(SVN_REVISION) $(SVN_BRANCH)/mythplugins tmp/mythplugins
	svn export -r $(SVN_REVISION) $(SVN_BRANCH)/myththemes tmp/myththemes
	tar czf $(CURDIR)/../$(TARFILE) -C $(CURDIR)/tmp mythtv mythplugins myththemes
	rm -rf $(CURDIR)/tmp

info:
	echo "Type: $(SVN_TYPE)" \
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

update-control-files:
	rm -f debian/control debian/mythtv-theme*.install
	sed s/#THEMES#/$(shell echo $(THEMES) | tr '[A-Z]' '[a-z]' | sed s/^/mythtv-theme-/ | sed s/\ /,\\\\\ mythtv-theme-/g)/ \
	   debian/control.in > debian/control
	$(foreach theme,$(THEMES),\
	   echo "myththemes/$(theme) usr/share/mythtv/themes" > debian/mythtv-theme-$(shell echo $(theme) | tr '[A-Z]' '[a-z]').install; \
	   cat debian/theme.stub | sed s/#THEME#/$(shell echo $(theme) | tr '[A-Z]' '[a-z]')/ >> debian/control; \
 	 )

