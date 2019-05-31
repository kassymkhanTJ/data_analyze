import psycopg2
connection = None

# Write here your own info
USER = "kassymkhantorgayev"
PASSWORD = ""
HOST = "127.0.0.1"
PORT = "5432"
DATABASE = "sdu_reports"

try:
    connection = psycopg2.connect(user = USER,
                                  password = PASSWORD,
                                  host = HOST,
                                  port = PORT,
                                  database = DATABASE)
    cursor = connection.cursor()
    # Print PostgreSQL Connection properties
    # Print PostgreSQL version
except (Exception, psycopg2.Error) as error :
    print ("Error while connecting to PostgreSQL", error)
finally:
    #closing database connection.
        # if(connection):
        #     cursor.close()
        #     connection.close()
        #     print("PostgreSQL connection is closed")
        pass