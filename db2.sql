DROP TABLE raum CASCADE CONSTRAINTS;
DROP TABLE kann_oeffnen CASCADE CONSTRAINTS;
DROP TABLE transponder CASCADE CONSTRAINTS;
DROP TABLE pfoertner CASCADE CONSTRAINTS;
DROP TABLE person CASCADE CONSTRAINTS;
DROP TABLE raumverantwortlicher CASCADE CONSTRAINTS;
DROP TABLE ausleihe CASCADE CONSTRAINTS;
DROP TABLE berechtigung CASCADE CONSTRAINTS;
DROP TABLE reservierung CASCADE CONSTRAINTS;
DROP TABLE labor CASCADE CONSTRAINTS;
DROP TABLE schadensmeldung CASCADE CONSTRAINTS;

CREATE TABLE raum(
raum_id NUMBER(9) PRIMARY KEY,
raum_nr NUMBER(4) NOT NULL,
etage VARCHAR2(15),
gebaeude VARCHAR2(45),
labor_id NUMBER (9),
gesperrt INTEGER
);

CREATE TABLE kann_oeffnen(
raum_id NUMBER (9),
transponder_id NUMBER (9),
CONSTRAINT XPKkann_oefnnen PRIMARY KEY (raum_id, transponder_id)
);

CREATE TABLE transponder(
transponder_id NUMBER (9) PRIMARY KEY,
funktionsfaehigkeit INTEGER
);

CREATE TABLE pfoertner(
pfoertner_id NUMBER (9) PRIMARY KEY,
nachname VARCHAR2 (45) NOT NULL,
vorname VARCHAR2 (45) NOT NULL,
geburtsdatum DATE NOT NULL
);

CREATE TABLE person(
person_id NUMBER (9) PRIMARY KEY,
nachname VARCHAR2 (45) NOT NULL,
vorname VARCHAR2 (45) NOT NULL,
geburtsdatum DATE
);

CREATE TABLE raumverantwortlicher(
raumverantwortlicher_id NUMBER (9) PRIMARY KEY,
nachname VARCHAR2 (45) NOT NULL,
vorname VARCHAR2 (45) NOT NULL,
geburtsdatum VARCHAR2 (45) NOT NULL,
labor_id NUMBER (9) NOT NULL
);

CREATE TABLE ausleihe(
transponder_id INTEGER,
person_id INTEGER,
pfoertner_id INTEGER NOT NUll,
ausgeliehen_von DATE,
ausgeliehen_bis DATE NOT NULL,
CONSTRAINT XPKausleihe PRIMARY KEY (transponder_id, person_id, ausgeliehen_von)
);

CREATE TABLE berechtigung(
person_id NUMBER (9),
raumverantwortlicher_id NUMBER (9),
berechtigung_von DATE NOT NULL,
berechtigung_bis DATE NOT NULL,
raum_nr VARCHAR2 (45) NOT NULL,
CONSTRAINT XPKberechtigung PRIMARY KEY (person_id,raumverantwortlicher_id)
);

CREATE TABLE reservierung(
reservierungs_id NUMBER (9) PRIMARY KEY,
person_id NUMBER (9) NOT NULL,
raum_id NUMBER (9) NOT NULL,
reserviert_von DATE NOT NULL,
reserviert_bis DATE NOT NULL
);

CREATE TABLE labor(
labor_id NUMBER (9) PRIMARY KEY,
labor_name VARCHAR2(45) NOT NULL
);

CREATE TABLE schadensmeldung(
schadensmeldung_id NUMBER (9) PRIMARY KEY,
transponder_id NUMBER (9) NOT NULL,
pfoertner_id NUMBER (9) NOT NULL,
person_id NUMBER (9) NOT NULL,
raum_id NUMBER (9) NOT NULL,
meldung VARCHAR2 (45) NOT NULL,
erheblicher_Schaden INTEGER NOT NULL
);

ALTER TABLE kann_oeffnen
        ADD ( CONSTRAINT wird_geoefnnet_fk
              FOREIGN KEY (raum_id)
                                REFERENCES raum ON DELETE CASCADE
                                                );

ALTER TABLE kann_oeffnen
        ADD ( CONSTRAINT oeffnet_fk
              FOREIGN KEY (transponder_id)
                                REFERENCES transponder ON DELETE CASCADE
                                                );

