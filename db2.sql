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
raum_id INTEGER,
CONSTRAINT XPKberechtigung PRIMARY KEY (person_id,raumverantwortlicher_id, raum_id, berechtigung_von)
);

CREATE TABLE reservierung(
reservierung_id NUMBER (9) PRIMARY KEY,
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


DROP SEQUENCE reservierung_sec;

CREATE SEQUENCE reservierung_sec
    INCREMENT BY 1
    START WITH 1;

/* Procedure 1 */
CREATE OR REPLACE PROCEDURE Ausleihen (p_transponder_id INTEGER, p_person_id INTEGER, p_pfoertner_id INTEGER, p_ausgeliehen_bis DATE)
IS
  funktionsfaehig INTEGER;
  geschlossen INTEGER;
BEGIN
  SELECT funktionsfaehigkeit INTO funktionsfaehig
    FROM transponder
    WHERE transponder_id = p_transponder_id;
  SELECT gesperrt INTO geschlossen
    FROM raum NATURAL JOIN kann_oeffnen NATURAL JOIN transponder
    WHERE transponder_id = p_transponder_id;
    IF funktionsfaehig = 0
      THEN
      DBMS_OUTPUT.PUT_LINE('Ausleihe nicht moeglich! Transponder nicht funktionsfaehig.');
    ELSIF geschlossen = 1
      THEN
      DBMS_OUTPUT.PUT_LINE('Ausleihe nicht moeglich! Raum geschlossen.');
    ELSE
      INSERT INTO ausleihe
      VALUES(p_transponder_id, p_person_id, p_pfoertner_id, sysdate, p_ausgeliehen_bis);
      DBMS_OUTPUT.PUT_LINE('Ausleihe erfolgreich');
    END IF;
  COMMIT;
END;
/
SHOW ERRORS;


/*Procedure 3*/

CREATE OR REPLACE PROCEDURE Berechtigen (p_raumverantwortlicher_id INTEGER,p_person_id INTEGER,p_raum_nr INTEGER,p_berechtigung_von DATE,p_berechtigung_bis DATE,p_labor_id INTEGER)
  IS
    gehoertDazu INTEGER;
BEGIN

  SELECT labor_id INTO gehoertDazu
  FROM raumverantwortlicher
  WHERE raumverantwortlicher_id = p_raumverantwortlicher_id;

  IF gehoertDazu = p_labor_id
    THEN
    INSERT INTO berechtigung
    VALUES(p_person_id,p_raumverantwortlicher_id,p_berechtigung_von,p_berechtigung_bis,p_raum_nr);
  END IF;
COMMIT;
END;
/
show errors;


/* Procedure 4 */
CREATE OR REPLACE PROCEDURE Reservieren ( p_person_id INTEGER, p_raum_id INTEGER, p_reserviert_von DATE, p_reserviert_bis DATE)
IS
  funktionsfaehig INTEGER;
  geschlossen INTEGER;
BEGIN
  SELECT funktionsfaehigkeit INTO funktionsfaehig
    FROM transponder t, kann_oeffnen k, raum r
    WHERE t.transponder_id = k.transponder_id AND k.raum_id = r.raum_id AND r.raum_id = p_raum_id;
  SELECT r.gesperrt INTO geschlossen
    FROM raum r, kann_oeffnen k, transponder t
    WHERE p_raum_id = r.raum_id AND r.raum_id = k.raum_id AND k.transponder_id = t.transponder_id;
    IF funktionsfaehig = 0
      THEN
      DBMS_OUTPUT.PUT_LINE('Reservierung nicht moeglich! Transponder nicht funktionsfaehig.');
    ELSIF geschlossen = 1
      THEN
      DBMS_OUTPUT.PUT_LINE('Reservierung nicht moeglich! Raum geschlossen.');
    ELSE
      INSERT INTO reservierung
      VALUES(reservierung_sec.NEXTVAL, p_person_id, p_raum_id, p_reserviert_von, p_reserviert_bis);
      DBMS_OUTPUT.PUT_LINE('Reservierung erfolgreich');
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

/* Trigger 1 Ausleihe*/
CREATE OR REPLACE TRIGGER Berechtigung_Ausleihe_pruefen BEFORE INSERT ON ausleihe FOR EACH ROW
  DECLARE
    berech_von DATE;
    berech_bis DATE;
    braum INTEGER;
    rraum INTEGER;
    pperson INTEGER;
    bperson INTEGER;
    ktrans INTEGER;
    kraum INTEGER;
BEGIN
    SELECT b.berechtigung_von, b.berechtigung_bis, b.raum_id, r.raum_id, p.person_id, b.person_id, k.transponder_id, k.raum_id INTO berech_von, berech_bis, braum, rraum, pperson, bperson, ktrans, kraum FROM berechtigung b, person p, raum r, kann_oeffnen k
      WHERE b.berechtigung_von <= sysdate AND b.berechtigung_bis > sysdate AND b.berechtigung_bis >= :NEW.ausgeliehen_bis AND b.raum_id = r.raum_id AND r.raum_id = k.raum_id AND p.person_id = b.person_id AND k.transponder_id = :NEW.transponder_id AND p.person_id = :NEW.person_id;
    EXCEPTION
      WHEN no_data_found THEN
      RAISE_APPLICATION_ERROR('-20001', 'Ausleihe nicht moeglich! Keine Berechtigung.');
END;
/
SHOW ERRORS;

/* Trigger 1 Reservierung*/
CREATE OR REPLACE TRIGGER Berechtigung_Reservierung_pruefen BEFORE INSERT ON reservierung FOR EACH ROW
  DECLARE
    berech_von DATE;
    berech_bis DATE;
    braum INTEGER;
    rraum INTEGER;
    pperson INTEGER;
    bperson INTEGER;
    kraum INTEGER;
BEGIN
    SELECT b.berechtigung_von, b.berechtigung_bis, b.raum_id, r.raum_id, p.person_id, b.person_id, k.raum_id INTO berech_von, berech_bis, braum, rraum, pperson, bperson, kraum FROM berechtigung b, person p, raum r, kann_oeffnen k
      WHERE b.berechtigung_von <= :NEW.reserviert_von AND b.berechtigung_bis >= :NEW.reserviert_bis AND b.raum_id = r.raum_id AND r.raum_id = k.raum_id AND p.person_id = b.person_id AND :NEW.person_id = p.person_id AND :NEW.raum_id = r.raum_id;
    EXCEPTION
      WHEN no_data_found THEN
      RAISE_APPLICATION_ERROR('-20002', 'Reservierung nicht moeglich! Keine Berechtigung.');
END;
/
SHOW ERRORS;

/* Trigger 2 Ausleihe */
CREATE OR REPLACE TRIGGER Zeitraum_Ausleihe_pruefen BEFORE INSERT ON ausleihe FOR EACH ROW
  DECLARE
    trans_id INTEGER;
    trans_id2 INTEGER;
BEGIN

IF :NEW.ausgeliehen_von + 1 < :NEW.ausgeliehen_bis
      THEN
      RAISE_APPLICATION_ERROR('-20003', 'Ausleihe darf nicht laenger als einen Tag sein.');
    END IF;

SELECT CASE
WHEN EXISTS(
    SELECT reservierung_id  FROM reservierung r, raum a, kann_oeffnen k, transponder t, person p WHERE p.person_id != r.person_id AND t.transponder_id = :NEW.transponder_id AND t.transponder_id = k.transponder_id AND k.raum_id = a.raum_id AND r.raum_id = a.raum_id AND ((r.reserviert_von <= :NEW.ausgeliehen_von AND r.reserviert_bis >= :NEW.ausgeliehen_bis)
            OR (r.reserviert_von <= :NEW.ausgeliehen_bis AND r.reserviert_bis >= :NEW.ausgeliehen_bis)))
    THEN 1
    ELSE 0
    END INTO trans_id
    FROM dual;

SELECT CASE
WHEN EXISTS(
SELECT * FROM ausleihe a, kann_oeffnen k WHERE (a.transponder_id = :new.transponder_id AND (a.ausgeliehen_von <= :new.ausgeliehen_von AND a.ausgeliehen_bis >= :new.ausgeliehen_von)
                OR (a.ausgeliehen_von <= :new.ausgeliehen_bis AND a.ausgeliehen_bis >= :new.ausgeliehen_bis)))
    THEN 1
    ELSE 0
    END INTO trans_id2
    FROM dual;
    IF trans_id = 1 OR trans_id2 = 1
    THEN
        RAISE_APPLICATION_ERROR('-20004', 'Ausleihe nicht moeglich! Transponder schon ausgeliehen oder reserviert');
    END IF;
END;
/
SHOW ERRORS;


/* Trigger 2 Ausleihe*/
CREATE OR REPLACE TRIGGER Zeitraum_Reservierung_pruefen BEFORE INSERT ON reservierung FOR EACH ROW
  DECLARE
    trans_id INTEGER;
    trans_id2 INTEGER;
BEGIN

SELECT CASE
WHEN EXISTS(
    SELECT reservierung_id  FROM reservierung r, raum a, kann_oeffnen k, transponder t, person p WHERE p.person_id != r.person_id AND /*t.transponder_id = :NEW.transponder_id AND*/ t.transponder_id = k.transponder_id AND k.raum_id = a.raum_id AND r.raum_id = a.raum_id AND ((r.reserviert_von <= :NEW.reserviert_von AND r.reserviert_bis >= :NEW.reserviert_bis)
            OR (r.reserviert_von <= :NEW.reserviert_bis AND r.reserviert_bis >= :NEW.reserviert_bis)))
    THEN 1
    ELSE 0
    END INTO trans_id
    FROM dual;

SELECT CASE
WHEN EXISTS(
SELECT * FROM ausleihe a, kann_oeffnen k WHERE (k.transponder_id = a.transponder_id/*a.transponder_id = :new.transponder_id*/ AND (a.ausgeliehen_von <= :new.reserviert_von AND a.ausgeliehen_bis >= :new.reserviert_von)
                OR (a.ausgeliehen_von <= :new.reserviert_bis AND a.ausgeliehen_bis >= :new.reserviert_bis)))
    THEN 1
    ELSE 0
    END INTO trans_id2
    FROM dual;
    IF trans_id = 1 OR trans_id2 = 1
    THEN
        RAISE_APPLICATION_ERROR('-20004', 'Reservierung nicht moeglich! Transponder schon ausgeliehen oder reserviert');
    END IF;
END;
/
SHOW ERRORS;


/* Trigger 6 */
CREATE OR REPLACE TRIGGER Schadensmeldung_pruefen AFTER INSERT ON schadensmeldung FOR EACH ROW
  DECLARE
    schaden INTEGER;
    ges INTEGER;
BEGIN
  SELECT erheblicher_schaden, gesperrt INTO schaden, ges FROM schadensmeldung s, raum r WHERE :NEW.schadensmeldung_id = s.schadensmeldung_id AND r.raum_id = s.raum_id;

    IF
      schaden = 1
      THEN ges := 1;
    END IF;
END;
/
SHOW ERRORS;


/* View */
CREATE OR REPLACE VIEW view_berechtigte
AS
    SELECT p.person_id , p.nachname, p.vorname, a.transponder_id, a.ausgeliehen_von, a.ausgeliehen_bis, k.raum_id
    FROM berechtigung b, person p, ausleihe a, raumverantwortlicher r, transponder t, kann_oeffnen k
    WHERE ((r.RAUMVERANTWORTLICHER_ID = 1)
    AND r.RAUMVERANTWORTLICHER_ID = b.raumverantwortlicher_id
    AND b.person_id = p.person_id
    AND p.person_id = a.person_id
    AND a.transponder_id = t.transponder_id
    AND t.transponder_id = k.transponder_id);

CREATE OR REPLACE TRIGGER instead_of_delete
INSTEAD OF DELETE ON view_berechtigte
FOR EACH ROW
DECLARE exist INTEGER;
        name VARCHAR2 (45);
        t_id INTEGER(9);
BEGIN
    select case when exists(SELECT MAX(p.nachname),MAX(p.vorname), MAX(a.transponder_id) FROM ausleihe a, person p WHERE a.person_id = :OLD.person_id and a.person_id = p.person_id)
            then 1
            else 0
            end
    into exist
    from dual;

if(exist = 1) then
     DBMS_OUTPUT.PUT_LINE('Person hat Transponder noch in Besitz, dieser muss vom Hausmeister nun aquiriert werden');
end if;

END;
/
SHOW ERRORS;



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


SELECT * FROM berechtigung;

SELECT * FROM ausleihe;
SELECT * FROM Ausleihe_Archiv;

SELECT * FROM reservierung;

SELECT * FROM view_berechtigte;
