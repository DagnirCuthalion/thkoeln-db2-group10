DROP TABLE kann_oeffnen;
DROP TABLE berechtigung;
DROP TABLE reservierung;
DROP TABLE schadensmeldung;
DROP TABLE raum;
DROP TABLE ausleihe;
DROP TABLE ausleihe_archiv;
DROP TABLE transponder;
DROP TABLE pfoertner;
DROP TABLE person;
DROP TABLE raumverantwortlicher;
DROP TABLE labor;


CREATE TABLE raum(
raum_id INTEGER(9) PRIMARY KEY,
raum_nr VARCHAR(10) NOT NULL,
gebaeude VARCHAR(45),
etage varchar(20),
labor_id INTEGER (9),
gesperrt BOOLEAN
);

CREATE TABLE kann_oeffnen(
raum_id INTEGER (9),
transponder_id INTEGER (9),
CONSTRAINT XPKkann_oefnnen PRIMARY KEY (raum_id, transponder_id)
);

CREATE TABLE transponder(
transponder_id INTEGER (9) PRIMARY KEY,
funktionsfaehigkeit BOOLEAN
);

CREATE TABLE pfoertner(
pfoertner_person_id INTEGER(9) PRIMARY KEY,
nachname VARCHAR (45) NOT NULL,
vorname VARCHAR (45) NOT NULL,
geburtsdatum DATE NOT NULL
);

CREATE TABLE person(
person_person_id INTEGER (9) PRIMARY KEY,
labor_id INTEGER (9) NOT NULL,
nachname VARCHAR (45) NOT NULL,
vorname VARCHAR (45) NOT NULL,
geburtsdatum DATE
);

CREATE TABLE raumverantwortlicher(
raumverantworlicher_person_id INTEGER (9)  PRIMARY KEY,
nachname VARCHAR (45) NOT NULL,
vorname VARCHAR (45) NOT NULL,
geburtsdatum DATE NOT NULL,
labor_id INTEGER (9) NOT NULL
);

CREATE TABLE ausleihe(
transponder_id INTEGER (9),
person_person_id INTEGER (9),
pfoertner_person_id INTEGER (9),
ausgeliehen_von DATETIME NOT NULL,
ausgeliehen_bis DATETIME NOT NULL,
CONSTRAINT XPKausleihe PRIMARY KEY (transponder_id, person_person_id,ausgeliehen_von)
);

CREATE TABLE ausleihe_archiv(
transponder_id INTEGER (9),
person_person_id INTEGER (9),
pfoertner_person_id INTEGER (9),
ausgeliehen_von DATETIME NOT NULL,
ausgeliehen_bis DATETIME NOT NULL,
CONSTRAINT XPKausleihe PRIMARY KEY (transponder_id, person_person_id,ausgeliehen_von)
);

CREATE TABLE berechtigung(
raumverantwortlicher_id INTEGER (9),
person_id INTEGER(9),
raum_nr VARCHAR (10) NOT NULL,
berechtigung_von DATETIME NOT NULL,
berechtigung_bis DATETIME NOT NULL,
CONSTRAINT XPKberechtigung PRIMARY KEY (person_id,raumverantwortlicher_id)
);

