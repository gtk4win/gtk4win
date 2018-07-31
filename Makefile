HERE=$(shell pwd)
NPROC=$(shell nproc)

#prereqs: wine mingw-w64 wine-binfmt

.PHONY: all
all: pure-gtk

.PHONY: pure-gtk
pure-gtk: checkdirs gtk

.PHONY: checkdirs
checkdirs:
	set -e ; \
	if [ ! -e usr ]; then \
		mkdir usr ; \
		mkdir usr/include ; \
		mkdir usr/lib ; \
		mkdir usr/bin ; \
		cp /usr/i686-w64-mingw32/lib/libwinpthread-1.dll ./usr/bin ; \
		if [ -e /usr/lib/gcc/i686-w64-mingw32/7.3-win32/ ]; then cp /usr/lib/gcc/i686-w64-mingw32/7.3-win32/libgcc_s_sjlj-1.dll ./usr/bin ; fi ; \
		if [ -e /usr/lib/gcc/i686-w64-mingw32/6.3-win32/ ]; then cp /usr/lib/gcc/i686-w64-mingw32/6.3-win32/libgcc_s_sjlj-1.dll ./usr/bin ; fi ; \
	fi; \
	if [ ! -e build ]; then \
		mkdir build ; \
	fi ; \
	if [ ! -e src ]; then \
		mkdir src ; \
	fi ; \
	if [ ! -e status ]; then \
		mkdir status ; \
	fi ; \

.PHONY: zlib
zlib: status/zlib

status/zlib: checkdirs
	echo "Build zlib"
	if [ ! -e src/zlib-1.2.11.tar.gz ]; then cd src; wget http://uprojects.org/archive/gtk4win/zlib-1.2.11.tar.gz ; fi
	if [ ! -e build/zlib-1.2.11 ]; then cd build; tar xf ../src/zlib-1.2.11.tar.gz; fi
	cd build/zlib-1.2.11/; make -j$(NPROC) -f win32/Makefile.gcc PREFIX=i686-w64-mingw32- DESTDIR=../../usr/ INCLUDE_PATH=include LIBRARY_PATH=lib BINARY_PATH=bin SHARED_MODE=1
	cd build/zlib-1.2.11/; make -f win32/Makefile.gcc PREFIX=i686-w64-mingw32- DESTDIR=../../usr/ INCLUDE_PATH=include LIBRARY_PATH=lib BINARY_PATH=bin SHARED_MODE=1 install
	sed -i -e "s|prefix=/usr/local|prefix=$(HERE)/usr|" $(HERE)/usr/lib/pkgconfig/zlib.pc
	sed -i -e 's|libdir=lib|libdir=$${exec_prefix}/lib|' $(HERE)/usr/lib/pkgconfig/zlib.pc
	sed -i -e 's|includedir=include|includedir=$${prefix}/include|' $(HERE)/usr/lib/pkgconfig/zlib.pc
	sed -i -e 's|sharedlibdir=.*|sharedlibdir=$${exec_prefix}/bin|' $(HERE)/usr/lib/pkgconfig/zlib.pc
	touch status/zlib

.PHONY: libpng
libpng: status/libpng

status/libpng: checkdirs status/zlib
	echo "Build libpng"
	if [ ! -e src/libpng-1.6.34.tar.xz ]; then cd src; wget http://uprojects.org/archive/gtk4win/libpng-1.6.34.tar.xz ; fi
	if [ ! -e build/libpng-1.6.34 ]; then cd build; tar xf ../src/libpng-1.6.34.tar.xz; fi
	cd build/libpng-1.6.34; ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ --with-zlib-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CPPFLAGS="-I$(HERE)/usr/include"
	cd build/libpng-1.6.34; make -j$(NPROC)
	cd build/libpng-1.6.34; make install
	touch status/libpng

.PHONY: pixman
pixman: status/pixman

status/pixman: checkdirs status/libpng
	echo "Build pixman"
	if [ ! -e src/pixman-0.34.0.tar.gz ]; then cd src; wget http://uprojects.org/archive/gtk4win/pixman-0.34.0.tar.gz ; fi
	if [ ! -e build/pixman-0.34.0 ]; then cd build; tar xf ../src/pixman-0.34.0.tar.gz; fi
	cd build/pixman-0.34.0; ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr/ --enable-libpng
	cd build/pixman-0.34.0; make -j$(NPROC)
	cd build/pixman-0.34.0; make install
	touch status/pixman

.PHONY: freetype
freetype: status/freetype

