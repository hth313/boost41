(define memories
  '((memory Boost (position independent)
            (bank 1) (address (#x0 . #xFFF))
            (section (BoostFAT #x0) BoostCode Lib41Code
                     BoostTable BoostSecondary BoostSecondary1
                     (ExtensionHandlers #xF00)
                     (CAT7Shell #xF04)
                     (CatShell #xF0C)
                     RPN (BoostFC2 #xFC2) (BoostPoll #xFE0))
            (checksum #xFFF hp41)
            (fill 0))))
