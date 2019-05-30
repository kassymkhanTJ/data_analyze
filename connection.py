import psycopg2
connection = None
try:
    connection = psycopg2.connect(user = "kassymkhantorgayev",
                                  password = "",
                                  host = "127.0.0.1",
                                  port = "5432",
                                  database = "datamorgana2")
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