== CSV2XLS == 
Convert csv file into xls file
    - input : All_deals_20150128_131030.csv
    - output: Ordrar ML 20150129.xls
    
== Requirement == 
These are the general information in both input and output files:

- Row 1 in import and export file is the header and should always carry the headers info which. It is a static row.
- Every other row should be transferred one by one from import file to export file
- Maximum rows in the both files will be 4000 rows. 
- Import file is in .csv format.
- Export file should be in .xls format and named always âOrdrar MLâ & put todayâs date after (in this format YYYYMMDD). example: "Ordrar ML 20150106"

These are the functional information.

Export file Columns A,C,D,E,F,G,J,U,V,W,X & Y: will be always empty

Export file Column B: 
- Will pick characters (not the numbers) of column Z from import file & add todays date info (in this format MM:YY) to the right side of the Characters. Example: TMG0115 

Export file Column H: 
- Will pick information from Column C in import file.

Export file Column I: 
- Will pick information from Column B in import file.

Export file Column K: 
- Will pick information from Column I in import file.

Export file Column L: 
- Will pick information from Column J in import file.

Export file Column M: 
- Will pick information from Column L in import file.

Export file Column N: 
- Will pick information from Column G in import file.

Export file Column O: 
- Always the same static text; "EK"

Export file Column P: 
- Always the same static text; "6"

Export file Column Q: 
- Will pick information from Column M in import file.
- If left of numbers, starts with â7â then should leave the cell empty, else copy the numbers and add a 0 at the left side of the numbers, also put a â in between the numbers (usually we put the â between 3rd & 4th number from left)
Example: this is import file format "4276478" then we need the export look like this "042-76478"

Export file Column R: 
- Will pick information from Column M in import file.
- If left of numbers, starts with â07â then copy the numbers and add a 0 at the left side of the numbers, also put a â in between the numbers (usually we put the â between 3rd & 4th number from left), else should leave the cell empty
- Example: this is import file format "727647861" then we need the export look like this "072-7647861"

Export file Column S: 
- Always the same static text; "1"

Export file Column T: 
- Will pick information from Column G in import file.
