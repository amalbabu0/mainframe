       IDENTIFICATION DIVISION.
       PROGRAM-ID. WEEK7.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-SUBSCRIPTED.
           05 S-NAME         PIC X(10).
           05 S-ACCT-NO      PIC 9(5) OCCURS 10 TIMES.
       01 WS-INDEXED.
           05 I-TABLE OCCURS 10 TIMES
                ASCENDING KEY IS I-ACCT-NO
                INDEXED BY IDX.
              10 I-ACCT-NO   PIC 9(5).
       01 WS-I               PIC 99     VALUE 0.
       01 WS-VALUE2          PIC 9(5)   VALUE 12345.
       01 WS-VALUE1          PIC 9(5)   VALUE 98765.
       01 WS-SEARCH          PIC 9(5).
       PROCEDURE DIVISION.
       0000-MAIN-PARA.
           PERFORM 0000-INSERT-PARA
           PERFORM 1000-DISPLAY-PARA
           PERFORM 2000-LINEAR-SEARCH
           PERFORM 3000-BINARY-SEARCH
           STOP RUN.
       0000-INSERT-PARA.
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
               MOVE WS-VALUE1 TO S-ACCT-NO(WS-I)
               ADD 5 TO WS-VALUE1
           END-PERFORM
           SET IDX TO 1
           PERFORM UNTIL IDX > 10
               MOVE WS-VALUE2 TO I-ACCT-NO(IDX)
               ADD 10 TO WS-VALUE2
               SET IDX UP BY 1
           END-PERFORM.
       1000-DISPLAY-PARA.
           DISPLAY "ACCT-NO1:"
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
               DISPLAY I-ACCT-NO(WS-I)
           END-PERFORM
           DISPLAY "ACCT-NO2:"
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
               DISPLAY S-ACCT-NO(WS-I)
           END-PERFORM.
       2000-LINEAR-SEARCH.
           MOVE 12345 TO WS-SEARCH
           SET IDX TO 1
           SEARCH I-TABLE
               WHEN I-ACCT-NO(IDX) = WS-SEARCH
                   DISPLAY "LINEAR:" IDX
           END-SEARCH.
       3000-BINARY-SEARCH.
           MOVE 12345 TO WS-SEARCH
           SEARCH ALL I-TABLE
               WHEN WS-SEARCH = I-ACCT-NO(IDX)
                   DISPLAY "BINARY:" IDX
           END-SEARCH.