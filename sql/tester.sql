USE climate;

CALL print_all_info('precipitation');
CALL add_precipitation_read('1990-09-01','daily',1,10);
CALL print_all_info('precipitation');
