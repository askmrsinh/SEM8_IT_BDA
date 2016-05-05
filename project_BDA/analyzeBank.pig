REGISTER 'piggybank-0.12.0.jar';


loanData = LOAD 'bank/demoLoan.csv' USING org.apache.pig.piggybank.storage.CSVExcelStorage(',', 'NO_MULTILINE', 'UNIX', 'SKIP_INPUT_HEADER') AS (name:chararray, location:chararray, type:chararray, risk:float);
DESCRIBE loanData;

--Number of cases per location
A = FOREACH loanData GENERATE location;
B = GROUP A BY location;
X = FOREACH B GENERATE group, COUNT(A);
DUMP X;

--Number of cases per type
A = FOREACH loanData GENERATE type;
B = GROUP A BY type;
X = FOREACH B GENERATE group, COUNT(A);
DUMP X;

--Average risk per type
A = GROUP loanData BY type;
type_avg_risk = FOREACH A GENERATE group, AVG(loanData.risk);
DUMP type_avg_risk;
