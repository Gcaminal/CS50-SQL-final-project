-- recreate.sql: rebuilds the database, inserts sample data and sets the
-- parameters that queries.sql uses, so both files can run in one session:
--
--   $ sqlite3 hiking.db
--   sqlite> .read recreate.sql
--   sqlite> .read queries.sql
--
-- Safe to run repeatedly: it drops everything first and starts clean.

.echo off
.changes off
.headers on
.mode box

-- =====================================================================
-- 0) Clean start (children before parents, views first)
-- =====================================================================
PRAGMA foreign_keys = OFF;
DROP VIEW  IF EXISTS public_user_activity;
DROP VIEW  IF EXISTS route_details;
DROP TABLE IF EXISTS ROUTE_SPECIES;
DROP TABLE IF EXISTS MOUNTAIN_HUT_ROUTE;
DROP TABLE IF EXISTS ROUTE_MASSIF;
DROP TABLE IF EXISTS ROUTE_PEAK;
DROP TABLE IF EXISTS USER_ROUTE;
DROP TABLE IF EXISTS VARIANT;
DROP TABLE IF EXISTS PEAK;
DROP TABLE IF EXISTS SPECIES;
DROP TABLE IF EXISTS MOUNTAIN_HUT;
DROP TABLE IF EXISTS ROUTE;
DROP TABLE IF EXISTS MASSIF;
DROP TABLE IF EXISTS USERS;
PRAGMA foreign_keys = ON;

.read schema.sql

-- =====================================================================
-- 1) Entities without FK
-- =====================================================================

-- massif_id: 1 Pyrenees, 2 Montseny, 3 Sierra Nevada, 4 Maladeta
INSERT INTO MASSIF (name, description, region, country) VALUES
  ('Pyrenees',      'Mountain range between Spain and France',  'Catalonia', 'Spain/France'),
  ('Montseny',      'Pre-coastal massif and biosphere reserve', 'Catalonia', 'Spain'),
  ('Sierra Nevada', 'Highest massif in the Iberian Peninsula',  'Andalusia', 'Spain'),
  ('Maladeta',      'Massif holding the highest Pyrenean peaks', 'Aragon',   'Spain');

-- user_id: 1 Gerard, 2 Laia, 3 Marc (private profile)
INSERT INTO USERS (name, email, password_hash, profile_description, profile_visibility) VALUES
  ('Gerard', 'gerard@example.com', 'hash_example_1', 'Keen hiker',                   'public'),
  ('Laia',   'laia@example.com',   'hash_example_2', 'Weekend trail runner',         'public'),
  ('Marc',   'marc@example.com',   'hash_example_3', 'Birdwatcher and photographer', 'private');

-- route_id: 1 Aneto, 2 Pica d'Estats, 3 Turó de l'Home, 4 Mulhacén, 5 Maladeta
INSERT INTO ROUTE (name, distance_km, elevation_gain_m, elevation_loss_m, difficulty,
                   estimated_time_min, route_type, description, max_altitude_m,
                   min_altitude_m, status, documentation_date, homologation) VALUES
  ('Aneto Normal Route',              18.5, 1700, 1700, 'Very difficult', 600, 'Circular', 'Classic ascent via the Portillón',   3404, 1700, 'Open', '2024-06-01', 'PR'),
  ('Pica d''Estats from Areu',        16.0, 1600, 1600, 'Hard',           540, 'Linear',   'Highest summit in Catalonia',        3143, 1240, 'Open', '2024-07-15', NULL),
  ('Turó de l''Home from Santa Fe',    9.2,  800,  800, 'Moderate',       210, 'Linear',   'Beech forest to the Montseny summit', 1706, 1130, 'Open', '2023-10-10', 'PR'),
  ('Mulhacén from Hoya del Portillo', 20.0, 1300, 1300, 'Hard',           480, 'Circular', 'Highest peak of the Peninsula',      3479, 2150, 'Open', '2025-05-20', 'GR'),
  ('Maladeta from La Besurta',        14.0, 1400, 1400, 'Expert',         480, 'Linear',   'Glacier ascent, crampons required',  3308, 1900, 'Open', '2025-06-10', NULL);

