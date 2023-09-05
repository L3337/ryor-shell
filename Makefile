ORG     ?= $(shell jq -r .org meta.json)
PRODUCT ?= $(shell jq -r .product meta.json)
VERSION ?= $(shell jq -r .version meta.json)
DESTDIR ?=

clean:
	# Remove temporary build files
	rm -rf ./.rpmbuild/ ./*.rpm

git-hooks:
	# Install git hooks for this repository to enable running tests before
	# committing, etc...
	cp -f tools/git-hooks/* .git/hooks/

install: \
	install_files \

	# Install various files for Linux,

install_files:
	cp -r files/* $(DESTDIR)/

rpm:
	# Build the RPM package locally in .rpmbuild
	rm -rf .rpmbuild
	mkdir -p .rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
	tar \
		--exclude='./venv' --exclude='.[^/]*' \
		--transform 's,^\.,$(PRODUCT)-$(VERSION),' \
		-czvf \
		./.rpmbuild/SOURCES/$(PRODUCT)-$(VERSION).tar.gz \
		./
	rpmbuild -v -ba \
		--define "_topdir $(shell pwd)/.rpmbuild" \
		--define "_tmppath $(shell pwd)/.rpmbuild/tmp"\
		tools/rpm.spec
	cp ./.rpmbuild/RPMS/noarch/*$(PRODUCT)-$(VERSION)*.rpm .

