# toshack
Provide patches to existing Atari TOS images (intended for TOS404 under DFB1)

## patcher.c
This is the 'master control' program and the thing that does the actual patching.

Input and output filenames are defined here.

Which patches to apply are defined here.

The patches consist of either a few bytes declared in a struct or a machine code file which is also declared in a struct.

The list of those structs active is then defined (two separate pointer arrays)

## machine code files
The machine code files are compiled using vasm from source files. Examples are included. The obvious one is the TT-RAM detection routine based on work by Anders Granlund and released under the GPLv2.

## make
The build environment is anticipated to be GNU/Linux with gcc and the Motorola syntax vasm assembler, although if you have an appropriate gcc and vasmm68k_mot in your path, this should work on any Posix-ish system.

By default runnning 'make' will build the patcher program and its dependencies and then will run patcher to produce the OUTPUT file from the INPUT file.

# Licence
Released under the terms of the GPLv2.
Copyright 2022 D Henderson and 2019 Anders Grandlund
