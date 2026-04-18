---------------------------------------------------------
-- TABLE : COURSE_REG2
---------------------------------------------------------
DROP TABLE COURSE_REG2;
COMMIT;

CREATE TABLE COURSE_REG2 (
    COURSE_ID        CHAR(5)      NOT NULL,
    COURSE_NAME      VARCHAR(15),
    APPL_ID          CHAR(5)      NOT NULL,
    APPLICATION_NAME CHAR(10),
    AGE              SMALLINT,
    SEX              CHAR(1)      NOT NULL,
    ENTRNCE_SCORE    DECIMAL(5,2) NOT NULL,
    COURSE_STATUS    CHAR(3)      NOT NULL,
    CONSTRAINT PK_COURSE_REG
        PRIMARY KEY (COURSE_ID, APPL_ID),
    CONSTRAINT CK_SEX
        CHECK (SEX = 'F'),
    CONSTRAINT CK_STATUS
        CHECK (COURSE_STATUS IN ('ACP','REJ')),
    CONSTRAINT CK_SCORE
        CHECK (ENTRNCE_SCORE BETWEEN 0 AND 999.99)
)
IN SHRDB4.SHRTS4;

CREATE UNIQUE INDEX R2IND
    ON COURSE_REG2 (COURSE_ID, APPL_ID);

COMMIT;

---------------------------------------------------------
-- TABLE : DEPT_ALOT2
---------------------------------------------------------
DROP TABLE DEPT_ALOT2;
COMMIT;

CREATE TABLE DEPT_ALOT2 (
    DEPT_ID      CHAR(5)      NOT NULL,
    COURSE_NAME2 VARCHAR(15),
    CLS_ID       CHAR(5)      NOT NULL,
    ROOM_NO      NUMERIC(2),
    CLS_TOT      NUMERIC(4),
    CLS_AVG      DECIMAL(5,2),
    CONSTRAINT PK_DEPT_ALOT
        PRIMARY KEY (DEPT_ID, CLS_ID),
    CONSTRAINT CK_AVG
        CHECK (CLS_AVG BETWEEN 0 AND 999.99)
)
IN SHRDB4.SHRTS4;

CREATE UNIQUE INDEX ALOIND
    ON DEPT_ALOT2 (DEPT_ID, CLS_ID);

COMMIT;

---------------------------------------------------------
-- VERIFY DATA
---------------------------------------------------------
SELECT * FROM COURSE_REG2;
SELECT * FROM DEPT_ALOT2;
COMMIT;