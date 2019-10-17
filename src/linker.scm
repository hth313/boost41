(define memories
  '((memory Boost (position independent)
            (bank 1) (address (#x0 . #xFFF))
            (section (BoostFAT #x0) BoostCode Lib41Code
                     BoostTable RPN (BoostPoll #xFE2))
            (checksum #xFFF hp41)
            (fill 0))))
