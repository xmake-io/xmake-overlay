# xmake-overlay

A Gentoo overlay that provides ebuilds for [xmake](https://xmake.io/) and related packages.

## Overview

This overlay contains ebuilds for packages that use the xmake build system, including:

- **xmake_ls** - A language server for xmake projects
- **tbox** - A glib-like multi-platform C library
- **xmake.eclass** - A custom eclass for building xmake-based packages in Gentoo

## Installation

### Using layman

```bash
layman -f -o https://raw.githubusercontent.com/xmake-io/xmake-overlay/master/repositories.xml -a xmake-overlay
```

### Using eselect-repository

```bash
eselect repository add xmake-overlay git https://github.com/xmake-io/xmake-overlay.git
emerge --sync xmake-overlay
```

### Manual installation

Add the overlay to your `/etc/portage/repos.conf/xmake-overlay.conf`:

```ini
[xmake-overlay]
location = /var/db/repos/xmake-overlay
sync-type = git
sync-uri = https://github.com/xmake-io/xmake-overlay.git
auto-sync = yes
```

Then sync:

```bash
emerge --sync
```

## Available Packages

### dev-util/xmake_ls

A language server for xmake that provides IDE integration features like:
- Auto-completion
- Go to definition
- Find references
- Diagnostics
- And more...

```bash
emerge dev-util/xmake_ls
```

### dev-libs/tbox

A glib-like multi-platform C library with features like:
- Cross-platform utilities
- Memory management
- String operations
- File I/O
- Network programming
- And more...

```bash
emerge dev-libs/tbox
```

## xmake.eclass

This overlay includes a custom `xmake.eclass` that provides functions for building xmake-based packages:

- `xmake_src_prepare()` - Prepares the build environment
- `xmake_src_configure()` - Configures the xmake project
- `xmake_src_compile()` - Builds the project
- `xmake_src_install()` - Installs the built files

### Usage Example

```bash
# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xmake

DESCRIPTION="Your package description"
HOMEPAGE="https://github.com/user/project"
SRC_URI="https://github.com/user/project/archive/v${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND="${DEPEND}"

# Set the project kind (shared, static, or executable)
XMAKE_PROJECT_KIND="shared"

# Optional: Add extra configuration flags
# XMAKE_EXTRA_CONFIG_FLAGS=( "--demo=n" "--small=y" )
```

## Requirements

- Gentoo Linux
- Portage package manager
- Git (for repository synchronization)

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for:

- New package ebuilds
- Bug fixes
- Improvements to the xmake.eclass
- Documentation updates

## License

This overlay is licensed under the GNU General Public License v2. Individual packages may have different licenses as specified in their respective ebuild files.

## Support

For issues related to:
- **This overlay**: Please open an issue on the [xmake-io/xmake-overlay](https://github.com/xmake-io/xmake-overlay) repository
- **xmake itself**: Visit the [xmake GitHub repository](https://github.com/xmake-io/xmake)
- **Gentoo packaging**: Refer to the [Gentoo Wiki](https://wiki.gentoo.org/)

## Links

- [xmake Official Website](https://xmake.io/)
- [xmake GitHub Repository](https://github.com/xmake-io/xmake)
- [Gentoo Overlays Project](https://gpo.zugaina.org/)
- [Gentoo Development Guide](https://devmanual.gentoo.org/)