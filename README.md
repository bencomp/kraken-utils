# Kraken utilities

[kraken] is an OCR/HTR application.
This repository contains utilities that do not fit kraken directly.

## Remove Word and Glyph elements from PageXML

The `remove-glyph.xsl` stylesheet removes `<Word>` and `<Glyph>` elements
from PageXML files (and formats the output) to make correcting OCR results
at the `<TextLine>` level easier.

For example, using `find`, `parallel` and `saxon` to remove the elements
and visualising the segmentation using a kraken-provided script:

```sh
find . -name "*_page_bl_ocr.xml" | parallel 'saxon -s:{} -xsl:/path/to/kraken-util/remove-glyph.xsl -o:{.}_clean.xml'
find . -name "*_page_bl_ocr_nfd.xml" | parallel 'saxon -s:{} -xsl:/path/to/kraken-util/remove-glyph.xsl -o:{.}_clean.xml'
find . -name "*_page_bl_ocr_clean.xml" | parallel 'python /path/to/kraken/kraken/contrib/segmentation_overlay.py {}'
```

[kraken]: http://kraken.re

## ALICE trick

Show resource availability on (a partition of) ALICE:

```sh
sinfo -p gpu-medium -N --Format=Nodelist:15,Available:10,Time:15,StateLong:10,Memory:10,FreeMem:10,CPUsLoad:10,CPUsState:15,GresUsed:10,Features:20,Reason:10
```

Check resource usage of a running job:

```sh
sstat --format=AveCPU,AvePages,AveRSS,AveVMSize,MaxVMSize,JobID -j $JOB_NUM
```