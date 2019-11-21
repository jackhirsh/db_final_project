import pymysql
host = 'localhost'
user = 'root'
password = 'root'
db = 'climate'


class DBManager:
    connection = None

    def __init__(self, **kwargs):
        # self.connection = pymysql.connect(
        #     host=host,
        #     user=user,
        #     password=password,
        #     db=db
        # )
        pass

    def call_procedure(self, name):
        with self.connection as con:
            cur = con.cursor()


if __name__ == "__main__":
    dbm = DBManager()
