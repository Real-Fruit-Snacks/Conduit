# Package Manager Support

This directory contains package definitions for various package managers.

## Homebrew (macOS/Linux)

### Installation from tap (future)

Once published to a tap:
```bash
brew tap real-fruit-snacks/conduit
brew install conduit
```

### Local testing

```bash
brew install --build-from-source packaging/homebrew/conduit.rb
```

### Publishing to Homebrew

1. Fork homebrew-core
2. Update SHA256 checksum after release
3. Submit PR with conduit.rb

## AUR (Arch Linux)

### Installation from AUR (future)

Once published:
```bash
yay -S conduit
# or
paru -S conduit
```

### Local testing

```bash
cd packaging/aur
makepkg -si
```

### Publishing to AUR

1. Create AUR account at https://aur.archlinux.org
2. Clone AUR repository:
   ```bash
   git clone ssh://aur@aur.archlinux.org/conduit.git
   ```
3. Copy PKGBUILD and .SRCINFO
4. Update checksums:
   ```bash
   updpkgsums
   makepkg --printsrcinfo > .SRCINFO
   ```
5. Commit and push:
   ```bash
   git add PKGBUILD .SRCINFO
   git commit -m "Initial import: conduit 1.0.0"
   git push
   ```

## Debian/Ubuntu (future)

To create .deb packages:
```bash
# Install build dependencies
sudo apt-get install debhelper dh-make

# Create debian package structure
cd /path/to/Conduit
dh_make --createorig -p conduit_1.0.0

# Build package
dpkg-buildpackage -us -uc
```

## RPM/Fedora (future)

To create .rpm packages:
```bash
# Install build dependencies
sudo dnf install rpm-build rpmdevtools

# Create RPM structure
rpmdev-setuptree

# Create spec file in ~/rpmbuild/SPECS/conduit.spec
# Build RPM
rpmbuild -ba ~/rpmbuild/SPECS/conduit.spec
```

## Contributing

To add support for additional package managers:

1. Create a subdirectory: `packaging/<manager-name>/`
2. Add package definition files
3. Test locally
4. Update this README with instructions
5. Submit a PR

## Notes

- Package definitions are updated with each release
- SHA256 checksums must be calculated after release tarball is created
- Test packages locally before publishing
- Follow each package manager's guidelines and best practices