CREATE TABLE reservierung(
reservierung_id INTEGER (9) PRIMARY KEY,
reserviert_von DATETIME NOT NULL,
reserviert_bis DATETIME NOT NULL,
raum_id INTEGER (9) NOT NULL,
person_id INTEGER (9) NOT NULL
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
                                REFERENCES raumverantwortlicher(raumverantworlicher_person_id) ON DELETE CASCADE
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
        ADD ( CONSTRAINT bezieht_sich_auf_transponder_fk
              FOREIGN KEY (transponder_id)
                                REFERENCES ausleihe(transponder_id) ON DELETE CASCADE
                                                );
ALTER TABLE schadensmeldung
        ADD ( CONSTRAINT bezieht_sich_auf_person_fk
              FOREIGN KEY (person_person_id)
                                REFERENCES ausleihe(person_person_id) ON DELETE CASCADE
                                                );  
ALTER TABLE schadensmeldung
        ADD ( CONSTRAINT bezieht_sich_auf_pfoerter_fk
              FOREIGN KEY (pfoertner_person_id)
                                REFERENCES ausleihe(pfoertner_person_id) ON DELETE CASCADE
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
DROP PROCEDURE IF EXISTS proc_transponder_ausleihen;
DELIMITER $$
CREATE PROCEDURE proc_transponder_ausleihen (IN p_transponder_id INTEGER(9), IN p_person_id INTEGER(9), IN p_pfoertner_person_id INTEGER(9), IN p_ausgeliehen_bis  DATETIME )
BEGIN
    IF EXISTS 
    (
		SELECT * 
		FROM berechtigung b, kann_oeffnen k, raum r 
        WHERE b.person_id = p_person_id AND r.raum_nr = b.raum_nr 
        AND k.raum_id = r.raum_id AND k.transponder_id = p_transponder_id
	)
	THEN
		IF(SELECT gesperrt 
		FROM berechtigung b, kann_oeffnen k, raum r 
        WHERE b.person_id = p_person_id AND r.raum_nr = b.raum_nr 
        AND k.raum_id = r.raum_id AND k.transponder_id = p_transponder_id=FALSE) THEN
			IF EXISTS(SELECT * FROM transponder t WHERE t.transponder_id = p_transponder_id AND t.funktionsfaehigkeit = TRUE)  THEN
			-- ausgeliehen
				IF NOT EXISTS (SELECT * FROM ausleihe a WHERE a.transponder_id = p_transponder_id AND (a.ausgeliehen_bis > current_timestamp() OR a.ausgeliehen_bis=NULL)) THEN
					-- berechtigender bestimmen
                
					-- alles in ausleihe einfügen
					INSERT INTO ausleihe
					VALUES (p_transponder_id, p_person_id, p_pfoertner_person_id, ausgeliehen_von = current_timestamp(), p_ausgeliehen_bis);
				ELSE
					SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'Transponder in diesem Zeitraum bereits ausgeliehen', MYSQL_ERRNO = 1002;
				END IF;
			SIGNAL SQLSTATE '45007' SET MESSAGE_TEXT = 'Transponder defekt', MYSQL_ERRNO = 1007;
			END IF;
		ELSE
			SIGNAL SQLSTATE '45009' SET MESSAGE_TEXT = 'Raum gesperrt', MYSQL_ERRNO = 1009;
        END IF;
	SIGNAL SQLSTATE '45008' SET MESSAGE_TEXT = 'Fehlende Berechtigung', MYSQL_ERRNO = 1008;
	END IF;
END $$
DELIMITER ;

    

-- proc2
DROP PROCEDURE IF EXISTS proc_transponder_zurueckgeben;
DELIMITER $$
CREATE PROCEDURE  proc_transponder_zurueckgeben (IN p_person_id INTEGER(9), IN p_transponder_id INTEGER(9))
BEGIN
	IF NOT EXISTS( 	SELECT s.schadensmeldung_id FROM schadensmeldung s, ausleihe a CROSS JOIN information_schema.tables i 
				WHERE s.transponder_id = p_transponder_id AND s.person_person_id = p_person_id AND i.UPDATE_TIME > a.ausgeliehen_von AND a.person_person_id = p_person_id AND i.TABLE_NAME = 'schadensmeldung') THEN
		UPDATE ausleihe a
		SET a.ausgeliehen_bis = current_timestamp()
		WHERE a.person_person_id = p_person_id AND a.transponder_id = p_transponder_id 
		AND a.ausgeliehen_von = (SELECT MAX(ausgeliehen_von) FROM ausleihe a WHERE a.person_person_id = p_person_id AND a.transponder_id = p_transponder_id);
    ELSE 
		SIGNAL SQLSTATE '45010' SET MESSAGE_TEXT = 'Schadensmeldung vorliegend', MYSQL_ERRNO = 1010;
	END IF;
END $$
DELIMITER ;

-- fun3
DROP PROCEDURE IF EXISTS proc_add_berechtigung;
DELIMITER $$
CREATE PROCEDURE  proc_add_berechtigung (IN p_raumverantwortlicher_id INTEGER(9), IN p_person_id INTEGER(9), IN p_raum_nr VARCHAR(10), IN p_berechtigung_von DATETIME, IN p_berechtigung_bis DATETIME)
BEGIN
	IF ((SELECT l.labor_name FROM labor l, person p WHERE l.labor_id = p.labor_id AND p.person_person_id = p_person_id) = 'Wartungspersonal' OR (EXISTS ( SELECT * FROM raum r, labor l, person p WHERE r.raum_nr = p_raum_nr AND r.labor_id = l.labor_id AND p.labor_id = l.labor_id and p.person_person_id = p_person_id))) THEN
		INSERT INTO berechtigung
        VALUES (p_raumverantwortlicher_id, p_person_id, p_raum_nr, p_berechtigung_von, p_berechtigung_bis);
    ELSE 
		SIGNAL SQLSTATE '45011' SET MESSAGE_TEXT = 'Zu Berechtigender gehört nicht zum entsprechenden Labor des Raums', MYSQL_ERRNO = 1011;
	END IF;
END $$
DELIMITER ;

-- fun4

-- trigger1
DROP TRIGGER IF EXISTS trg_check_berechtigung_still_valid;
DELIMITER $$
CREATE TRIGGER trg_check_berechtigung_still_valid
BEFORE INSERT
ON ausleihe
FOR EACH ROW
BEGIN
	IF NOT EXISTS
    (
        SELECT * 
        FROM berechtigung b, raum r, kann_oeffnen k
        WHERE b.berechtigung_bis > current_timestamp() AND b.raum_nr = r.raum_nr 
        AND r.raum_id = k.raum_id AND k.transponder_id = new.transponder_id
		AND NOT k.transponder_id != new.transponder_id
	) THEN
		SIGNAL SQLSTATE '45006' SET MESSAGE_TEXT = 'Berechtigung nicht mehr gueltig' , MYSQL_ERRNO = 1006;
    END IF;
END $$
DELIMITER ;


-- trigger2
DROP TRIGGER IF EXISTS trg_check_ausleihe_duration;
DELIMITER $$
CREATE TRIGGER trg_check_ausleihe_duration
BEFORE INSERT
ON ausleihe
FOR EACH ROW
BEGIN
	IF( DATEDIFF(new.ausgeliehen_von, new.ausgeliehen_bis) > 1) THEN
		CALL proc_transponder_ausleihen(new.transponder_id, new.person_person_id, new.pfoertner_person_id, new.ausgeliehen_bis-1);
        SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'Transponder darf nicht für laenger als einen Tag ausgeliehen werden', MYSQL_ERRNO = 1003;
	END IF;
    IF EXISTS ( SELECT count(*) FROM reservierung r WHERE (r.transponder_id = new.transponder_id AND (r.reserviert_von < new.ausgeliehen_von AND r.reserviert_bis > new.ausgeliehen_von) 
				OR (r.reserviert_von < new.ausgeliehen_bis AND r.reserviert_bis > new.ausgeliehen_bis)) ) THEN
			-- SELECT MAX(r.reserviert_bis) as 'Alternativtermin zur Ausleihe' FROM reservierung r WHERE r.transponder_id = new.transponder_id;
			SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Transponder in diesem Zeitraum bereits reserviert', MYSQL_ERRNO = 1001;
		ELSE IF EXISTS ( SELECT COUNT(*) FROM ausleihe a WHERE (a.transponder_id = new.transponder_id AND (a.ausgeliehen_von < new.ausgeliehen_von AND a.ausgeliehen_bis > new.ausgeliehen_von) 
				OR (a.ausgeliehen_von < new.ausgeliehen_bis AND a.ausgeliehen_bis > new.ausgeliehen_bis)) ) THEN
			-- SELECT MAX(a.ausgeliehen_bis) as 'Alternativtermin zur Ausleihe' FROM ausleihe a WHERE a.transponder_id = new.transponder_id;
			SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'Transponder in diesem Zeitraum bereits ausgeliehen', MYSQL_ERRNO = 1002;
		END IF;
    END IF;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'An error occurred', MYSQL_ERRNO = 1000;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS trg_check_reservierung_duration;
DELIMITER $$
CREATE TRIGGER trg_check_reservierung_duration
BEFORE INSERT
ON reservierung
FOR EACH ROW
BEGIN
	IF( DATEDIFF(new.reserviert_von, new.reserviert_bis) > 1) THEN
		-- CALL proc_raum_reservieren(new.transponder_id, new.person_person_id, new.pfoertner_person_id, new.ausgeliehen_bis - 1);
        SIGNAL SQLSTATE '46003' SET MESSAGE_TEXT = 'Transponder darf nicht für laenger als einen Tag resverviert werden', MYSQL_ERRNO = 1103;
	END IF;
    IF EXISTS ( SELECT count(*) FROM reservierung r, kann_oeffnen k WHERE (r.transponder_id = k.transponder_id AND k.raum_id = new.raum_id AND (r.reserviert_von < new.reserviert_von AND r.reserviert_bis > new.reserviert_von) 
				OR (r.reserviert_von < new.reserviert_bis AND r.reserviert_bis > new.reserviert_bis)) ) THEN
			-- SELECT MAX(r.reserviert_bis) as 'Alternativtermin zur Ausleihe' FROM reservierung r WHERE r.transponder_id = new.transponder_id;
			SIGNAL SQLSTATE '46001' SET MESSAGE_TEXT = 'Transponder in diesem Zeitraum bereits reserviert', MYSQL_ERRNO = 1101;
		ELSE IF EXISTS ( SELECT COUNT(*) FROM ausleihe a, kann_oeffnen k WHERE (a.transponder_id = k.transponder_id AND k.raum_id = new.raum_id AND (a.ausgeliehen_von < new.reserviert_von AND a.ausgeliehen_bis > new.reserviert_von) 
				OR (a.ausgeliehen_von < new.reserviert_bis AND a.ausgeliehen_bis > new.reserviert_bis)) ) THEN
			-- SELECT MAX(a.ausgeliehen_bis) as 'Alternativtermin zur Ausleihe' FROM ausleihe a WHERE a.transponder_id = new.transponder_id;
			SIGNAL SQLSTATE '46002' SET MESSAGE_TEXT = 'Transponder in diesem Zeitraum bereits ausgeliehen', MYSQL_ERRNO = 1102;
		END IF;
    END IF;
    SIGNAL SQLSTATE '46000'
      SET MESSAGE_TEXT = 'An error occurred', MYSQL_ERRNO = 1100;
END $$
DELIMITER ;

-- trigger3
DROP TRIGGER IF EXISTS trg_delete_reservations;
DELIMITER $$
CREATE TRIGGER trg_delete_reservations
BEFORE DELETE
ON berechtigung
FOR EACH ROW
BEGIN
	DELETE FROM reservierung WHERE person_id = old.person_id AND (current_timestamp() - reserviert_von) >0;
    SIGNAL SQLSTATE '45005' SET MESSAGE_TEXT = 'Berechtigte Person hatte ausstehende Reservierungen' , MYSQL_ERRNO = 1005;
END $$
DELIMITER ;

-- trigger4
DROP TRIGGER IF EXISTS trg_notify_new_room;
DELIMITER $$
CREATE TRIGGER trg_notify_new_room
AFTER INSERT 
ON raum
FOR EACH ROW
BEGIN
	DECLARE rid integer(9);
    DECLARE vname VARCHAR(45);
    DECLARE nname VARCHAR(45);
    DECLARE msg varchar(255);
	SELECT r.raumverantwortlicher_id, r.vorname, r.nachname INTO rid, vname, nname FROM raumverantwortlicher r, labor l WHERE r.labor_id = l.labor_id AND l.labor_id = new.labor_id;
    SET msg = 'placeholdernotification to ' || rid || ' ' || vname || ' ' || nname;
    -- TODO: notify
    SIGNAL SQLSTATE '45004' SET MESSAGE_TEXT = msg , MYSQL_ERRNO = 1004;
END $$
DELIMITER ;

/*
-- trigger5

DROP TRIGGER IF EXISTS trg_delete_records;
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
    WHERE ((r.raumverantworlicher_person_id = 1)
    AND r.raumverantworlicher_person_id = b.raumverantwortlicher_id
    AND b.person_id = p.person_person_id
    AND p.person_person_id = a.person_person_id
    AND a.transponder_id = t.transponder_id
    AND t.transponder_id = k.transponder_id);