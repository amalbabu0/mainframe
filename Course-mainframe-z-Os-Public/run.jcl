//#USEDIDD JOB NOTIFY=&SYSUID
//* ----------------------------------------------------
//* JOB NAME : DB2-COBOL-BATCH
//* PURPOSE  : Sort output from DB2 COBOL program
//* ----------------------------------------------------

//DELFILE  EXEC PGM=IEFBR14
//DD1      DD DSN=#usedID.DB2.PS1,
//             DISP=(MOD,DELETE,DELETE),
//             SPACE=(TRK,(1,1)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=800)

//SORTSTEP EXEC PGM=SORT
//SORTIN   DD DSN=#usedID.DB2.PS,DISP=SHR
//SORTOUT  DD DSN=#usedID.DB2.PS1,
//             DISP=(MOD,CATLG,DELETE),
//             SPACE=(TRK,(1,1)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=800)
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SYSIN    DD *
  SORT FIELDS=(7,5,CH,A)
  OUTREC BUILD=(1,5,C' ',
                22,3,C' ',
                7,5,C' ',
                19,2)
/*
