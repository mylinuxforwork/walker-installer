#!/usr/bin/env bash

# --- Configuration ---
BIN_DIR="$HOME/.local/bin"
CACHE_DIR="$HOME/.cache"

# Ensure the bin directory exists
mkdir -p "$BIN_DIR"

# --- Helper Functions ---

# Function to display help usage
_show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Installs 'walker' and 'elephant' and their related components."
    echo ""
    echo "Options:"
    echo "  -w, --walker              Install only the 'walker' binary."
    echo "  -e, --elephant            Install only the 'elephant' core."
    echo "  -h, --help                Show this help message and exit."
    echo ""
    echo "Default behavior (no options): Install walker, elephant, and the 'desktopapplications' provider."
}

# --- Installation Functions ---

# INSTALL WALKER
_install_walker() {
    echo "--- Installing Walker ---"

    if [ -d "$CACHE_DIR/walker" ]; then
        sudo rm -rf "$CACHE_DIR/walker"
        echo ":: Legacy build folder $CACHE_DIR/walker removed"
    fi

    # Clone the repository
    echo ":: Cloning Walker repository..."
    if ! git clone https://github.com/abenz1267/walker.git "$CACHE_DIR/walker"; then
        echo ":: ERROR: Failed to clone Walker repository."
        exit 1
    fi
    cd "$CACHE_DIR/walker"

    # Build with Cargo
    echo ":: Starting build ..."
    sudo make install

    WALKER_BIN="/usr/local/bin/walker"

    # Success message
    if [ -f "$WALKER_BIN" ]; then
        echo ":: Installation of walker complete"
    else
        echo ":: ERROR: Installation of walker failed"
        exit 1
    fi
    echo
}

# INSTALL ELEPHANT
_install_elephant() {
    echo "--- Installing Elephant Core ---"

    if [ -d "$CACHE_DIR/elephant" ]; then
        sudo rm -rf "$CACHE_DIR/elephant"
        echo ":: Legacy build folder $CACHE_DIR/elephant removed"
    fi

    # Clone the repository
    echo ":: Cloning Elephant repository..."
    if ! git clone https://github.com/abenz1267/elephant "$CACHE_DIR/elephant"; then
        echo ":: ERROR: Failed to clone Elephant repository."
        exit 1
    fi
    cd "$CACHE_DIR/elephant"
    
    # Build and install the main binary
    echo ":: Starting build and install for Elephant..."
    sudo make install

    ELEPHANT_BIN="/usr/local/bin/elephant"

    # Success message
    if [ -f "$ELEPHANT_BIN" ]; then
        echo ":: Installation of elephant complete"
    else
        echo ":: ERROR: Installation of elephant failed"
        exit 1
    fi
    echo

    # Create configuration directories
    mkdir -p ~/.config/elephant/providers
    echo ":: Providers folder in ~/.config/elephant/providers created"
    echo ":: Installation of elephant complete"
    echo
}

# INSTALL PROVIDERS
_install_provider() {
    local provider="$1"
    echo "--- Installing Provider: $provider ---"
    
    # Check if the elephant source directory exists, as it's required to build providers
    if [ ! -d "$CACHE_DIR/elephant/internal/providers/$provider" ]; then
        echo ":: ERROR: Elephant source files or provider directory not found."
        echo ":: Please ensure Elephant is installed before attempting to install providers."
        exit 1
    fi

    echo ":: Building provider $provider"
    
    # Build and install a provider
    cd "$CACHE_DIR/elephant/internal/providers/$provider" || exit 1
    if ! go build -buildmode=plugin; then
        echo ":: ERROR: Provider $provider build failed."
        exit 1
    fi
    
    # Copy the built plugin
    cp "$provider.so" "$HOME/.config/elephant/providers/"
    
    if [ -f "$HOME/.config/elephant/providers/$provider.so" ]; then
        echo ":: Installation of provider $provider complete"
    else
        echo ":: ERROR: Installation of provider $provider failed"
        exit 1
    fi
    echo
}


# --- Main Logic and Argument Parsing ---

INSTALL_WALKER=false
INSTALL_ELEPHANT=false

# Parse arguments for short and long options
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help)
            _show_help
            exit 0
            ;;
        -w|--walker)
            INSTALL_WALKER=true
            ;;
        -e|--elephant)
            INSTALL_ELEPHANT=true
            ;;
        *)
            echo ":: ERROR: Unknown parameter: $1" >&2
            _show_help
            exit 1
            ;;
    esac
    shift # Consume the current argument
done

# Check if any specific option was chosen. If not, default to full install.
if ! $INSTALL_WALKER && ! $INSTALL_ELEPHANT ]; then
    echo ":: No specific flags provided. Performing full default installation (walker and elephant)."
    INSTALL_WALKER=true
    INSTALL_ELEPHANT=true
fi

# --- Execution Phase ---

# 1. Install Walker
if $INSTALL_WALKER; then
    _install_walker
fi

# 2. Install Elephant
if $INSTALL_ELEPHANT; then
    _install_elephant
fi