ALTER TABLE ausleihe
        ADD ( CONSTRAINT wird_ausgeliehent_fk
              FOREIGN KEY (transponder_id)
                                REFERENCES transponder ON DELETE CASCADE
                                                );

ALTER TABLE ausleihe
        ADD ( CONSTRAINT vergibt_transponder_fk
              FOREIGN KEY (pfoertner_id)
                                REFERENCES pfoertner
                                                );


ALTER TABLE ausleihe
        ADD ( CONSTRAINT leiht_aus_fk
              FOREIGN KEY (person_id)
                                REFERENCES person
                                                );


ALTER TABLE berechtigung
        ADD ( CONSTRAINT vergibt_berechtigung_fk
              FOREIGN KEY (raumverantwortlicher_id)
                                REFERENCES raumverantwortlicher ON DELETE CASCADE
                                                );

ALTER TABLE berechtigung
        ADD ( CONSTRAINT erhaelt_berechtigung_fk
              FOREIGN KEY (person_id)
                                REFERENCES person ON DELETE CASCADE
                                                );

ALTER TABLE reservierung
        ADD ( CONSTRAINT wird_reserviret_fk
              FOREIGN KEY (raum_id)
                                REFERENCES raum ON DELETE CASCADE
                                                );

ALTER TABLE reservierung
        ADD ( CONSTRAINT reserviret_fk
              FOREIGN KEY (person_id)
                                REFERENCES person ON DELETE CASCADE
                                                );

ALTER TABLE raum
        ADD ( CONSTRAINT teil_von_fk
              FOREIGN KEY (labor_id)
                                REFERENCES labor
                                                );
ALTER TABLE raumverantwortlicher
        ADD ( CONSTRAINT gehoert_zu_fk
              FOREIGN KEY (labor_id)
                                REFERENCES labor
                                                );

ALTER TABLE schadensmeldung
        ADD ( CONSTRAINT schaden_person_fk
              FOREIGN KEY (person_id)
                                REFERENCES person
                                                );

ALTER TABLE schadensmeldung
        ADD ( CONSTRAINT schaden_transponder_fk
              FOREIGN KEY (transponder_id)
                                REFERENCES transponder
                                                );

ALTER TABLE schadensmeldung
        ADD ( CONSTRAINT schaden_pfoertner_fk
              FOREIGN KEY (pfoertner_id)
                                REFERENCES pfoertner
                                                );

ALTER TABLE schadensmeldung
        ADD ( CONSTRAINT bezieht_sich_auf_raum_fk
              FOREIGN KEY (raum_id)
                                REFERENCES raum
                                                );


/* MS2 */

SET SERVEROUTPUT ON;

DROP TABLE Ausleihe_Archiv;

CREATE TABLE Ausleihe_Archiv (
transponder_id INTEGER,
person_id INTEGER,
pfoertner_id INTEGER NOT NULL,
ausgeliehen_von DATE,
ausgeliehen_bis DATE NOT NULL,
PRIMARY KEY (transponder_id, person_id, ausgeliehen_von)
);


CREATE OR REPLACE PROCEDURE Ausleihen (p_transponder_id INTEGER, p_person_id INTEGER, p_pfoertner_id INTEGER, p_ausgeliehen_von DATE, p_ausgeliehen_bis DATE)
IS
  funktionsfaehig INTEGER;
  erheb_schaden INTEGER;
  geschlossen INTEGER;
BEGIN
  SELECT funktionsfaehigkeit INTO funktionsfaehig
    FROM transponder
    WHERE transponder_id = p_transponder_id;
  SELECT erheblicher_Schaden INTO erheb_schaden
    FROM schadensmeldung
    WHERE transponder_id = p_transponder_id;
  SELECT gesperrt INTO geschlossen
    FROM raum NATURAL JOIN kann_oeffnen NATURAL JOIN transponder
    WHERE transponder_id = p_transponder_id;
    IF funktionsfaehig = 0
      THEN
      DBMS_OUTPUT.PUT_LINE('Ausleihe nicht moeglich! Transponder nicht funktionsfaehig.');
    ELSIF erheb_schaden = 1
      THEN
      DBMS_OUTPUT.PUT_LINE('Ausleihe nicht moeglich! Raum weist erheblichen Schaden auf.');
    ELSIF geschlossen = 1
      THEN
      DBMS_OUTPUT.PUT_LINE('Ausleihe nicht moeglich! Raum geschlossen.');
    ELSE
      INSERT INTO ausleihe
      VALUES(p_transponder_id, p_person_id, p_pfoertner_id, p_ausgeliehen_von, p_ausgeliehen_bis);
    END IF;
  COMMIT;
