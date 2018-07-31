# GTK for windows environments

This project aims to produce consistent, complete and portable gtk environment for windows targets (mingw).

# Build process

## Basic prereqs

```
# apt-get install git make
```

## Build prereqs

```
# apt-get install gcc-mingw-w64-i686 gcc pkg-config
```

## glib prereqs

```
# apt-get install gettext
```

## atk prereqs

debian stretch:
```
# apt-get install libglib2.0-dev
```

newer debian:
```
# apt-get install libglib2.0-dev-bin
```

## gdk-pixbuf prereqs

```
# apt-get install wine wine-binfmt mingw-w64-i686-dev
```

## harfbuzz prereqs

```
# apt-get install g++-mingw-w64-i686
```

GDK-pixbuf needs to run some win32 programs during build. These can be executed by wine, but if you are building 32bit version, it needs wine32:

```
# dpkg --add-architecture i386 && apt-get update &&
# apt-get install wine32
```


* VTE prereqs:

```
apt-get install intltool
```
