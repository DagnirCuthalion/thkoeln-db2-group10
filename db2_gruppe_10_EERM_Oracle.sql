CREATE OR REPLACE TYPE persons AS OBJECT(
person_id NUMBER (9) ,
nachname VARCHAR2 (45) ,
vorname VARCHAR2 (45) ,
geburtsdatum DATE 
)NOT FINAL;

create or replace type pfoertners under persons(
pfoertner_id NUMBER (9) )
;

CREATE TABLE personen of persons;
CREATE TABLE pfoertner of pfoertners;