INSERT INTO transponder VALUES(1, 0); /* Ausleihe nicht moeglich! Transponder nicht funktionsfaehig. */
INSERT INTO transponder VALUES(2, 1); /* Ausleihe nicht moeglich! Raum geschlossen. */
INSERT INTO transponder VALUES(3, 1); /* Ausleihe nicht moeglich! Keine Berechtigung. */
INSERT INTO transponder VALUES(5, 1); /* Ausleihe darf nicht laenger als einen Tag sein. */
INSERT INTO transponder VALUES(4, 1); /* Ausleihe moeglich */
INSERT INTO transponder VALUES(6, 1); /* Ausleihe nicht moeglich! Transponder schon ausgeliehen oder reserviert */

INSERT INTO person VALUES(20, 'Mueller', 'Hans', to_date('01.01.1991', 'DD.MM.YYYY'));
INSERT INTO person VALUES(50, 'Fritz', 'Jaeger', to_date('08.01.1991', 'DD.MM.YYYY'));
INSERT INTO person VALUES(70, 'Tobias', 'Adler', to_date('16.01.1991', 'DD.MM.YYYY'));

INSERT INTO pfoertner VALUES(30, 'Schmitz', 'Fritz', to_date('02.02.1992', 'DD.MM.YYYY'));

INSERT INTO labor VALUES(40, 'DB');
INSERT INTO labor VALUES(30, 'KTN');

INSERT INTO raum VALUES(1, 1, '1. OG', 'gebaeudeXY', 40, 0); /* Ausleihe nicht moeglich! Transponder nicht funktionsfaehig. */
INSERT INTO raum VALUES(2, 2, '1. OG', 'gebaeudeXY', 40, 1); /* Ausleihe nicht moeglich! Raum geschlossen. */
INSERT INTO raum VALUES(3, 3, '1. OG', 'gebaeudeXY', 40, 0); /* Ausleihe nicht moeglich! Keine Berechtigung. */
INSERT INTO raum VALUES(5, 5, '1. OG', 'gebaeudeXY', 40, 0); /* Ausleihe darf nicht laenger als einen Tag sein. */
INSERT INTO raum VALUES(4, 4, '1. OG', 'gebaeudeXY', 40, 0); /* Ausleihe moeglich */
INSERT INTO raum VALUES(6, 6, '1. OG', 'gebaeudeXY', 40, 0); /* Ausleihe nicht moeglich! Transponder schon ausgeliehen oder reserviert */

INSERT INTO raumverantwortlicher VALUES(20, 'Meier', 'Peter', to_date('03.03.1993', 'DD.MM.YYYY'), 40);

INSERT INTO schadensmeldung VALUES(10, 3, 30, 20, 3, 'Dies ist eine erhebliche Schadensmeldung', 1); /* Ausleihe nicht moeglich! Raum weist erheblichen Schaden auf. */

INSERT INTO kann_oeffnen VALUES(1, 1); /* Ausleihe nicht moeglich! Transponder nicht funktionsfaehig. */
INSERT INTO kann_oeffnen VALUES(2, 2); /* Ausleihe nicht moeglich! Raum geschlossen. */
INSERT INTO kann_oeffnen VALUES(3, 3); /* Ausleihe nicht moeglich! Keine Berechtigung */
INSERT INTO kann_oeffnen VALUES(5, 5); /* Ausleihe darf nicht laenger als einen Tag sein. */
INSERT INTO kann_oeffnen VALUES(4, 4); /* Ausleihe moeglich */
INSERT INTO kann_oeffnen VALUES(6, 6); /* Ausleihe nicht moeglich! Transponder schon ausgeliehen oder reserviert */

INSERT INTO berechtigung VALUES(20, 20, to_date('01.05.2020 09:00', 'DD.MM.YYYY HH24:MI'), to_date('30.05.2020 12:00', 'DD,MM.YYYY HH24:MI'), 1); /* Ausleihe nicht moeglich! Transponder nicht funktionsfaehig. */
INSERT INTO berechtigung VALUES(20, 20, to_date('02.05.2020 09:00', 'DD.MM.YYYY HH24:MI'), to_date('30.05.2020 12:00', 'DD,MM.YYYY HH24:MI'), 2); /* Ausleihe nicht moeglich! Raum geschlossen. */
INSERT INTO berechtigung VALUES(20, 20, to_date('01.05.2020 09:00', 'DD.MM.YYYY HH24:MI'), to_date('10.05.2020 12:00', 'DD,MM.YYYY HH24:MI'), 3); /* Ausleihe nicht moeglich! Keine Berechtigung. */
INSERT INTO berechtigung VALUES(20, 20, to_date('05.05.2020 09:00', 'DD.MM.YYYY HH24:MI'), to_date('30.05.2020 12:00', 'DD,MM.YYYY HH24:MI'), 5); /* Ausleihe darf nicht laenger als einen Tag sein. */
INSERT INTO berechtigung VALUES(20, 20, to_date('04.05.2020 09:00', 'DD.MM.YYYY HH24:MI'), to_date('30.05.2020 12:00', 'DD,MM.YYYY HH24:MI'), 4); /* Ausleihe moeglich */
INSERT INTO berechtigung VALUES(20, 20, to_date('04.05.2020 09:00', 'DD.MM.YYYY HH24:MI'), to_date('30.05.2020 12:00', 'DD,MM.YYYY HH24:MI'), 6); /* Ausleihe moeglich */
INSERT INTO berechtigung VALUES(50, 20, to_date('06.05.2020 09:00', 'DD.MM.YYYY HH24:MI'), to_date('30.05.2020 12:00', 'DD,MM.YYYY HH24:MI'), 6); /* Ausleihe nicht moeglich! Transponder schon ausgeliehen oder reserviert */
INSERT INTO berechtigung VALUES(50, 20, to_date('06.05.2020 09:00', 'DD.MM.YYYY HH24:MI'), to_date('30.05.2020 12:00', 'DD,MM.YYYY HH24:MI'), 4); /* Ausleihe nicht moeglich! Transponder schon ausgeliehen oder reserviert */


