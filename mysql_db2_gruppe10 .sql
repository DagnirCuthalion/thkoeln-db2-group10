DROP TABLE kann_oeffnen;
DROP TABLE berechtigung;
DROP TABLE reservierung;
DROP TABLE schadensmeldung;
DROP TABLE raum;
DROP TABLE ausleihe;
DROP TABLE transponder;
DROP TABLE pfoertner;
DROP TABLE person;
DROP TABLE raumverantwortlicher;
DROP TABLE labor;


CREATE TABLE raum(
raum_id INTEGER(9) PRIMARY KEY,
raum_nr INTEGER(4) NOT NULL,
etage INTEGER(1),
gebaeude VARCHAR(45),
labor_id INTEGER (9)
);

CREATE TABLE kann_oeffnen(
raum_id INTEGER (9),
transponder_id INTEGER (9),
CONSTRAINT XPKkann_oefnnen PRIMARY KEY (raum_id, transponder_id)
);

CREATE TABLE transponder(
transponder_id INTEGER (9) PRIMARY KEY,
funktionsfaehigkeit VARCHAR (45)
);

CREATE TABLE pfoertner(
pfoertner_person_id INTEGER (9) PRIMARY KEY,
nachname VARCHAR (45) NOT NULL,
vorname VARCHAR (45) NOT NULL,
geburtsdatum VARCHAR (45) NOT NULL
);

CREATE TABLE person(
person_person_id INTEGER (9) PRIMARY KEY,
labor_id INTEGER (9) NOT NULL,
nachname VARCHAR (45) NOT NULL,
vorname VARCHAR (45) NOT NULL,
geburtsdatum DATE
);

CREATE TABLE raumverantwortlicher(
person_person_id INTEGER (9) NOT NULL,
raumverantwortlicher_id INTEGER (9) PRIMARY KEY,
nachname VARCHAR (45) NOT NULL,
vorname VARCHAR (45) NOT NULL,
geburtsdatum VARCHAR (45) NOT NULL,
labor_id INTEGER (9) NOT NULL
);

CREATE TABLE ausleihe(
transponder_id INTEGER (9),
person_person_id INTEGER (9),
pfoertner_person_id INTEGER (9),
ausgeliehen_von DATE NOT NULL,
ausgeliehen_bis DATE NOT NULL,
CONSTRAINT XPKausleihe PRIMARY KEY (transponder_id, person_person_id,ausgeliehen_von)
);

CREATE TABLE berechtigung(
person_id INTEGER(9),
raumverantwortlicher_id INTEGER (9),
berechtigung_von DATE NOT NULL,
berechtigung_bis DATE NOT NULL,
raum_nr VARCHAR (45) NOT NULL,
CONSTRAINT XPKberechtigung PRIMARY KEY (person_id,raumverantwortlicher_id)
);

CREATE TABLE reservierung(
reservierungs_id INTEGER (9) PRIMARY KEY,
person_id INTEGER (9) NOT NULL,
raum_id INTEGER (9) NOT NULL,
reserviert_von DATE NOT NULL,
reserviert_bis DATE NOT NULL
);

CREATE TABLE labor(
labor_id INTEGER (9) PRIMARY KEY,
labor_name VARCHAR(45) NOT NULL
);

CREATE TABLE schadensmeldung(
schadensmeldung_id INTEGER (9) PRIMARY KEY,
transponder_id INTEGER (9) NOT NULL,
person_person_id INTEGER (9) NOT NULL,
pfoertner_person_id INTEGER (9) NOT NULL,
raum_id INTEGER (9) NOT NULL,
meldung VARCHAR (45) NOT NULL
);

ALTER TABLE kann_oeffnen
        ADD ( CONSTRAINT wird_geoefnnet_fk
              FOREIGN KEY (raum_id)
                                REFERENCES raum(raum_id) ON DELETE CASCADE
                                                );                                                  
