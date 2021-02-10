-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema ingrosso-piante
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `ingrosso-piante` ;

-- -----------------------------------------------------
-- Schema ingrosso-piante
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `ingrosso-piante` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `ingrosso-piante` ;

-- -----------------------------------------------------
-- Table `ingrosso-piante`.`utenti`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`utenti` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`utenti` (
  `username` VARCHAR(45) NOT NULL,
  `password` CHAR(32) NOT NULL,
  `ruolo` ENUM('amministratore', 'cliente', 'gestore_magazzino', 'manager', 'operatore') NOT NULL,
  PRIMARY KEY (`username`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`cliente`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`cliente` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`cliente` (
  `recapito_preferito` VARCHAR(45) NOT NULL,
  `nome` VARCHAR(45) NOT NULL,
  `codice_fiscale` CHAR(16) NULL DEFAULT NULL,
  `partita_IVA` CHAR(11) NULL DEFAULT NULL,
  `tipo` ENUM('privato', 'rivendita') NOT NULL,
  `via` VARCHAR(45) NOT NULL,
  `numero_civico` INT UNSIGNED NOT NULL,
  `città` VARCHAR(45) NOT NULL,
  `via_fatturazione` VARCHAR(45) NOT NULL,
  `civico_fatturazione` INT UNSIGNED NOT NULL,
  `città_fatturazione` VARCHAR(45) NOT NULL,
  `username` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`recapito_preferito`),
  CONSTRAINT `fk_cliente_1`
    FOREIGN KEY (`username`)
    REFERENCES `ingrosso-piante`.`utenti` (`username`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE UNIQUE INDEX `username_UNIQUE` ON `ingrosso-piante`.`cliente` (`username` ASC) VISIBLE;

CREATE UNIQUE INDEX `codice_fiscale_UNIQUE` ON `ingrosso-piante`.`cliente` (`codice_fiscale` ASC) VISIBLE;

CREATE UNIQUE INDEX `partita_IVA_UNIQUE` ON `ingrosso-piante`.`cliente` (`partita_IVA` ASC) VISIBLE;

CREATE INDEX `fk_cliente_1_idx` ON `ingrosso-piante`.`cliente` (`username` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`specie_di_piante`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`specie_di_piante` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`specie_di_piante` (
  `codice` VARCHAR(45) NOT NULL,
  `nome_comune` VARCHAR(45) NOT NULL,
  `nome_latino` VARCHAR(45) NOT NULL,
  `da_interno` TINYINT NOT NULL,
  `esotica` TINYINT NOT NULL,
  PRIMARY KEY (`codice`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE UNIQUE INDEX `nome_comune_UNIQUE` ON `ingrosso-piante`.`specie_di_piante` (`nome_comune` ASC) VISIBLE;

CREATE UNIQUE INDEX `nome_latino_UNIQUE` ON `ingrosso-piante`.`specie_di_piante` (`nome_latino` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`fornitore`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`fornitore` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`fornitore` (
  `codice_fornitore` INT UNSIGNED NOT NULL,
  `nome` VARCHAR(45) NOT NULL,
  `codice_fiscale` CHAR(16) NOT NULL,
  PRIMARY KEY (`codice_fornitore`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE UNIQUE INDEX `codice_fiscale_UNIQUE` ON `ingrosso-piante`.`fornitore` (`codice_fiscale` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`rifornimento`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`rifornimento` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`rifornimento` (
  `fornitore` INT UNSIGNED NOT NULL,
  `data_richiesta` DATETIME NOT NULL,
  `data_consegna` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`fornitore`, `data_richiesta`),
  CONSTRAINT `fk_rifornimento_1`
    FOREIGN KEY (`fornitore`)
    REFERENCES `ingrosso-piante`.`fornitore` (`codice_fornitore`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`contenente`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`contenente` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`contenente` (
  `fornitore` INT UNSIGNED NOT NULL,
  `data_richiesta_rifornimento` DATETIME NOT NULL,
  `specie_di_piante` VARCHAR(45) NOT NULL,
  `quantità` INT UNSIGNED NOT NULL DEFAULT '1',
  PRIMARY KEY (`fornitore`, `data_richiesta_rifornimento`, `specie_di_piante`),
  CONSTRAINT `fk_contenente_1`
    FOREIGN KEY (`specie_di_piante`)
    REFERENCES `ingrosso-piante`.`specie_di_piante` (`codice`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_contenente_2`
    FOREIGN KEY (`fornitore` , `data_richiesta_rifornimento`)
    REFERENCES `ingrosso-piante`.`rifornimento` (`fornitore` , `data_richiesta`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_contenente_1_idx` ON `ingrosso-piante`.`contenente` (`specie_di_piante` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`ordine`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`ordine` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`ordine` (
  `codice` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `data_apertura` DATETIME NOT NULL,
  `data_finalizzazione` DATETIME NULL DEFAULT NULL,
  `via` VARCHAR(45) NULL DEFAULT NULL,
  `numero_civico` INT UNSIGNED NULL DEFAULT NULL,
  `città` VARCHAR(45) NULL DEFAULT NULL COMMENT '	',
  `recapito` VARCHAR(45) NULL DEFAULT NULL,
  `referente` VARCHAR(45) NULL DEFAULT NULL,
  `tipo` ENUM('aperto', 'finalizzato', 'spedito') NOT NULL,
  `richiesta` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`codice`),
  CONSTRAINT `fk_ordine_1`
    FOREIGN KEY (`richiesta`)
    REFERENCES `ingrosso-piante`.`cliente` (`recapito_preferito`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_ordine_1_idx` ON `ingrosso-piante`.`ordine` (`richiesta` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`pianta`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`pianta` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`pianta` (
  `colore` VARCHAR(45) NOT NULL DEFAULT 'Senza fiori',
  `codice_specie` VARCHAR(45) NOT NULL,
  `numero_giacenze` INT UNSIGNED NOT NULL DEFAULT '0',
  PRIMARY KEY (`colore`, `codice_specie`),
  CONSTRAINT `fk_pianta_specie`
    FOREIGN KEY (`codice_specie`)
    REFERENCES `ingrosso-piante`.`specie_di_piante` (`codice`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_pianta_specie_idx` ON `ingrosso-piante`.`pianta` (`codice_specie` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`contiene`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`contiene` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`contiene` (
  `ordine` INT UNSIGNED NOT NULL,
  `colore_pianta` VARCHAR(45) NOT NULL,
  `specie` VARCHAR(45) NOT NULL,
  `quantità` INT UNSIGNED NOT NULL DEFAULT '1',
  PRIMARY KEY (`ordine`, `colore_pianta`, `specie`),
  CONSTRAINT `fk_contiene_ordine`
    FOREIGN KEY (`ordine`)
    REFERENCES `ingrosso-piante`.`ordine` (`codice`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_contiene_pianta`
    FOREIGN KEY (`colore_pianta` , `specie`)
    REFERENCES `ingrosso-piante`.`pianta` (`colore` , `codice_specie`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_contiene_pianta_idx` ON `ingrosso-piante`.`contiene` (`colore_pianta` ASC, `specie` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`ordine_in_elaborazione`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`ordine_in_elaborazione` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`ordine_in_elaborazione` (
  `codice` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `data_apertura` DATETIME NOT NULL,
  `data_finalizzazione` DATETIME NOT NULL,
  `via` VARCHAR(45) NOT NULL,
  `numero_civico` INT UNSIGNED NOT NULL,
  `città` VARCHAR(45) NOT NULL,
  `recapito` VARCHAR(45) NOT NULL,
  `referente` VARCHAR(45) NULL DEFAULT NULL,
  `richiesta1` DATETIME NOT NULL,
  PRIMARY KEY (`codice`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`contiene1`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`contiene1` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`contiene1` (
  `ordine_in_elaborazione` INT UNSIGNED NOT NULL,
  `colore_pianta` VARCHAR(45) NOT NULL,
  `specie` VARCHAR(45) NOT NULL,
  `quantità` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`ordine_in_elaborazione`, `colore_pianta`, `specie`),
  CONSTRAINT `fk_contiene1_ordine_elaborazione`
    FOREIGN KEY (`ordine_in_elaborazione`)
    REFERENCES `ingrosso-piante`.`ordine_in_elaborazione` (`codice`),
  CONSTRAINT `fk_contiene1_pianta`
    FOREIGN KEY (`colore_pianta` , `specie`)
    REFERENCES `ingrosso-piante`.`pianta` (`colore` , `codice_specie`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_contiene1_pianta_idx` ON `ingrosso-piante`.`contiene1` (`colore_pianta` ASC, `specie` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`evasi`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`evasi` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`evasi` (
  `pacco` INT UNSIGNED NOT NULL,
  `ordine` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`pacco`, `ordine`),
  CONSTRAINT `fk_evasi_ordine`
    FOREIGN KEY (`ordine`)
    REFERENCES `ingrosso-piante`.`ordine` (`codice`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_evasi_ordine_idx` ON `ingrosso-piante`.`evasi` (`ordine` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`evasi1`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`evasi1` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`evasi1` (
  `pacco` INT UNSIGNED NOT NULL,
  `ordine_in_elaborazione` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`pacco`, `ordine_in_elaborazione`),
  CONSTRAINT `fk_evasi1_ordine_elaborazione`
    FOREIGN KEY (`ordine_in_elaborazione`)
    REFERENCES `ingrosso-piante`.`ordine_in_elaborazione` (`codice`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_evasi1_ordine_elaborazione_idx` ON `ingrosso-piante`.`evasi1` (`ordine_in_elaborazione` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`fornisce`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`fornisce` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`fornisce` (
  `fornitore` INT UNSIGNED NOT NULL,
  `specie_di_piante` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`fornitore`, `specie_di_piante`),
  CONSTRAINT `fk_fornisce_fornitore`
    FOREIGN KEY (`fornitore`)
    REFERENCES `ingrosso-piante`.`fornitore` (`codice_fornitore`),
  CONSTRAINT `fk_fornisce_specie`
    FOREIGN KEY (`specie_di_piante`)
    REFERENCES `ingrosso-piante`.`specie_di_piante` (`codice`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_fornisce_specie_idx` ON `ingrosso-piante`.`fornisce` (`specie_di_piante` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`indirizzo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`indirizzo` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`indirizzo` (
  `via` VARCHAR(45) NOT NULL,
  `numero_civico` INT UNSIGNED NOT NULL,
  `città` VARCHAR(45) NOT NULL,
  `fornitore` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`via`, `numero_civico`, `città`),
  CONSTRAINT `fk_indirizzo_fornitore`
    FOREIGN KEY (`fornitore`)
    REFERENCES `ingrosso-piante`.`fornitore` (`codice_fornitore`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_indirizzo_1_idx` ON `ingrosso-piante`.`indirizzo` (`fornitore` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`inserita`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`inserita` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`inserita` (
  `id_pacco` INT UNSIGNED NOT NULL,
  `colore_pianta` VARCHAR(45) NOT NULL,
  `specie` VARCHAR(45) NOT NULL,
  `quantità` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_pacco`, `colore_pianta`, `specie`),
  CONSTRAINT `fk_inserita_pianta`
    FOREIGN KEY (`colore_pianta` , `specie`)
    REFERENCES `ingrosso-piante`.`pianta` (`colore` , `codice_specie`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_inserita_pianta_idx` ON `ingrosso-piante`.`inserita` (`colore_pianta` ASC, `specie` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`listino_prezzi`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`listino_prezzi` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`listino_prezzi` (
  `data_inizio_validità` DATETIME NOT NULL,
  `codice_specie` VARCHAR(45) NOT NULL,
  `valore` FLOAT UNSIGNED NOT NULL,
  `data_fine_validità` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`data_inizio_validità`, `codice_specie`),
  CONSTRAINT `fk_listino_prezzi_1`
    FOREIGN KEY (`codice_specie`)
    REFERENCES `ingrosso-piante`.`specie_di_piante` (`codice`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_listino_prezzi_1_idx` ON `ingrosso-piante`.`listino_prezzi` (`codice_specie` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`recapito_secondario_cliente`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`recapito_secondario_cliente` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`recapito_secondario_cliente` (
  `recapito` VARCHAR(45) NOT NULL,
  `cliente` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`recapito`),
  CONSTRAINT `fk_recapito_secondario_cliente_cliente`
    FOREIGN KEY (`cliente`)
    REFERENCES `ingrosso-piante`.`cliente` (`recapito_preferito`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_recapito_secondario_cliente_cliente_idx` ON `ingrosso-piante`.`recapito_secondario_cliente` (`cliente` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`referente_rivendita`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`referente_rivendita` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`referente_rivendita` (
  `cliente` VARCHAR(45) NOT NULL,
  `nome` VARCHAR(45) NOT NULL,
  `recapito_primario` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`cliente`),
  CONSTRAINT `fk_referente_rivendita_cliente`
    FOREIGN KEY (`cliente`)
    REFERENCES `ingrosso-piante`.`cliente` (`recapito_preferito`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `ingrosso-piante`.`recapito_secondario_referente`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`recapito_secondario_referente` ;

CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`recapito_secondario_referente` (
  `recapito` VARCHAR(45) NOT NULL,
  `referente_rivendita` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`recapito`),
  CONSTRAINT `fk_recapito_secondario_referente_ref_rivendita`
    FOREIGN KEY (`referente_rivendita`)
    REFERENCES `ingrosso-piante`.`referente_rivendita` (`cliente`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

CREATE INDEX `fk_recapito_secondario_referente_ref_rivendita_idx` ON `ingrosso-piante`.`recapito_secondario_referente` (`referente_rivendita` ASC) VISIBLE;

USE `ingrosso-piante` ;

-- -----------------------------------------------------
-- Placeholder table for view `ingrosso-piante`.`ordini_aperti`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `ingrosso-piante`.`ordini_aperti` (`codice` INT, `data_apertura` INT, `'recapito cliente'` INT);

-- -----------------------------------------------------
-- procedure aggiungi_cliente
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`aggiungi_cliente`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `aggiungi_cliente`(in var_username varchar(45), in var_tipo varchar(20), in var_recapito_preferito varchar(45), in var_nome varchar(45), in var_codice_fiscale char(16), in var_partita_IVA char(11), in var_via varchar(45), in var_numero_civico int, in var_città varchar(45), in var_via_fatturazione varchar(45), in var_civico_fatturazione int, in var_città_fatturazione varchar(45), in var_referente varchar(45), in var_recapito_referente varchar(45))
BEGIN
	declare exit handler for sqlexception
    begin
        resignal;  -- raise again the sql exception to the caller
    end;
    
    -- verifico se il recapito corrisponde a un telefono o a un'email
	if (not `valid_email` (var_recapito_preferito) and not `valid_phone` (var_recapito_preferito)) then
		signal sqlstate '45001'
        set message_text = "Il recapito inserito non sembra corrispondere né a un'email né a un numreo di telefono";
	end if;
    
    set transaction isolation level read uncommitted;
	start transaction;
		if var_tipo = 'rivendita' then
			insert into `cliente` (`recapito_preferito`, `nome`, `partita_IVA`, `tipo`, `via`, `numero_civico`, `città`, `via_fatturazione`, `civico_fatturazione`, `città_fatturazione`, `username`) values (var_recapito_preferito, var_nome, var_partita_IVA, 'rivendita', var_via, var_numero_civico, var_città, var_via_fatturazione, var_civico_fatturazione, var_città_fatturazione, var_username);
			if var_recapito_referente = '-' then
				insert into `referente_rivendita` (`cliente`, `nome`) values (var_recapito_preferito, var_referente);
			else 
				insert into `referente_rivendita` values (var_recapito_preferito, var_referente, var_recapito_referente);
			end if;
		else
			insert into `cliente` (`recapito_preferito`, `nome`, `codice_fiscale`, `tipo`, `via`, `numero_civico`, `città`, `via_fatturazione`, `civico_fatturazione`, `città_fatturazione`, `username`) values (var_recapito_preferito, var_nome, var_codice_fiscale, 'privato', var_via, var_numero_civico, var_città, var_via_fatturazione, var_civico_fatturazione, var_città_fatturazione, var_username);
		end if;
    commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure aggiungi_contatto_cliente
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`aggiungi_contatto_cliente`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `aggiungi_contatto_cliente`(in var_username varchar(45), in var_contatto varchar(45))
BEGIN
	declare var_cliente varchar(45);
	declare exit handler for sqlexception
    begin
        resignal;  -- raise again the sql exception to the caller
    end;
    
    -- verifico se il recapito corrisponde a un telefono o a un'email
	if (not `valid_email` (var_contatto) and not `valid_phone` (var_contatto)) then
		signal sqlstate '45001'
        set message_text = "Il recapito inserito non sembra corrispondere né a un'email né a un numreo di telefono";
	end if;
	
	set transaction isolation level read committed;
    start transaction;
    select `recapito_preferito` from `cliente` where var_username = `username` into var_cliente;
    insert into `recapito_secondario_cliente` values (var_contatto, var_cliente);
    commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure aggiungi_fornitore
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`aggiungi_fornitore`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `aggiungi_fornitore`(in var_codice_fornitore int, in var_nome varchar(45),in var_codice_fiscale char(16), in var_via varchar(45), in var_numero_civico int, in var_città varchar(45), in var_specie_fornita varchar(45))
BEGIN
	set transaction isolation level read uncommitted;
    start transaction;
	insert into `fornitore` values (var_codice_fornitore, var_nome, var_codice_fiscale);
    insert into `indirizzo` values (var_via, var_numero_civico, var_città, var_codice_fornitore);
    insert into `fornisce` values (var_codice_fornitore, var_specie_fornita);
    commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure aggiungi_indirizzo_fornitore
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`aggiungi_indirizzo_fornitore`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `aggiungi_indirizzo_fornitore`(in var_via varchar(45), in var_numero_civico int, in var_città varchar(45), in var_codice_fornitore int)
BEGIN
	insert into `indirizzo` values (var_via, var_numero_civico, var_città, var_codice_fornitore);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure aggiungi_pianta_ordine
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`aggiungi_pianta_ordine`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `aggiungi_pianta_ordine`(in var_ordine int, in var_nome varchar(45), in var_colore varchar(45), in var_quantità int)
BEGIN
	declare var_specie varchar(45);
	declare exit handler for sqlstate '22003'   -- catturo segnale generato dall'inserimento di un numero negativo in un UNSIGNED
    begin
        rollback;  -- rollback any changes made in the transaction
        resignal;  -- raise again the sql exception to the caller
    end;
    
    set transaction isolation level read committed;
	start transaction;
		select `codice`
			from `specie_di_piante`
            where `nome_comune` = var_nome
            into var_specie;

		update `pianta`
			set `numero_giacenze` = `numero_giacenze` - var_quantità 
			where `colore` = var_colore and `codice_specie` = var_specie;  -- verifica il codice di errore tornato al client in caso di sottrazione con risultato negativo e scrivi "prodotto non disponibile"
    
		insert into `contiene` values (var_ordine, var_colore, var_specie, var_quantità);
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure aggiungi_specie
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`aggiungi_specie`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `aggiungi_specie`(in var_codice varchar(45), in var_nome_comune varchar(45), in var_nome_latino varchar(45), in var_da_interno tinyint, in var_esotica tinyint, in var_prezzo float, in var_array_colore varchar(255))  -- corrent usage var_array_colore: rosso.bianco.blu.
BEGIN
	declare var_num_specie int;
	declare var_start_index int default 1;
    declare var_end_index int;
	set transaction isolation level read uncommitted;
    start transaction;
		insert into `specie_di_piante` values (var_codice, var_nome_comune, var_nome_latino, var_da_interno, var_esotica);
        insert into `listino_prezzi` (`data_inizio_validità`, `codice_specie`, `valore`) values (now(), var_codice, var_prezzo);
        
        if (var_array_colore = '-') then     -- correct usage: se non ha colorazioni immetti var_array_colore = '-'
			insert into `pianta` (`codice_specie`) values (var_codice);
		else
			select locate('.', var_array_colore) into var_end_index;
			
			while var_end_index <> 0 do
				insert into `pianta` (`colore`, `codice_specie`) values (substring(var_array_colore from var_start_index for (var_end_index - var_start_index)), var_codice);
				set var_start_index = var_end_index + 1;
				select locate('.', var_array_colore, var_start_index) into var_end_index;
			end while;
		end if;
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure aggiungi_specie_fornita
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`aggiungi_specie_fornita`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `aggiungi_specie_fornita`(in var_fornitore int, in var_specie varchar(45))
BEGIN
	insert into `fornisce` values (var_fornitore, var_specie);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure crea_ordine
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`crea_ordine`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `crea_ordine`(in var_username varchar(45), in var_colore_pianta varchar(45), in var_nome_specie varchar(45), in var_quantità int, out var_codice_ordine int)
BEGIN
	declare var_cliente varchar(45);
	declare var_specie varchar(45);
	declare exit handler for sqlstate '22003'
    begin
        rollback;  -- rollback any changes made in the transaction
        resignal;  -- raise again the sql exception to the caller
    end;
    
    set transaction isolation level read committed;
	start transaction;
		select `codice`
        from `specie_di_piante`
        where `nome_comune` = var_nome_specie
        into var_specie;
        
		select `recapito_preferito`
			from `cliente`
            where `username` = var_username
            into var_cliente;
            
		update `pianta`
			set `numero_giacenze` = `numero_giacenze` - var_quantità 
			where `colore` = var_colore_pianta and `codice_specie` = var_specie;  
            
		insert into `ordine` (`data_apertura`, `tipo`, `richiesta`) values (now(), 'aperto', var_cliente);
		set var_codice_ordine = last_insert_id();
		
		insert into `contiene` values (var_codice_ordine, var_colore_pianta, var_specie, var_quantità);
		
    commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure crea_utente
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`crea_utente`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `crea_utente`(IN username VARCHAR(45), IN pass VARCHAR(45), IN ruolo varchar(45))
BEGIN
	insert into utenti VALUES(username, MD5(pass), ruolo);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure elimina_ordine_aperto
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`elimina_ordine_aperto`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `elimina_ordine_aperto` (in var_ordine int, in var_username varchar(45))
BEGIN
	declare var_cliente varchar(45);

	declare exit handler for sqlexception
    begin
        rollback;  -- rollback any changes made in the transaction
        resignal;  -- raise again the sql exception to the caller
    end;
    
	set transaction isolation level read committed;
    start transaction;
		select `recapito_preferito` 
			from `cliente` 
			where `username` = var_username
            into var_cliente;
            
		if ((select `tipo` from `ordine` where `codice` = var_ordine) <> 'aperto') then
			signal sqlstate '45002' set message_text = "Non puoi eliminare un ordine già confermato";
		end if;
        
        if (var_ordine not in (select `codice` from `ordini_aperti` where `recapito cliente` = var_cliente)) then
			signal sqlstate '45003' set message_text = "Non puoi eliminare un ordine non tuo";
		end if;
        
        delete from `contiene` where `ordine` = var_ordine;  -- attiva il trigger che libera le quantità di piante momentaneamente riservate
		delete from `ordine` where `codice` = var_ordine;
    commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure finalizza_ordine
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`finalizza_ordine`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `finalizza_ordine`(in var_ordine int, in var_via varchar(45), in var_numero_civico int, in var_città varchar(45), in var_recapito varchar(45), in var_referente varchar(45), in var_username varchar(45))
BEGIN
	declare exit handler for sqlexception
    begin
        rollback;  -- rollback any changes made in the transaction
        resignal;  -- raise again the sql exception to the caller
    end;
    
	set transaction isolation level read committed;
    start transaction;
	if ((select `username` from `cliente` where `recapito_preferito` in (select `richiesta` from `ordine` where `codice` = var_ordine)) <> var_username) then
		signal sqlstate '45003' set message_text = "Non ci provare: puoi finalizzare un ordine non tuo!";
	end if;
    if (var_referente = '-') then
		update `ordine` set `data_finalizzazione` = now(), `via` = var_via, `numero_civico` = var_numero_civico, `città` = var_città, `recapito` = var_recapito, `tipo` = 'finalizzato' where `codice` = var_ordine;
	else
		update `ordine` set `data_finalizzazione` = now(), `via` = var_via, `numero_civico` = var_numero_civico, `città` = var_città, `recapito` = var_recapito, `referente` = var_referente, `tipo` = 'finalizzato' where `codice` = var_ordine;
	end if;
	commit;
	
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure login
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`login`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `login`(in var_username varchar(45), in var_pass varchar(45), out var_role INT)
BEGIN
	declare var_user_role ENUM('amministratore', 'cliente', 'gestore_magazzino', 'manager', 'operatore');
    
	select `ruolo` from `utenti`
		where `username` = var_username
        and `password` = md5(var_pass)
        into var_user_role;
        
		if var_user_role = 'amministratore' then
			set var_role = 1;
		elseif var_user_role = 'cliente' then
			set var_role = 2;
		elseif var_user_role = 'gestore_magazzino' then
			set var_role = 3;
		elseif var_user_role = 'manager' then
			set var_role = 4;
		elseif var_user_role = 'operatore' then
			set var_role = 5;
		else
			set var_role = 6;
		end if;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure piante_specie
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`piante_specie`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `piante_specie`(in var_nome varchar(45), out var_costo float)
BEGIN
	declare var_specie varchar(45);
	set transaction isolation level read committed;
    start transaction;
		select `codice`
			from `specie_di_piante`
            where `nome_comune` = var_nome
            into var_specie;
            
		select `valore`
			from `listino_prezzi`
            where `codice_specie` = var_specie and `data_fine_validità` is NULL
            into var_costo;
	
		select `colore`, `numero_giacenze`
			from `pianta`
            where `codice_specie` = var_specie;
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure richiesta_rifornimento
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`richiesta_rifornimento`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `richiesta_rifornimento`(in var_fornitore int, in var_array_specie varchar(255), in var_array_quantità varchar(255))  -- es. array rosa.ciclamino
BEGIN
	declare var_start_index int default 1;
    declare var_end_index int;
    declare var_start_index_num int default 1;
    declare var_end_index_num int;
    
	set transaction isolation level read uncommitted;
    start transaction;
		insert into `rifornimento` (`fornitore`, `data_richiesta`) values (var_fornitore, now());
        
        select locate('.', var_array_specie) into var_end_index;
        select locate('.', var_array_quantità) into var_end_index_num;
        while var_end_index <> 0 do
			insert into `contenente` values (var_fornitore, now(), substring(var_array_specie from var_start_index for (var_end_index - var_start_index)), cast(substring(var_array_quantità from var_start_index_num for (var_end_index_num - var_start_index_num)) as unsigned));
            set var_start_index = var_end_index + 1;
            set var_start_index_num = var_end_index_num + 1;
            select locate('.', var_array_specie, var_start_index) into var_end_index;
            select locate('.', var_array_quantità, var_start_index_num) into var_end_index_num;
		end while;
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure visualizza_info_ordine
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`visualizza_info_ordine`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `visualizza_info_ordine`(in var_ordine int)
BEGIN
	set transaction read only;
    set transaction isolation level read committed;
    start transaction;
	select `data_finalizzazione`, `colore_pianta`, `nome_comune`, `valore`
		from `ordine` join `contiene` on `ordine`.`codice` = `ordine` 
			join `pianta` on `colore_pianta` = `colore` and `specie` = `codice_specie` 
            join `specie_di_piante` on `codice_specie` = `specie_di_piante`.`codice` 
            join `listino_prezzi` on `specie_di_piante`.`codice` = `listino_prezzi`.`codice_specie` and ((timestampdiff(second, `data_inizio_validità`, `data_apertura`) > 0 and timestampdiff(second, `data_apertura`, `data_fine_validità`) > 0 ) or (timestampdiff(second, `data_inizio_validità`, `data_apertura`) > 0 and `data_fine_validità` is NULL)) 
        where var_ordine = `ordine`.`codice`;
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure visualizza_ordini
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`visualizza_ordini`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `visualizza_ordini`(in var_username varchar(45))
BEGIN
	declare var_cliente varchar(45);
	set transaction read only;
    set transaction isolation level read committed;
    start transaction;
		select `recapito_preferito` 
			from `cliente` 
			where `username` = var_username
            into var_cliente;
            
		select `codice`, `data_apertura`, `tipo`
			from `ordine` 
            where `richiesta` = var_cliente;
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure visualizza_ordini_aperti
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`visualizza_ordini_aperti`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `visualizza_ordini_aperti`(in var_username varchar(45))
BEGIN
	declare var_cliente varchar(45);
	set transaction read only;
    set transaction isolation level read committed;
    start transaction;
		select `recapito_preferito`
			from `cliente`
            where `username` = var_username
            into var_cliente;
		select `codice`, `data_apertura` from ordini_aperti;
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure listini_passati
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`listini_passati`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE PROCEDURE `listini_passati` (in var_nome varchar(45))
BEGIN
	declare var_specie varchar(45);
    
    select `codice`
		from `specie_di_piante`
        where `nome_comune` = var_nome
        into var_specie;
        
	select `valore`, `data_inizio_validità`, `data_fine_validità`
		from `listino_prezzi`
        where `codice_specie` = var_specie and `data_fine_validità` is not NULL;
        
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure lista_speci_ordinate
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`lista_speci_ordinate`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE PROCEDURE `lista_speci_ordinate` ()
BEGIN
	set transaction isolation level read committed;
    start transaction;
		select `codice`, `nome_comune`, `nome_latino`
			from `specie_di_piante`
			order by `nome_comune`;
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure nuovo_listino
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`nuovo_listino`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE PROCEDURE `nuovo_listino` (in var_specie varchar(45), in var_nuovo_valore float)
BEGIN
	set transaction isolation level read uncommitted;
    start transaction;
		update `listino_prezzi` 
			set `data_fine_validità` = now() 
			where `codice_specie` = var_specie and `data_fine_validità` is NULL;
            
		insert into `listino_prezzi` (`data_inizio_validità`, `codice_specie`, `valore`) values (now(), var_specie, var_nuovo_valore);
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure specie_da_rifornire
-- -----------------------------------------------------

USE `ingrosso-piante`;
DROP procedure IF EXISTS `ingrosso-piante`.`specie_da_rifornire`;

DELIMITER $$
USE `ingrosso-piante`$$
CREATE PROCEDURE `specie_da_rifornire` ()
BEGIN
    
    drop temporary table if exists `giacenza_specie`;
	create temporary table `giacenza_specie` (
		`codice_specie` varchar(45),
        `giacenze` int
	);
    
	set transaction isolation level read committed;
	start transaction;
		insert into `giacenza_specie`
			select `codice_specie`, sum(numero_giacenze)
			from `pianta`
			group by `codice_specie`;
			
		delete from `giacenza_specie`
			where `codice_specie` in (select `specie_di_piante` 
										from `rifornimento` join `contenente` on `rifornimento`.`fornitore` = `contenente`.`fornitore` 
										where `data_consegna` is null);
		
		select `codice_specie`
			from `giacenza_specie`
			where `giacenze` = 0;
		
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- View `ingrosso-piante`.`ordini_aperti`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ingrosso-piante`.`ordini_aperti`;
DROP VIEW IF EXISTS `ingrosso-piante`.`ordini_aperti` ;
USE `ingrosso-piante`;
CREATE  OR REPLACE VIEW `ordini_aperti` AS select `codice`, `data_apertura`, `richiesta` as 'recapito cliente'
	from `ordine` 
    where `tipo` = 'aperto';
USE `ingrosso-piante`;

DELIMITER $$

USE `ingrosso-piante`$$
DROP TRIGGER IF EXISTS `ingrosso-piante`.`contiene_AFTER_DELETE` $$
USE `ingrosso-piante`$$
CREATE DEFINER = CURRENT_USER TRIGGER `ingrosso-piante`.`contiene_AFTER_DELETE` AFTER DELETE ON `ingrosso-piante`.`contiene` FOR EACH ROW
BEGIN
	update pianta 
		set numero_giacenze = numero_giacenze + OLD.quantità 
        where codice_specie = OLD.specie  and colore = OLD.colore_pianta;
END$$


DELIMITER ;
SET SQL_MODE = '';
DROP USER IF EXISTS amministratore;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'amministratore' IDENTIFIED BY 'amministratore';

GRANT EXECUTE ON procedure `ingrosso-piante`.`crea_utente` TO 'amministratore';
GRANT EXECUTE ON procedure `ingrosso-piante`.`visualizza_ordini` TO 'amministratore';
GRANT EXECUTE ON procedure `ingrosso-piante`.`visualizza_info_ordine` TO 'amministratore';
GRANT EXECUTE ON procedure `ingrosso-piante`.`aggiungi_cliente` TO 'amministratore';
GRANT EXECUTE ON procedure `ingrosso-piante`.`aggiungi_contatto_cliente` TO 'amministratore';
SET SQL_MODE = '';
DROP USER IF EXISTS cliente;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'cliente' IDENTIFIED BY 'cliente';

GRANT EXECUTE ON procedure `ingrosso-piante`.`aggiungi_contatto_cliente` TO 'cliente';
GRANT EXECUTE ON procedure `ingrosso-piante`.`aggiungi_pianta_ordine` TO 'cliente';
GRANT EXECUTE ON procedure `ingrosso-piante`.`crea_ordine` TO 'cliente';
GRANT EXECUTE ON procedure `ingrosso-piante`.`elimina_ordine_aperto` TO 'cliente';
GRANT EXECUTE ON procedure `ingrosso-piante`.`finalizza_ordine` TO 'cliente';
GRANT EXECUTE ON procedure `ingrosso-piante`.`piante_specie` TO 'cliente';
GRANT EXECUTE ON procedure `ingrosso-piante`.`visualizza_info_ordine` TO 'cliente';
GRANT EXECUTE ON procedure `ingrosso-piante`.`visualizza_ordini_aperti` TO 'cliente';
GRANT EXECUTE ON procedure `ingrosso-piante`.`visualizza_ordini` TO 'cliente';
SET SQL_MODE = '';
DROP USER IF EXISTS gestore_magazzino;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'gestore_magazzino' IDENTIFIED BY 'gestore_magazzino';

GRANT EXECUTE ON procedure `ingrosso-piante`.`aggiungi_fornitore` TO 'gestore_magazzino';
GRANT EXECUTE ON procedure `ingrosso-piante`.`aggiungi_indirizzo_fornitore` TO 'gestore_magazzino';
GRANT EXECUTE ON procedure `ingrosso-piante`.`aggiungi_specie_fornita` TO 'gestore_magazzino';
GRANT EXECUTE ON procedure `ingrosso-piante`.`richiesta_rifornimento` TO 'gestore_magazzino';
GRANT EXECUTE ON procedure `ingrosso-piante`.`specie_da_rifornire` TO 'gestore_magazzino';
SET SQL_MODE = '';
DROP USER IF EXISTS manager;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'manager' IDENTIFIED BY 'manager';

GRANT EXECUTE ON procedure `ingrosso-piante`.`aggiungi_specie` TO 'manager';
GRANT EXECUTE ON procedure `ingrosso-piante`.`piante_specie` TO 'manager';
GRANT EXECUTE ON procedure `ingrosso-piante`.`lista_speci_ordinate` TO 'manager';
GRANT EXECUTE ON procedure `ingrosso-piante`.`listini_passati` TO 'manager';
GRANT EXECUTE ON procedure `ingrosso-piante`.`nuovo_listino` TO 'manager';
SET SQL_MODE = '';
DROP USER IF EXISTS operatore;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'operatore' IDENTIFIED BY 'operatore';

SET SQL_MODE = '';
DROP USER IF EXISTS login;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'login' IDENTIFIED BY 'login';

GRANT EXECUTE ON procedure `ingrosso-piante`.`login` TO 'login';

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
-- begin attached script 'script1'
delimiter !
create function `valid_email`(email varchar(45)) 
returns bool
deterministic
begin
	if email regexp '^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9._-]@[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]\\.[a-zA-Z]{2,63}$' then
		return true;
    end if;
    return false;
end!
delimiter ;
-- end attached script 'script1'
-- begin attached script 'script2'
delimiter !
create function `valid_phone`(telefono varchar(45)) 
returns boolean
deterministic
begin
	if telefono regexp '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'   then
		 return true;
    end if;
    return false;
end!
delimiter ;
-- end attached script 'script2'

-- -----------------------------------------------------
-- Data for table `ingrosso-piante`.`utenti`
-- -----------------------------------------------------
START TRANSACTION;
USE `ingrosso-piante`;
INSERT INTO `ingrosso-piante`.`utenti` (`username`, `password`, `ruolo`) VALUES ('dada.cliente', '0c88028bf3aa6a6a143ed846f2be1ea4', 'cliente');
INSERT INTO `ingrosso-piante`.`utenti` (`username`, `password`, `ruolo`) VALUES ('dada.manager', '0c88028bf3aa6a6a143ed846f2be1ea4', 'manager');
INSERT INTO `ingrosso-piante`.`utenti` (`username`, `password`, `ruolo`) VALUES ('dada.operatore', '0c88028bf3aa6a6a143ed846f2be1ea4', 'operatore');
INSERT INTO `ingrosso-piante`.`utenti` (`username`, `password`, `ruolo`) VALUES ('dada.magazzino', '0c88028bf3aa6a6a143ed846f2be1ea4', 'gestore_magazzino');
INSERT INTO `ingrosso-piante`.`utenti` (`username`, `password`, `ruolo`) VALUES ('dada.amministratore', '0c88028bf3aa6a6a143ed846f2be1ea4', 'amministratore');
INSERT INTO `ingrosso-piante`.`utenti` (`username`, `password`, `ruolo`) VALUES ('pippo.riventita', '0c88028bf3aa6a6a143ed846f2be1ea4', 'cliente');
INSERT INTO `ingrosso-piante`.`utenti` (`username`, `password`, `ruolo`) VALUES ('dada.rivendita', '0c88028bf3aa6a6a143ed846f2be1ea4', 'cliente');

COMMIT;


-- -----------------------------------------------------
-- Data for table `ingrosso-piante`.`cliente`
-- -----------------------------------------------------
START TRANSACTION;
USE `ingrosso-piante`;
INSERT INTO `ingrosso-piante`.`cliente` (`recapito_preferito`, `nome`, `codice_fiscale`, `partita_IVA`, `tipo`, `via`, `numero_civico`, `città`, `via_fatturazione`, `civico_fatturazione`, `città_fatturazione`, `username`) VALUES ('3332547894', 'davide', 'dvdslr97fge5748d', NULL, 'privato', 'via roma', 58, 'roma', 'via appia', 5, 'roma', 'dada.cliente');
INSERT INTO `ingrosso-piante`.`cliente` (`recapito_preferito`, `nome`, `codice_fiscale`, `partita_IVA`, `tipo`, `via`, `numero_civico`, `città`, `via_fatturazione`, `civico_fatturazione`, `città_fatturazione`, `username`) VALUES ('6258529595', 'paolo', NULL, 'IT123456789', 'rivendita', 'via nord', 5, 'roma', 'via appia', 5, 'roma', 'dada.rivendita');

COMMIT;


-- -----------------------------------------------------
-- Data for table `ingrosso-piante`.`specie_di_piante`
-- -----------------------------------------------------
START TRANSACTION;
USE `ingrosso-piante`;
INSERT INTO `ingrosso-piante`.`specie_di_piante` (`codice`, `nome_comune`, `nome_latino`, `da_interno`, `esotica`) VALUES ('a1', 'rosa', 'rosae', 0, 0);
INSERT INTO `ingrosso-piante`.`specie_di_piante` (`codice`, `nome_comune`, `nome_latino`, `da_interno`, `esotica`) VALUES ('a2', 'ciclamino', 'ciclaminae', 0, 0);
INSERT INTO `ingrosso-piante`.`specie_di_piante` (`codice`, `nome_comune`, `nome_latino`, `da_interno`, `esotica`) VALUES ('a3', 'girasole', 'girasolae', 0, 0);

COMMIT;


-- -----------------------------------------------------
-- Data for table `ingrosso-piante`.`ordine`
-- -----------------------------------------------------
START TRANSACTION;
USE `ingrosso-piante`;
INSERT INTO `ingrosso-piante`.`ordine` (`codice`, `data_apertura`, `data_finalizzazione`, `via`, `numero_civico`, `città`, `recapito`, `referente`, `tipo`, `richiesta`) VALUES (1, '2021-02-07 09:52:12', '2021-02-07 10:50:12', 'via roma', 4, 'napoli', '3366547896', NULL, 'finalizzato', '3332547894');
INSERT INTO `ingrosso-piante`.`ordine` (`codice`, `data_apertura`, `data_finalizzazione`, `via`, `numero_civico`, `città`, `recapito`, `referente`, `tipo`, `richiesta`) VALUES (2, '2021-02-07 10:49:14', '2021-02-07 10:58:54', 'via appia', 45, 'roma', '3365214568', NULL, 'finalizzato', '3332547894');

COMMIT;


-- -----------------------------------------------------
-- Data for table `ingrosso-piante`.`pianta`
-- -----------------------------------------------------
START TRANSACTION;
USE `ingrosso-piante`;
INSERT INTO `ingrosso-piante`.`pianta` (`colore`, `codice_specie`, `numero_giacenze`) VALUES ('blu', 'a1', 46);
INSERT INTO `ingrosso-piante`.`pianta` (`colore`, `codice_specie`, `numero_giacenze`) VALUES ('rosso', 'a2', 5);
INSERT INTO `ingrosso-piante`.`pianta` (`colore`, `codice_specie`, `numero_giacenze`) VALUES ('bianco', 'a2', 45);
INSERT INTO `ingrosso-piante`.`pianta` (`colore`, `codice_specie`, `numero_giacenze`) VALUES ('rossa', 'a1', 5);
INSERT INTO `ingrosso-piante`.`pianta` (`colore`, `codice_specie`, `numero_giacenze`) VALUES ('bianca', 'a1', 55);
INSERT INTO `ingrosso-piante`.`pianta` (`colore`, `codice_specie`, `numero_giacenze`) VALUES ('giallo', 'a3', 100);

COMMIT;


-- -----------------------------------------------------
-- Data for table `ingrosso-piante`.`contiene`
-- -----------------------------------------------------
START TRANSACTION;
USE `ingrosso-piante`;
INSERT INTO `ingrosso-piante`.`contiene` (`ordine`, `colore_pianta`, `specie`, `quantità`) VALUES (1, 'blu', 'a1', 4);
INSERT INTO `ingrosso-piante`.`contiene` (`ordine`, `colore_pianta`, `specie`, `quantità`) VALUES (2, 'bianco', 'a2', 8);
INSERT INTO `ingrosso-piante`.`contiene` (`ordine`, `colore_pianta`, `specie`, `quantità`) VALUES (2, 'blu', 'a1', 1);
INSERT INTO `ingrosso-piante`.`contiene` (`ordine`, `colore_pianta`, `specie`, `quantità`) VALUES (2, 'rossa', 'a1', 2);
INSERT INTO `ingrosso-piante`.`contiene` (`ordine`, `colore_pianta`, `specie`, `quantità`) VALUES (1, 'giallo', 'a3', 5);

COMMIT;


-- -----------------------------------------------------
-- Data for table `ingrosso-piante`.`listino_prezzi`
-- -----------------------------------------------------
START TRANSACTION;
USE `ingrosso-piante`;
INSERT INTO `ingrosso-piante`.`listino_prezzi` (`data_inizio_validità`, `codice_specie`, `valore`, `data_fine_validità`) VALUES ('2021-02-06 21:13:21', 'a1', 20.99, NULL);
INSERT INTO `ingrosso-piante`.`listino_prezzi` (`data_inizio_validità`, `codice_specie`, `valore`, `data_fine_validità`) VALUES ('2021-02-07 14:04:25', 'a2', 9.99, NULL);
INSERT INTO `ingrosso-piante`.`listino_prezzi` (`data_inizio_validità`, `codice_specie`, `valore`, `data_fine_validità`) VALUES ('2021-02-06 14:04:25', 'a3', 10.99, NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `ingrosso-piante`.`referente_rivendita`
-- -----------------------------------------------------
START TRANSACTION;
USE `ingrosso-piante`;
INSERT INTO `ingrosso-piante`.`referente_rivendita` (`cliente`, `nome`, `recapito_primario`) VALUES ('6258529595', 'lorenzo', '4868465418');

COMMIT;

-- begin attached script 'script'
set global event_scheduler = on;

create event if not exists `clean_order`
	on schedule every 1 hour on completion preserve
    comment 'Remove order open for more than 12 hours'
    do
		delete from `ordine`
			where `tipo` = 'aperto' and `data_apertura` < (now() - interval 12 hour)
	

-- end attached script 'script'
