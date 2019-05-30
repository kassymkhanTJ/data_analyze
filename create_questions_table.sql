BEGIN;

drop table IF EXISTS questions;
drop table IF EXISTS question_titles;
drop SEQUENCE IF EXISTS question_title_seq;
drop table IF EXISTS grades;
drop table IF EXISTS registr;
drop table IF EXISTS course_names;
drop SEQUENCE IF EXISTS course_name_seq;


Create table questions(
QUESTION_TITLE_EN TEXT NULL,
ANSWER_TITLE_EN TEXT NULL,
COURSE_CODE TEXT NULL,
COURSE_TITLE_EN TEXT NULL,
LECTURER_INSTRUCTOR TEXT NULL,
PRACTICE_INSTRUCTOR TEXT NULL,
GENDER_TITLE_EN TEXT NULL,
AGE FLOAT NULL,
CLASS INTEGER NULL,
EDU_LEVEL TEXT NULL,
DEP_CODE_F TEXT NULL,
SPECIALITY_CIPHER TEXT NULL,
EDU_LANG TEXT NULL,
SPECIALITY_TITLE_EN TEXT NULL);




copy questions(%s) from '%s' WITH DELIMITER ',' CSV HEADER encoding 'windows-1251';



update  questions set
QUESTION_TITLE_EN=trim(QUESTION_TITLE_EN),
ANSWER_TITLE_EN=trim(ANSWER_TITLE_EN),
COURSE_CODE=trim(COURSE_CODE),
COURSE_TITLE_EN=trim(COURSE_TITLE_EN),
LECTURER_INSTRUCTOR=trim(LECTURER_INSTRUCTOR),
PRACTICE_INSTRUCTOR=trim(PRACTICE_INSTRUCTOR),
GENDER_TITLE_EN=trim(GENDER_TITLE_EN),
EDU_LEVEL=trim(EDU_LEVEL),
DEP_CODE_F=trim(DEP_CODE_F),
SPECIALITY_CIPHER=trim(SPECIALITY_CIPHER),
EDU_LANG=trim(EDU_LANG),
SPECIALITY_TITLE_EN=trim(SPECIALITY_TITLE_EN);


-- Create questions name table
create table question_titles(id int PRIMARY KEY, title TEXT, type integer);

create sequence question_title_seq;
alter table question_titles alter id set default nextval('question_title_seq');

insert into question_titles(title, type) 
	select distinct QUESTION_TITLE_EN, case when(QUESTION_TITLE_EN like 'Practice%%') then 0 else 1 end "type" from questions;


ALTER TABLE questions add column question_id int;

ALTER TABLE questions ADD CONSTRAINT questions_question_titles_fkey FOREIGN KEY (question_id) REFERENCES question_titles(id)  ON UPDATE CASCADE ON DELETE CASCADE;


update questions set question_id = s.id from (select id, title from question_titles) AS s WHERE trim(s.title)=trim(questions.QUESTION_TITLE_EN);
update question_titles set title = REPLACE(title, 'Practice. ', '') where title LIKE 'Practice%%';
update question_titles set title = REPLACE(title, 'Lecture. ', '') where title LIKE 'Lecture%%';





-- Create course name table

create table course_names(id int PRIMARY KEY, name VARCHAR(200), code varchar(10));

create sequence course_name_seq;
alter table course_names alter id set default nextval('course_name_seq');

insert into course_names(code, name) select distinct course_code, course_title_en from questions;


ALTER TABLE questions add column course_id int;

ALTER TABLE questions ADD CONSTRAINT questions_course_names_fkey FOREIGN KEY (course_id) REFERENCES course_names(id)  ON UPDATE CASCADE ON DELETE CASCADE;


update questions set course_id = s.id from (select id, code from course_names) AS s WHERE trim(s.code)=trim(questions.course_code);





-- Create grades name table

