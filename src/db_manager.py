import pymysql
host = 'localhost:3306'
user = 'root'
password = 'root'
db = 'climate'


class DBManager:
    connection = None

    def __init__(self, **kwargs):
        self.connection = pymysql.connect(
            host=host,
            user=user,
            password=password,
            db=db
        )


if __name__ == "__main__":
    dbm = DBManager()
