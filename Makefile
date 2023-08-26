ORG ?= $(shell jq -r .org meta.json)
PRODUCT ?= $(shell jq -r .product meta.json)
VERSION ?= 0.0.1
DESTDIR ?=
PREFIX ?= /usr

clean:
	# Remove temporary build files
	rm -rf build/ dist/ htmlcov/ ./*.egg-info ./*.nsi .pytest_cache/ \
		./.rpmbuild/ ./*.rpm ./*.deb
	find test/ src/ -name __pycache__ -type d \
		-exec rm -rf {} \; 2>/dev/null \
		|| true

deb: 
	# Build the Debian package
	_COMPLETIONS_DIR=. COMPLETIONS_EXT=.completions \
		make install_completions
	tar \
		--exclude='__pycache__' \
		--exclude='venv' \
		--exclude='.[^/]*' \
		--exclude='*.tar.*' \
		--transform 's,^\.,$(PRODUCT)-$(VERSION),' \
		-czvf \
		../python3-$(PRODUCT)_$(VERSION).orig.tar.gz \
		./
	DEB_BUILD_OPTIONS=nocheck debuild -i
	rm ../*.orig ../python3-$(PRODUCT)* debian/*debhelper*

git-hooks:
	# Install git hooks for this repository to enable running tests before
	# committing, etc...
	cp -f tools/git-hooks/* .git/hooks/

install: \
	install_files \

	# Install various files for Linux,
	# `pip install .` must be run separately

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

override_dh_auto_build:
	# Debian shenanigans

override_dh_auto_install:
	# Debian shenanigans

