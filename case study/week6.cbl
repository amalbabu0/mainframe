       IDENTIFICATION DIVISION.
       PROGRAM-ID. WEEK5.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
            SELECT OUTFILE ASSIGN DD1
            ORGANIZATION SEQUENTIAL
            ACCESS MODE SEQUENTIAL
            FILE STATUS WS-FS2.
       DATA DIVISION.
       FILE SECTION.
       FD OUTFILE.
       01 OUTREC.
            10 O-ACC-NO         PIC X(5).
            10 O-OLDEST-DATE    PIC X(10).
            10 O-LATEST-DATE    PIX X(10).
            10 O-PY-CHANGE      PIC X(3).
            10 FILLER           PIC X(47).
       WORKING-STORAGE SECTION.
           EXEC SQL
               INCLUDE SQLCA
           END-EXEC.
           EXEC SQL 
               INCLUDE PAYMENT-DETAIL
           END-EXEC. 
           EXEC SQL
               DECLARE CR1 CURSOR FOR
               SELECT * FROM TABLE1 ORDER BY ACCT_NBR
           END-EXEC.
            01  WS-FS2                 PIC 99.
            01  WS-DAY                 PIC 99.
            01  WS-MONTH               PIC 99.
            01  WS-YEAR                PIC 9(4).
            01  WS-DATE                PIC 9(8).
            01  P-WS-DATE              PIC 9(8).
            01  P-ACC-NO               PIC X(5).
            01  P-PMNT_DT              PIC X(10).
            01  P-PY-AMT               PIC S9(9)V99 COMP-3.
            01 WS-CRT                  PIC 99.
       PROCEDURE DIVISION.
       0000-MAIN-PARA.
            PERFORM 1000-INIT-PARA
               THRU 1000-INIT-EXIT.
            PERFORM 2000-PFM-PARA
               THRU 2000-PFM-EXIT
            PERFORM 3000-TERM-PARA.
       1000-INIT-PARA.
            INITIALIZE WS-FS2 WS-DATE WS-CRT WS-DAY 
                       WS-MONTH
       1000-INIT-EXIT.
            EXIT.
       2000-PFM-PARA.
            PERFORM 2100-OPEN-PARA
               THRU 2100-OPEN-EXIT.
            PERFORM 2200-FETCH-PARA
               THRU 2200-FETCH-EXIT UNTIL SQLCODE = 100.
            PERFORM 2300-CLOSE-PARA
               THRU 2300-CLOSE-EXIT.
       2000-PFM-EXIT.
            EXIT.
       3000-TERM-PARA.
            STOP RUN.
       2100-OPEN-PARA.
      *-----------------------------------------------------------------
            OPEN OUTPUT OUTFILE.
            EVALUATE WS-FS2
               WHEN 00
                   DISPLAY "OPEN OUTFILE SUCCESS"
               WHEN OTHER
                   DISPLAY "OPEN ERROR OUTFILE: " WS-FS2
                   PERFORM 2300-CLOSE-PARA
                      THRU 2300-CLOSE-EXIT
            END-EVALUATE
      *-----------------------------------------------------------------
           EXEC SQL 
               OPEN CR1
           END-EXEC.
            EVALUATE TRUE
               WHEN SQLCODE = 00
                   DISPLAY "OPEN CR1 SUCCESS"
               WHEN OTHER
                   DISPLAY "OPEN ERROR CR1: " SQLCODE
                   PERFORM 2300-CLOSE-PARA
                      THRU 2300-CLOSE-EXIT
            END-EVALUATE
      *-----------------------------------------------------------------
       2100-OPEN-EXIT.
            EXIT.
       2200-FETCH-PARA.
            EXEC SQL
               FETCH CR1 INTO  :HV-ACCT_NBR
                               :HV-PMNT_AMT
                               :HV-PMNT_DT 
            END-EXEC.
            EVALUATE TRUE
               WHEN SQLCODE = 0
                   PERFORM 2210-DATE-PARA
                      THRU 2210-DATE-EXIT.
               WHEN SQLCODE = 100
                   DISPLAY "NO RECORD FOUND"
               WHEN OTHER
                   DISPLAY "OPEN ERROR CR1: " SQLCODE
                   PERFORM 2300-CLOSE-PARA
                      THRU 2300-CLOSE-EXIT
            END-EVALUATE
       2200-FETCH-EXIT.
            EXIT.
       2300-CLOSE-PARA.
      *-----------------------------------------------------------------
            EXEC SQL
               CLOSE CR1
            END-EXEC.
            EVALUATE TRUE
               WHEN SQLCODE = 0
                   DISPLAY "CLOSE CR1 SUCCESS"
               WHEN OTHER
                   DISPLAY "CLOSE ERROR CR1: " SQLCODE
                   PERFORM 3000-TERM-PARA
            END-EVALUATE
      *-----------------------------------------------------------------
            CLOSE OUTFILE.
            EVALUATE WS-FS2
               WHEN 00
                   DISPLAY "CLOSE OUTFILE SUCCESS"
               WHEN OTHER
                   DISPLAY "CLOSE ERROR OUTFILE: " WS-FS2
                   PERFORM 2300-CLOSE-PARA
                      THRU 2300-CLOSE-EXIT
            END-EVALUATE
      *-----------------------------------------------------------------
       2210-DATE-PARA.
            EVALUATE TRUE
                 WHEN HV-ACCT_NBR = P-ACC-NO
      *-----------------------------------------------------------------
                      ADD 1 TO WS-CRT
                      MOVE HV-ACCT_NBR TO O-ACC-NO.
                      UNSTRING HV-PMNT_DT DELIMITED BY '/'
                          INTO WS-DAY WS-MONTH WS-YEAR
                      END-UNSTRING
                      STRING WS-YEAR  DELIMITED BY SIZE
                             WS-MONTH DELIMITED BY SIZE
                             WS-DAY   DELIMITED BY SIZE
                        INTO WS-DATE
      *-----------------------------------------------------------------
                      EVALUATE TRUE
                           WHEN WS-DATE = P-WS-DATE
                                MOVE HV-PMNT_DT TO O-LATEST-DATE
                                MOVE HV-PMNT_DT TO O-OLDEST-DATE
                           WHEN WS-DATE < P-WS-DATE
                                MOVE HV-PMNT_DT TO O-LATEST-DATE
                                MOVE P-PMNT_DT  TO O-OLDEST-DATE
                           WHEN WS-DATE > P-WS-DATE
                                MOVE P-PMNT_DT  TO O-LATEST-DATE
                                MOVE HV-PMNT_DT TO O-OLDEST-DATE
                      END-EVALUATE
      *-----------------------------------------------------------------
                      EVALUATE TRUE 
                           WHEN HV-PMNT_AMT NOT = P-PY-AMT
                                MOVE "YES" TO O-PY-CHANGE
                           WHEN OTHER
                                MOVE "NO" TO O-PY-CHANGE
                      END-EVALUATE
      *-----------------------------------------------------------------
                      MOVE PY-AMT     TO P-PY-AMT.
                      MOVE ACC-NO     TO P-ACC-NO.
                      MOVE HV-PMNT_DT TO P-PMNT_DT.
                 WHEN OTHER
                      EVALUATE TRUE
                           WHEN WS-CRT NOT = 0
                                WRITE OUTREC
                                MOVE 00 TO WS-CRT
                           WHEN OTHER 
                                CONTINUE
                      END-EVALUATE
                      MOVE PY-AMT     TO P-PY-AMT.
                      MOVE ACC-NO     TO P-ACC-NO.
                      MOVE HV-PMNT_DT TO P-PMNT_DT.
                      UNSTRING HV-PMNT_DT DELIMITED BY '/'
                          INTO WS-DAY WS-MONTH WS-YEAR
                      END-UNSTRING.
                      STRING WS-YEAR  DELIMITED BY SIZE
                             WS-MONTH DELIMITED BY SIZE
                             WS-DAY   DELIMITED BY SIZE
                        INTO P-WS-DATE.
            END-EVALUATE.
      *----------------------------------------------------------------- 
       2210-DATE-EXIT.
            EXIT.