RUBY := $(shell which ruby)
BREW := $(shell which brew)
BUNDLER := $(shell which bundler)
GITHUB_RELEASE := $(shell which github-release)
SWIFT := $(shell which swift)
SWIFTLINT := $(shell which swiftlint)
XCODEBUILD := $(shell which xcodebuild)
CURL := $(shell which curl)

repo_name := github-scanner
version := $(shell cat .app-version)
cmd_version = $(shell $(MAKE) build run CMD='version' | tail -1)
versions_equal = $(shell if [ $(version) == $(cmd_version) ] ; then echo 1 ; else echo 0 ; fi)
artifact_osx = $(repo_name)-$(version)-osx-amd64.tar.gz


# Generates the xcodeproj and compiles the executable
build: xcodeproj
	$(SWIFT) build
.PHONY: build

build-release:
	$(SWIFT) build --configuration release
.PHONY: build-release

xcodeproj:
	$(SWIFT) package generate-xcodeproj --enable-code-coverage
.PHONY: xcodeproj


# Runs the debug executable to simplify the developement cycle. The expected
# pattern would be:
#
# 1. Change some code.
# 2. Run `make build run` or `make build run CMD=scan` if you want to test a
#    specific command.
run:
	./.build/debug/$(repo_name) $(CMD)
.PHONY: run


lint:
	$(SWIFTLINT) lint
.PHONY: lint

test:
	$(SWIFT) test
.PHONY: test

test-xcode:
	$(XCODEBUILD) test -project $(repo_name).xcodeproj -scheme $(repo_name) | xcpretty
.PHONY: test-xcode

release-create:
	@if [ $(versions_equal) -eq 0 ]; then (echo "Versions not equal in `.app-version` and version command."; exit 1); fi
	$(GITHUB_RELEASE) release --user ustwo \
						--repo $(repo_name) \
						--tag $(version) \
						--name v$(version)
.PHONY: release-create

release-artifacts: artifacts
	$(GITHUB_RELEASE) upload --user ustwo \
                        --repo $(repo_name) \
                        --tag $(version) \
                        --name $(artifact_osx) \
                        --file dist/$(artifact_osx)
.PHONY: release-artifacts

release-info:
	$(GITHUB_RELEASE) info --user ustwo --repo $(repo_name)
.PHONY: release-info

release-delete:
	$(GITHUB_RELEASE) delete --user ustwo --repo $(repo_name) --tag $(version)
.PHONY: release-delete

artifacts: dist/$(artifact_osx)
.PHONY: artifacts

dist/$(artifact_osx): build-release
	@mkdir -p dist
	@echo "Compressing"
	@cp ./.build/release/$(repo_name) dist/$(repo_name)
	@cp LICENSE.md dist/LICENSE.md
	@cp README.md dist/README.md
	@tar -zcvf $@ -C dist/ $(repo_name) \
                         LICENSE.md \
                         README.md
	@echo "****************************************************************"
	@shasum -a 256 $@
	@du -sh $@
	@echo "****************************************************************"

artifacts-expand:
	cd dist && \
	mkdir -p temp && \
	tar -zxvf $(artifact_osx) -C temp/


# Installs the required dependencies.
dependencies:
ifndef RUBY
	$(error "Couldn't find Ruby installed.")
endif
	@$(MAKE) install-bundler install-homebrew install-swiftlint install-github-release


install-homebrew:
ifndef BREW
	$(RUBY) -e "$($(CURL) -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
	$(BREW) update
endif

install-bundler:
ifndef BUNDLER
	$(RUBY) gem install bundler
else
	$(BUNDLER) install
endif

install-swiftlint:
ifndef SWIFTLINT
	$(BREW) install swiftlint
else
	$(BREW) outdated swiftlint || $(BREW) upgrade swiftlint
endif

install-github-release:
ifndef GITHUB_RELEASE
	$(BREW) install github-release
else
	$(BREW) outdated github-release || $(BREW) upgrade github-release
endif
