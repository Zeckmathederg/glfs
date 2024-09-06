# NOTICE

Development will eventually switch to https://github.com/glfs-book/glfs.
Please read the announcement in the Bulletin section of the book.

# Gaming Linux From Scatch (GLFS)

Gaming Linux From Scratch is a book that covers how to install packages
like Steam and Wine after the Linux From Scratch book.

# Where to Read

Go to https://zeckmathederg.github.io/glfs/ and start going through the book!

# Installation

How do I convert these XML files to HTML myself? You need to have some software
installed that deal with these conversions. Please read the `INSTALL.md` file to
determine what programs you need to install and where to get instructions to
install that software.

After that, you can build the html with a simple **make** command.
The default target builds the html in `$(HOME)/public_html/glfs.`

For all targets, setting the parameter `REV=systemd` is needed to build the
systemd version of the book.

Furthermore, the dark theme is the default, but you can switch the theme by
running `switch-theme.sh` with the parameter `light` or `dark`.

Other Makefile targets are: `pdf`, `nochunks`, `validate`, and `glfs-patch-list`.

`pdf`: builds GLFS as a PDF file.

`nochunks`: builds GLFS in one huge file.

`validate`:  does an extensive check for xml errors in the book.

`glfs-patch-list`: generates a list of all GLFS controlled patches in the book.
