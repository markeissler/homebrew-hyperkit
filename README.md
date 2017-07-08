# HyperKit Homebrew (homebrew-hyperkit)

Install [HyperKit](https://github.com/moby/hyperkit), a MacOS hypervisor built
on top of the [Hypervisor.Framework](https://developer.apple.com/documentation/hypervisor), with a simple `brew` command.

## Installation

Run the following in your command-line:

```sh
prompt> brew tap markeissler/hyperkit
```

Once the tap has been installed, you can proceed with `hyperkit` installation by running the following command:

```sh
prompt> brew install hyperkit
```

That's all there is to it. In most cases, a `hyperkit` binary will be installed from a pre-compiled binary specific for
your platform. With a prepared development environment you can also build the current stable or HEAD releases locally.
Refer to the [Building HyperKit](#build-hyperkit) section below for instructions.

## Usage

### Determing the Installed HyperKit Version

[HyperKit](https://github.com/moby/hyperkit) uses a versioning scheme based on the date of the release milestone. For
this standalone version the specific git commit hash is also provided in parantheses to avoid abiguity in the case that
a release is tagged multiple times with the same date.

```sh
prompt> hyperkit -v
hyperkit: v0.20170425 (a9c368b)

Homepage: https://github.com/docker/hyperkit
License: BSD
```

There are two parts to the version number:

| Field Value    | Description                                            |
|:---------------|:-------------------------------------------------------|
|__v0.20170425__ | Version number.                                        |
|__(a9c368b)__   | Short form commit hash (sha1) for the specific release |

### Building HyperKit

To build `hyperkit` locally you will need to make sure you have development dependencies install (either a full Xcode
development environment or at least the command line tools).

Build stable:

```sh
prompt> brew install --build-from-source hyperkit
```

Build HEAD:

```sh
prompt> brew install --HEAD hyperkit
```

Beware that building `HEAD` may result in a non-functional install since it consists of the latest code contributions
from the `hyperkit` team.

## Testing

The `hyperkit` installation can be be tested by running the following command after installation:

```sh
prompt> brew test -vd hyperkit
```

This test will download a [Tiny Core Linux](http://www.tinycorelinux.net/) kernel and init ram disk image that have
been prepared specifically for use with `hyperkit`. With the above command you will see verbose output during the test
which will start an instance of __tinycorelinux__ and wait for the terminal prompt to appear. If the prompt appears
before the test times out, then the instance will be shutdown (you will see a `shutdown` command issued) and the test
will be deemed a success.

It's important to note that all of this will happen quickly.

## Uninstallation

To remove `hyperkit` from your system run the following commands:

```sh
prompt> brew uninstall hyperkit
prompt> brew untap markeissler/hyperkit
```

## Tap instead of a regular Homebrew formula

When you use the `brew tap` command it means you are searching for formulas that are stored in other repositories, that
is, outside of the main __Homebrew__ repository. This formula is currently maintained in its own __Tap__ due to the
greater level of flexibility it affords the maintainers with regard to ongoing development, testing, future automation
of builds.

## Bugs and such

Submit bugs __related to this formula__ by opening an issue on the [homebrew-hyperkit issues page](https://github.com/markeissler/homebrew-hyperkit/issues).

## Authors

__homebrew-hyperkit__ is the work of __Mark Eissler__.

## License

__homebrew-hyperkit__ is licensed under the 2-clause BSD open source license.

---
Without open source, there would be no Internet as we know it today.