COMMIT;


EXECUTE Reservieren (20, 1, to_date('22.05.2020 09:00', 'DD,MM.YYYY HH24:MI'), to_date('22.05.2020 12:00', 'DD,MM.YYYY HH24:MI')) /* Reservierung nicht moeglich! Transponder nicht funktionsfaehig. */
EXECUTE Reservieren (20, 2, to_date('22.05.2020 09:00', 'DD,MM.YYYY HH24:MI'), to_date('22.05.2020 12:00', 'DD,MM.YYYY HH24:MI')) /* Reservierung nicht moeglich! Raum geschlossen. */
EXECUTE Reservieren (20, 3, to_date('22.05.2020 09:00', 'DD,MM.YYYY HH24:MI'), to_date('22.05.2020 12:00', 'DD,MM.YYYY HH24:MI')) /* Reservierung nicht moeglich! Keine Berechtigung. */
EXECUTE Reservieren (20, 4, to_date('22.05.2020 09:00', 'DD,MM.YYYY HH24:MI'), to_date('22.05.2020 12:00', 'DD,MM.YYYY HH24:MI')) /* Reservierung moeglich */
EXECUTE Reservieren (20, 6, to_date('22.05.2020 09:00', 'DD,MM.YYYY HH24:MI'), to_date('28.05.2020 12:00', 'DD,MM.YYYY HH24:MI')) /* Reservierung moeglich */ /* Ausleihe nicht moeglich! Transponder schon ausgeliehen oder reserviert */

EXECUTE Ausleihen (1, 20, 30, to_date('22.05.2020 12:00', 'DD,MM.YYYY HH24:MI')) /* Ausleihe nicht moeglich! Transponder nicht funktionsfaehig. */
EXECUTE Ausleihen (2, 20, 30, to_date('22.05.2020 12:00', 'DD,MM.YYYY HH24:MI')) /* Ausleihe nicht moeglich! Raum geschlossen. */
EXECUTE Ausleihen (3, 20, 30, to_date('22.05.2020 12:00', 'DD,MM.YYYY HH24:MI')) /* Ausleihe nicht moeglich! Keine Berechtigung. */
EXECUTE Ausleihen (5, 20, 30, to_date('28.05.2020 08:00', 'DD,MM.YYYY HH24:MI')) /* Ausleihe darf nicht laenger als einen Tag sein. */
EXECUTE Ausleihen (4, 20, 30, to_date('25.05.2020 12:00', 'DD,MM.YYYY HH24:MI')) /* Ausleihe moeglich */
EXECUTE Ausleihen (4, 50, 30, to_date('25.05.2020 12:00', 'DD,MM.YYYY HH24:MI')) /* Ausleihe nicht moeglich! Transponder schon ausgeliehen oder reserviert */

EXECUTE Reservieren (50, 4, to_date('22.05.2020 09:00', 'DD,MM.YYYY HH24:MI'), to_date('25.05.2020 12:00', 'DD,MM.YYYY HH24:MI')) /* Reservierung nicht moeglich! Transponder schon ausgeliehen oder reserviert */

EXECUTE Berechtigen(20,50,3,to_date('22.05.2020 09:00', 'DD,MM.YYYY HH24:MI'), to_date('22.05.2020 12:00', 'DD,MM.YYYY HH24:MI'),40) /* Berechtigung erfolgreich vergeben */
EXECUTE Berechtigen(20,70,2,to_date('22.05.2020 09:00', 'DD,MM.YYYY HH24:MI'), to_date('22.05.2020 12:00', 'DD,MM.YYYY HH24:MI'),40) /* Berechtigung erfolgreich vergeben */


EXECUTE Ausleihen (5, 20, 30, to_date('22.05.2020 08:00', 'DD,MM.YYYY HH24:MI'))
EXECUTE Transponder_zurueckgeben(4, 20, 0) /* Transponder wird zurueckgegeben */
EXECUTE Transponder_zurueckgeben(5, 20, 0) /* Transponder wird zurueckgegeben */


SELECT * FROM berechtigung;

SELECT * FROM ausleihe;
SELECT * FROM Ausleihe_Archiv;

SELECT * FROM reservierung;

SELECT * FROM view_berechtigte;