END;
/
SHOW ERRORS;


CREATE OR REPLACE TRIGGER Ausleihe_historie AFTER INSERT ON ausleihe FOR EACH ROW
BEGIN
    INSERT INTO Ausleihe_Archiv
        VALUES(:NEW.transponder_id, :NEW.person_id, :NEW.pfoertner_id, :NEW.ausgeliehen_von, :NEW.ausgeliehen_bis);
END;
/
SHOW ERRORS;


/*CREATE OR REPLACE TRIGGER berechtigung_kontrolle BEFORE INSERT ON ausleihe FOR EACH ROW
BEGIN
    raum nicht gesperrt
    reservierung erstelle procedure
    nicht laenger als einen tag ausleihen
END;
/
SHOW ERRORS;*/


INSERT INTO transponder VALUES(1, 0);
INSERT INTO transponder VALUES(2, 1);
INSERT INTO transponder VALUES(3, 1);
INSERT INTO transponder VALUES(4, 1);

INSERT INTO person VALUES(3, 'Mueller', 'Hans', to_date('01.01.1990', 'DD.MM.YYYY'));

INSERT INTO pfoertner VALUES(4, 'Schmitz', 'Fritz', to_date('02.02.1992', 'DD.MM.YYYY'));

INSERT INTO labor VALUES(6, 'DB');

INSERT INTO raum VALUES(7, 8, '1. OG', 'gebaeudeXY', 6, 0);
INSERT INTO raum VALUES(13, 13, '1. OG', 'gebaeudeXY', 6, 0);
INSERT INTO raum VALUES(14, 13, '1. OG', 'gebaeudeXY', 6, 1);
INSERT INTO raum VALUES(15, 13, '1. OG', 'gebaeudeXY', 6, 0);

INSERT INTO raumverantwortlicher VALUES(5, 'Meier', 'Peter', to_date('03.03.1993', 'DD.MM.YYYY'), 6);

INSERT INTO schadensmeldung VALUES(8, 1, 4, 3, 7, 'Dies ist eine Schadensmeldung', 0);
INSERT INTO schadensmeldung VALUES(9, 3, 4, 3, 7, 'Dies ist eine Schadensmeldung', 0);
INSERT INTO schadensmeldung VALUES(11, 4, 4, 3, 13, 'Dies ist eine Schadensmeldung', 0);
INSERT INTO schadensmeldung VALUES(10, 2, 4, 3, 7, 'Dies ist eine erhebliche Schadensmeldung', 1);

INSERT INTO kann_oeffnen VALUES(13, 1);
INSERT INTO kann_oeffnen VALUES(13, 2);
INSERT INTO kann_oeffnen VALUES(14, 3);
INSERT INTO kann_oeffnen VALUES(15, 4);

COMMIT;


EXECUTE Ausleihen (1, 3, 4, to_date('05.05.2020 09:00', 'DD.MM.YYYY HH24:MI'), to_date('05.05.2020 12:00', 'DD,MM.YYYY HH24:MI')) /* Ausleihe nicht moeglich! Transponder nicht funktionsfaehig. */
EXECUTE Ausleihen (2, 3, 4, to_date('07.05.2020 09:00', 'DD.MM.YYYY HH24:MI'), to_date('07.05.2020 12:00', 'DD,MM.YYYY HH24:MI')) /* Ausleihe nicht moeglich! Raum weist erheblichen Schaden auf. */
EXECUTE Ausleihen (3, 3, 4, to_date('08.05.2020 09:00', 'DD.MM.YYYY HH24:MI'), to_date('08.05.2020 12:00', 'DD,MM.YYYY HH24:MI')) /* Ausleihe nicht moeglich! Raum geschlossen. */
EXECUTE Ausleihen (4, 3, 4, to_date('06.05.2020 09:00', 'DD.MM.YYYY HH24:MI'), to_date('06.05.2020 12:00', 'DD,MM.YYYY HH24:MI')) /* Ausleihe moeglich */


SELECT * FROM ausleihe;
SELECT * FROM Ausleihe_Archiv;
