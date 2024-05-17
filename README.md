# Gaming Linux From Scatch (GLFS)

Gaming Linux From Scratch is a book that covers how to install packages
like Steam and Wine after the Linux From Scratch book.

# Where to Read and How

The HTML files aren't hosted anywhere yet, except for the GitHub releases.
Go to https://github.com/Zeckmathederg/glfs/releases and go the the newest
release. Chunked means the book is seperated into multiple HTML files.
Nochunked means the book is just one big HTML file. PDF is a big PDF
file of the book.

### Chunked:

Point your browser or HTML reader to `index.html`

### Nochunked:

Point your browser or HTML reader to `glfs.html`

### PDF

Point your browser or PDF reader to `glfs.pdf`

# Installation

How do I convert these XML files to HTML? You need to have some software
installed that deal with these conversions. Please read the `INSTALL.md` file to
determine what programs you need to install and where to get instructions to
install that software.

After that, you can build the html with a simple **make** command.
The default target builds the html in `$(HOME)/public_html/glfs.`

For all targets, setting the parameter `REV=systemd` is needed to build the
systemd version of the book.

Other Makefile targets are: `pdf`, `nochunks`, `validate`, and `glfs-patch-list`.

`pdf`: builds GLFS as a PDF file.

`nochunks`: builds GLFS in one huge file.

`validate`:  does an extensive check for xml errors in the book.

`glfs-patch-list`: generates a list of all GLFS controlled patches in the book.