ALTER TABLE kann_oeffnen
        ADD ( CONSTRAINT oeffnet_fk
              FOREIGN KEY (transponder_id)
                                REFERENCES transponder(transponder_id) ON DELETE CASCADE
                                                );                                                 
ALTER TABLE ausleihe
        ADD ( CONSTRAINT wird_ausgeliehent_fk
              FOREIGN KEY (transponder_id)
                                REFERENCES transponder(transponder_id) ON DELETE CASCADE
                                                );      
ALTER TABLE ausleihe
        ADD ( CONSTRAINT vergibt_transponder_fk
              FOREIGN KEY (pfoertner_person_id)
                                REFERENCES pfoertner(pfoertner_person_id) ON DELETE CASCADE
                                                );                                                   
ALTER TABLE ausleihe
        ADD ( CONSTRAINT leiht_aus_fk
              FOREIGN KEY (person_person_id)
                                REFERENCES person(person_person_id) ON DELETE CASCADE
                                                );  											
ALTER TABLE berechtigung
        ADD ( CONSTRAINT vergibt_berechtigung_fk
              FOREIGN KEY (raumverantwortlicher_id)
                                REFERENCES raumverantwortlicher(raumverantwortlicher_id) ON DELETE CASCADE
                                                );                                                   
ALTER TABLE berechtigung
        ADD ( CONSTRAINT erhaelt_berechtigung_fk
              FOREIGN KEY (person_id)
                                REFERENCES person(person_person_id) ON DELETE CASCADE
                                                );  										
ALTER TABLE reservierung
        ADD ( CONSTRAINT wird_reserviert_fk
              FOREIGN KEY (raum_id)
                                REFERENCES raum(raum_id) ON DELETE CASCADE
                                                );                                               
ALTER TABLE reservierung
        ADD ( CONSTRAINT reserviert_fk
              FOREIGN KEY (person_id)
                                REFERENCES person(person_person_id) ON DELETE CASCADE
                                                );      
ALTER TABLE raum
        ADD ( CONSTRAINT teil_von_fk
              FOREIGN KEY (labor_id)
                                REFERENCES labor(labor_id) ON DELETE CASCADE
                                                );     
ALTER TABLE raumverantwortlicher
        ADD ( CONSTRAINT gehoert_zu_fk
              FOREIGN KEY (labor_id)
                                REFERENCES labor(labor_id) ON DELETE CASCADE
                                                ); 
ALTER TABLE schadensmeldung
        ADD ( CONSTRAINT bezieht_sich_auf_fk
              FOREIGN KEY (transponder_id,person_person_id,pfoertner_person_id)
                                REFERENCES ausleihe(transponder_id,person_person_id,pfoertner_person_id) ON DELETE CASCADE
                                                );
ALTER TABLE schadensmeldung
        ADD ( CONSTRAINT bezieht_sich_auf_raum_fk
              FOREIGN KEY (raum_id)
                                REFERENCES raum(raum_id) ON DELETE CASCADE
                                                );  
ALTER TABLE person
        ADD ( CONSTRAINT gehoert_an_fk
              FOREIGN KEY (labor_id)
                                REFERENCES labor(labor_id) ON DELETE CASCADE
                                                );                                                

-- notification function

