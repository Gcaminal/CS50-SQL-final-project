-- 1. Find routes associated with a particular peak.
-- Replace :peak_id with the desired peak ID.
SELECT r.route_id, r.name, r.distance_km, r.difficulty
FROM ROUTE AS r
JOIN ROUTE_PEAK AS rp ON rp.route_id = r.route_id
WHERE rp.peak_id = :peak_id
ORDER BY r.name;

-- 2. Find routes that cross a particular massif.
-- Replace :massif_id with the desired massif ID.
SELECT r.route_id, r.name, r.distance_km, r.difficulty
FROM ROUTE AS r
JOIN ROUTE_MASSIF AS rm ON rm.route_id = r.route_id
WHERE rm.massif_id = :massif_id
ORDER BY r.name;

-- 3. List mountain huts associated with a route, including distance from its start.
-- Replace :route_id with the desired route ID.
SELECT h.hut_id, h.name, h.altitude_m, h.service_type, h.capacity,
       hrt.distance_from_start_km
FROM MOUNTAIN_HUT AS h
JOIN MOUNTAIN_HUT_ROUTE AS hrt ON hrt.hut_id = h.hut_id
WHERE hrt.route_id = :route_id
ORDER BY hrt.distance_from_start_km;

-- 4. List species associated with a route.
-- Replace :route_id with the desired route ID.
SELECT s.common_name, s.scientific_name, s.species_type,
       s.conservation_status, rs.observations
FROM SPECIES AS s
JOIN ROUTE_SPECIES AS rs ON rs.species_id = s.species_id
WHERE rs.route_id = :route_id
ORDER BY s.common_name;

-- 5. Show public activities, respecting both profile and activity visibility.
SELECT user_name, route_name, activity_date, activity_status,
       actual_distance_km, duration_min, rating
FROM public_user_activity
ORDER BY activity_date DESC;

-- 6. Show a user's hiking history.
-- Replace :user_id with the desired user ID.
SELECT r.name AS route_name, ur.activity_date, ur.status,
       ur.actual_distance_km, ur.duration_min, ur.rating
FROM USER_ROUTE AS ur
JOIN ROUTE AS r ON r.route_id = ur.route_id
WHERE ur.user_id = :user_id
ORDER BY ur.activity_date DESC;

-- 7. Find peaks above a specified altitude.
-- Replace :minimum_altitude with an altitude in metres.
SELECT p.name, p.altitude_m, p.prominence_m, m.name AS massif_name
FROM PEAK AS p
JOIN MASSIF AS m ON m.massif_id = p.massif_id
WHERE p.altitude_m >= :minimum_altitude
ORDER BY p.altitude_m DESC;

-- INSERT QUERIES

-- 8. Register a new user.
-- Store a securely generated password hash, never a plain-text password.
INSERT INTO USERS (name, email, password_hash, profile_description)
VALUES (:name, :email, :password_hash, :profile_description);

-- 9. Store a new massif.
INSERT INTO MASSIF (name, description, region, country)
VALUES (:name, :description, :region, :country);

-- 10. Store a new route.
INSERT INTO ROUTE (name, distance_km, elevation_gain_m, elevation_loss_m, difficulty, estimated_time_min, route_type, max_altitude_m, min_altitude_m, status, documentation_date, homologation)
VALUES (:name, :distance_km, :elevation_gain_m, :elevation_loss_m, :difficulty, :estimated_time_min, :route_type, :max_altitude_m, :min_altitude_m, :route_status, :documentation_date, :homologation);

-- 11. Store a new peak.
INSERT INTO PEAK (name, latitude, longitude, altitude_m, prominence_m, massif_id)
VALUES (:name, :latitude, :longitude, :altitude_m, :prominence_m, :massif_id);

-- 12. Store a new mountain hut.
INSERT INTO MOUNTAIN_HUT (name, latitude, longitude, altitude_m, service_type, capacity, seasonal_availability)
VALUES (:name, :latitude, :longitude, :altitude_m, :service_type, :capacity, :seasonal_availability);

-- 13. Store a new specie.
INSERT INTO SPECIES (common_name, scientific_name, conservation_status, species_type, ecosystem)
VALUES (:common_name, :scientific_name, :conservation_status, :species_type, :ecosystem);

-- 14. Record a hiking activity for an existing user and route.
INSERT INTO USER_ROUTE (
    user_id, route_id, activity_date, status,
    actual_distance_km, actual_elevation_gain_m, duration_min,
    rating, description, visibility
)
VALUES (
    :user_id, :route_id, :activity_date, :status,
    :actual_distance_km, :actual_elevation_gain_m, :duration_min,
    :rating, :description, :visibility
);

-- 15. Record a peak for an existing route.
INSERT INTO ROUTE_PEAK (
    route_id, peak_id
)
VALUES (
    :route_id, :peak_id
);

-- 16. Record a massif for an existing route.
INSERT INTO ROUTE_MASSIF (
    route_id, massif_id
)
VALUES (
    :route_id, :massif_id
);

-- 17. Record a mountain hut for an existing route.
INSERT INTO MOUNTAIN_HUT_ROUTE (
    hut_id, route_id, distance_from_start_km
)
VALUES (
    :hut_id, :route_id, :distance_from_start_km
);

-- 18. Record a specie for an existing route.
INSERT INTO ROUTE_SPECIES (
    route_id, species_id, observations
)
VALUES (
    :route_id, :species_id, :observations
);

-- UPDATE QUERIES

-- 19. Update a route's status.
-- Allowed values are Open, Closed, and Restricted.
UPDATE ROUTE
SET status = :new_status
WHERE route_id = :route_id;

-- 20. Update the visibility of one user's activity.
UPDATE USER_ROUTE
SET visibility = :new_visibility
WHERE user_route_id = :user_route_id
  AND user_id = :user_id;

-- DELETE QUERIES

-- 21. Delete one activity belonging to the specified user.
-- The user_id condition helps prevent deleting another user's activity.
DELETE FROM USER_ROUTE
WHERE user_route_id = :user_route_id
  AND user_id = :user_id;

-- 22. Remove a route-species association.
DELETE FROM ROUTE_SPECIES
WHERE route_id = :route_id
  AND species_id = :species_id;
