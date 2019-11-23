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
        self.get_login()
        self.create_connection()
        self.call_procedure('test')

    def create_connection(self):
        self.connection = pymysql.connect(
            host=self.host,
            user=self.user,
            password=self.password,
            db=self.db
        )


    def call_procedure(self, name):
        with self.connection:
            try:
                cur = self.connection.cursor()
                cur.execute('SELECT * FROM location')
                print(cur.fetchone())
            except:
                print('ERROR: Call Failed')


    def get_login(self):
        self.user = input("Username: ")
        self.password = getpass(prompt='Password: ', stream=None)
