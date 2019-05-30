import pdfkit
import os
import jinja2
from connection import connection, cursor
from psycopg2 import Error
templateLoader = jinja2.FileSystemLoader(searchpath="./")
templateEnv = jinja2.Environment(loader=templateLoader)
TEMPLATE_FILE = "index_template.html"
template = templateEnv.get_template(TEMPLATE_FILE)

def create_questions_table():
    if not os.path.exists('data'):
        os.makedirs('data')

    if not os.path.exists('reports'):
        os.makedirs('reports')

    # questions_column_names = os.popen('head -1 %s' % os.path.join(os.getcwd(), 'data/questions.csv')).read()
    with open('data/questions.csv', 'r') as f:
        questions_column_names = f.readline()


    # grades_column_names = os.popen('head -1 %s' % os.path.join(os.getcwd(), 'data/grades.csv')).read()
    with open('data/grades.csv', 'r') as f:
        grades_column_names = f.readline()


    # registr_column_names = os.popen('head -1 %s' % os.path.join(os.getcwd(), 'data/registr.csv')).read()
    with open('data/registr.csv', 'r') as f:
        registr_column_names = f.readline()



    with open('create_questions_table.sql', 'r') as f:
        postgreSQL_create_questions_table = ' '.join(f.readlines()) % (
            questions_column_names, 
            os.path.join(os.getcwd(), 'data/questions.csv'),
            grades_column_names, 
            os.path.join(os.getcwd(), 'data/grades.csv'),
            registr_column_names, 
            os.path.join(os.getcwd(), 'data/registr.csv'),
            )

    return cursor.execute(postgreSQL_create_questions_table)

try:
    question_titles = {}
    course_names = {}

    # print(create_questions_table())

    cursor.execute("select id, title from question_titles") 
    question_title_records = cursor.fetchall() 
    for row in question_title_records:
        question_titles[row[0]] = row[1]


    cursor.execute("select id, name, code from course_names") 
    course_name_records = cursor.fetchall() 
    for row in course_name_records:
        course_names[row[0]] = (row[1], row[2])

    if not os.path.exists('reports'):
        os.makedirs('reports')

    cursor.execute("select DISTINCT dep_code_f from questions")
    deps = cursor.fetchall()
    for dep in deps:
        if not os.path.exists('reports/%s' % dep[0]):
            os.makedirs('reports/%s' % dep[0])

    cursor.execute("select distinct practice_instructor from (select DISTINCT practice_instructor from questions UNION (select DISTINCT lecturer_instructor from questions))s")
    names_list = [i[0] for i in cursor.fetchall()]
    print(len(names_list))
    if len(names_list)%10 == 0:
        n = len(names_list)//10
    else:
        n = len(names_list)//10 + 1
    for i in range(n):
        names_list[i:i+10] = [names_list[i:i+10]]
    for i in range(len(names_list[-1])):
        if names_list[-1][i] is None:
            names_list[-1][i] = ''
    names_list = [['Azamat Zhamanov', 'asdfds']]
    with open('output.txt', 'w') as wf:
        for names in names_list:
            with open(os.path.join(os.getcwd(), 'Percentages.sql'), 'r') as f:
                postgreSQL_select_Query = ' '.join(f.readlines())
            cursor.execute(postgreSQL_select_Query.format(names=tuple(names)))
            result_records = cursor.fetchall() 

            result = {}
            prev_key = None
            participated_students_count = 0
            wf.write('{TEACHER NAMES} %s\n'%str(names))
            for row in result_records + [(None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None, None)]:
                key = (row[0], row[1], row[2], row[3], row[20])
                wf.write('%s\n'%str((key, row[20], row[21])))
                if key not in result:
                    if result:
                        outputText = template.render(
                            results=result[prev_key], 
                            question_titles=question_titles, 
                            instructor_name=prev_key[0],
                            course_name=course_names[prev_key[2]][0],
                            course_code=course_names[prev_key[2]][1],
                            type=prev_key[3],
                            statistics=statistics,
                            total_students_count=total_students_count,
                            participated_students_count=int(participated_students_count),
                            class_=class_, 
                            credits=credits
                            )

                        if not os.path.exists('reports/%s/%s' % (prev_key[1], prev_key[0])):
                            os.makedirs('reports/%s/%s' % (prev_key[1], prev_key[0]))
                        if not os.path.exists('reports/%s/%s/%s' % (prev_key[1], prev_key[0], class_)):
                            os.makedirs('reports/%s/%s/%s' % (prev_key[1], prev_key[0], class_))
                        pdfkit.from_string(
                            outputText,
                            'reports/%s/%s/%s/%s %s.pdf'%(prev_key[1], prev_key[0], class_, course_names[prev_key[2]][1], 'Practice' if prev_key[3] == 0 else 'Lecture'),
                            options={'orientation': 'Portrait', 'page-size': 'A4', 'dpi': 500}
                        )
                        del result[prev_key]
                        del outputText
                    result[key] = []
                    prev_key = key
                    participated_students_count = 0
                    statistics = (row[11], row[12], row[13], row[14], row[15], row[16], row[17])
                    if row[18]:
                        total_students_count = row[18]
                    elif row[19]:
                        total_students_count = row[19]
                    else:
                        total_students_count = 'unknown'
                    class_ = row[20]
                    credits = row[21]
                    
                if not any(key):
                    break
                result[key].append((
                    row[4], row[5], row[6], row[7], row[8], row[9], row[10]
                ))
                participated_students_count = max(participated_students_count, row[10])
except (Error) as error :
    print ("Error while fetching data from PostgreSQL", error)
finally:
    if(connection):
        cursor.close()
        connection.close()
        print("PostgreSQL connection is closed")