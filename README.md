# x86-64 assembly programs

This directory contains some small assembly programs I wrote. They can all be assembled with [fasm](https://flatassembler.net/download.php).

- **cyrillify**: takes a file and replaces Latin letters with similar looking Cyrillic letters (e.g. n with п). Stealth mode (using the `-s` flag) replaces only exact matches (e.g. a with а). **MODIFIES THE FILE IN PLACE**.
- **reverse**: asks the user for a input, returns the reverse of that input and exits.
- **fizzbuzz** solves the famous fizzbuzz problem from 1 to 100 then exits.
