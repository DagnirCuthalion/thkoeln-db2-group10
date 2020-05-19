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
etage NUMBER(1),
gebaeude VARCHAR2(45),
labor_id NUMBER (9)
);


CREATE TABLE kann_oeffnen(
raum_id NUMBER (9),
transponder_id NUMBER (9),
CONSTRAINT XPKkann_oefnnen PRIMARY KEY (raum_id, transponder_id)
);

CREATE TABLE transponder(
transponder_id NUMBER (9) PRIMARY KEY,
funktionsfaehigkeit VARCHAR2 (6)
);

CREATE TABLE pfoertner(
pfoertner_id NUMBER (9) PRIMARY KEY,
nachname VARCHAR2 (45) NOT NULL,
vorname VARCHAR2 (45) NOT NULL,
geburtsdatum VARCHAR (45) NOT NULL
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
transponder_id Integer,
person_id integer,
pfoertner_id integer NOT NUll,
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
meldung VARCHAR2 (45) NOT NULL
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

/* ALTER TABLE person
        ADD ( CONSTRAINT gehoert_an_fk
              FOREIGN KEY (labor_id)
                                REFERENCES labor
                                                ); */


/* Ausleihe */

SET SERVEROUTPUT ON;

DROP TABLE Ausleihe_Archiv;

CREATE TABLE Ausleihe_Archiv (
transponder_id integer,
person_id integer,
pfoertner_id integer not null,
ausgeliehen_von DATE,
ausgeliehen_bis DATE NOT NULL,
Zeitpunkt date,
PRIMARY KEY (transponder_id, person_id, ausgeliehen_von, Zeitpunkt)
);



CREATE OR REPLACE TRIGGER Ausleihe_historie after INSERT ON ausleihe for each row
BEGIN
    INSERT INTO Ausleihe_Archiv
        VALUES(:NEW.transponder_id, :NEW.person_id, :NEW.pfoertner_id, :NEW.ausgeliehen_von, :NEW.ausgeliehen_bis, sysdate);
END;
/
SHOW ERRORS;


/*CREATE OR REPLACE TRIGGER berechtigung_zeitraum_kontrolle before INSERT ON ausleihe for each row
BEGIN

END;
/
SHOW ERRORS;*/




CREATE OR REPLACE PROCEDURE Ausleihen (p_transponder_id integer, p_person_id integer, p_pfoertner_id integer, p_ausgeliehen_von DATE, p_ausgeliehen_bis DATE)
IS
  funktionsfaehig VARCHAR2(6);
BEGIN
  SELECT funktionsfaehigkeit INTO funktionsfaehig
  FROM transponder
  where transponder_id = p_transponder_id;
  IF( funktionsfaehig = 'wahr')
    THEN

          INSERT INTO ausleihe
            VALUES(p_transponder_id, p_person_id, p_pfoertner_id, p_ausgeliehen_von, p_ausgeliehen_bis);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Ausleihe nicht moeglich! Transponder nicht funktionsfaehig.');
  END IF;

  commit;
END;
/
show errors;

INSERT INTO transponder VALUES(1, 'falsch');
INSERT INTO transponder VALUES(2, 'wahr');

INSERT INTO person VALUES(3, 'Mueller', 'Hans', to_date('01.01.1990', 'DD.MM.YYYY'));

INSERT INTO pfoertner VALUES(4, 'Schmitz', 'Fritz', to_date('02.02.1992', 'DD.MM.YYYY'));

INSERT INTO labor VALUES(6, 'DB');

INSERT INTO raum VALUES(5, 5, 2, 'gebaeudeXY', 6);

INSERT INTO raumverantwortlicher VALUES(7, 'Meier', 'Peter', to_date('03.03.1993', 'DD.MM.YYYY'), 6);

COMMIT;


execute Ausleihen (2, 3, 4, to_date('05.05.2020', 'DD.MM.YYYY'), to_date('06.05.2020', 'DD.MM.YYYY'));



SELECT * FROM ausleihe;
SELECT * FROM Ausleihe_Archiv;
