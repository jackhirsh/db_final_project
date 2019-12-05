USE climate;
/*
CALL print_all_info('precipitation');
CALL add_precipitation_read('1990-09-01','daily',1,10);
CALL print_all_info('precipitation');

 */
-- adding some values
-- need to recreate schema otherwise cant update same read (even if same values), there's a separate edit function to do that
call add_station('petersburg 2',-98,48,466);
call add_station('chicago ohare international',-88,42,202);
call add_time('daily','2010-01-01');
call add_temperature_read('2010-01-01','daily',1,-178,-311,-245);
call add_temperature_read('2010-01-03','daily',1,-178,-311,-245);
call add_temperature_read('2010-01-05','daily',1,-128,-321,-295);
call add_temperature_read('2010-01-01','daily',2,1,311,245);
call add_temperature_read('2010-01-18','daily',2,3,1,5);
call add_precipitation_read('2010-01-01','daily',1,0);
call add_precipitation_read('2010-02-01','daily',1,10);
call add_precipitation_read('2011-01-01','monthly',2,999);
call add_temperature_read('2010-01-01','annual',1,493,282,300);
call add_precipitation_read('2010-01-01','annual',1,2022);
call add_temperature_read('2011-05-01','monthly',1,333,111,222);
call add_precipitation_read('2015-01-01','annual',1,1999);
call add_wind_read('2010-01-01','daily',1,10,10,11,11,12);
call add_wind_read('2010-01-03','daily',2,101,101,111,111,121);