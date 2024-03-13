# nanoFET calibration

CREATED: 10 October 2023 Jack Long (MBARI)

CONTACT: Yui Takeshita (MBARI) yui@mbari.org 

For further details, including file storage paths, see Google Document: /Carbon Group/..../Calibration code notes: NanoFET.docx

DESCRIPTION
Scripts to generate a cal file (xyz.cal) to upload onto the NanoFET after it has gone through the k0 process. The k0 process is when the NanoFET will be run in the wetlab, and periodically discrete samples are taken for calibration. 
The main objective is to have a user-friendly cal file so that when we ship out a NanoFET to another lab, they are able to load the new calibration information themselves.

EXAMPLE FILES
INPUT:
DF383_Calibration_20230410.TXT
OUTPUT:
NanoFET_calfile_example.cal 


Each DSD is in a separate folder, named: DF_308_MSC0931 (for example). 308 is the DSD number, and MSC0931 is the controller number. The MSC Controller will get assigned once it goes through the k0 process in the Johnson lab for floats. For ours, it will not have a MSC associated with it, so the directory will be called, e.g. DF_403_MSCxxxxx (will verify)

The rest will have to be calculated, based on the spec pH measurements and sensor readings in the wet lab. 

To calculate k0, you will need Vrs (sensor reading), k2 (from Johnson lab cal file), and pH of the solution (discrete sample). Use function calc_k0_ext.m for this.



