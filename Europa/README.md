Decoding ARM-Binaries of GME files
==================================

This is a temporary repository to collaborate on understanding the `OidMain` binary of a Tiptoi pen, in particular the ZC3202N binar of of "WWW Europa.gme".

File `OidMain.txt` contains that binary deassembled. It can be copied to
`test.txt`, edited, and then the script `test.sh` can assemble it and inject it
into the GME file. This produces `WWW Europa2.gme`, which can be copied onto
the device.

If no changes are made to `OidMain.txt` this produces (here) bitwise-identical output.

File `still-works.txt` is a partial attempt at finding the smallest file that still loads the GME file, i.e. no start-up sound, but then other fields still work.

Some random notes in `notes.md`.

I am hacking on this without actually having that Toiptoi-book; I used `tttool oid-table` and printed the first page to have something to tap on. See `WWW Europa.pdf`.



