WITH total AS ( 
	SELECT CASE WHEN(type = 1 or practice_instructor is null) THEN lecturer_instructor ELSE practice_instructor END instructor_name, Array_Agg(distinct lecturer_instructor) as lecturer_instructors, type, dep_code_f, course_id, question_id, COUNT(answer_title_en) AS answers_count, class FROM questions JOIN question_titles ON question_titles.id = questions.question_id GROUP BY instructor_name, dep_code_f, course_id, question_id, type, class
), g AS (
	select 
		COUNT(LG) filter (where LG LIKE 'A%') AS "A_count",
		COUNT(LG) filter (where LG LIKE 'B%') AS "B_count",
		COUNT(LG) filter (where LG LIKE 'C%') AS "C_count",
		COUNT(LG) filter (where LG LIKE 'D%') AS "D_count",
		COUNT(LG) filter (where LG LIKE 'F%') AS "F_count",
		COUNT(LG) filter (where LG LIKE 'NP%') AS "NP_count",
		COUNT(LG) filter (where LG LIKE 'P%') AS "P_count",
		course_id, 
		DEP_CODE_F,
		TEACHER,
		COUNT(*) AS all_count,
		class,
		credits
	from grades group by TEACHER, DEP_CODE_F, course_id, class, credits
), r AS (
	select count(*) as total_students_count, dep_code_f, course_id, teacher, class from registr group by course_id, dep_code_f, teacher, class
)


SELECT 
	o.instructor_name,
	o.dep_code_f,
	o.course_id,
	o.type,
	o.question_id,
	"excellent" / total * 100.0 AS "excellent",
	"satisfactory" / total * 100.0 AS "satisfactory",
	"good" / total * 100.0 AS "good",
	"poor" / total * 100.0 AS "poor",
	"not applicable" / total * 100.0 AS "not applicable",
	total,
	CASE WHEN(o.type=1) THEN SUM(g."A_count" )ELSE NULL END,
	CASE WHEN(o.type=1) THEN SUM(g."B_count" )ELSE NULL END,
	CASE WHEN(o.type=1) THEN SUM(g."C_count" )ELSE NULL END,
	CASE WHEN(o.type=1) THEN SUM(g."D_count" )ELSE NULL END,
	CASE WHEN(o.type=1) THEN SUM(g."F_count" )ELSE NULL END,
	CASE WHEN(o.type=1) THEN SUM(g."NP_count") ELSE NULL END,
	CASE WHEN(o.type=1) THEN SUM(g."P_count" )ELSE NULL END,
	g.all_count AS total_students_count,
	(
		SELECT total_students_count 
		FROM r
		WHERE o.course_id = r.course_id
			AND o.dep_code_f = r.dep_code_f
			AND o.instructor_name = r.teacher
			AND o.class = r.class
	) :: varchar(200) total_students_count_2,
	o.class,
	credits,
	lecturer_instructors
FROM (
	SELECT  DISTINCT ss.instructor_name,
			ss.dep_code_f,
			ss.course_id,
			ss.question_id,
			ss.type,
			SUM(ss."excellent") AS "excellent", 
			SUM(ss."satisfactory") AS "satisfactory", 
			SUM(ss."good") AS "good", 
			SUM(ss."poor") AS "poor", 
			SUM(ss."not applicable") AS "not applicable",
			ss.class,
			answers_count as total,
			lecturer_instructors
	FROM (
		SELECT instructor_name, 
			s.dep_code_f,
			s.course_id,
			s.question_id,
			s.type,
			CASE WHEN(s.answer_title_en = 'excellent') THEN s.answers_count ELSE 0 END "excellent",
			CASE WHEN(s.answer_title_en = 'satisfactory') THEN s.answers_count ELSE 0 END "satisfactory",
			CASE WHEN(s.answer_title_en = 'good') THEN s.answers_count ELSE 0 END "good",
			CASE WHEN(s.answer_title_en = 'poor') THEN s.answers_count ELSE 0 END "poor",
			CASE WHEN(s.answer_title_en = 'not applicable') THEN s.answers_count ELSE 0 END "not applicable",
			s.class
		FROM(
			SELECT CASE WHEN(type = 1 or practice_instructor is null) THEN lecturer_instructor ELSE practice_instructor END instructor_name,
					answer_title_en, 
					COUNT(answer_title_en) AS answers_count,
					dep_code_f,
					course_id,
					question_id,
					type,
					class
				FROM questions 
				JOIN question_titles ON question_titles.id = questions.question_id
				GROUP BY instructor_name, answer_title_en, dep_code_f, course_id, question_id, type, class, lecturer_instructor
				) s
				-- WHERE instructor_name in ('PhD Kanat Kozhakhmet', 'PhD Cemil Turan', 'Rashid Baimukashev', 'PhD Cemal Ozdemir', 'Ardak Shalkarbay-uly') 
				WHERE instructor_name in {names}
				ORDER by course_id, type
				-- WHERE instructor_name = 'Abdullah Almas' 
		) ss 
		JOIN total on total.instructor_name = ss.instructor_name
		            AND ss.dep_code_f = total.dep_code_f
		            AND ss.course_id = total.course_id
		            AND ss.question_id = total.question_id
					AND ss.class = total.class
		GROUP BY ss.instructor_name, ss.dep_code_f, ss.course_id, ss.question_id, ss.type, ss.class, total, lecturer_instructors
	ORDER BY ss.class, ss.instructor_name, ss.dep_code_f, ss.course_id, ss.type, ss.question_id, lecturer_instructors
	) o 
	LEFT JOIN g on g.course_id = o.course_id
			AND g.DEP_CODE_F = o.dep_code_f
			AND g.TEACHER = o.instructor_name
			AND g.class = o.class
	GROUP BY o.instructor_name, o.dep_code_f, o.course_id, o.question_id, o.type, o.class, total, lecturer_instructors,"excellent",
"satisfactory",
"good",
"poor",
"not applicable",
credits, 
total_students_count
ORDER BY o.class, o.instructor_name, o.dep_code_f, o.course_id, o.type, o.question_id
	-- LIMIT 1000;	










