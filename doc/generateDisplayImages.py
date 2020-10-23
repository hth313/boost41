import sys
sys.path.insert(0, '../module/lcd41')

import os
import subprocess
from lcd import *

lcd = LCD41()
prgmMode = Anns()
prgmMode.annPRGM.set()

lcdImages = [ ("ramed-1", lcd.image("419B 0C00020", prgmMode))
            , ("ramed-2", lcd.image("419B 0C000_0", prgmMode))
            , ("catprompt", lcd.image("CAT' __", prgmMode))]

for (file, body) in lcdImages:
    svgfile = file + ".svg"
    pdffile = file + ".pdf"
    f = open(os.path.join("_static", svgfile), "w")
    f.write(body)
    f.close()
    command_line = ["inkscape", "--export-filename=" + pdffile, "--export-dpi=96", svgfile]
    subprocess.call(command_line, cwd="_static")
