import pymysql
from getpass import getpass, getuser
import sys
from pymysql import err


class DBManager:
    connection = None
    host = None
    user = None
    password = None
    db = None
    debug = None

    def __init__(self, **kwargs):
        self.debug = True

    def create_connection(self):
        '''
        Creates the connection to the database, returns true if connected
        '''
        try:
            self.connection = pymysql.connect(
                host=self.host,
                user=self.user,
                password=self.password,
                db=self.db
            )
            return True
        except (err.InternalError, err.OperationalError):
            print("Database Error")
            return False

    def set_login(self, user, password, host='localhost', db='climate'):
        '''
        Sets the login information for the database
        '''
        self.user = user
        self.password = password
        self.host = host
        self.db = db

    def print_all_info(self, weatherType):
        '''
        Prints all rows for a given weather type
        '''
        with self.connection:
            cur = self.connection.cursor()
            cur.execute("CALL print_all_info('{}')".format(weatherType))
            all_info = cur.fetchall()
            print(all_info)

    def add_reading(self, date, station, level, read_time_type, weatherType='p'):
        '''
        adds a reading for the given type
        '''
        with self.connection:
            cur = self.connection.cursor()
            command = "CALL add_precipitation_read({})".format(
                date + ',' + read_time_type + ',' +
                str(station) + ',' + str(level)
            )
            cur.execute(command)
