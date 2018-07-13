This repository contains partially reverse-engineered firmware of
Intel iSBC 215 Multibus Winchester disk controllers.

Contents:

* 14458x.asm, from 2732 EPROMs with part numbers 144580-001 and 144581-001.
These are from an iMDX 704 controller (iSBC 215B), part of an iMDX 750
subsystem for Series II/III MDS.

* 147931.asm, from 2764 EPROMs with part numbers 147931-001 and 147931-002.
This is believed to be a production release of "normal" iSBC 215G firmware,
as opposed to special firmware for the Intel MDS Series II/III/IV
development systems.

## Technical documentation for iSBC 215 and related hardware
Large PDF files of scans, from the [Bitsavers](http://bitsavers.org/) collection:
* [iSBC 215 Winchester Disk Controller Hardware Reference Manual](http://bitsavers.org/pdf/intel/iSBC/121593-002_iSBC_215A_B_Winchester_Disk_Controller_Hardware_Reference_Manual_Sep81.pdf)  
  Intel Corporation, September 1981, order number 121593-002  
  covers iSBC 215A and iSBC 215B

* [iSBC 215 Generic Winchester Disk Controller Hardware Reference Manual](http://bitsavers.org/pdf/intel/iSBC/144780-002_iSBC_215_Generic_Winchester_Disk_Controller_Hardware_Reference_Manual_Dec84.pdf)  
  Intel Corporation, December 1984, order number 144780-002  
  covers iSBC 215G

* [iSBX 218A Flexible Diskette Controller Board Hardware Reference Manual](http://bitsavers.org/pdf/intel/iSBX/145911-001_iSBX_218_Flexible_Diskette_Controller_Hardware_Reference_Aug83.pdf)  
  Intel Corporation, August 1983, order number 145911-001

* [iSBX 217B Magnetic Cartridge Tape Interface Multimodule Board Hardware Reference Manual](http://bitsavers.org/pdf/intel/iSBX/145497-001_iSBX_217B_Magnetic_Cartridge_Tape_Interface_Hardware_Reference_Manual_Dec82.pdf)  
  Intel Corporation, November 1982, order number 145497-001
