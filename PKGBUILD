# Maintainer: Cherry Linux <info.cherrylinux@gmail.com>
pkgname=md2config
pkgver=0.0.1
pkgrel=1
epoch=
pkgdesc="Convert MD files into the actual config for your programs"
arch=("any")
url=""
license=("GPL")
groups=()
depends=()
makedepends=()
checkdepends=()
optdepends=()
provides=("md2config")
conflicts=()
replaces=()
backup=()
options=()
install=
changelog=
source=("$pkgname-$pkgver.tar.gz"
        "$pkgname-$pkgver.patch")
noextract=()
md5sums=()
validpgpkeys=()

prepare() {
	cd "$pkgname-$pkgver"
	patch -p1 -i "$srcdir/$pkgname-$pkgver.patch"
}

build() {
	cd "$pkgname-$pkgver"
	./configure --prefix=/usr
	make
}

check() {
	cd "$pkgname-$pkgver"
	make -k check
}

package() {
	cd "$pkgname-$pkgver"
	make DESTDIR="$pkgdir/" install
}
