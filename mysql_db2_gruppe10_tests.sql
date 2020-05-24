-- tests mysql
INSERT INTO labor (labor_name) VALUES ('Irgeneinname');
INSERT INTO labor (labor_name) VALUES ('Irgeneinname2');
INSERT INTO person (labor_id,nachname,vorname,geburtsdatum) VALUES (1,'Müller','Max',current_timestamp());
INSERT INTO person (labor_id,nachname,vorname,geburtsdatum) VALUES (1,'Radigk','Rolf',current_timestamp());
INSERT INTO raumverantwortlicher (nachname,vorname,geburtsdatum, labor_id) VALUES ('Raumver1','Rolf',current_timestamp(),1);
INSERT INTO pfoertner (nachname, vorname, geburtsdatum) VALUES ('Pfoert1', 'Paul', current_date);
INSERT INTO raum (raum_nr,labor_id,gesperrt) VALUES (1401,1,false);
INSERT INTO raum (raum_nr,labor_id,gesperrt) VALUES (1402,1,true);
INSERT INTO raum (raum_nr,labor_id,gesperrt) VALUES (1403,2,false);
INSERT INTO transponder VALUES (1, true);
INSERT INTO transponder VALUES (2, false);
INSERT INTO transponder VALUES (3, true);
INSERT INTO kann_oeffnen VALUES (1,1);
INSERT INTO kann_oeffnen VALUES (2,1);
INSERT INTO kann_oeffnen VALUES (1,2);
INSERT INTO kann_oeffnen VALUES (2,3);

SELECT * FROM raum;
SELECT * FROM raumverantwortlicher;
SELECT * FROM person;

CALL `db2_test`.`proc_raum_reservieren`(1,1, '2020-05-24 11:10:10', '2020-05-24 19:10:10'); -- fehlende berechtigung
CALL `db2_test`.`proc_transponder_ausleihen`(1, 1, 1, current_timestamp()); -- fehlende berechtigung
CALL `db2_test`.`proc_add_berechtigung`( 1, 1, 1403, '2020-04-01 10:10:10', '2020-06-01 10:10:10'); -- falsches labor 
SELECT * FROM berechtigung;
CALL `db2_test`.`proc_add_berechtigung`( 1, 1, 1402, '2020-04-01 10:10:10', '2020-06-01 10:10:10'); -- ok
CALL `db2_test`.`proc_add_berechtigung`( 1, 1, 1401, '2020-04-01 10:10:10', '2020-06-01 10:10:10'); -- ok
SELECT * FROM berechtigung;
CALL `db2_test`.`proc_raum_reservieren`(1,1, '2020-05-24 11:10:10', '2020-04-01 10:10:10'); -- negative zeit
CALL `db2_test`.`proc_raum_reservieren`(2,1, '2020-05-24 11:10:10', '2020-05-24 19:10:10'); -- gesperrt
CALL `db2_test`.`proc_transponder_ausleihen`(2, 1, 1, current_timestamp()); -- defekt
CALL `db2_test`.`proc_transponder_ausleihen`(3, 1, 1, current_timestamp()); -- gesperrt
CALL `db2_test`.`proc_transponder_ausleihen`(1, 1, 1, '2020-05-29 12:00:00'); -- ok
CALL `db2_test`.`proc_transponder_ausleihen`(1, 1, 1, current_timestamp()); -- bereits ausgeliehen
SELECT * FROM ausleihe;
SELECT * FROM reservierung;
CALL `db2_test`.`proc_raum_reservieren`(1,1, '2020-05-26 11:10:10', '2020-05-30 19:10:10'); -- ok

SELECT * FROM reservierung r, kann_oeffnen k WHERE (r.raum_id = k.raum_id AND k.transponder_id = 1 AND ((r.reserviert_von <= current_timestamp() AND r.reserviert_bis >= current_timestamp()) 
				OR (r.reserviert_von <= '2020-05-29 12:00:00' AND r.reserviert_bis >= '2020-05-29 12:00:00')));

CALL `db2_test`.`proc_transponder_ausleihen`(1, 1, 1, '2020-05-29 12:00:00'); -- bereits reserviert
SELECT * FROM reservierung;
INSERT INTO schadensmeldung (transponder_id,person_person_id,pfoertner_person_id,raum_id,meldung) VALUES (1,1,1,1,'test');
CALL `db2_test`.`proc_transponder_zurueckgeben`(1,1); -- schadensmeldung
DELETE FROM schadensmeldung;
CALL `db2_test`.`proc_transponder_zurueckgeben`(1,1); -- ok