status/freetype: checkdirs status/zlib status/harfbuzz
	echo "Build freetype"
	if [ ! -e src/freetype-2.9.1.tar.bz2 ]; then cd src; wget http://uprojects.org/archive/gtk4win/freetype-2.9.1.tar.bz2 ; fi
	if [ ! -e build/freetype-2.9.1 ]; then cd build; tar xf ../src/freetype-2.9.1.tar.bz2; fi
	cd build/freetype-2.9.1; ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr/
	cd build/freetype-2.9.1; make -j$(NPROC)
	cd build/freetype-2.9.1; make install
	touch status/freetype

.PHONY: libiconv
libiconv: status/libiconv

status/libiconv: checkdirs
	echo "Build iconv"
	if [ ! -e src/libiconv-1.15.tar.gz ]; then cd src; wget http://uprojects.org/archive/gtk4win/libiconv-1.15.tar.gz ; fi
	if [ ! -e build/libiconv-1.15 ]; then cd build; tar xf ../src/libiconv-1.15.tar.gz; fi
	cd build/libiconv-1.15; ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr/
	cd build/libiconv-1.15; make -j$(NPROC)
	cd build/libiconv-1.15; make install
	touch status/libiconv

.PHONY: libxml2
libxml2: status/libxml2

status/libxml2: checkdirs
	echo "Build libxml2"
	if [ ! -e src/libxml2-2.9.8.tar.gz ]; then cd src; wget http://uprojects.org/archive/gtk4win/libxml2-2.9.8.tar.gz ; fi
	if [ ! -e build/libxml2-2.9.8 ]; then cd build; tar xf ../src/libxml2-2.9.8.tar.gz; fi
	cd build/libxml2-2.9.8; ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr/ --without-python
	cd build/libxml2-2.9.8; make -j$(NPROC)
	cd build/libxml2-2.9.8; make install
	touch status/libxml2

.PHONY: gettext
gettext: status/gettext

status/gettext: checkdirs
	echo "Build gettext"
	if [ ! -e src/gettext-0.19.8.1.tar.xz ]; then cd src; wget http://uprojects.org/archive/gtk4win/gettext-0.19.8.1.tar.xz ; fi
	if [ ! -e build/gettext-0.19.8.1 ]; then cd build; tar xf ../src/gettext-0.19.8.1.tar.xz; fi
	cd build/gettext-0.19.8.1/gettext-runtime; ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr/
	cd build/gettext-0.19.8.1/gettext-runtime; make -j$(NPROC)
	cd build/gettext-0.19.8.1/gettext-runtime; make install
	touch status/gettext

.PHONY: libffi
libffi: status/libffi

status/libffi: checkdirs
	echo "Build libffi"
	if [ ! -e src/libffi-3.2.1.tar.gz ]; then cd src; wget http://uprojects.org/archive/gtk4win/libffi-3.2.1.tar.gz ; fi
	if [ ! -e build/libffi-3.2.1 ]; then cd build; tar xf ../src/libffi-3.2.1.tar.gz; fi
	cd build/libffi-3.2.1; ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr
	cd build/libffi-3.2.1; make -j$(NPROC)
	cd build/libffi-3.2.1; make install
	touch status/libffi

.PHONY: glib
glib: status/glib

status/glib: checkdirs status/zlib status/libffi status/gettext
	echo "Build glib"
	if [ ! -e src/glib-2.56.1.tar.xz ]; then cd src; wget http://uprojects.org/archive/gtk4win/glib-2.56.1.tar.xz ; fi
	if [ ! -e build/glib-2.56.1 ]; then cd build; tar xf ../src/glib-2.56.1.tar.xz; fi
	cd build/glib-2.56.1; ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr --with-pcre=internal
	cd build/glib-2.56.1; make -j$(NPROC)
	cd build/glib-2.56.1; make install
	touch status/glib

#PCRE_CFLAGS="-I$(HERE)/usr/include" PCRE_LIBS="-L$(HERE)/usr/bin -lpcre-1"

.PHONY: atk
atk: status/atk

status/atk: checkdirs status/glib
	echo "Build atk"
	if [ ! -e src/atk-2.28.1.tar.xz ]; then cd src; wget http://uprojects.org/archive/gtk4win/atk-2.28.1.tar.xz ; fi
	if [ ! -e build/atk-2.28.1 ]; then cd build; tar xf ../src/atk-2.28.1.tar.xz; fi
	cd build/atk-2.28.1; ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr/
	cd build/atk-2.28.1; make -j$(NPROC)
	cd build/atk-2.28.1; make install
	touch status/atk

