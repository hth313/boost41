(define memories
  '((memory Boost (position independent)
            (bank 1) (address (#x0 . #xFFF))
            (section (BoostFAT #x0) BoostCode Lib41Code
                     BoostTable BoostSecondary BoostSecondary1
                     RPN (BoostFC6 #xFC6) (BoostPoll #xFE0))
            (checksum #xFFF hp41)
            (fill 0))))
