# minnowTraits
Using trait segmentation to understand minnow trait evolution across an ecological gradient

## Minnow image selection
Images were previously segmented using machine learning (<a href="https://github.com/hdr-bgnn/BGNN-trait-segmentation">BGNN trait segementation</a>).

We used the combined violation tables merged with the image quality metadata and image metadata (<a href="https://drive.google.com/file/d/1rrXSM77S7iduVbNogI-_0bucrpqZdzvM/view?usp=sharing">fish.meta.qual.tax.csv</a>), this was done using this <a href=
"https://drive.google.com/file/d/13o_ComN2cNaZxT_gqjqFi6_If0FFavBQ/view?usp=sharing">R code</a>. See the <a href="https://drive.google.com/file/d/1mtSAuxQKvctaUp4ksPPGYpsvNzsoypc9/view?usp=sharing">Batch Info</a> for how these violation tables were made and <a href="https://drive.google.com/file/d/1H0AQSLY3-Akr4DFa2zYo8JJ_N_ET0I7m/view?usp=sharing">CSV Info</a> for information about the column headers.

The minnow.selected.csv file was derived from the fish.meta.qual.tax.csv, and filtered on institution.y == “INHS”, specimen.viewing == “left”, as well as only one “blob” for the head and the eye (CC.HEAD == 1, CC.EYE == 1). 
