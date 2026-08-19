name := 'cosmic-app-library'
appid := 'com.system76.CosmicAppLibrary'

rootdir := ''
prefix := '/usr'

base-dir := absolute_path(clean(rootdir / prefix))
cargo-target-dir := env('CARGO_TARGET_DIR', 'target')

export APPID := 'com.system76.CosmicAppLibrary'
export INSTALL_DIR := base-dir / 'share'

bin-src := cargo-target-dir / 'release' / name
bin-dst := base-dir / 'bin' / name

appdata := appid + '.metainfo.xml'
appdata-dst := base-dir / 'share' / 'appdata' / appdata

desktop := appid + '.desktop'
desktop-dst := base-dir / 'share' / 'applications' / desktop

icon := appid + '.svg'
icon-dst := base-dir / 'share' / 'icons' / 'hicolor' / 'scalable' / 'apps' / icon

# Default recipe which runs `just build-release`
default: xdgen build-release

# Runs `cargo clean`
clean:
    cargo clean

# `cargo clean` and removes vendored dependencies
clean-dist: clean
    rm -rf .cargo vendor vendor.tar

# Compiles with debug profile
build-debug *args:
    cargo build {{args}}

# Compiles with release profile
build-release *args: (build-debug '--release' args)

# Compiles release profile with vendored dependencies
build-vendored *args: vendor-extract (build-release '--frozen --offline' args)

# Compiles and runs a standalone instance
run *args: build-release
    {{bin-src}} run {{args}}

# Runs a clippy check
check *args:
    cargo clippy --all-features {{args}} -- -W clippy::pedantic

# Runs a clippy check with JSON message format
check-json: (check '--message-format=json')

# Installs files
install:
    install -Dm0755 {{bin-src}} {{bin-dst}}
    install -Dm0644 {{ 'target' / 'xdgen' / desktop }} {{desktop-dst}}
    install -Dm0644 {{ 'target' / 'xdgen' / appdata }} {{appdata-dst}}
    install -Dm0644 {{ 'data' / 'icons' / icon }} {{icon-dst}}

# Uninstalls installed files
uninstall:
    rm {{bin-dst}} {{desktop-dst}} {{appdata-dst}} {{icon-dst}}

# Vendor dependencies locally
vendor: xdgen
    mkdir -p .cargo
    cargo vendor --locked  | head -n -1 > .cargo/config.toml
    echo 'directory = "vendor"' >> .cargo/config.toml
    tar pcf vendor.tar vendor
    rm -rf vendor

# Extracts vendored dependencies
vendor-extract:
    #!/usr/bin/env sh
    rm -rf vendor
    tar pxf vendor.tar

# Generate desktop entries and appstream metadata with translations
xdgen:
    cargo run --manifest-path hooks/generate/Cargo.toml -- {{name}}
