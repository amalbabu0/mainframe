      *****************************************************************
      * PROGRAM NAME : PGM
      * DESCRIPTION  : Fetches accepted course registrations from DB2,
      *                joins department allocation table, writes
      *                selected data to sequential output file.
      * TECHNOLOGY   : COBOL + DB2
      *****************************************************************

       IDENTIFICATION DIVISION.
       PROGRAM-ID. PGM.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT OUTFILE
               ASSIGN TO DD1
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-FS.

       DATA DIVISION.
       FILE SECTION.

       FD  OUTFILE.
       01  OUTREC                  PIC X(80).

       WORKING-STORAGE SECTION.

      *---------------- DB2 DECLARATIONS ----------------*
           EXEC SQL
                INCLUDE REGDCL
           END-EXEC.

           EXEC SQL
                INCLUDE ALODCL
           END-EXEC.

           EXEC SQL
                INCLUDE SQLCA
           END-EXEC.

      *---------------- CURSOR DECLARATION --------------*
           EXEC SQL
                DECLARE CR1 CURSOR FOR
                    SELECT R.COURSE_ID,
                           R.APPL_ID,
                           A.DEPT_ID,
                           R.AGE,
                           R.COURSE_STATUS,
                           A.CLS_ID
                      FROM COURSE_REG2 R
                      INNER JOIN DEPT_ALOT2 A
                        ON R.COURSE_NAME = A.COURSE_NAME2
                     WHERE R.COURSE_STATUS = 'ACP'
                       AND A.CLS_AVG > 60
                     ORDER BY R.APPL_ID
           END-EXEC.

      *---------------- WORK VARIABLES ------------------*
       01 WS-FS                   PIC 99.
       01 WS-AGE                  PIC ZZ.
       01 WS-TIME                 PIC X(10).

       PROCEDURE DIVISION.

       0000-MAIN.
           PERFORM 1000-INIT
           PERFORM 2000-OPEN
           PERFORM 3000-FETCH
               UNTIL SQLCODE = 100
           PERFORM 4000-CLOSE
           STOP RUN.

      *---------------- INITIALIZATION ------------------*
       1000-INIT.
           INITIALIZE WS-FS WS-AGE OUTREC

           EXEC SQL
                SELECT CURRENT TIME
                  INTO :WS-TIME
                  FROM SYSIBM.SYSDUMMY1
           END-EXEC.

           DISPLAY "JOB START TIME : " WS-TIME.

           EXEC SQL
                UPDATE DEPT_ALOT2
                   SET CLS_AVG = CLS_TOT / 30
           END-EXEC.

       1000-INIT-EXIT.
           EXIT.

      *---------------- OPEN CURSOR & FILE --------------*
       2000-OPEN.
           EXEC SQL
                OPEN CR1
           END-EXEC.

           OPEN OUTPUT OUTFILE.

           IF SQLCODE = 0 AND WS-FS = 00
               DISPLAY "OPEN SUCCESSFUL"
           ELSE
               DISPLAY "OPEN ERROR"
               PERFORM 4000-CLOSE
               STOP RUN
           END-IF.

       2000-OPEN-EXIT.
           EXIT.

      *---------------- FETCH PROCESS -------------------*
       3000-FETCH.
           EXEC SQL
                FETCH CR1
                  INTO :R-COURSE-ID,
                       :R-APPL-ID,
                       :A-DEPT-ID,
                       :R-AGE,
                       :R-COURSE-STATUS,
                       :A-CLS-ID
           END-EXEC.

           EVALUATE TRUE
               WHEN SQLCODE = 0
                    PERFORM 3500-MOVE
               WHEN SQLCODE = 100
                    DISPLAY "END OF CURSOR"
               WHEN OTHER
                    DISPLAY "FETCH ERROR : " SQLCODE
                    PERFORM 4000-CLOSE
                    STOP RUN
           END-EVALUATE.

       3000-FETCH-EXIT.
           EXIT.

      *---------------- MOVE & WRITE --------------------*
       3500-MOVE.
           MOVE R-AGE            TO WS-AGE
           MOVE R-COURSE-ID      TO OUTREC(1:5)
           MOVE R-APPL-ID        TO OUTREC(7:5)
           MOVE A-DEPT-ID        TO OUTREC(13:5)
           MOVE WS-AGE           TO OUTREC(19:2)
           MOVE R-COURSE-STATUS  TO OUTREC(22:3)
           MOVE A-CLS-ID         TO OUTREC(26:5)

           WRITE OUTREC.

       3500-MOVE-EXIT.
           EXIT.

      *---------------- CLOSE CURSOR & FILE -------------*
       4000-CLOSE.
           EXEC SQL
                CLOSE CR1
           END-EXEC.

           CLOSE OUTFILE.

           IF SQLCODE = 0 AND WS-FS = 00
               DISPLAY "CLOSE SUCCESSFUL"
           ELSE
               DISPLAY "CLOSE ERROR"
           END-IF.

       4000-CLOSE-EXIT.
           EXIT.
