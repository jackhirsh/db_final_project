import pymysql
from getpass import getpass, getuser

class DBManager:
    connection = None
    host = 'localhost'
    user = None
    password = None
    db = 'climate'
    debug = None

    def __init__(self, **kwargs):
        self.debug = True

    def create_connection(self):
            self.connection = pymysql.connect(
                host=self.host,
                user=self.user,
                password=self.password,
                db=self.db
            )

    def set_login(self, user, password):
        self.user = user
        self.password = password

    def print_all_info(self, weatherType):
        with self.connection:
            cur = self.connection.cursor()
            cur.execute("CALL print_all_info('{}')".format(weatherType))
            all_info = cur.fetchone()
            print(all_info)
