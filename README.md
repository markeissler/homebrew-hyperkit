# HyperKit Homebrew Tap (homebrew-hyperkit)

>BETA: This is a test to determine viability of a brew formula for Hyperkit.

This tap has been created to specifically install [HyperKit](https://github.com/moby/hyperkit), a MacOS hypervisor built
on top of the Hypervisor.Framework.

## Installation

Run the following in your command-line:

```sh
>brew tap markeissler/hyperkit
```

Once the tap has been installed, you can proceed with `hyperkit` installation by running the following command:

```sh
>brew install hyperkit
```

## Usage

To list available configuration options run:

```sh
>brew options hyperkit
>brew info hyperkit
```

## Uninstallation

To remove `hyperkit` from your system run the following commands:

```sh
>brew uninstall hyperkit
>brew untap markeissler/hyperkit
```

## Tap instead of a regular Homebrew formula

When you use the `brew tap` command it means you are searching for formulas that are stored in other repositories, that
is, outside of the main __Homebrew__ repository. The goal is to add a `hyperkit` formula to the main __Homebrew__
respository but that work cannot proceed until the `hyperkit` team selects and begins to enforce a versioning scheme to
govern releases.

In the meantime, this tap exists for those that need it, want it.

## Bugs and such
Submit bugs by opening an issue on the [homebrew-hyperkit issues page](https://github.com/markeissler/homebrew-hyperkit/issues).

## Authors

__homebrew-hyperkit__ is the work of __Mark Eissler__.

## License

__homebrew-hyperkit__ is licensed under the 2-clause BSD open source license.

---
Without open source, there would be no Internet as we know it today.
