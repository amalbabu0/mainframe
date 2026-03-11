       IDENTIFICATION DIVISION.
       PROGRAM-ID. BLD-BILL-DETAILS.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT OUTFILE ASSIGN DD1
           ORGANIZATION SEQUENTIAL
           ACCESS MODE SEQUENTIAL
           FILE STATUS WS-FS.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       EXEC SQL
            INCLUDE SQLCA
       END-EXEC.
       EXEC SQL
            INCLUDE MENU_DETAIL
       END-EXEC.
       EXEC SQL
            INCLUDE ORDER_DETAI
       END-EXEC.
       EXEC SQL
            INCLUDE CUSTOMER_DETAIL
       END-EXEC.
       EXEC SQL
            DECLARE C1 CURSOR FOR
               SELECT O.*, M.ITEM_NM, M.PRICE, 
                      C.CUST_NAME, C.MEMBER, C.IT_EMPLOYEE, C.TIE_UP
            FROM ORDER_DETAIL O
            JOIN MENU_DETAIL M ON O.ITEM_ORDERED = M.ITEM_CODE
            JOIN CUSTOMER_DETAIL C ON O.CUSTOMER_CODE = C.CUSTOMER_CODE
            ORDER BY O.CUSTOMER_CODE
       END-EXEC.
       01 WS-FS            PIC 99.
       01 WS-BILL-NO       PIC 9(4).
       01 WS-BILL-AMOUNT   PIC 9(10).
       01 WS-FINAL-BILL    PIC 9(10).
       PROCEDURE DIVISION.
       0000-MAIN-PARA.
            PERFORM 1000-INIT-PARA.
            PERFORM 2000-PFM-EXIT.
            PERFORM 3000-TERM-PARA.
       1000-INIT-PARA.
            INITIALIZE 
            EXIT.
       2000-PFM-PARA.
            PERFORM 2100-OPEN-PARA.
            PERFORM 2200-FETCH-PARA UNTIL SQLCODE = 100.
            PERFORM 2300-CLOSE-PARA.
       3000-TERM-PARA.
            STOP RUN.
       2100-OPEN-PARA.
      *-----------------------------------------------------------------
           EXEC SQL
              OPEN C1
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   DISPLAY " OPEN SUCESS"
               WHEN OTHER
                   DISPLAY 'OPEN CURSOR FAILED SQLCODE=' SQLCODE
                   PERFORM 2300-CLOSE-PARA
           END-EVALUATE.
      *-----------------------------------------------------------------
            OPEN OUTPUT OUTFILE.
            EVALUATE WS-FS
               WHEN 0
                   DISPLAY "OPEN SUCCES"
               WHEN OTHER 
                   DISPLAY "ERROR ON OPEN " WS-FS
                   PERFORM 2300-CLOSE-PARA
            END-EVALUATE.
      *-----------------------------------------------------------------
       2200-FETCH-PARA.
           EXEC SQL
              FETCH C1 INTO
                 :HV-CUSTOMER-CODE,
                 :HV-ITEM-ORDERED,
                 :HV-QTY-ORDERED,
                 :HV-ITEM-NM       :IND-ITEM-NM,
                 :HV-PRICE,
                 :HV-CUST-NAME,
                 :HV-MEMBER,
                 :HV-IT-EMP,
                 :HV-TIE-UP
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   EVALUATE IND-ITEM-NM
                       WHEN 0
                           PERFORM 2210-BILL-PARA
                       WHEN OTHER
                           DISPLAY "NULL"
                           NEXT SENTENCE
                   END-EVALUATE
               WHEN OTHER
                   DISPLAY 'OPEN CURSOR FAILED SQLCODE=' SQLCODE
                   PERFORM 2300-CLOSE-PARA
           END-EVALUATE.
       2300-CLOSE-PARA.
      *-----------------------------------------------------------------
           EXEC SQL
              CLOSE C1
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   DISPLAY " CLOSE SUCESS"
               WHEN OTHER
                   DISPLAY 'CLOSE CURSOR FAILED SQLCODE=' SQLCODE
                   PERFORM 3000-TERM-PARA
           END-EVALUATE.
      *-----------------------------------------------------------------
           CLOSE OUTFILE.
            EVALUATE WS-FS
               WHEN 0
                   DISPLAY "CLOSE SUCCES"
               WHEN OTHER
                   DISPLAY "ERROR ON CLOSE " WS-FS
               PERFORM 3000-TERM-PARA
            END-EVALUATE.
      *-----------------------------------------------------------------
       2210-BILL-PARA.
            INITIALIZE WS-BILL-NO WS-BILL-AMOUNT WS-FINAL-BILL
      *---------------------BILL NUMBER---------------------------------     
            UNSTRING FUNCTION REVERSE(HV-CUSTOMER-CODE) DELIMITED BY SPACE
            INTO WS-BILL-NO.
            MOVE FUNCTION REVERSE(WS-BILL-NO) TO WS-BILL-NO.
      *---------------------BILL AMOUNT---------------------------------
            COMPUTE WS-BILL-AMOUNT = HV-QTY-ORDERED * HV-PRICE.
      *----------------------FINAL BILL---------------------------------
            EVALUATE TRUE
               WHEN WS-BILL-AMOUNT > 2500
                   COMPUTE WS-FINAL-BILL = WS-BILL-AMOUNT - 
                           (WS-BILL-AMOUNT * 10/100)
               WHEN WS-BILL-AMOUNT < 2500
                   EVALUATE TRUE
                       WHEN HV-TIE-UP = "YES"
                           COMPUTE WS-FINAL-BILL = WS-BILL-AMOUNT - 
                           (WS-BILL-AMOUNT * 7/100)
                       WHEN HV-TIE-UP = "NO"
                           COMPUTE WS-FINAL-BILL = WS-BILL-AMOUNT - 50
                   END-EVALUATE
               WHEN OTHER
                    MOVE WS-BILL-AMOUNT TO WS-FINAL-BILL
            END-EVALUATE.
            PERFORM 2211-WRITE-PARA.
            PERFORM 2212-INSERT-PARA.
            EXIT.
       2211-WRITE-PARA.
            MOVE WS-BILL-NO     TO O-BILL-NO
            MOVE HV-CUST-NAME   TO O-CUST-NAME
            MOVE HV-ITEM-NM     TO O-ITEM-NAME
            MOVE HV-QTY-ORDERED TO O-QUANTITY
            MOVE WS-BILL-AMOUNT TO O-BILL-AMOUNT
            MOVE WS-FINAL-BILL  TO O-FINAL-BILL
            WRITE OUTREC.
       2212-INSERT-PARA.
            EXEC SQL
                 INSERT INTO MY_BILLING_TABLE
                            (BILL_NO, CUST_NAME, ITEM_NAME, QUANTITY,
                             BILL_AMOUNT, FINAL_BILL)
                 VALUES
                       ( :WS-BILL-NO, :HV-CUST-NAME, :HV-ITEM-NM, 
                         :HV-QTY-ORDERED, :WS-BILL-AMOUNT, 
                         :WS-FINAL-BILL )
            END-EXEC.