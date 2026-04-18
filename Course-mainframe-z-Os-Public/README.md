# Student Course Processing using COBOL, DB2, and JCL

Objective

To develop a mainframe batch application using COBOL with embedded DB2 SQL that retrieves student course data, processes it using business rules, and generates a formatted output file using JCL utilities.

Technology Stack

Language: COBOL

Database: DB2

Job Control: JCL

Utilities: SORT, IEFBR14

Platform: IBM Mainframe (z/OS)

System Description

The COBOL program uses a DB2 cursor to fetch records by joining the COURSE_REG2 and DEPT_ALOT2 tables.
Only accepted courses (ACP) with class average greater than 60 are selected.
The processed records are written to a sequential file, which is later sorted and formatted using JCL.

Input Data

COURSE_REG2: Course registration details

DEPT_ALOT2: Department and class allocation details

Processing Logic

Update class average based on total strength

Open DB2 cursor and fetch records

Validate SQL return codes

Move required fields to output record

Write output to sequential file

Sort output by Application ID

Output

A sequential output file containing:

Course ID

Application ID

Department ID

Age

Course Status

Class ID

Error Handling

SQLCODE validation after every DB2 operation

Proper open/close of cursor and files

Graceful termination on errors

Conclusion

This project demonstrates end-to-end batch processing on a mainframe using COBOL, DB2, and JCL, following standard coding practices. It is suitable for academic labs, assessments, and mainframe training.