-- fun1
/*
DROP PROCEDURE IF EXISTS fun_transponder_ausleihen;
DELIMITER $$
CREATE PROCEDURE fun_transponder_ausleihen (IN p_person_id INTEGER(9), IN p_transponder_id INTEGER(9), IN p_pfoertner_person_id INTEGER(9))
BEGIN
    IF (
		SELECT count(*) 
		FROM 
        (	
			(SELECT * FROM berechtigung b, kann_oeffnen k, raum r 
			WHERE b.person_id = p_person_id AND r.raum_nr = b.raum_nr 
			AND k.raum_id = r.raum_id AND k.transponder_id = p_transponder_id)
			MINUS
			(SELECT * FROM berechtigung b, kann_oeffnen k, raum r 
			WHERE b.person_id = p_person_id AND r.raum_nr = b.raum_nr 
			AND k.raum_id = r.raum_id AND NOT k.transponder_id = p_transponder_id);
		)
	)
        
							
	THEN
    -- funktionsfähig
		IF(SELECT t.funktionsfähigkeit FROM transponder t WHERE t.transponder_id=p_transponder_id) = 'funktionsfähig') THEN
        -- ausgeliehen
			IF NOT EXISTS (SELECT * FROM ausleihe a WHERE a.transponder_id = p_transponder_id AND (a.ausgeliehen_bis > current_timestamp() OR a.ausgeliehen_bis=NULL) THEN
				-- berechtigender bestimmen
                
                -- alles in ausleihe einfügen
                INSERT INTO ausleihe
                VALUES (p_transponder_id, p_person_id, p_pfoertner_person_id, ausgeliehen_von = current_timestamp());
			END IF;
		END IF;
	END IF;
END $$
DELIMITER ;
*/
    

-- proc2
DROP PROCEDURE IF EXISTS fun_transponder_zurueckgeben;
DELIMITER $$
CREATE PROCEDURE  fun_transponder_zurueckgeben (IN p_person_id INTEGER(9), IN p_transponder_id INTEGER(9))
BEGIN
	UPDATE ausleihe a
    SET a.ausgeliehen_bis = current_timestamp()
    WHERE a.person_person_id = p_person_id AND a.transponder_id = p_transponder_id 
    AND a.ausgeliehen_von = (SELECT MAX(ausgeliehen_von) FROM ausleihe a WHERE a.person_person_id = p_person_id AND a.transponder_id = p_transponder_id);
END $$
DELIMITER ;

-- fun3

-- fun4

-- trigger1

-- trigger2

-- trigger3
DELIMITER $$
CREATE TRIGGER trg_delete_reservations
BEFORE DELETE
ON berechtigung
FOR EACH ROW
BEGIN
	DELETE FROM reservierung r
    WHERE r.person_id = old.person_id
    AND current_timestamp() < r.reserviert_von;
END $$
DELIMITER ;

-- trigger4
DELIMITER $$
CREATE TRIGGER trg_notify_new_room
AFTER INSERT 
ON raum
FOR EACH ROW
BEGIN
	SELECT r.raumverantwortlicher_id, r.vorname, r.nachname FROM raumverantwortlicher r, labor l
    WHERE r.labor_id = l.labor_id
    AND l.labor_id = new.labor_id;
    -- TODO: notify
END $$
DELIMITER ;

-- trigger5
/*

DELIMITER $$
CREATE TRIGGER trg_delete_records
BEFORE DELETE 
ON person
FOR EACH ROW
BEGIN
IF(@trg_delete_records_active=1) THEN
    CREATE EVENT IF NOT EXISTS delete_records
    ON SCHEDULE AT DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 1 YEAR)
    DO 
		SET @trg_delete_records_active=0;
        DELETE FROM person p
        WHERE p.person_person_id = OLD.person_person_id;
        SET @trg_delete_records_active=1;
END IF;
END$$
/
DELIMITER ;
SET @trg_delete_records_active=1;
*/

-- view
CREATE OR REPLACE VIEW view_berechtigte 
AS 
	SELECT p.person_person_id person_id, p.nachname, p.vorname, a.transponder_id, a.ausgeliehen_von, a.ausgeliehen_bis, k.raum_id 
	FROM berechtigung b, person p, ausleihe a, raumverantwortlicher r, transponder t, kann_oeffnen k
    WHERE ((r.raumverantwortlicher_id = 1)
    AND r.raumverantwortlicher_id = b.raumverantwortlicher_id
    AND b.person_id = p.person_person_id
    AND p.person_person_id = a.person_person_id
    AND a.transponder_id = t.transponder_id
    AND t.transponder_id = k.transponder_id);