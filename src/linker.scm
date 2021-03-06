(define memories
  '((memory Boost1 (position independent)
            (bank 1) (address (#x0 . #xFFF))
            (section (BoostFAT #x0) BoostCode BoostCode1
                     BoostTable BoostSecondary1
                     (ExtensionHandlers #xF00)
                     (CAT7Shell #xF04)
                     (CatShell #xF0C)
                     (DelayShell #xF14)
                     (KeyInputShell #xF1C)
                     (BoostBankSwitchers1 #xFC3)
                     (BoostLegal7 #xCDD)
                     RPN (BoostFC2 #xFC2) (BoostPoll #xFCE) (BoostPollPart2 #xFB6))
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
