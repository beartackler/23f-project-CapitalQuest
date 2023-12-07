-- This file is to bootstrap a database for the CS3200 project. 

-- Create a new database.  You can change the name later.  You'll
-- need this name in the FLASK API file(s),  the AppSmith 
-- data source creation.
create database capquest;

-- Via the Docker Compose file, a special user called webapp will 
-- be created in MySQL. We are going to grant that user 
-- all privilages to the new database we just created. 
-- TODO: If you changed the name of the database above, you need 
-- to change it here too.
grant all privileges on capquest.* to 'webapp'@'%';
flush privileges;

-- Move into the database we just created.
-- TODO: If you changed the name of the database above, you need to
-- change it here too. 
use capquest;

-- DDL
-- Company table
CREATE TABLE IF NOT EXISTS company (
    name         VARCHAR(100) UNIQUE                 NOT NULL,
    email        VARCHAR(75),
    phone        VARCHAR(100),
    address      VARCHAR(255),
    url          VARCHAR(255),
    type         VARCHAR(255),
    company_id           INTEGER AUTO_INCREMENT      NOT NULL,
    CONSTRAINT pk_company PRIMARY KEY (company_id)
);

-- Internship table
CREATE TABLE IF NOT EXISTS internship (
    internship_id           INTEGER AUTO_INCREMENT   NOT NULL,
    name         VARCHAR(255)                        NOT NULL,
    description  TEXT,
    url          VARCHAR(255),
    company_id    INTEGER                            NOT NULL,

    INDEX uq_idx_int (company_id),

    CONSTRAINT pk_company PRIMARY KEY (internship_id),
    CONSTRAINT fk_int FOREIGN KEY (company_id)
        REFERENCES company (company_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Recruiter table
CREATE TABLE IF NOT EXISTS recruiter (
    recruiter_id           INTEGER AUTO_INCREMENT   NOT NULL,
    firstName    VARCHAR(25)                        NOT NULL,
    lastName     VARCHAR(40)                        NOT NULL,
    email        VARCHAR(75),
    company_id    INTEGER                           NOT NULL,

    INDEX uq_idx_recruiter (company_id),

    CONSTRAINT pk_recruiter PRIMARY KEY (recruiter_id),
    CONSTRAINT fk_recr FOREIGN KEY (company_id)
        REFERENCES company (company_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Course table
CREATE TABLE IF NOT EXISTS course (
    course_id          INTEGER AUTO_INCREMENT       NOT NULL,
    name        VARCHAR(100)                        NOT NULL,
    CONSTRAINT pk_course PRIMARY KEY (course_id)
);

-- Student table
-- to maximize efficency we assume that there is a file system,
-- hence will be linkin resume with path varchar instead of BLOB.
CREATE TABLE IF NOT EXISTS student (
    student_id           INTEGER AUTO_INCREMENT     NOT NULL,
    recruiter_id  INTEGER                           NOT NULL,
    firstName    VARCHAR(25)                        NOT NULL,
    lastName     VARCHAR(40)                        NOT NULL,
    email        VARCHAR(75)                        NOT NULL,
    eduLevel     VARCHAR(20),
    resumePath   VARCHAR(255),
    gradDate     DATE,

    INDEX uq_idx_recruiter (recruiter_id),

    CONSTRAINT pk_student PRIMARY KEY (student_id),
    CONSTRAINT fk_designated_recruiter FOREIGN KEY (recruiter_id)
        REFERENCES recruiter (recruiter_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- junction table for n:m course --> student
CREATE TABLE IF NOT EXISTS course_student(
    course_id    INTEGER                            NOT NULL,
    student_id   INTEGER                            NOT NULL,
    CONSTRAINT fk_course FOREIGN KEY (course_id) REFERENCES course(course_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_student FOREIGN KEY (student_id) REFERENCES student(student_id) ON UPDATE CASCADE ON DELETE CASCADE
);


-- Professor table (associated only with the course that runs the simulation)
CREATE TABLE IF NOT EXISTS professor (
    professor_id          INTEGER AUTO_INCREMENT   NOT NULL,
    course_id    INTEGER                           NOT NULL,
    firstName   VARCHAR(25),
    lastName    VARCHAR(40),
    department  VARCHAR(50),
    university  VARCHAR(50),
    email       VARCHAR(75)                        NOT NULL,

    INDEX uq_idx_recruiter (course_id),

    CONSTRAINT pk_prof PRIMARY KEY (professor_id),
    CONSTRAINT fk_associated_course FOREIGN KEY (course_id)
        REFERENCES course (course_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
-- Engineer table
CREATE TABLE IF NOT EXISTS engineer(
    engineer_id          INTEGER AUTO_INCREMENT    NOT NULL,
    firstName   VARCHAR(25),
    lastName    VARCHAR(40),
    email       VARCHAR(75)                        NOT NULL,

    CONSTRAINT pk_eng PRIMARY KEY (engineer_id)
);

-- Simulation table
CREATE TABLE IF NOT EXISTS simulation (
    simulation_id          INTEGER AUTO_INCREMENT  NOT NULL,
    startingBal DECIMAL(10,2),
    endDate     DATETIME ON UPDATE CURRENT_TIMESTAMP,
    desc        VARCHAR(255),
    createdBy   INTEGER,
    name        VARCHAR(255),
    startDate   DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status      VARCHAR(50),

    INDEX uq_idx_created_by (createdBy),

    CONSTRAINT pk_sim PRIMARY KEY (simulation_id),
    CONSTRAINT fk_associated_eng FOREIGN KEY (createdBy)
        REFERENCES engineer (engineer_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- junction table for n:m course --> simulation
CREATE TABLE IF NOT EXISTS course_simulation(
    course_id           INTEGER                    NOT NULL,
    simulation_id       INTEGER                    NOT NULL,
    CONSTRAINT fk_course FOREIGN KEY (course_id) REFERENCES course(course_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_simulation FOREIGN KEY (simulation_id) REFERENCES simulation(simulation_id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Stock table
CREATE TABLE IF NOT EXISTS stock (
    ticker       VARCHAR(15)                        NOT NULL,
    bidPrice     INTEGER                            NOT NULL,
    askPrice     INTEGER                            NOT NULL,
    eps          DECIMAL(10,2),
    volume       INTEGER,
    name         VARCHAR(30),
    beta         DECIMAL(10,2),

    CONSTRAINT pk_stock PRIMARY KEY (ticker)
);

-- junction table n:m stock --> simulation
CREATE TABLE IF NOT EXISTS stock_simulation(
    stock_Ticker VARCHAR(255)                       NOT NULL,
    sim_id       INTEGER                            NOT NULL,
    CONSTRAINT pk_stock PRIMARY KEY (stock_Ticker, sim_id),

    CONSTRAINT fk_stock FOREIGN KEY (stock_Ticker) REFERENCES stock(ticker) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_sim FOREIGN KEY (sim_id) REFERENCES simulation(simulation_id) ON UPDATE CASCADE ON DELETE CASCADE
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

    CONSTRAINT fk_stock_1 FOREIGN KEY (simId) REFERENCES simulation (simulation_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_stock_2 FOREIGN KEY (studentId) REFERENCES student (student_id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Adding sample data (testing if it works here)

# Company

insert into company (name, email, phone, address, url, type, company_id) values ('Blognation', 'iarchard0@skype.com', '278-268-2241', '30 Gale Circle', 'java.com', 'technology', 1);
insert into company (name, email, phone, address, url, type, company_id) values ('Vcompany_idoo', 'mworld1@marriott.com', '720-711-7335', '86362 Lien Court', 'ted.com', 'healthcare', 2);
insert into company (name, email, phone, address, url, type, company_id) values ('Youspan', 'dvasenin2@naver.com', '361-532-9264', '78404 Porter Alley', 'rakuten.co.jp', 'technology', 3);
insert into company (name, email, phone, address, url, type, company_id) values ('Tanoodle', 'cklemps3@ftc.gov', '872-243-8672', '7548 High Crossing Court', 'wix.com', 'finance', 4);
insert into company (name, email, phone, address, url, type, company_id) values ('Tavu', 'ezanicchi4@ft.com', '736-892-3296', '819 Elgar Park', 'jugem.jp', 'healthcare', 5);
insert into company (name, email, phone, address, url, type, company_id) values ('Gigaclub', 'fbogart5@nifty.com', '166-234-7220', '979 Mifflin Pass', 'reverbnation.com', 'healthcare', 6);
insert into company (name, email, phone, address, url, type, company_id) values ('Oyoloo', 'lkenwood6@trellian.com', '754-742-6486', '2 Tennessee Place', 'fc2.com', 'manufacturing', 7);
insert into company (name, email, phone, address, url, type, company_id) values ('Rhycero', 'balphonso7@amazon.com', '964-811-7117', '28834 Wayrcompany_idge Pass', 'sina.com.cn', 'finance', 8);
insert into company (name, email, phone, address, url, type, company_id) values ('Wikibox', 'tcasaroli8@usatoday.com', '579-693-8532', '09 Elka Crossing', 'liveinternet.ru', 'healthcare', 9);
insert into company (name, email, phone, address, url, type, company_id) values ('Jaxbean', 'fplacompany_id9@opensource.org', '412-601-4741', '45101 Bonner Street', 'smugmug.com', 'retail', 10);
insert into company (name, email, phone, address, url, type, company_id) values ('Kaymbo', 'amacglorya@dmoz.org', '479-388-9451', '0463 Dahle Parkway', 'forbes.com', 'finance', 11);
insert into company (name, email, phone, address, url, type, company_id) values ('Photojam', 'bmcianb@nasa.gov', '971-428-0835', '0242 Pankratz Avenue', 'ezinearticles.com', 'retail', 12);
insert into company (name, email, phone, address, url, type, company_id) values ('Dabshots', 'gpittendreighc@merriam-webster.com', '209-650-5552', '70233 Nobel Court', 'topsy.com', 'retail', 13);
insert into company (name, email, phone, address, url, type, company_id) values ('Yozio', 'bpercevald@auda.org.au', '745-859-2096', '27 Grover Court', 'angelfire.com', 'finance', 14);
insert into company (name, email, phone, address, url, type, company_id) values ('Blogtag', 'fasline@gnu.org', '250-661-0571', '42 Fuller Junction', 'theglobeandmail.com', 'finance', 15);
insert into company (name, email, phone, address, url, type, company_id) values ('Vipe', 'mcadaganf@npr.org', '327-572-3113', '4352 Manitowish Drive', 'seesaa.net', 'technology', 16);
insert into company (name, email, phone, address, url, type, company_id) values ('Trupe', 'mhurleyg@usgs.gov', '109-445-4886', '8 Stuart Lane', 'ning.com', 'technology', 17);
insert into company (name, email, phone, address, url, type, company_id) values ('Brainsphere', 'cboswardh@time.com', '880-503-7502', '0382 Dexter Lane', 'drupal.org', 'finance', 18);
insert into company (name, email, phone, address, url, type, company_id) values ('Gabcube', 'twiersmai@techcrunch.com', '309-289-9058', '72215 Miller Parkway', 'omniture.com', 'technology', 19);
insert into company (name, email, phone, address, url, type, company_id) values ('Linkbrcompany_idge', 'tmetherellj@opera.com', '438-789-1865', '61256 Hoepker Street', 'scribd.com', 'healthcare', 20);
insert into company (name, email, phone, address, url, type, company_id) values ('Feedmix', 'cgilphillank@cpanel.net', '853-862-2891', '655 Sutherland Avenue', 'facebook.com', 'healthcare', 21);
insert into company (name, email, phone, address, url, type, company_id) values ('Rhybox', 'crendelll@loc.gov', '997-257-5114', '5 Pierstorff Alley', 'google.it', 'technology', 22);
insert into company (name, email, phone, address, url, type, company_id) values ('JumpXS', 'estaffm@amazonaws.com', '959-247-5166', '10008 6th Terrace', 'nba.com', 'finance', 23);
insert into company (name, email, phone, address, url, type, company_id) values ('Voonix', 'sdeavesn@blinklist.com', '304-524-6960', '14237 Cambrcompany_idge Street', 'miibeian.gov.cn', 'manufacturing', 24);
insert into company (name, email, phone, address, url, type, company_id) values ('Pixonyx', 'zfrankisso@jiathis.com', '362-357-0850', '3824 Algoma Center', 'msn.com', 'technology', 25);
insert into company (name, email, phone, address, url, type, company_id) values ('Eare', 'dbourgesp@multiply.com', '741-580-5201', '31157 Northwestern Drive', 'webs.com', 'healthcare', 26);
insert into company (name, email, phone, address, url, type, company_id) values ('Realmix', 'ewhithornq@bandcamp.com', '996-817-0976', '101 Kipling Pass', 'bing.com', 'finance', 27);
insert into company (name, email, phone, address, url, type, company_id) values ('Lajo', 'hcarhartr@whitehouse.gov', '507-853-9664', '488 Katie Terrace', 'hhs.gov', 'technology', 28);
insert into company (name, email, phone, address, url, type, company_id) values ('Rhyzio', 'lfosberrys@bacompany_idu.com', '301-932-6631', '4 Springs Center', 'wikia.com', 'manufacturing', 29);
insert into company (name, email, phone, address, url, type, company_id) values ('Tambee', 'tbendittt@cornell.edu', '110-827-3838', '83594 Sutherland Terrace', 'icio.us', 'finance', 30);
insert into company (name, email, phone, address, url, type, company_id) values ('BoptyBop', 'csieneu@exblog.jp', '932-279-3421', '922 Nancy Center', 'istockphoto.com', 'healthcare', 31);
insert into company (name, email, phone, address, url, type, company_id) values ('Oyoba', 'omattiassiv@google.co.uk', '441-770-5833', '220 Bartillon Way', 'ehow.com', 'technology', 32);
insert into company (name, email, phone, address, url, type, company_id) values ('Ntags', 'bdrancew@adobe.com', '598-199-0405', '89137 Orin Circle', 'php.net', 'finance', 33);
insert into company (name, email, phone, address, url, type, company_id) values ('Yodoo', 'kantoniazzix@sakura.ne.jp', '155-990-4661', '241 Buena Vista Hill', 'examiner.com', 'manufacturing', 34);
insert into company (name, email, phone, address, url, type, company_id) values ('Jaxnation', 'gdumpletony@cocolog-nifty.com', '535-833-6572', '7 Clarendon Avenue', 'hugedomains.com', 'retail', 35);
insert into company (name, email, phone, address, url, type, company_id) values ('Layo', 'mdumphreyz@arstechnica.com', '408-113-3007', '59 Lunder Road', 'google.de', 'finance', 36);
insert into company (name, email, phone, address, url, type, company_id) values ('Skyvu', 'twooland10@meetup.com', '444-637-5911', '3 Mccormick Hill', 'cafepress.com', 'finance', 37);
insert into company (name, email, phone, address, url, type, company_id) values ('Youfeed', 'ktommis11@mapquest.com', '352-560-5992', '493 Clyde Gallagher Junction', 'zdnet.com', 'finance', 38);
insert into company (name, email, phone, address, url, type, company_id) values ('Jamia', 'bdade12@loc.gov', '571-528-6386', '24 Valley Edge Drive', 'com.com', 'technology', 39);
insert into company (name, email, phone, address, url, type, company_id) values ('Roodel', 'rallmark13@blogs.com', '114-760-3311', '87 Heffernan Road', 'yahoo.com', 'technology', 40);
insert into company (name, email, phone, address, url, type, company_id) values ('Devbug', 'gmahony14@trellian.com', '360-898-9590', '74319 Brentwood Road', 't.co', 'retail', 41);
insert into company (name, email, phone, address, url, type, company_id) values ('Rooxo', 'zdmitr15@tmall.com', '146-145-7589', '4 Warbler Road', 'adobe.com', 'manufacturing', 42);
insert into company (name, email, phone, address, url, type, company_id) values ('Voolith', 'mmangan16@canalblog.com', '594-387-4701', '3822 Lakewood Gardens Court', 'google.com.br', 'retail', 43);
insert into company (name, email, phone, address, url, type, company_id) values ('Babbleblab', 'kcobbe17@technorati.com', '180-354-0745', '96 Fuller Plaza', '163.com', 'technology', 44);
insert into company (name, email, phone, address, url, type, company_id) values ('Tagcat', 'ogrzegorecki18@goodreads.com', '913-565-8893', '04 Texas Circle', 'exblog.jp', 'healthcare', 45);
insert into company (name, email, phone, address, url, type, company_id) values ('Minyx', 'aredmayne19@feedburner.com', '401-689-8995', '7212 Mayer Drive', 'ebay.co.uk', 'retail', 46);
insert into company (name, email, phone, address, url, type, company_id) values ('Fadeo', 'tronca1a@unesco.org', '780-252-0044', '58766 Montana Lane', 'odnoklassniki.ru', 'healthcare', 47);
insert into company (name, email, phone, address, url, type, company_id) values ('Brightdog', 'achettle1b@eventbrite.com', '226-623-7007', '6930 Hallows Point', 'craigslist.org', 'technology', 48);
insert into company (name, email, phone, address, url, type, company_id) values ('Tagfeed', 'lgeorg1c@fc2.com', '525-886-9879', '11983 Novick Place', 'mysql.com', 'technology', 49);
insert into company (name, email, phone, address, url, type, company_id) values ('Ntag', 'jsouness1d@washington.edu', '933-264-4507', '861 Anderson Court', 'eventbrite.com', 'retail', 50);

# Course

insert into course (course_id, name) values (1, 'International Finance');
insert into course (course_id, name) values (2, 'Financial Accounting');
insert into course (course_id, name) values (3, 'Financial Accounting');
insert into course (course_id, name) values (4, 'Financial Accounting');
insert into course (course_id, name) values (5, 'International Finance');
insert into course (course_id, name) values (6, 'Investment Analysis');
insert into course (course_id, name) values (7, 'Corporate Finance');
insert into course (course_id, name) values (8, 'Financial Accounting');
insert into course (course_id, name) values (9, 'Corporate Finance');
insert into course (course_id, name) values (10, 'Corporate Finance');
insert into course (course_id, name) values (11, 'Corporate Finance');
insert into course (course_id, name) values (12, 'Investment Analysis');
insert into course (course_id, name) values (13, 'International Finance');
insert into course (course_id, name) values (14, 'International Finance');
insert into course (course_id, name) values (15, 'Investment Analysis');
insert into course (course_id, name) values (16, 'Financial Management');
insert into course (course_id, name) values (17, 'Financial Accounting');
insert into course (course_id, name) values (18, 'Financial Management');
insert into course (course_id, name) values (19, 'Financial Management');
insert into course (course_id, name) values (20, 'Corporate Finance');
insert into course (course_id, name) values (21, 'International Finance');
insert into course (course_id, name) values (22, 'Investment Analysis');
insert into course (course_id, name) values (23, 'Corporate Finance');
insert into course (course_id, name) values (24, 'Financial Accounting');
insert into course (course_id, name) values (25, 'Investment Analysis');
insert into course (course_id, name) values (26, 'Investment Analysis');
insert into course (course_id, name) values (27, 'Corporate Finance');
insert into course (course_id, name) values (28, 'Financial Management');
insert into course (course_id, name) values (29, 'Financial Accounting');
insert into course (course_id, name) values (30, 'Financial Management');
insert into course (course_id, name) values (31, 'Managerial Accounting');
insert into course (course_id, name) values (32, 'Corporate Finance');
insert into course (course_id, name) values (33, 'Financial Accounting');
insert into course (course_id, name) values (34, 'Managerial Accounting');
insert into course (course_id, name) values (35, 'Managerial Accounting');
insert into course (course_id, name) values (36, 'International Finance');
insert into course (course_id, name) values (37, 'International Finance');
insert into course (course_id, name) values (38, 'Corporate Finance');
insert into course (course_id, name) values (39, 'Managerial Accounting');
insert into course (course_id, name) values (40, 'Investment Analysis');
insert into course (course_id, name) values (41, 'Managerial Accounting');
insert into course (course_id, name) values (42, 'Corporate Finance');
insert into course (course_id, name) values (43, 'Financial Accounting');
insert into course (course_id, name) values (44, 'Financial Management');
insert into course (course_id, name) values (45, 'International Finance');
insert into course (course_id, name) values (46, 'Corporate Finance');
insert into course (course_id, name) values (47, 'Financial Management');
insert into course (course_id, name) values (48, 'Financial Management');
insert into course (course_id, name) values (49, 'Managerial Accounting');
insert into course (course_id, name) values (50, 'Investment Analysis');

# Engineer

insert into engineer (engineer_id, firstName, lastName, email) values (1, 'Shana', 'McAlroy', 'smcalroy0@webnode.com');
insert into engineer (engineer_id, firstName, lastName, email) values (2, 'Haleigh', 'Feeney', 'hfeeney1@netlog.com');
insert into engineer (engineer_id, firstName, lastName, email) values (3, 'Augy', 'Durtnell', 'adurtnell2@chron.com');
insert into engineer (engineer_id, firstName, lastName, email) values (4, 'Ericka', 'Faraker', 'efaraker3@digg.com');
insert into engineer (engineer_id, firstName, lastName, email) values (5, 'Roxanna', 'Waadenburg', 'rwaadenburg4@goodreads.com');
insert into engineer (engineer_id, firstName, lastName, email) values (6, 'Veronike', 'Leaman', 'vleaman5@cmu.edu');
insert into engineer (engineer_id, firstName, lastName, email) values (7, 'Rupert', 'Prandin', 'rprandin6@cocolog-nifty.com');
insert into engineer (engineer_id, firstName, lastName, email) values (8, 'Amye', 'Losel', 'alosel7@joomla.org');
insert into engineer (engineer_id, firstName, lastName, email) values (9, 'Lenette', 'Lubomirski', 'llubomirski8@nsw.gov.au');
insert into engineer (engineer_id, firstName, lastName, email) values (10, 'Renault', 'Deschelle', 'rdeschelle9@seattletimes.com');
insert into engineer (engineer_id, firstName, lastName, email) values (11, 'Gerhard', 'Lockyer', 'glockyera@xinhuanet.com');
insert into engineer (engineer_id, firstName, lastName, email) values (12, 'Wittie', 'Danielsohn', 'wdanielsohnb@livejournal.com');
insert into engineer (engineer_id, firstName, lastName, email) values (13, 'Yves', 'Genaddy', 'ygengineer_iddyc@ed.gov');
insert into engineer (engineer_id, firstName, lastName, email) values (14, 'Elsey', 'Treven', 'etrevend@php.net');
insert into engineer (engineer_id, firstName, lastName, email) values (15, 'Kania', 'Fratson', 'kfratsone@stanford.edu');
insert into engineer (engineer_id, firstName, lastName, email) values (16, 'Sayres', 'Still', 'sstillf@eepurl.com');
insert into engineer (engineer_id, firstName, lastName, email) values (17, 'Jerry', 'Fronek', 'jfronekg@icio.us');
insert into engineer (engineer_id, firstName, lastName, email) values (18, 'Tymon', 'Cousin', 'tcousinh@discovery.com');
insert into engineer (engineer_id, firstName, lastName, email) values (19, 'Austine', 'Gullane', 'agullanei@opera.com');
insert into engineer (engineer_id, firstName, lastName, email) values (20, 'Griffy', 'Morrissey', 'gmorrisseyj@addthis.com');
insert into engineer (engineer_id, firstName, lastName, email) values (21, 'Sheree', 'Girardi', 'sgirardik@usatoday.com');
insert into engineer (engineer_id, firstName, lastName, email) values (22, 'Amabel', 'Paulou', 'apauloul@naver.com');
insert into engineer (engineer_id, firstName, lastName, email) values (23, 'Stevie', 'Leber', 'sleberm@sohu.com');
insert into engineer (engineer_id, firstName, lastName, email) values (24, 'Sayre', 'Sinnie', 'ssinnien@umich.edu');
insert into engineer (engineer_id, firstName, lastName, email) values (25, 'Dimitry', 'Scourfield', 'dscourfieldo@surveymonkey.com');
insert into engineer (engineer_id, firstName, lastName, email) values (26, 'Kristi', 'Bleue', 'kbleuep@shareasale.com');
insert into engineer (engineer_id, firstName, lastName, email) values (27, 'Dunstan', 'McArthur', 'dmcarthurq@gizmodo.com');
insert into engineer (engineer_id, firstName, lastName, email) values (28, 'Moises', 'Eliaz', 'meliazr@github.com');
insert into engineer (engineer_id, firstName, lastName, email) values (29, 'Tracee', 'Arnault', 'tarnaults@mapquest.com');
insert into engineer (engineer_id, firstName, lastName, email) values (30, 'Priscella', 'Di Dello', 'pdengineer_idellot@blogger.com');
insert into engineer (engineer_id, firstName, lastName, email) values (31, 'Tracee', 'Wallis', 'twallisu@canalblog.com');
insert into engineer (engineer_id, firstName, lastName, email) values (32, 'Sherman', 'Trobe', 'strobev@purevolume.com');
insert into engineer (engineer_id, firstName, lastName, email) values (33, 'Carolin', 'Preddle', 'cpreddlew@reverbnation.com');
insert into engineer (engineer_id, firstName, lastName, email) values (34, 'Benoite', 'Rodbourne', 'brodbournex@nps.gov');
insert into engineer (engineer_id, firstName, lastName, email) values (35, 'Alaine', 'Jolliman', 'ajollimany@woothemes.com');
insert into engineer (engineer_id, firstName, lastName, email) values (36, 'Fawnia', 'Batterbee', 'fbatterbeez@webnode.com');
insert into engineer (engineer_id, firstName, lastName, email) values (37, 'Rubin', 'Flippini', 'rflippini10@wp.com');
insert into engineer (engineer_id, firstName, lastName, email) values (38, 'Millicent', 'Jephcote', 'mjephcote11@scribd.com');
insert into engineer (engineer_id, firstName, lastName, email) values (39, 'Addy', 'Enright', 'aenright12@skype.com');
insert into engineer (engineer_id, firstName, lastName, email) values (40, 'Sydelle', 'Fewell', 'sfewell13@ox.ac.uk');
insert into engineer (engineer_id, firstName, lastName, email) values (41, 'Murielle', 'Bonney', 'mbonney14@spotify.com');
insert into engineer (engineer_id, firstName, lastName, email) values (42, 'Rhona', 'Gengineer_iddons', 'rgengineer_iddons15@cmu.edu');
insert into engineer (engineer_id, firstName, lastName, email) values (43, 'Camille', 'Bouzek', 'cbouzek16@ibm.com');
insert into engineer (engineer_id, firstName, lastName, email) values (44, 'Darby', 'Glentworth', 'dglentworth17@joomla.org');
insert into engineer (engineer_id, firstName, lastName, email) values (45, 'Hyman', 'Phoenix', 'hphoenix18@about.com');
insert into engineer (engineer_id, firstName, lastName, email) values (46, 'Baird', 'Fairs', 'bfairs19@sohu.com');
insert into engineer (engineer_id, firstName, lastName, email) values (47, 'Nadiya', 'Ivanichev', 'nivanichev1a@moonfruit.com');
insert into engineer (engineer_id, firstName, lastName, email) values (48, 'Wes', 'Eby', 'weby1b@canalblog.com');
insert into engineer (engineer_id, firstName, lastName, email) values (49, 'Wainwright', 'Thackeray', 'wthackeray1c@thetimes.co.uk');
insert into engineer (engineer_id, firstName, lastName, email) values (50, 'Desiree', 'Blaker', 'dblaker1d@drupal.org');

# Internship

insert into internship (internship_id, name, description, url, company_id) values (1, 'Marketing Intern', 'teamwork', 'http://I+\.Q{2,}/-+', 24);
insert into internship (internship_id, name, description, url, company_id) values (2, 'Marketing Intern', 'problem-solving', 'http://www\.-+\.n{2,}\.h{2,}/-+', 23);
insert into internship (internship_id, name, description, url, company_id) values (3, 'Marketing Intern', 'communication skills', 'http://www\.-+\.S{2,}\.O{2,}/-+', 28);
insert into internship (internship_id, name, description, url, company_id) values (4, 'Software Engineering Intern', 'critical thinking', 'https://-+\.k{2,}/1+', 19);
insert into internship (internship_id, name, description, url, company_id) values (5, 'Data Analyst Intern', 'communication skills', 'http://www\.K+\.G{2,}//+', 7);
insert into internship (internship_id, name, description, url, company_id) values (6, 'Graphic Design Intern', 'creativity', 'http://www\.4+\.H{2,}\.a{2,}/_+', 17);
insert into internship (internship_id, name, description, url, company_id) values (7, 'Human Resources Intern', 'problem-solving', 'http://B+\.p{2,}/e+', 30);
insert into internship (internship_id, name, description, url, company_id) values (8, 'Graphic Design Intern', 'analytical skills', 'https://www\.n+\.x{2,}/F+', 20);
insert into internship (internship_id, name, description, url, company_id) values (9, 'Graphic Design Intern', 'problem-solving', 'https://www\.Q+\.g{2,}/w+', 2);
insert into internship (internship_id, name, description, url, company_id) values (10, 'Data Analyst Intern', 'time management', 'http://6+\.h{2,}\.E{2,}//+', 8);
insert into internship (internship_id, name, description, url, company_id) values (11, 'Data Analyst Intern', 'teamwork', 'http://www\.0+\.O{2,}\.K{2,}//+', 13);
insert into internship (internship_id, name, description, url, company_id) values (12, 'Graphic Design Intern', 'critical thinking', 'http://-+\.T{2,}/n+', 13);
insert into internship (internship_id, name, description, url, company_id) values (13, 'Marketing Intern', 'analytical skills', 'http://H+\.V{2,}\.i{2,}/G+', 18);
insert into internship (internship_id, name, description, url, company_id) values (14, 'Graphic Design Intern', 'analytical skills', 'http://S+\.f{2,}\.t{2,}/-+', 14);
insert into internship (internship_id, name, description, url, company_id) values (15, 'Graphic Design Intern', 'adaptability', 'http://-+\.d{2,}//+', 6);
insert into internship (internship_id, name, description, url, company_id) values (16, 'Software Engineering Intern', 'creativity', 'https://a+\.t{2,}\.J{2,}/-+', 11);
insert into internship (internship_id, name, description, url, company_id) values (17, 'Human Resources Intern', 'creativity', 'https://www\.J+\.H{2,}/_+', 9);
insert into internship (internship_id, name, description, url, company_id) values (18, 'Software Engineering Intern', 'adaptability', 'http://-+\.I{2,}//+', 30);
insert into internship (internship_id, name, description, url, company_id) values (19, 'Software Engineering Intern', 'teamwork', 'https://e+\.X{2,}\.o{2,}/-+', 5);
insert into internship (internship_id, name, description, url, company_id) values (20, 'Data Analyst Intern', 'adaptability', 'http://R+\.N{2,}\.g{2,}/-+', 14);
insert into internship (internship_id, name, description, url, company_id) values (21, 'Human Resources Intern', 'adaptability', 'https://z+\.n{2,}//+', 3);
insert into internship (internship_id, name, description, url, company_id) values (22, 'Data Analyst Intern', 'communication skills', 'https://-+\.K{2,}\.e{2,}/H+', 4);
insert into internship (internship_id, name, description, url, company_id) values (23, 'Data Analyst Intern', 'leadership', 'http://2+\.J{2,}\.F{2,}/9+', 23);
insert into internship (internship_id, name, description, url, company_id) values (24, 'Data Analyst Intern', 'communication skills', 'http://www\.-+\.j{2,}\.r{2,}/6+', 6);
insert into internship (internship_id, name, description, url, company_id) values (25, 'Human Resources Intern', 'teamwork', 'http://www\.-+\.z{2,}/c+', 4);
insert into internship (internship_id, name, description, url, company_id) values (26, 'Graphic Design Intern', 'adaptability', 'https://www\.-+\.Z{2,}/0+', 11);
insert into internship (internship_id, name, description, url, company_id) values (27, 'Software Engineering Intern', 'teamwork', 'https://-+\.L{2,}\.x{2,}/-+', 20);
insert into internship (internship_id, name, description, url, company_id) values (28, 'Graphic Design Intern', 'adaptability', 'http://6+\.m{2,}\.Y{2,}/_+', 5);
insert into internship (internship_id, name, description, url, company_id) values (29, 'Software Engineering Intern', 'teamwork', 'https://www\.I+\.p{2,}/_+', 9);
insert into internship (internship_id, name, description, url, company_id) values (30, 'Marketing Intern', 'time management', 'http://www\.C+\.p{2,}/e+', 18);
insert into internship (internship_id, name, description, url, company_id) values (31, 'Human Resources Intern', 'leadership', 'https://4+\.T{2,}/_+', 11);
insert into internship (internship_id, name, description, url, company_id) values (32, 'Graphic Design Intern', 'problem-solving', 'https://t+\.R{2,}\.I{2,}//+', 21);
insert into internship (internship_id, name, description, url, company_id) values (33, 'Data Analyst Intern', 'teamwork', 'http://1+\.O{2,}\.t{2,}/A+', 3);
insert into internship (internship_id, name, description, url, company_id) values (34, 'Human Resources Intern', 'leadership', 'https://www\.3+\.A{2,}/-+', 8);
insert into internship (internship_id, name, description, url, company_id) values (35, 'Data Analyst Intern', 'critical thinking', 'https://www\.-+\.V{2,}/5+', 2);
insert into internship (internship_id, name, description, url, company_id) values (36, 'Human Resources Intern', 'problem-solving', 'https://www\.-+\.d{2,}\.b{2,}/_+', 24);
insert into internship (internship_id, name, description, url, company_id) values (37, 'Data Analyst Intern', 'problem-solving', 'http://www\.5+\.R{2,}\.b{2,}/_+', 25);
insert into internship (internship_id, name, description, url, company_id) values (38, 'Software Engineering Intern', 'attention to detail', 'http://0+\.S{2,}\.U{2,}//+', 30);
insert into internship (internship_id, name, description, url, company_id) values (39, 'Marketing Intern', 'analytical skills', 'https://www\.n+\.O{2,}\.l{2,}//+', 30);
insert into internship (internship_id, name, description, url, company_id) values (40, 'Human Resources Intern', 'teamwork', 'https://www\.N+\.n{2,}\.b{2,}/_+', 25);
insert into internship (internship_id, name, description, url, company_id) values (41, 'Human Resources Intern', 'attention to detail', 'http://5+\.q{2,}/N+', 3);
insert into internship (internship_id, name, description, url, company_id) values (42, 'Software Engineering Intern', 'time management', 'https://-+\.Z{2,}/C+', 26);
insert into internship (internship_id, name, description, url, company_id) values (43, 'Software Engineering Intern', 'adaptability', 'https://www\.3+\.y{2,}/_+', 2);
insert into internship (internship_id, name, description, url, company_id) values (44, 'Marketing Intern', 'problem-solving', 'https://www\.2+\.I{2,}/-+', 10);
insert into internship (internship_id, name, description, url, company_id) values (45, 'Graphic Design Intern', 'problem-solving', 'http://f+\.t{2,}//+', 29);
insert into internship (internship_id, name, description, url, company_id) values (46, 'Software Engineering Intern', 'teamwork', 'https://www\.4+\.t{2,}//+', 6);
insert into internship (internship_id, name, description, url, company_id) values (47, 'Data Analyst Intern', 'time management', 'http://c+\.f{2,}\.T{2,}/y+', 1);
insert into internship (internship_id, name, description, url, company_id) values (48, 'Software Engineering Intern', 'problem-solving', 'https://5+\.L{2,}//+', 20);
insert into internship (internship_id, name, description, url, company_id) values (49, 'Software Engineering Intern', 'communication skills', 'https://www\.b+\.Z{2,}\.J{2,}//+', 16);
insert into internship (internship_id, name, description, url, company_id) values (50, 'Data Analyst Intern', 'teamwork', 'https://-+\.H{2,}//+', 16);

# Professor

insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (1, 27, 'Britt', 'Caswall', 'Economics', 'Sahand University of Technology', 'bcaswall0@t-online.de');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (2, 20, 'Hatti', 'Watson', 'Physics', 'World Maritime University', 'hwatson1@toplist.cz');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (3, 2, 'Chaunce', 'Titman', 'Mathematics', 'Spring Hill College', 'ctitman2@diigo.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (4, 3, 'Lona', 'Plume', 'Biology', 'Otsuma Women''s University', 'lplume3@bing.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (5, 19, 'Teddy', 'Browell', 'Mathematics', 'University of Lucknow', 'tbrowell4@state.gov');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (6, 2, 'Jens', 'Thorpe', 'Mathematics', 'University Institute of Teacher Training "Suor Orsola Benincasa"', 'jthorpe5@timesonline.co.uk');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (7, 15, 'Keenan', 'Powton', 'History', 'Southeastern Bible College', 'kpowton6@oracle.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (8, 18, 'Zebadiah', 'Errington', 'Art', 'Dhaka University of Engineering and Technology', 'zerrington7@noaa.gov');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (9, 14, 'Merrill', 'Garter', 'Psychology', 'University of Burao', 'mgarter8@symantec.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (10, 3, 'Calhoun', 'Rowbrey', 'Sociology', 'University of South Carolina - Lancaster', 'crowbrey9@yandex.ru');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (11, 17, 'Hubie', 'Skurm', 'Business', 'Nebraska Christian College', 'hskurma@phoca.cz');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (12, 28, 'Lola', 'Franks', 'Business', 'University of Pretoria', 'lfranksb@dropbox.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (13, 10, 'Libbie', 'Hanway', 'Chemistry', 'Royal University of Bhutan', 'lhanwayc@reddit.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (14, 14, 'Mureil', 'Celand', 'History', 'Stillman College', 'mcelandd@alibaba.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (15, 23, 'Ofilia', 'Jellico', 'Mathematics', 'University of Akureyri', 'ojellicoe@github.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (16, 25, 'Corbie', 'Billson', 'Mathematics', 'Central South Forestry University', 'cbillsonf@booking.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (17, 18, 'Allie', 'Marsy', 'Chemistry', 'British Royal University', 'amarsyg@tmall.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (18, 27, 'Quentin', 'Osband', 'Physics', 'Islamic University of Medinah', 'qosbandh@clickbank.net');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (19, 27, 'Enprofessor_id', 'Buxy', 'Economics', 'Université Paris-Dauphine (Paris IX)', 'ebuxyi@netlog.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (20, 7, 'Libbi', 'Dumberell', 'English', 'Universprofessor_idade Mackenzie', 'ldumberellj@pen.io');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (21, 21, 'Lothario', 'Dengel', 'Computer Science', 'American Military University', 'ldengelk@photobucket.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (22, 17, 'Rora', 'Salt', 'History', 'EMESCAM - Escola Superior de Ciências da Santa Casa de Misericórdia de Vitória', 'rsaltl@patch.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (23, 9, 'Ailene', 'MacGill', 'Art', 'Siena College', 'amacgillm@mit.edu');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (24, 14, 'Sacha', 'Castelyn', 'Psychology', 'Finlandia University', 'scastelynn@timesonline.co.uk');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (25, 8, 'Jacob', 'Girodin', 'Biology', 'Universprofessor_idade Cprofessor_idade de São Paulo', 'jgirodino@comsenz.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (26, 14, 'Calv', 'Crannage', 'English', 'Technological University (Hmawbi)', 'ccrannagep@lulu.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (27, 19, 'Jocelin', 'Cubuzzi', 'Biology', 'Indiana University at Kokomo', 'jcubuzziq@shinystat.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (28, 25, 'Ashlee', 'Gaber', 'Biology', 'Slippery Rock University', 'agaberr@usda.gov');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (29, 11, 'Yvor', 'Mumbey', 'Computer Science', 'Help University College', 'ymumbeys@soup.io');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (30, 4, 'Lucais', 'Tunstall', 'Chemistry', 'Kent State University - Stark', 'ltunstallt@ucsd.edu');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (31, 14, 'Ruperta', 'Marin', 'Business', 'King Abdul Aziz University', 'rmarinu@vinaora.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (32, 23, 'Jeffry', 'Starton', 'History', 'Neijiang Teacher University', 'jstartonv@sakura.ne.jp');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (33, 3, 'Ethelda', 'Dollen', 'Mathematics', 'Kumamoto Prefectural University', 'edollenw@tinyurl.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (34, 10, 'Euell', 'Greenmon', 'Computer Science', 'Xi''an International Studies University', 'egreenmonx@dropbox.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (35, 5, 'Ferd', 'Glasman', 'Chemistry', 'Ecole des Ingénieurs de la Ville de Paris', 'fglasmany@redcross.org');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (36, 28, 'Rasla', 'Waller-Brprofessor_idge', 'English', 'Brussels School of International Studies', 'rwallerbrprofessor_idgez@photobucket.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (37, 9, 'Mahalia', 'Tortoishell', 'Art', 'Dowling College', 'mtortoishell10@angelfire.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (38, 20, 'Paola', 'Bateson', 'Biology', 'Ningbo University of Technology', 'pbateson11@51.la');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (39, 19, 'Lyn', 'Larking', 'Physics', 'Academy of Fine Arts', 'llarking12@tinyurl.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (40, 8, 'Turner', 'McKimmey', 'Computer Science', 'Universprofessor_idad Distral "Francisco José de Caldas"', 'tmckimmey13@soundcloud.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (41, 6, 'Micky', 'Arthy', 'Chemistry', 'Clarion University', 'marthy14@ucoz.ru');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (42, 19, 'Willy', 'Paroni', 'Physics', 'Universprofessor_idad Autónoma de San Luis Potosí', 'wparoni15@vkontakte.ru');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (43, 1, 'Merrie', 'Withers', 'Music', 'National Sun Yat-Sen University', 'mwithers16@elpais.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (44, 12, 'Terrill', 'Bernaert', 'History', 'Faculté Polytechnique de Mons', 'tbernaert17@pagesperso-orange.fr');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (45, 4, 'Kata', 'Hamber', 'Business', 'University of Korca "Fan Noli"', 'khamber18@ucla.edu');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (46, 4, 'Anna-diana', 'Wardlaw', 'Art', 'Dakota State University', 'awardlaw19@goodreads.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (47, 2, 'Ingunna', 'Boschmann', 'Chemistry', 'Baptist Bible College of Pennsylvania', 'iboschmann1a@paginegialle.it');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (48, 2, 'Laurens', 'Haack', 'Psychology', 'Universprofessor_idad Privada Los Andes', 'lhaack1b@bloglines.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (49, 11, 'Marcille', 'Causton', 'Art', 'University of Bergen', 'mcauston1c@nbcnews.com');
insert into professor (professor_id, course_id, firstName, lastName, department, university, email) values (50, 1, 'Wallie', 'Sproson', 'History', 'Universprofessor_idad Tecnologica Israel', 'wsproson1d@princeton.edu');

# Recruiter

insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (1, 'Kailey', 'Freshwater', 'kfreshwater0@constantcontact.com', 14);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (2, 'Jasmina', 'Precruiter_idgin', 'jprecruiter_idgin1@qq.com', 1);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (3, 'Aubrey', 'Puckett', 'apuckett2@mozilla.com', 13);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (4, 'Maggi', 'Walthall', 'mwalthall3@godaddy.com', 7);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (5, 'Pavla', 'Knightsbrrecruiter_idge', 'pknightsbrrecruiter_idge4@google.pl', 12);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (6, 'Killie', 'Scohier', 'kscohier5@shareasale.com', 9);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (7, 'Patsy', 'Elsworth', 'pelsworth6@cpanel.net', 17);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (8, 'Levin', 'Selly', 'lselly7@google.co.uk', 4);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (9, 'Adina', 'Mosen', 'amosen8@last.fm', 24);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (10, 'Itch', 'Udie', 'iudie9@hatena.ne.jp', 6);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (11, 'Gnni', 'Cheke', 'gchekea@theguardian.com', 20);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (12, 'Mercedes', 'Devoy', 'mdevoyb@technorati.com', 5);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (13, 'Oren', 'Puleque', 'opulequec@dion.ne.jp', 26);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (14, 'Candrecruiter_ide', 'Shower', 'cshowerd@xrea.com', 11);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (15, 'Talyah', 'MacTeague', 'tmacteaguee@springer.com', 17);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (16, 'Shanon', 'Greenham', 'sgreenhamf@phpbb.com', 29);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (17, 'Kaylyn', 'Cuff', 'kcuffg@imdb.com', 21);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (18, 'Charlean', 'Walework', 'cwaleworkh@facebook.com', 11);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (19, 'Lothaire', 'Orrell', 'lorrelli@ed.gov', 23);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (20, 'Kiele', 'Thomton', 'kthomtonj@cdc.gov', 26);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (21, 'Cindy', 'Dorre', 'cdorrek@delicious.com', 30);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (22, 'Sharlene', 'Llop', 'sllopl@joomla.org', 1);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (23, 'Heriberto', 'Fickling', 'hficklingm@blog.com', 7);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (24, 'Edd', 'Dregan', 'edregann@dyndns.org', 4);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (25, 'Lonni', 'Ilyukhov', 'lilyukhovo@nytimes.com', 18);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (26, 'Daron', 'Fewings', 'dfewingsp@thetimes.co.uk', 5);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (27, 'Bernarr', 'Casin', 'bcasinq@cpanel.net', 9);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (28, 'Vina', 'Vigietti', 'vvigiettir@squarespace.com', 22);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (29, 'Lowrance', 'Huckel', 'lhuckels@cpanel.net', 3);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (30, 'Beau', 'Srecruiter_idlow', 'bsrecruiter_idlowt@mlb.com', 22);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (31, 'Ramon', 'Goodrick', 'rgoodricku@issuu.com', 3);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (32, 'Dav', 'Kilgallon', 'dkilgallonv@goo.gl', 27);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (33, 'Hector', 'Faiers', 'hfaiersw@jimdo.com', 17);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (34, 'Zeke', 'Cotilard', 'zcotilardx@statcounter.com', 1);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (35, 'Doy', 'Gooddy', 'dgooddyy@narod.ru', 3);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (36, 'Carley', 'Aslam', 'caslamz@is.gd', 26);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (37, 'Gabe', 'Tooth', 'gtooth10@istockphoto.com', 10);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (38, 'Cal', 'Croose', 'ccroose11@list-manage.com', 10);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (39, 'Ernaline', 'Eble', 'eeble12@nymag.com', 23);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (40, 'Cybill', 'De''Vere - Hunt', 'cdeverehunt13@ow.ly', 7);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (41, 'Raychel', 'Gingold', 'rgingold14@nps.gov', 2);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (42, 'Bartholomew', 'Presnell', 'bpresnell15@angelfire.com', 8);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (43, 'Kitty', 'Tuckie', 'ktuckie16@chron.com', 23);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (44, 'Bennett', 'Pitsall', 'bpitsall17@marriott.com', 30);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (45, 'Marshal', 'Sture', 'msture18@soundcloud.com', 23);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (46, 'Sindee', 'Martino', 'smartino19@prlog.org', 11);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (47, 'Orsa', 'Romanini', 'oromanini1a@tiny.cc', 10);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (48, 'Addie', 'Pulman', 'apulman1b@geocities.jp', 10);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (49, 'Hope', 'Livezey', 'hlivezey1c@artisteer.com', 25);
insert into recruiter (recruiter_id, firstName, lastName, email, company_id) values (50, 'Jorie', 'Rowlstone', 'jrowlstone1d@upenn.edu', 27);

# Simulation

insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (1, 229644.75, '2/26/2023', 'Learn financial concepts through interactive exercises.', 6, 'Money Matters', '1/16/2023', 'active');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (2, 306079.49, '7/21/2023', 'Immerse yourself in the world of finance.', 19, 'Budgeting Basics', '9/26/2023', 'inactive');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (3, 673488.2, '6/19/2023', 'Gain practical knowledge in personal finance.', 10, 'Budgeting Basics', '4/26/2023', 'active');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (4, 919754.9, '2/9/2023', 'Enhance your financial literacy with hands-on simulations.', 27, 'Financial Foundations', '8/31/2023', 'inactive');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (5, 188807.45, '9/7/2023', 'Explore the principles of money management.', 4, 'Financial Foundations', '9/12/2023', 'inactive');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (6, 397192.88, '3/10/2023', 'Enhance your financial literacy with hands-on simulations.', 19, 'Money Matters', '10/22/2023', 'pending');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (7, 905805.11, '1/25/2023', 'Immerse yourself in the world of finance.', 3, 'Investment Insights', '10/14/2023', 'completed');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (8, 933927.25, '8/1/2023', 'Immerse yourself in the world of finance.', 22, 'Budgeting Basics', '6/24/2023', 'active');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (9, 132667.53, '9/25/2023', 'Welcome to the finance simulation!', 5, 'Budgeting Basics', '9/18/2023', 'pending');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (10, 110084.46, '1/13/2023', 'Master financial decision-making skills.', 11, 'Wealth Wisdom', '5/10/2023', 'active');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (11, 808051.03, '8/20/2023', 'Gain practical knowledge in personal finance.', 29, 'Investment Insights', '6/21/2023', 'inactive');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (12, 425117.97, '8/17/2023', 'Explore the principles of money management.', 26, 'Financial Foundations', '1/14/2023', 'completed');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (13, 229071.86, '6/8/2023', 'Enhance your financial literacy with hands-on simulations.', 12, 'Investment Insights', '10/22/2023', 'active');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (14, 317743.64, '12/20/2022', 'Gain practical knowledge in personal finance.', 14, 'Money Matters', '7/14/2023', 'inactive');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (15, 994440.86, '2/5/2023', 'Immerse yourself in the world of finance.', 14, 'Investment Insights', '3/23/2023', 'inactive');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (16, 765582.73, '9/4/2023', 'Welcome to the finance simulation!', 15, 'Financial Foundations', '12/25/2022', 'active');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (17, 201054.8, '4/19/2023', 'Experience real-world financial scenarios.', 12, 'Money Matters', '9/11/2023', 'completed');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (18, 372331.96, '6/20/2023', 'Experience real-world financial scenarios.', 9, 'Investment Insights', '9/15/2023', 'pending');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (19, 96044.89, '5/20/2023', 'Immerse yourself in the world of finance.', 11, 'Budgeting Basics', '11/21/2023', 'inactive');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (20, 110488.11, '3/11/2023', 'Experience real-world financial scenarios.', 27, 'Wealth Wisdom', '4/2/2023', 'pending');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (21, 917261.4, '1/2/2023', 'Welcome to the finance simulation!', 8, 'Budgeting Basics', '9/29/2023', 'active');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (22, 754945.26, '10/21/2023', 'Welcome to the finance simulation!', 18, 'Budgeting Basics', '3/6/2023', 'inactive');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (23, 737863.16, '8/11/2023', 'Learn financial concepts through interactive exercises.', 22, 'Wealth Wisdom', '2/27/2023', 'pending');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (24, 717177.28, '1/17/2023', 'Enhance your financial literacy with hands-on simulations.', 27, 'Budgeting Basics', '7/16/2023', 'inactive');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (25, 383413.23, '11/26/2023', 'Master financial decision-making skills.', 24, 'Financial Foundations', '9/6/2023', 'pending');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (26, 97774.49, '9/16/2023', 'Welcome to the finance simulation!', 23, 'Money Matters', '4/5/2023', 'completed');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (27, 577424.08, '8/16/2023', 'Enhance your financial literacy with hands-on simulations.', 5, 'Wealth Wisdom', '7/5/2023', 'active');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (28, 450083.13, '7/22/2023', 'Experience real-world financial scenarios.', 8, 'Money Matters', '6/3/2023', 'inactive');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (29, 969183.39, '6/21/2023', 'Learn financial concepts through interactive exercises.', 25, 'Wealth Wisdom', '1/22/2023', 'completed');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (30, 458464.33, '10/1/2023', 'Explore the principles of money management.', 2, 'Investment Insights', '6/19/2023', 'inactive');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (31, 690927.63, '3/21/2023', 'Immerse yourself in the world of finance.', 28, 'Money Matters', '1/13/2023', 'active');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (32, 762338.12, '7/16/2023', 'Experience real-world financial scenarios.', 28, 'Budgeting Basics', '5/25/2023', 'completed');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (33, 961873.89, '6/12/2023', 'Learn financial concepts through interactive exercises.', 8, 'Money Matters', '4/11/2023', 'active');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (34, 792815.34, '5/20/2023', 'Experience real-world financial scenarios.', 18, 'Investment Insights', '8/9/2023', 'completed');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (35, 896198.81, '10/30/2023', 'Explore the principles of money management.', 23, 'Investment Insights', '3/5/2023', 'inactive');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (36, 494800.95, '12/5/2022', 'Explore the principles of money management.', 8, 'Budgeting Basics', '6/26/2023', 'pending');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (37, 69339.56, '2/6/2023', 'Immerse yourself in the world of finance.', 20, 'Financial Foundations', '11/9/2023', 'active');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (38, 83371.81, '7/11/2023', 'Immerse yourself in the world of finance.', 24, 'Financial Foundations', '7/21/2023', 'active');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (39, 923244.96, '11/9/2023', 'Immerse yourself in the world of finance.', 17, 'Wealth Wisdom', '5/25/2023', 'active');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (40, 624782.89, '10/24/2023', 'Enhance your financial literacy with hands-on simulations.', 13, 'Financial Foundations', '6/7/2023', 'active');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (41, 814604.67, '7/31/2023', 'Gain practical knowledge in personal finance.', 15, 'Investment Insights', '6/26/2023', 'completed');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (42, 800711.9, '2/12/2023', 'Learn financial concepts through interactive exercises.', 19, 'Financial Foundations', '12/10/2022', 'inactive');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (43, 356479.51, '11/15/2023', 'Learn financial concepts through interactive exercises.', 27, 'Wealth Wisdom', '11/7/2023', 'active');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (44, 510686.58, '8/26/2023', 'Immerse yourself in the world of finance.', 18, 'Budgeting Basics', '4/9/2023', 'pending');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (45, 803246.65, '6/26/2023', 'Enhance your financial literacy with hands-on simulations.', 20, 'Investment Insights', '6/1/2023', 'inactive');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (46, 625599.93, '1/14/2023', 'Explore the principles of money management.', 6, 'Budgeting Basics', '7/13/2023', 'pending');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (47, 243362.83, '4/5/2023', 'Learn financial concepts through interactive exercises.', 17, 'Budgeting Basics', '4/21/2023', 'pending');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (48, 100516.83, '8/17/2023', 'Enhance your financial literacy with hands-on simulations.', 20, 'Budgeting Basics', '4/5/2023', 'active');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (49, 752603.89, '9/21/2023', 'Master financial decision-making skills.', 15, 'Wealth Wisdom', '9/30/2023', 'pending');
insert into simulation (simulation_id, startingBal, endDate, desc, createdBy, name, startDate, status) values (50, 490543.83, '1/13/2023', 'Gain practical knowledge in personal finance.', 30, 'Financial Foundations', '4/22/2023', 'completed');


# Simulation Results

insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (3, 15, 106.33, 11.6, 0, 0.95);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (17, 48, 513.56, 8.15, 0, 0.6);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (16, 38, 861.93, 9.66, 2, 0.12);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (29, 40, 584.3, 14.2, 1, 0.35);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (22, 34, 730.46, 15.0, 3, 0.12);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (27, 26, 719.69, 5.41, 3, 0.21);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (8, 50, 122.94, 15.88, 3, 0.72);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (28, 42, 616.26, 11.91, 0, 0.88);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (29, 49, 393.75, 6.22, 1, 0.13);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (25, 13, 286.12, 2.71, 3, 0.6);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (9, 24, 711.67, 18.35, 2, 0.92);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (7, 28, 917.78, 0.49, 3, 0.56);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (28, 36, 175.17, 4.26, 0, 0.94);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (11, 47, 442.22, 14.86, 2, 0.78);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (10, 30, 348.23, 5.64, 3, 0.3);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (16, 39, 643.12, 14.87, 1, 0.37);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (1, 3, 614.4, 11.3, 2, 0.18);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (30, 30, 631.3, 18.27, 3, 0.16);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (12, 13, 334.06, 4.27, 2, 0.61);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (13, 23, 260.38, 1.92, 3, 0.99);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (12, 43, 780.63, 11.4, 0, 0.5);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (24, 41, 831.51, 18.64, 3, 0.28);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (23, 37, 632.59, 17.9, 0, 0.93);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (3, 14, 332.59, 7.68, 2, 0.5);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (17, 14, 38.95, 13.47, 1, 0.45);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (11, 20, 929.61, 7.18, 1, 0.12);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (22, 27, 600.75, 10.69, 2, 0.46);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (23, 18, 508.58, 14.46, 1, 0.88);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (10, 38, 476.5, 9.39, 1, 0.09);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (4, 14, 668.67, 3.62, 0, 0.32);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (8, 8, 106.8, 0.96, 0, 0.63);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (22, 33, 925.49, 17.21, 3, 0.43);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (10, 48, 626.65, 15.79, 1, 0.94);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (27, 36, 416.21, 18.21, 0, 0.62);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (17, 2, 916.95, 9.57, 1, 0.3);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (14, 24, 388.86, 12.09, 1, 0.34);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (9, 12, 237.72, 5.71, 1, 0.47);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (16, 10, 592.71, 11.29, 2, 0.01);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (20, 28, 23.14, 2.45, 3, 0.16);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (14, 18, 281.64, 5.14, 3, 0.96);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (29, 31, 948.94, 9.18, 0, 0.89);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (16, 31, 669.2, 12.45, 0, 0.24);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (26, 11, 879.18, 9.0, 1, 0.4);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (5, 49, 687.17, 2.43, 0, 0.61);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (24, 46, 943.01, 2.31, 3, 0.98);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (3, 37, 357.54, 1.28, 1, 0.43);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (8, 25, 42.89, 13.24, 0, 0.64);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (29, 31, 895.87, 2.99, 1, 0.71);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (15, 8, 431.8, 19.84, 2, 0.77);
insert into simulation_results (simId, studentId, commission, pnl, sharpeRatio, execScore) values (22, 8, 24.21, 4.6, 2, 0.85);

# Stock

insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('LINU', 221.48, 222.51, 13, 846756, 'Wealth Wisdom', 0.17);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('TRNC', 734.5, 737.06, 14, 516676, 'Financial Foundations', 0.76);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('PIE', 593.73, 594.72, 12, 651984, 'Financial Foundations', 0.5);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('COE', 111.58, 112.41, 3, 129663, 'Financial Foundations', 0.98);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('HD', 142.91, 143.28, 1, 983176, 'Financial Foundations', 0.58);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('NUROW', 483.14, 484.77, 6, 138498, 'Investment Insights', 0.65);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('WSO.B', 217.04, 218.04, 15, 685226, 'Budgeting Basics', 0.44);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('TESS', 148.5, 149.85, 11, 703811, 'Budgeting Basics', 0.97);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('GDL^B', 274.22, 274.56, 9, 535597, 'Wealth Wisdom', 0.6);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('PSA^B', 844.16, 846.68, 7, 606146, 'Money Matters', 0.53);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('EEI', 54.8, 57.21, 3, 187533, 'Financial Foundations', 0.78);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('DCP', 143.3, 143.59, 9, 913524, 'Financial Foundations', 0.52);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('NTAP', 104.05, 106.77, 9, 969319, 'Money Matters', 0.6);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('ANET', 752.39, 754.96, 11, 137100, 'Wealth Wisdom', 0.69);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('STAA', 694.41, 694.68, 10, 392544, 'Budgeting Basics', 0.33);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('RDCM', 67.73, 68.01, 2, 685722, 'Money Matters', 0.16);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('SDRL', 349.13, 350.39, 13, 616381, 'Wealth Wisdom', 0.63);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('RDI', 134.26, 136.82, 6, 910973, 'Financial Foundations', 0.12);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('CAFD', 823.51, 824.87, 11, 291488, 'Money Matters', 0.44);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('QVCA', 569.03, 569.61, 15, 815034, 'Wealth Wisdom', 0.4);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('CODI', 541.47, 541.49, 1, 971533, 'Investment Insights', 0.1);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('PLNT', 604.68, 605.64, 8, 725113, 'Budgeting Basics', 0.32);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('VIVE', 171.85, 172.34, 11, 835238, 'Investment Insights', 0.17);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('CFC^B', 893.65, 896.01, 5, 208738, 'Wealth Wisdom', 0.62);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('TSI', 644.04, 646.61, 4, 574570, 'Budgeting Basics', 0.78);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('IOSP', 662.99, 665.86, 8, 657705, 'Money Matters', 0.88);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('CNNX', 790.09, 792.91, 5, 930483, 'Financial Foundations', 0.76);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('WMAR', 205.16, 205.7, 3, 331198, 'Wealth Wisdom', 0.64);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('NAVI', 312.39, 314.26, 6, 632658, 'Investment Insights', 0.93);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('CAMP', 172.55, 175.48, 8, 803892, 'Financial Foundations', 0.19);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('RGNX', 137.26, 139.04, 15, 349288, 'Financial Foundations', 0.58);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('AAON', 226.69, 227.53, 13, 385197, 'Investment Insights', 0.99);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('DVMT', 529.18, 529.39, 2, 326251, 'Financial Foundations', 0.33);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('BRCD', 171.76, 172.17, 2, 595732, 'Money Matters', 0.68);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('CDNS', 874.28, 874.71, 6, 570018, 'Wealth Wisdom', 0.16);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('NRCIA', 669.3, 672.15, 8, 685032, 'Financial Foundations', 0.21);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('MRVL', 333.32, 335.31, 10, 35984, 'Financial Foundations', 0.88);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('AA', 790.12, 791.74, 10, 918092, 'Budgeting Basics', 0.97);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('CLACU', 154.48, 154.9, 14, 771235, 'Financial Foundations', 0.77);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('VALX', 553.59, 556.2, 4, 823926, 'Wealth Wisdom', 0.93);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('CRM', 459.99, 460.83, 10, 945963, 'Investment Insights', 0.47);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('WPRT', 347.34, 347.42, 6, 420912, 'Wealth Wisdom', 0.76);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('BAP', 470.65, 472.82, 8, 250845, 'Money Matters', 0.2);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('MHNC', 559.63, 559.98, 5, 298065, 'Money Matters', 0.98);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('ELU', 332.64, 334.69, 9, 218463, 'Investment Insights', 0.87);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('JDD', 634.99, 636.36, 10, 273300, 'Money Matters', 0.32);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('XCRA', 84.39, 85.38, 7, 835779, 'Financial Foundations', 0.17);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('ROG', 491.83, 492.06, 6, 133828, 'Money Matters', 0.86);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('VMO', 887.97, 888.17, 2, 449919, 'Financial Foundations', 0.93);
insert into stock (ticker, bidPrice, askPrice, eps, volume, name, beta) values ('CRVL', 287.0, 288.7, 3, 602349, 'Investment Insights', 0.1);

# Student

insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (1, 16, 'Perl', 'Hughs', 'phughs0@networksolutions.com', 1, 'http://dummyimage.com/107x100.png/5fa2dd/ffffff', '69/0/6116');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (2, 31, 'Andriette', 'MacMenemy', 'amacmenemy1@surveymonkey.com', 3, 'http://dummyimage.com/132x100.png/ff4444/ffffff', '26/61/3044');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (3, 21, 'Duffie', 'Speight', 'dspeight2@cbslocal.com', 2, 'http://dummyimage.com/141x100.png/dddddd/000000', '83/99/8471');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (4, 19, 'Laurena', 'Yexley', 'lyexley3@elegantthemes.com', 4, 'http://dummyimage.com/184x100.png/ff4444/ffffff', '5/56/0569');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (5, 26, 'Madelin', 'Varty', 'mvarty4@cornell.edu', 4, 'http://dummyimage.com/148x100.png/cc0000/ffffff', '5/97/4310');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (6, 2, 'Edwin', 'Kollatsch', 'ekollatsch5@goo.ne.jp', 4, 'http://dummyimage.com/125x100.png/5fa2dd/ffffff', '3/02/6651');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (7, 48, 'Allie', 'Walkden', 'awalkden6@harvard.edu', 1, 'http://dummyimage.com/186x100.png/ff4444/ffffff', '2/34/0470');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (8, 39, 'Briant', 'Castiglio', 'bcastiglio7@wufoo.com', 1, 'http://dummyimage.com/121x100.png/dddddd/000000', '93/1/4241');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (9, 23, 'Petronilla', 'Banner', 'pbanner8@themeforest.net', 4, 'http://dummyimage.com/195x100.png/5fa2dd/ffffff', '5/09/8789');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (10, 8, 'Kareem', 'De Paoli', 'kdepaoli9@yahoo.com', 3, 'http://dummyimage.com/196x100.png/5fa2dd/ffffff', '48/1/4235');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (11, 15, 'Tani', 'Gaskins', 'tgaskinsa@salon.com', 3, 'http://dummyimage.com/217x100.png/dddddd/000000', '9/1/6768');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (12, 29, 'Rorke', 'Hatherell', 'rhatherellb@issuu.com', 1, 'http://dummyimage.com/103x100.png/ff4444/ffffff', '3/25/6166');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (13, 6, 'Avery', 'Chatto', 'achattoc@amazon.co.uk', 3, 'http://dummyimage.com/233x100.png/cc0000/ffffff', '22/5/7110');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (14, 12, 'Lawrence', 'Hymus', 'lhymusd@guardian.co.uk', 1, 'http://dummyimage.com/198x100.png/cc0000/ffffff', '33/58/9965');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (15, 45, 'Marketa', 'Mabbutt', 'mmabbutte@sciencedaily.com', 4, 'http://dummyimage.com/173x100.png/ff4444/ffffff', '09/1/8767');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (16, 48, 'Rabi', 'Bogies', 'rbogiesf@google.nl', 3, 'http://dummyimage.com/179x100.png/dddddd/000000', '9/93/0874');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (17, 24, 'Stuart', 'Bettanay', 'sbettanayg@netscape.com', 1, 'http://dummyimage.com/243x100.png/dddddd/000000', '1/0/1488');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (18, 42, 'Michel', 'Cough', 'mcoughh@4shared.com', 2, 'http://dummyimage.com/111x100.png/cc0000/ffffff', '0/7/3430');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (19, 11, 'Jonathan', 'Nyssen', 'jnysseni@google.de', 1, 'http://dummyimage.com/207x100.png/ff4444/ffffff', '5/40/7145');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (20, 23, 'Bernie', 'Georgiev', 'bgeorgievj@skype.com', 1, 'http://dummyimage.com/113x100.png/dddddd/000000', '45/6/9762');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (21, 31, 'Estrella', 'Croose', 'ecroosek@google.nl', 3, 'http://dummyimage.com/130x100.png/dddddd/000000', '9/37/7991');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (22, 8, 'Ashil', 'Adlem', 'aadleml@miibeian.gov.cn', 1, 'http://dummyimage.com/138x100.png/5fa2dd/ffffff', '4/8/9565');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (23, 4, 'Carma', 'Dillinton', 'cdillintonm@hao123.com', 2, 'http://dummyimage.com/215x100.png/dddddd/000000', '4/1/0263');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (24, 26, 'Javier', 'Petzold', 'jpetzoldn@jugem.jp', 2, 'http://dummyimage.com/153x100.png/5fa2dd/ffffff', '2/5/5581');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (25, 48, 'Manfred', 'Brumfitt', 'mbrumfitto@google.cn', 4, 'http://dummyimage.com/182x100.png/ff4444/ffffff', '1/80/2632');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (26, 30, 'Kaspar', 'Draycott', 'kdraycottp@mail.ru', 4, 'http://dummyimage.com/130x100.png/cc0000/ffffff', '3/2/0214');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (27, 4, 'Dicky', 'Eve', 'deveq@tmall.com', 1, 'http://dummyimage.com/103x100.png/dddddd/000000', '34/1/1781');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (28, 24, 'Ursulina', 'Jedryka', 'ujedrykar@taobao.com', 4, 'http://dummyimage.com/188x100.png/5fa2dd/ffffff', '9/78/6300');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (29, 48, 'Leanora', 'Van Brug', 'lvanbrugs@networksolutions.com', 2, 'http://dummyimage.com/141x100.png/dddddd/000000', '3/15/6179');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (30, 44, 'Carri', 'Gstudent_iddins', 'cgstudent_iddinst@princeton.edu', 4, 'http://dummyimage.com/228x100.png/5fa2dd/ffffff', '2/82/7591');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (31, 37, 'Ingra', 'MacKill', 'imackillu@tumblr.com', 1, 'http://dummyimage.com/219x100.png/dddddd/000000', '7/1/2754');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (32, 28, 'Marney', 'Sarfass', 'msarfassv@cdc.gov', 3, 'http://dummyimage.com/160x100.png/cc0000/ffffff', '4/81/1879');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (33, 14, 'Lindon', 'Stanett', 'lstanettw@patch.com', 2, 'http://dummyimage.com/161x100.png/5fa2dd/ffffff', '61/11/4211');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (34, 30, 'Isabelle', 'Dundredge', 'student_idundredgex@usa.gov', 3, 'http://dummyimage.com/202x100.png/5fa2dd/ffffff', '7/1/0117');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (35, 16, 'Mitch', 'Menichini', 'mmenichiniy@squstudent_idoo.com', 1, 'http://dummyimage.com/210x100.png/cc0000/ffffff', '8/4/0779');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (36, 22, 'Emmery', 'Bilney', 'ebilneyz@soup.io', 3, 'http://dummyimage.com/155x100.png/5fa2dd/ffffff', '5/7/7675');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (37, 40, 'Wilmar', 'Syrett', 'wsyrett10@cdc.gov', 4, 'http://dummyimage.com/152x100.png/ff4444/ffffff', '6/8/7720');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (38, 14, 'Lyell', 'Loffel', 'lloffel11@sakura.ne.jp', 1, 'http://dummyimage.com/138x100.png/dddddd/000000', '99/01/0411');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (39, 42, 'Andi', 'Franklen', 'afranklen12@weibo.com', 3, 'http://dummyimage.com/221x100.png/dddddd/000000', '7/54/6119');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (40, 24, 'Zora', 'Mityukov', 'zmityukov13@about.com', 3, 'http://dummyimage.com/200x100.png/ff4444/ffffff', '18/5/0171');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (41, 3, 'Rozele', 'Ibbett', 'ribbett14@adobe.com', 4, 'http://dummyimage.com/120x100.png/5fa2dd/ffffff', '85/9/0562');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (42, 49, 'Karylin', 'Bamblett', 'kbamblett15@google.cn', 4, 'http://dummyimage.com/197x100.png/cc0000/ffffff', '6/74/9160');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (43, 40, 'Saleem', 'Timewell', 'stimewell16@wufoo.com', 2, 'http://dummyimage.com/116x100.png/cc0000/ffffff', '96/38/2076');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (44, 48, 'Chilton', 'Ferre', 'cferre17@cornell.edu', 3, 'http://dummyimage.com/222x100.png/cc0000/ffffff', '38/3/9344');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (45, 28, 'Renae', 'Wellum', 'rwellum18@google.com.hk', 2, 'http://dummyimage.com/222x100.png/5fa2dd/ffffff', '42/9/4223');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (46, 40, 'Tiebold', 'Carrodus', 'tcarrodus19@pen.io', 2, 'http://dummyimage.com/115x100.png/dddddd/000000', '0/88/3442');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (47, 40, 'Britt', 'Armsden', 'barmsden1a@ow.ly', 2, 'http://dummyimage.com/247x100.png/5fa2dd/ffffff', '7/33/3539');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (48, 46, 'Jefferson', 'Ugoni', 'jugoni1b@columbia.edu', 3, 'http://dummyimage.com/242x100.png/dddddd/000000', '1/25/0757');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (49, 38, 'Douglas', 'Grent', 'dgrent1c@github.com', 3, 'http://dummyimage.com/223x100.png/cc0000/ffffff', '9/5/7613');
insert into student (student_id, recruiter_id, firstName, lastName, email, eduLevel, resumePath, gradDate) values (50, 43, 'Rodrick', 'Dudenie', 'rdudenie1d@eventbrite.com', 3, 'http://dummyimage.com/127x100.png/dddddd/000000', '01/4/9717');
