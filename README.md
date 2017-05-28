# HyperKit Homebrew Tap (homebrew-hyperkit)

>BETA: This is a test to determine viability of a brew formula for Hyperkit.

This tap has been created to specifically install [HyperKit](https://github.com/moby/hyperkit), a MacOS hypervisor built
on top of the Hypervisor.Framework.

## Installation

Run the following in your command-line:

```sh
prompt> brew tap markeissler/hyperkit
```

Once the tap has been installed, you can proceed with `hyperkit` installation by running the following command:

```sh
prompt> brew install hyperkit
```

## Usage

### Determing the Installed HyperKit Version

[HyperKit](https://github.com/moby/hyperkit) does not comply with the [Semantic Versioning](http://semver.org/) release
numbering scheme (the familiar X.y.z format); consequently, the versioning scheme for this utility may appear a bit odd:

```sh
prompt> hyperkit -v
hyperkit: 20170515-fa78d94

Homepage: https://github.com/docker/hyperkit
License: BSD
```

There are two parts to the version number:

| Field Value | Description                                            |
|:------------|:-------------------------------------------------------|
|__20170515__ | Commit date for the for the specific release.          |
|__fa77d94__  | Short form commit hash (sha1) for the specific release |

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
is, outside of the main __Homebrew__ repository. The goal is to add a `hyperkit` formula to the main __Homebrew__
respository but there's still some work to be done before that can happen.

In the meantime, this tap exists for those that need it, want it.

## Bugs and such

Submit bugs by opening an issue on the [homebrew-hyperkit issues page](https://github.com/markeissler/homebrew-hyperkit/issues).

## Authors

__homebrew-hyperkit__ is the work of __Mark Eissler__.

## License

__homebrew-hyperkit__ is licensed under the 2-clause BSD open source license.

---
Without open source, there would be no Internet as we know it today.