.PHONY: gdk-pixbuf
gdk-pixbuf: status/gdk-pixbuf

status/gdk-pixbuf: checkdirs status/libpng status/glib status/gettext status/libiconv
	echo "Build gdk-pixbuf"
	if [ ! -e src/gdk-pixbuf-2.36.11.tar.xz ]; then cd src; wget http://uprojects.org/archive/gtk4win/gdk-pixbuf-2.36.11.tar.xz ; fi
	if [ ! -e build/gdk-pixbuf-2.36.11 ]; then cd build; tar xf ../src/gdk-pixbuf-2.36.11.tar.xz; fi
	cd build/gdk-pixbuf-2.36.11; WINEPATH="%WINEPATH;$(HERE)/usr/bin/" ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr/
	cd build/gdk-pixbuf-2.36.11; WINEPATH="%WINEPATH;$(HERE)/usr/bin" make -j$(NPROC)
	cd build/gdk-pixbuf-2.36.11; make install
	touch status/gdk-pixbuf

#WINEPATH="%WINEPATH;$(HERE)/usr/bin/" 

.PHONY: fontconfig
fontconfig: status/fontconfig

status/fontconfig: checkdirs
	echo "Build fontconfig"
	if [ ! -e src/fontconfig-2.13.0.tar.gz ]; then cd src; wget http://uprojects.org/archive/gtk4win/fontconfig-2.13.0.tar.gz ; fi
	if [ ! -e build/fontconfig-2.13.0 ]; then cd build; tar xf ../src/fontconfig-2.13.0.tar.gz; fi
	cd build/fontconfig-2.13.0; ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/bin -liconv-2 -lintl-8" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr/ --enable-libxml2
	cd build/fontconfig-2.13.0; make -j$(NPROC)
	cd build/fontconfig-2.13.0; make install
	touch status/fontconfig

.PHONY: cairo
cairo: status/cairo

status/cairo: checkdirs status/pixman status/freetype
	echo "Build cairo"
	if [ ! -e src/cairo-1.15.12.tar.xz ]; then cd src; wget http://uprojects.org/archive/gtk4win/cairo-1.15.12.tar.xz ; fi
	if [ ! -e build/cairo-1.15.12 ]; then cd build; tar xf ../src/cairo-1.15.12.tar.xz; fi
	cd build/cairo-1.15.12; ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr/
	cd build/cairo-1.15.12; make -j$(NPROC)
	cd build/cairo-1.15.12; make install
	touch status/cairo

.PHONY: fribidi
fribidi: status/fribidi

status/fribidi: checkdirs
	echo "Build fribidi"
	if [ ! -e src/fribidi-1.0.2.tar.bz2 ]; then cd src; wget http://uprojects.org/archive/gtk4win/fribidi-1.0.2.tar.bz2 ; fi
	if [ ! -e build/fribidi-1.0.2 ]; then cd build; tar xf ../src/fribidi-1.0.2.tar.bz2; fi
	cd build/fribidi-1.0.2; ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr/ --disable-docs
	cd build/fribidi-1.0.2; make -j$(NPROC)
	cd build/fribidi-1.0.2; make install
	touch status/fribidi

.PHONY: harfbuzz
harfbuzz: status/harfbuzz

status/harfbuzz: checkdirs status/glib status/cairo status/fontconfig status/freetype
	echo "Build harfbuzz"
	if [ ! -e src/harfbuzz-1.8.1.tar.bz2 ]; then cd src; wget http://uprojects.org/archive/gtk4win/harfbuzz-1.8.1.tar.bz2 ; fi
	if [ ! -e build/harfbuzz-1.8.1 ]; then cd build; tar xf ../src/harfbuzz-1.8.1.tar.bz2; fi
	cd build/harfbuzz-1.8.1; ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" CXXFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr/ --with-icu=no
	cd build/harfbuzz-1.8.1; make -j$(NPROC)
	cd build/harfbuzz-1.8.1; make install
	touch status/harfbuzz

.PHONY: pango
pango: status/pango

status/pango: checkdirs
	echo "Build pango"
	if [ ! -e src/pango-1.42.1.tar.xz ]; then cd src; wget http://uprojects.org/archive/gtk4win/pango-1.42.1.tar.xz ; fi
	if [ ! -e build/pango-1.42.1 ]; then cd build; tar xf ../src/pango-1.42.1.tar.xz; fi
	cd build/pango-1.42.1; ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr/ --disable-installed-tests
	cd build/pango-1.42.1; WINEPATH="%WINEPATH;$(HERE)/usr/bin" make -j$(NPROC)
	cd build/pango-1.42.1; make install
	touch status/pango

