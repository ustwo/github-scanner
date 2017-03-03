# GitHub Scanner

[![Build Status](https://travis-ci.org/ustwo/github-scanner.svg?branch=master)](https://travis-ci.org/ustwo/github-scanner)
[![codecov.io](https://codecov.io/github/ustwo/github-scanner/coverage.svg?branch=master)](https://codecov.io/github/ustwo/github-scanner?branch=master)
[![Twitter](https://img.shields.io/badge/twitter-@ustwo-blue.svg?style=flat)](http://twitter.com/ustwo)

This is a commandline tool for scanning GitHub repositories. It is built by developers at [ustwo][ustwo].

## Usage

### Installing

You can build from source by cloning the repository and running the `make build-release` command. Alternatively, you can download the precompiled package from the [latest release][release]. In either case, you can add it to your `$PATH`.

### Running

To scan an organization's repositories, use

```sh
github-scanner scan organization <org-name> \
                                 --oauth <token>
```

To get a full list of available commands, use

```sh
github-scanner help
```

## Contributing

Check our [contributing guidelines][contributing].

## License

GitHub Scanner is released under the MIT license. See [LICENSE.md][license] for details. Note that while github-scanner is licensed under the MIT license, not all of its dependencies may be. Please check the depedencies listed in the [`Package.swift`][package] file and their respective licesnses.

## Maintainers

* Aaron McTavish ([@aamctustwo][aamctustwo])

## Contact

* [open.source@ustwo.com](mailto:open.source@ustwo.com)

<!-- Links -->

[aamctustwo]: https://github.com/aamctustwo
[contributing]: .github/CONTRIBUTING.md
[license]: LICENSE.md
[package]: Package.swift
[release]: https://github.com/ustwo/github-scanner/releases/latest
