# Peeq [![Build Status](https://travis-ci.org/dbhowell/peeq.svg?branch=master)](https://travis-ci.org/dbhowell/peeq)
[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.dbhowell.peeq)

![Screenshot](data/screenshot_001.png?raw=true)

## Building and Installation

You'll need the following dependencies:
* meson
* libgee-0.8-dev
* libgtksourceview-3.0-dev >= 3.24
* libgranite-dev
* libvala-0.34-dev (or higher)
* libpq
* valac

Run `meson build` to configure the build environment.

    meson build --prefix=/usr

To install, use `ninja install`, then execute with `com.github.dbhowell.peeq`

    sudo ninja install
    com.github.dbhowell.peeq