create table grades(
	EDU_LEVEL varchar(200) null,
	DEP_CODE_F varchar(200) null,
	DEP_CODE varchar(200) null,
	PROG_CODE varchar(200) null,
	SPECIALITY varchar(200) null,
	CLASS integer,
	CODE varchar(200) null,
	TITLE varchar(200) null,
	CREDITS integer,
	TEACHER varchar(200) null,
	MT1 integer,
	MT2 integer,
	FIN integer,
	GRADE integer,
	LG varchar(200) null);

copy grades(%s) from '%s' WITH DELIMITER ',' CSV HEADER;


update grades set
EDU_LEVEL=trim(EDU_LEVEL),
DEP_CODE_F=trim(DEP_CODE_F),
DEP_CODE=trim(DEP_CODE),
PROG_CODE=trim(PROG_CODE),
SPECIALITY=trim(SPECIALITY),
CODE=trim(CODE),
TITLE=trim(TITLE),
TEACHER=trim(TEACHER),
LG=trim(LG);

ALTER TABLE grades add column course_id int;
ALTER TABLE grades ADD CONSTRAINT grades_course_names_fkey FOREIGN KEY (course_id) REFERENCES course_names(id)  ON UPDATE CASCADE ON DELETE CASCADE;
update grades set course_id = s.id from (select id, code from course_names) AS s WHERE trim(s.code)=trim(grades.CODE);




-- Create registr name table

create table registr(
YEAR integer null,
TERM integer null,
EDU_LEVEL varchar(200) null,
DEP_CODE_F varchar(200) null,
DEP_CODE varchar(200) null,
CIPHER varchar(200) null,
PROG_CODE varchar(200) null,
SPECIALITY varchar(200) null,
PERIOD_COUNT integer null,
EDU_LANG varchar(200) null,
CLASS integer null,
TYPE varchar(200) null,
REPEATS_YEAR integer null,
STUD_ID varchar(200) null,
NAME varchar(200) null,
SURNAME varchar(200) null,
DERS_KOD varchar(200) null,
COURSE_TITLE varchar(200) null,
CREDITS integer null,
ECTS integer null,
COURSE_TYPE varchar(200) null,
SECTION varchar(200) null,
TEACHER varchar(200) null,
REF_TYPE varchar(200) null,
COURSE_TERM integer null,
REPEAT varchar(200) null,
FINANCIAL_DEBT integer null,
ACADEMIC_DEBT integer null,
POOR_ATTENDANCE integer null);

copy registr(%s) from '%s' WITH DELIMITER ',' CSV HEADER;

update registr set
EDU_LEVEL=trim(EDU_LEVEL),
DEP_CODE_F=trim(DEP_CODE_F),
DEP_CODE=trim(DEP_CODE),
CIPHER=trim(CIPHER),
PROG_CODE=trim(PROG_CODE),
SPECIALITY=trim(SPECIALITY),
EDU_LANG=trim(EDU_LANG),
TYPE=trim(TYPE),
STUD_ID=trim(STUD_ID),
NAME=trim(NAME),
SURNAME=trim(SURNAME),
DERS_KOD=trim(DERS_KOD),
COURSE_TITLE=trim(COURSE_TITLE),
COURSE_TYPE=trim(COURSE_TYPE),
SECTION=trim(SECTION),
TEACHER=trim(TEACHER),
REF_TYPE=trim(REF_TYPE),
REPEAT=trim(REPEAT);


ALTER TABLE registr add column course_id int;
ALTER TABLE registr ADD CONSTRAINT registr_course_names_fkey FOREIGN KEY (course_id) REFERENCES course_names(id)  ON UPDATE CASCADE ON DELETE CASCADE;
update registr set course_id = s.id from (select id, code from course_names) AS s WHERE trim(s.code)=trim(registr.DERS_KOD);




COMMIT;


-- select distinct practice_instructor from questions left join registr on questions.practice_instructor=registr.teacher where registr.teacher is null;