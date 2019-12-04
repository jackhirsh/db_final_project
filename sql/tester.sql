USE climate;
/*
CALL print_all_info('precipitation');
CALL add_precipitation_read('1990-09-01','daily',1,10);
CALL print_all_info('precipitation');

 */
-- adding some values
call add_station('petersburg 2',-98,48,466);
call add_station('chicago ohare international',-88,42,202);
call add_time('daily','2010-01-01');
call add_temperature_read('2010-01-01','daily',1,-178,-311,-245);
call add_precipitation_read('2010-01-01','daily',1,0);
call add_temperature_read('2010-01-01','annual',1,493,282,300);
call add_precipitation_read('2010-01-01','annual',1,2022);