.PHONY: libepoxy
libepoxy: status/libepoxy

status/libepoxy: checkdirs
	echo "Build libepoxy"
	if [ ! -e src/libepoxy-1.5.2.tar.xz ]; then cd src; wget http://uprojects.org/archive/gtk4win/libepoxy-1.5.2.tar.xz ; fi
	if [ ! -e build/libepoxy-1.5.2 ]; then cd build; tar xf ../src/libepoxy-1.5.2.tar.xz; fi
	cd build/libepoxy-1.5.2; ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" CXXFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr/
	cd build/libepoxy-1.5.2; make -j$(NPROC)
	cd build/libepoxy-1.5.2; make install
	touch status/libepoxy

.PHONY: gtk
gtk: status/gtk

status/gtk: checkdirs
	echo "Build gtk"
	if [ ! -e src/gtk+-3.22.30.tar.xz ]; then cd src; wget http://uprojects.org/archive/gtk4win/gtk+-3.22.30.tar.xz ; fi
	if [ ! -e build/gtk+-3.22.30 ]; then cd build; tar xf ../src/gtk+-3.22.30.tar.xz; fi
	cd build/gtk+-3.22.30; WINEPATH="%WINEPATH;$(HERE)/usr/bin" ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr/ --disable-installed-tests
	cd build/gtk+-3.22.30; WINEPATH="%WINEPATH;$(HERE)/usr/bin" make -j$(NPROC)
	cd build/gtk+-3.22.30; WINEPATH="%WINEPATH;$(HERE)/usr/bin" make install
	touch status/gtk

.PHONY: vte
vte: status/vte

status/vte: checkdirs
	echo "Build vte"
	if [ ! -e src/vte-0.52.2.tar.xz ]; then cd src; wget http://uprojects.org/archive/gtk4win/vte-0.52.2.tar.xz ; fi
	if [ ! -e build/vte-0.52.2 ]; then cd build; tar xvf ../src/vte-0.52.2.tar.xz; fi
	cd build/vte-0.52.2; WINEPATH="%WINEPATH;$(HERE)/usr/bin" ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr/ --disable-installed-tests --without-gnutls --disable-introspection --disable-vala
	cd build/vte-0.52.2; WINEPATH="%WINEPATH;$(HERE)/usr/bin" make -j$(NPROC)
	cd build/vte-0.52.2; WINEPATH="%WINEPATH;$(HERE)/usr/bin" make install
	touch status/vte

.PHONY: pcre
pcre: status/pcre

status/pcre: checkdirs
	echo "Build pcre"
	if [ ! -e src/pcre-8.42.tar.bz2 ]; then cd src; wget http://uprojects.org/archive/gtk4win/pcre-8.42.tar.bz2 ; fi
	if [ ! -e build/pcre-8.42 ]; then cd build; tar xf ../src/pcre-8.42.tar.bz2; fi
	cd build/pcre-8.42; ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr/ --enable-utf --enable-unicode-properties
	cd build/pcre-8.42; make -j$(NPROC)
	cd build/pcre-8.42; make install
	touch status/pcre

.PHONY: pcre2
pcre2: status/pcre2

status/pcre2: checkdirs
	echo "Build pcre2"
	if [ ! -e src/pcre2-10.31.tar.bz2 ]; then cd src; wget http://uprojects.org/archive/gtk4win/pcre2-10.31.tar.bz2 ; fi
	if [ ! -e build/pcre2-10.31 ]; then cd build; tar xf ../src/pcre2-10.31.tar.bz2; fi
	cd build/pcre2-10.31; ./configure --host=i686-w64-mingw32 --prefix=$(HERE)/usr/ --exec-prefix=$(HERE)/usr/ LDFLAGS="-L$(HERE)/usr/lib" CFLAGS="-I$(HERE)/usr/include" CPPFLAGS="-I$(HERE)/usr/include" PKG_CONFIG_PATH=$(HERE)/usr/lib/pkgconfig PKG_CONFIG_LIBDIR=$(HERE)/usr/ --enable-utf --enable-unicode-properties
	cd build/pcre2-10.31; make -j$(NPROC)
	cd build/pcre2-10.31; make install
	touch status/pcre2

.PHONY: gnulib
gnulib: status/gnulib

status/gnulib: checkdirs
	echo "Build gnulib"
	if [ ! -e build/gnulib ]; then cd build; cp -pr ../src/gnulib ./ ; fi

.PHONY: dist-clean
dist-clean:
	rm -rf usr
	rm -rf build
	rm -rf status
