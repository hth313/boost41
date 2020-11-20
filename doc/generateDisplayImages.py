import sys
sys.path.insert(0, '../module/lcd41')

import os
import subprocess
from lcd import *

lcd = LCD41()
prgmMode = Anns()
prgmMode.annPRGM.set()

normalMode = Anns()

lcdImages = [ ("ramed-1", lcd.image("419B 0C00020", prgmMode))
            , ("ramed-2", lcd.image("419B 0C000_0", prgmMode))
            , ("catprompt", lcd.image("CAT' __", normalMode))
            , ("exchange-1", lcd.image("&lt;&gt; __", normalMode))
            , ("exchange-2", lcd.image("&lt;&gt; ST _", normalMode))
            , ("exchange-3", lcd.image("&lt;&gt; Z __", normalMode))
            , ("exchange-4", lcd.image("&lt;&gt; Z IND __", normalMode))
            , ("exchange-5", lcd.image("&lt;&gt; Z IND 10", normalMode))
            , ("exchange-6", lcd.image("05 Z &lt;&gt; 07", prgmMode))
            , ("cat-7", lcd.image("15 002  @192", normalMode))
            , ("asn-1", lcd.image("ASN' ___", normalMode))
            , ("asn-xrom-1", lcd.image("ASN' XR __", normalMode))
            , ("asn-xrom-2", lcd.image("ASN' XR 0_", normalMode))
            , ("asn-xrom-3", lcd.image("ASN' XR 06,__", normalMode))
            , ("asn-xrom-4", lcd.image("ASN' XR 06,1_", normalMode))
            , ("asn-xrom-5", lcd.image("N' XR 06,10 _", normalMode))
            , ("xeq-1", lcd.image("XEQ' __", normalMode))
            , ("xeq-xrom-1", lcd.image("XEQ' XR __", normalMode))
            , ("xeq-xrom-2", lcd.image("XEQ' XR 0_", normalMode))
            , ("xeq-xrom-3", lcd.image("XEQ' XR 06,__", normalMode))
            , ("xeq-xrom-4", lcd.image("XEQ' XR 06,1_", normalMode))
            , ("xeq-xrom-5", lcd.image("XROM 06,10", normalMode))
            ]

for (file, body) in lcdImages:
    svgfile = file + ".svg"
    pdffile = file + ".pdf"
    f = open(os.path.join("_static", svgfile), "w")
    f.write(body)
    f.close()
    command_line = ["inkscape", "--export-filename=" + pdffile, "--export-dpi=96", svgfile]
    subprocess.call(command_line, cwd="_static")
