-- This file is to bootstrap a database for the CS3200 project. 

-- Create a new database.  You can change the name later.  You'll
-- need this name in the FLASK API file(s),  the AppSmith 
-- data source creation.
drop database capital_db;
create database capital_db;

-- Via the Docker Compose file, a special user called webapp will 
-- be created in MySQL. We are going to grant that user 
-- all privilages to the new database we just created. 
-- TODO: If you changed the name of the database above, you need 
-- to change it here too.
grant all privileges on capital_db.* to 'webapp'@'%';
flush privileges;

-- Move into the database we just created.
-- TODO: If you changed the name of the database above, you need to
-- change it here too. 
use capital_db;

-- DDL
-- Company table
CREATE TABLE IF NOT EXISTS company (
  name         VARCHAR(100) UNIQUE                NOT NULL,
  email        VARCHAR(75),
  phone        VARCHAR(100),
  address      VARCHAR(255),
  url          VARCHAR(255),
  type         VARCHAR(255),
  id           INTEGER AUTO_INCREMENT             NOT NULL,
  CONSTRAINT pk_company PRIMARY KEY (id)
);

-- Internship table
CREATE TABLE IF NOT EXISTS internship (
  id           INTEGER AUTO_INCREMENT             NOT NULL,
  name         VARCHAR(255)                       NOT NULL,
  description  TEXT,
  url          VARCHAR(255),
  companyId    INTEGER                            NOT NULL,

  INDEX uq_idx_int (companyId),

  CONSTRAINT pk_company PRIMARY KEY (id),
  CONSTRAINT fk_int FOREIGN KEY (companyId)
      REFERENCES company (id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
);

-- Recruiter table
CREATE TABLE IF NOT EXISTS recruiter (
  id           INTEGER AUTO_INCREMENT             NOT NULL,
  firstName    VARCHAR(25)                        NOT NULL,
  lastName     VARCHAR(40)                        NOT NULL,
  email        VARCHAR(75),
  companyId    INTEGER                            NOT NULL,

  INDEX uq_idx_recruiter (companyId),

  CONSTRAINT pk_recruiter PRIMARY KEY (id),
  CONSTRAINT fk_int FOREIGN KEY (companyId)
      REFERENCES company (id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
);

-- Course table
CREATE TABLE IF NOT EXISTS course (
    id          INTEGER AUTO_INCREMENT             NOT NULL,
    name        VARCHAR(100)                       NOT NULL,
    CONSTRAINT pk_course PRIMARY KEY (id)
);

-- Student table
-- to maximize efficency we assume that there is a file system,
-- hence will be linkin resume with path varchar instead of BLOB.
CREATE TABLE IF NOT EXISTS student (
    id           INTEGER AUTO_INCREMENT             NOT NULL,
    recruiterId  INTEGER                            NOT NULL,
    firstName    VARCHAR(25)                        NOT NULL,
    lastName     VARCHAR(40)                        NOT NULL,
    email        VARCHAR(75)                        NOT NULL,
    eduLevel     VARCHAR(20),
    resumePath   VARCHAR(255),
    gradDate     DATE,

    INDEX uq_idx_recruiter (recruiterId),

    CONSTRAINT pk_student PRIMARY KEY (id),
    CONSTRAINT fk_designated_recruiter FOREIGN KEY (recruiterId)
        REFERENCES recruiter (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- junction table for n:m course --> student
CREATE TABLE IF NOT EXISTS course_student(
    courseId    INTEGER                            NOT NULL,
    studentId   INTEGER                            NOT NULL,
    CONSTRAINT fk_course FOREIGN KEY (courseId) REFERENCES course(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_student FOREIGN KEY (studentId) REFERENCES student(id) ON UPDATE CASCADE ON DELETE CASCADE
);


-- Professor table (associated only with the course that runs the simulation)
CREATE TABLE IF NOT EXISTS professor (
    id          INTEGER AUTO_INCREMENT             NOT NULL,
    courseID    INTEGER                            NOT NULL,
    firstName   VARCHAR(25),
    lastName    VARCHAR(40),
    department  VARCHAR(50),
    university  VARCHAR(50),
    email       VARCHAR(75)                        NOT NULL,

    INDEX uq_idx_recruiter (courseID),

    CONSTRAINT pk_prof PRIMARY KEY (id),
    CONSTRAINT fk_associated_course FOREIGN KEY (courseID)
      REFERENCES course (id)
      ON DELETE RESTRICT
      ON UPDATE CASCADE
);
-- Engineer table
CREATE TABLE IF NOT EXISTS engineer(
    id          INTEGER AUTO_INCREMENT             NOT NULL,
    firstName   VARCHAR(25),
    lastName    VARCHAR(40),
    email       VARCHAR(75)                        NOT NULL,

    CONSTRAINT pk_eng PRIMARY KEY (id)
);

-- Simulation table
CREATE TABLE IF NOT EXISTS simulation (
    id          INTEGER AUTO_INCREMENT             NOT NULL,
    startingBal DECIMAL(10,2),
    endDate     DATETIME ON UPDATE CURRENT_TIMESTAMP,
    desc        TINYTEXT,
    createdBy   INTEGER                            NOT NULL,
    name        VARCHAR(255),
    startDate   DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status      VARCHAR(50),

    INDEX uq_idx_created_by (createdBy),

    CONSTRAINT pk_sim PRIMARY KEY (id),
    CONSTRAINT fk_associated_eng FOREIGN KEY (createdBy)
      REFERENCES engineer (id)
      ON DELETE RESTRICT
      ON UPDATE CASCADE
);

-- junction table for n:m course --> simulation
CREATE TABLE IF NOT EXISTS course_simulation(
    courseId    INTEGER                            NOT NULL,
    simID       INTEGER                            NOT NULL,
    CONSTRAINT fk_course FOREIGN KEY (courseId) REFERENCES course(id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_simulation FOREIGN KEY (simID) REFERENCES simulation(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Stock table
CREATE TABLE IF NOT EXISTS stock (
    ticker       VARCHAR(15)                        NOT NULL,
    bidPrice     INTEGER                            NOT NULL,
    askPrice     INTEGER                            NOT NULL,
    eps          DECIMAL(10,2),
    volume       INTEGER,
    beta         DECIMAL(10,2),

    CONSTRAINT pk_stock PRIMARY KEY (ticker)
);

-- junction table n:m stock --> simulation
CREATE TABLE IF NOT EXISTS stock_simulation(
    stock_Ticker VARCHAR(255)                       NOT NULL,
    sim_id       INTEGER                            NOT NULL,
    CONSTRAINT pk_stock PRIMARY KEY (stock_Ticker, sim_id),

    CONSTRAINT fk_stock FOREIGN KEY (stock_Ticker) REFERENCES stock(ticker) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_sim FOREIGN KEY (sim_id) REFERENCES simulation(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- simulation results table
CREATE TABLE IF NOT EXISTS simulation_results
(
    simId       INTEGER        NOT NULL,
    studentId   INTEGER        NOT NULL,
    commission  DECIMAL(10, 2) NOT NULL,
    pnl         DECIMAL(10, 2) NOT NULL,
    sharpeRatio DECIMAL(10, 2) NOT NULL,
    execScore   INTEGER        NOT NULL,
    CONSTRAINT pk_sim_res PRIMARY KEY (simId, studentId),

    CONSTRAINT fk_stock_1 FOREIGN KEY (simId) REFERENCES simulation (id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_stock_2 FOREIGN KEY (studentId) REFERENCES student (id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Add sample data. DON'T TOUCH YET
-- we will duplicate in here to make sure its executed
