USE climate;

-- CALL add_station('Test station', 10, 20, 30);
-- CALL get_stationIDs();

CALL print_all_info('precipitation');
CALL print_all_info('wind');
CALL print_all_info('temperature');

SELECT * from precipitation;
SELECT * from wind;
SELECT * from temperature;