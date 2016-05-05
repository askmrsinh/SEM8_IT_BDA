REGISTER 'piggybank-0.12.0.jar';


uData = LOAD 'movie/u.data' USING org.apache.pig.piggybank.storage.CSVExcelStorage('\t', 'NO_MULTILINE', 'UNIX') AS (userID:int, itemID:int, rating:int, timestamp:float);
DESCRIBE uData;

--Top 10 and Bottom 10 raters
--(userID,TotalRatingsGiven)
A = FOREACH uData GENERATE userID;
B = GROUP A BY userID;
D = FOREACH B GENERATE group, COUNT(A) AS cnt;
XM = LIMIT (ORDER D BY cnt DESC) 10;
DUMP XM;
XL = LIMIT (ORDER D BY cnt ASC) 10;
DUMP XL;

uUser = LOAD 'movie/u.user' USING org.apache.pig.piggybank.storage.CSVExcelStorage('|', 'NO_MULTILINE', 'UNIX') AS (userID:int, age:int, gender:chararray, occupation:chararray, zip:int);
DESCRIBE uUser;

--Total rating given by a Specific occupation
--(occupation,TotalRatingsGiven)
A = FOREACH uUser GENERATE occupation;
B = GROUP A BY occupation;
X = FOREACH B GENERATE group, COUNT(A);
DUMP X;


--Number of underage users
A = FILTER uUser BY (age<18);
B = GROUP A ALL;
X = FOREACH B GENERATE COUNT(A);
DUMP X; /*Count of users below 18*/
DUMP A; /*Info of users below 18*/
