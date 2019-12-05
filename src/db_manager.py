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
    connected = False

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
            self.connected = True
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

    def get_stations(self):
        if not self.connected:
            return '-1'
        with self.connection:
            cur = self.connection.cursor()
            command = "CALL get_stationIDs()"
            cur.execute(command)
            rows = cur.fetchall()
            stations = []
            for row in rows:
                stations.append(str(row[0]))
            return stations

    def call_procedure(self, procedure):
        with self.connection:
            cur = self.connection.cursor()
            print("Executing: {}".format(procedure))
            cur.execute(procedure)
            return cur.fetchall()

    def print_all(self, ftype):
        if self.connection is None:
            return False
        with self.connection:
            cur = self.connection.cursor()
            cur.execute("CALL print_all_info('{}')".format(ftype))
            print("Printing from dbm")
            rows = cur.fetchall()
            for row in rows:
                print(row)

            return rows

    def delete(self, idn):
        if self.connection is None:
            return False
        with self.connection:
            cur = self.connection.cursor()
            cur.execute("CALL delete_reading('{}')".format(idn))

    def update(self, idn, field_no, new_val):
        if self.connection is None:
            return False
        with self.connection:
            cur = self.connection.cursor()
            cur.execute("CALL edit_read_field({}, {}, {})".format(
                idn, field_no, new_val))
