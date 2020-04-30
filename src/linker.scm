(define memories
  '((memory Boost1 (position independent)
            (bank 1) (address (#x0 . #xFFF))
            (section (BoostFAT #x0) BoostCode BoostCode1 Lib41Code
                     BoostTable BoostSecondary1
                     (ExtensionHandlers #xF00)
                     (CAT7Shell #xF04)
                     (CatShell #xF0C)
                     (BoostBankSwitchers1 #xFC3)
                     RPN (BoostFC2 #xFC2) (BoostPoll #xFDC))
            (checksum #xFFF hp41)
            (fill 0))
    (memory Boost2 (position independent)
            (bank 2) (address (#x0 . #xFFF))
            (section (BoostHeader2 #x0) BoostCode2
                     BoostSecondary2
                     (BoostBankSwitchers2 #xFC3)
                     (BoostTail2 #xFF4))
            (checksum #xFFF hp41)
            (fill 0))))
