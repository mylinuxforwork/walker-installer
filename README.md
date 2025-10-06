# Walker Installer

## Arch Linux

yay -S walker-bin

## Fedora

```
sudo dnf copr enable errornointernet/walker
sudo dnf install elephant
sudo dnf install walker
```
## openSuse

Usage: walkerinstaller.sh [OPTIONS]"

Installs 'walker' and 'elephant' and their related components.
```
Options:
    -w, --walker              Install only the 'walker' binary."
    -e, --elephant            Install only the 'elephant' core."
    -p <provider>, --provider <provider>"
                            Install a specific provider (e.g., 'desktopapplications')."
                            Can be specified multiple times."
    -h, --help                Show this help message and exit."
```

Default behavior (no options): Install walker, elephant, and the 'desktopapplications' provider.

The script will install walker and elephant to the folder ~/.local/bin folder. Please add this folder to your path variable to execute the binaries without adding the full path.