-- species_id: 1 chamois, 2 vulture, 3 newt, 4 ibex, 5 saxifrage
INSERT INTO SPECIES (common_name, scientific_name, conservation_status, species_type, ecosystem) VALUES
  ('Pyrenean chamois',    'Rupicapra pyrenaica',  'LC', 'Animal', 'Alpine meadows'),
  ('Bearded vulture',     'Gypaetus barbatus',    'EN', 'Animal', 'Cliffs'),
  ('Montseny brook newt', 'Calotriton arnoldi',   'CR', 'Animal', 'Mountain streams'),
  ('Iberian ibex',        'Capra pyrenaica',      'LC', 'Animal', 'Rocky slopes'),
  ('Pyrenean saxifrage',  'Saxifraga longifolia', 'LC', 'Plant',  'Limestone walls');

-- hut_id: 1 Renclusa, 2 Vallferrera, 3 Poqueira, 4 Caldera, 5 Coronas
INSERT INTO MOUNTAIN_HUT (name, latitude, longitude, altitude_m, service_type, capacity, seasonal_availability) VALUES
  ('Refugi de la Renclusa', 42.6731,  0.6497, 2140, 'Guarded',   92, 'June-September'),
  ('Refugi de Vallferrera', 42.6403,  1.3797, 1940, 'Guarded',   34, 'June-September'),
  ('Refugio Poqueira',      37.0236, -3.3203, 2500, 'Guarded',   87, 'All year'),
  ('Refugio de la Caldera', 37.0478, -3.3369, 3030, 'Unguarded', 12, 'All year'),
  ('Refugio de Coronas',    42.6425,  0.6650, 2700, 'Emergency',  6, 'All year');

-- =====================================================================
-- 2) Entities with FK
-- =====================================================================

-- peak_id: 1 Aneto, 2 Pica d'Estats, 3 Turó de l'Home, 4 Mulhacén, 5 Veleta, 6 Maladeta
INSERT INTO PEAK (name, latitude, longitude, altitude_m, prominence_m, massif_id) VALUES
  ('Aneto',           42.6311,  0.6569, 3404, 2812, 4),
  ('Pica d''Estats',  42.6662,  1.3975, 3143, 1281, 1),
  ('Turó de l''Home', 41.7746,  2.4500, 1706,  975, 2),
  ('Mulhacén',        37.0533, -3.3113, 3479, 3285, 3),
  ('Veleta',          37.0564, -3.3661, 3396,  180, 3),
  ('Maladeta',        42.6458,  0.6303, 3308,  300, 4);

INSERT INTO VARIANT (main_route_id, name, reason, distance_km, description) VALUES
  (1, 'Aneto via Portillón Superior', 'Less crowded', 17.0, 'Skips the Renclusa hut section'),
  (4, 'Mulhacén from Trevélez',       'Longer approach', 28.0, 'Starts from the Alpujarra side');

-- user_route_id: 1..5 (4 hidden by private profile, 5 hidden by private activity)
INSERT INTO USER_ROUTE (user_id, route_id, activity_date, status, description,
                        actual_distance_km, actual_elevation_gain_m, duration_min, rating, visibility) VALUES
  (1, 1, '2025-07-12', 'Completed', 'Perfect weather',     18.9, 1720, 640, 5, 'Public'),
  (1, 3, '2025-10-05', 'Completed', 'Autumn colours',       9.4,  810, 200, 4, 'Public'),
  (2, 4, '2025-08-21', 'Completed', 'Sunrise at the top',  20.3, 1310, 455, 5, 'Public'),
  (3, 2, '2025-09-14', 'Attempted', 'Turned back at 2900m', 11.0, 1200, 380, 3, 'Public'),
  (2, 5, '2025-09-01', 'Abandoned', 'Storm on the glacier',  6.5,  700, 190, 2, 'Private');

-- =====================================================================
-- 3) Bridge tables (both sides must exist)
-- =====================================================================
INSERT INTO ROUTE_PEAK (route_id, peak_id) VALUES
  (1, 1), (2, 2), (3, 3), (4, 4), (4, 5), (5, 6);

INSERT INTO ROUTE_MASSIF (route_id, massif_id) VALUES
  (1, 1), (2, 1), (3, 2), (4, 3), (5, 1), (5, 4);

INSERT INTO MOUNTAIN_HUT_ROUTE (hut_id, route_id, distance_from_start_km) VALUES
  (1, 1, 2.5), (2, 2, 5.8), (3, 4, 6.0), (4, 4, 9.5), (1, 5, 2.5);

