## lunar-ips

This Chocolatey package installs Lunar IPS, a file patching utility. The below summary is from the project's homepage.

---

**Lunar IPS (LIPS)** is intended as an easy to use, lightweight IPS patch utility for windows to replace the **SNESTool** DOS program. It can both create and apply IPS patches.

As far as features go, LIPS has:
- IPS patch creation/application support.
- full RLE encoding/decoding support.
- file expanding/truncating support.
- the IPS encoder creates files that are the same size or smaller than files created with **SNESTool**.
- the IPS encoder avoids the rare "0x454F46 (EOF) offset bug" that **SNESTool's** IPS encoder has.
- logging feature for applying IPS patches (ROMFileName.log).
- registers the ".IPS" file type so that you can just double click on an IPS file and choose the file to apply it to for convenience.
- support for patching files up to 16 MB in size, which is the limit of the IPS format. The files can technically be larger than that, but the IPS format cannot record changes beyond the 16 MB mark due to 24-bit addressing. The IPS file itself can be any size.

Note that the logging and file registration options are saved to the registry.

## Installation

> **Note:** This package has not yet been uploaded as of this time of writing. This disclaimer will be removed once the package is available on the community feed.

You must ensure [Chocolatey is installed](https://chocolatey.org/install) before you consume this package.

Once Chocolatey is installed, run the following to install **Lunar IPS**

```powershell
choco install lunar-ips
```

### Different Languages

As **Lunar IPS** supports multiple languages, so too does this package. You can install any of the supported languages, for example, let's install the **German** version:

```powershell
choco install lunar-ips --params "'/Language:German'"
```

If we later decide we want another language, we can force-install with that language instead:

```powershell
choco install lunar-ips --params "'/Language:English'"
```

At this time of writing, **Lunar IPS** supports the following languages:

- English (default if unspecified)
- Croatian
- Dutch
- German
- Portuguese
- Spanish
- Swedish

Keep in mind that installing a different language will overwrite the currently installed files with the new language.
## Running **Lunar IPS**

This package adds two shortcuts to the Start Menu as well for **Lunar IPS** (32 and 64 bit variants), making it easy to launch without having to customize the Start Menu yourself.

You can also run `Lunar IPS.exe` or `Lunar IPS (64-bit).exe` without the full path as the commands are shimmed to the `PATH`, but note that the spaces in the executable name makes this a bit less useful.

## Issue Reporting

Please do not report issues with the **Lunar IPS** software itself to this project's [issue tracker](https://github.com/codewario/chocolatey-lunar-ips/issues). This issue tracker is for reporting issues with the Chocolatey package *only*. Any issues opened here for the software itself will be closed.

Likewise, the maintainer of **Lunar IPS** is not affiliated with this package in any way, so **do not reach out to them for issues with this package**.

For Lunar IPS support, please visit the [Lunar IPS homepage](https://fusoya.eludevisibility.org/lips/).

## Building the package

To build this package, make sure **Chocolatey** is installed and simply run the following in PowerShell after cloning the source:

```powershell
# Use the real path here
cd /path/to/cloned/chocolatey-lunar-ips/

# Build the package
choco pack ./lunar-ips.nuspec --force

# Install the local nupkg
choco install -y lunar-ips -s .
```