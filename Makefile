RUBY := $(shell which ruby)
BREW := $(shell which brew)
SWIFT := $(shell which swift)
SWIFTLINT := $(shell which swiftlint)
CURL := $(shell which curl)


# Generates the xcodeproj and compiles the executable
build: xcodeproj
	$(SWIFT) build
.PHONY: build

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
	./.build/debug/github-scanner $(CMD)
.PHONY: run


lint:
	$(SWIFTLINT) lint
.PHONY: lint

test:
	$(SWIFT) test
.PHONY: test


# Installs the required dependencies.
dependencies:
ifndef RUBY
	$(error "Couldn't find Ruby installed.")
endif
	@$(MAKE) install-homebrew install-swiftlint


install-homebrew:
ifndef BREW
	$(RUBY) -e "$($(CURL) -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
	$(BREW) update
endif


install-swiftlint:
ifndef SWIFTLINT
	$(BREW) install swiftlint
else
	$(BREW) outdated swiftlint || $(BREW) upgrade swiftlint
endif