INSERT INTO ROUTE_SPECIES (route_id, species_id, observations) VALUES
  (1, 1, 'Herd seen near the Portillón'),
  (1, 2, 'Adult flying over the glacier'),
  (2, 5, 'On limestone walls'),
  (3, 3, 'Do not disturb streams'),
  (4, 4, 'Common near the summit'),
  (5, 1, 'Small group on the moraine');

-- =====================================================================
-- 4) Show every table
-- =====================================================================
.print ''
.print '=== USERS ==='
SELECT * FROM USERS;
.print '=== MASSIF ==='
SELECT * FROM MASSIF;
.print '=== ROUTE ==='
SELECT * FROM ROUTE;
.print '=== VARIANT ==='
SELECT * FROM VARIANT;
.print '=== PEAK ==='
SELECT * FROM PEAK;
.print '=== MOUNTAIN_HUT ==='
SELECT * FROM MOUNTAIN_HUT;
.print '=== SPECIES ==='
SELECT * FROM SPECIES;
.print '=== USER_ROUTE ==='
SELECT * FROM USER_ROUTE;
.print '=== ROUTE_PEAK ==='
SELECT * FROM ROUTE_PEAK;
.print '=== ROUTE_MASSIF ==='
SELECT * FROM ROUTE_MASSIF;
.print '=== MOUNTAIN_HUT_ROUTE ==='
SELECT * FROM MOUNTAIN_HUT_ROUTE;
.print '=== ROUTE_SPECIES ==='
SELECT * FROM ROUTE_SPECIES;

-- =====================================================================
-- 5) Parameters for queries.sql
-- Text values go as "'...'" so the shell stores them as SQL strings.
-- The same name is shared by every query that uses it (e.g. :name).
-- =====================================================================
.parameter init
.parameter clear

-- SELECT queries 1-7
.parameter set :peak_id 6
.parameter set :massif_id 4
.parameter set :route_id 1
.parameter set :user_id 1
.parameter set :minimum_altitude 3000

-- INSERT queries 8-13 (:name is shared by user, massif, route, peak and hut)
.parameter set :name "'Posets'"
.parameter set :email "'posets.fan@example.com'"
.parameter set :password_hash "'hash_example_4'"
.parameter set :profile_description "'New user'"
.parameter set :description "'Added from queries.sql'"
.parameter set :region "'Aragon'"
.parameter set :country "'Spain'"
.parameter set :distance_km 21.0
.parameter set :elevation_gain_m 1700
.parameter set :elevation_loss_m 1700
.parameter set :difficulty "'Hard'"
.parameter set :estimated_time_min 600
.parameter set :route_type "'Circular'"
.parameter set :max_altitude_m 3375
.parameter set :min_altitude_m 1700
.parameter set :route_status "'Open'"
.parameter set :documentation_date "'2025-06-15'"
.parameter set :homologation "'PR'"
.parameter set :latitude 42.6572
.parameter set :longitude 0.4369
.parameter set :altitude_m 3375
.parameter set :prominence_m 1307
.parameter set :service_type "'Guarded'"
.parameter set :capacity 40
.parameter set :seasonal_availability "'June-September'"
.parameter set :common_name "'Alpine marmot'"
.parameter set :scientific_name "'Marmota marmota'"
.parameter set :conservation_status "'LC'"
.parameter set :species_type "'Animal'"
.parameter set :ecosystem "'Alpine meadows'"

-- INSERT query 14 (creates user_route_id 6) and bridges 15-18
.parameter set :activity_date "'2025-10-20'"
.parameter set :status "'Completed'"
.parameter set :actual_distance_km 19.2
.parameter set :actual_elevation_gain_m 1650
.parameter set :duration_min 615
.parameter set :rating 5
.parameter set :visibility "'Public'"
.parameter set :hut_id 5
.parameter set :distance_from_start_km 7.0
.parameter set :species_id 5
.parameter set :observations "'Seen on rocky ledges'"

-- UPDATE / DELETE queries 19-22 (act on the activity created by query 14)
.parameter set :new_status "'Restricted'"
.parameter set :new_visibility "'Private'"
.parameter set :user_route_id 6

.print ''
.print '=== Parameters ready: now run  .read queries.sql ==='

-- Print each statement of queries.sql before its result
.echo on
