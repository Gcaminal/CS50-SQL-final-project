-- Registered users and their profile visibility settings.
CREATE TABLE USERS (
    user_id INTEGER,
    name TEXT NOT NULL,
    registration_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    profile_description TEXT,
    profile_visibility TEXT NOT NULL DEFAULT 'public'
        CHECK (profile_visibility IN ('public', 'private')),
    PRIMARY KEY("user_id")
);

-- Main hiking routes and their general characteristics.
CREATE TABLE ROUTE (
    route_id INTEGER,
    name TEXT NOT NULL,
    distance_km REAL NOT NULL CHECK (distance_km > 0),
    elevation_gain_m INTEGER NOT NULL CHECK (elevation_gain_m >= 0),
    elevation_loss_m INTEGER NOT NULL CHECK (elevation_loss_m >= 0),
    difficulty TEXT NOT NULL
        CHECK (difficulty IN ('Easy', 'Moderate', 'Hard', 'Very difficult', 'Expert')),
    estimated_time_min INTEGER NOT NULL CHECK (estimated_time_min > 0),
    route_type TEXT NOT NULL CHECK (route_type IN ('Circular', 'Linear')),
    description TEXT,
    max_altitude_m INTEGER NOT NULL,
    min_altitude_m INTEGER NOT NULL CHECK (min_altitude_m <= max_altitude_m),
    status TEXT NOT NULL DEFAULT 'Open'
        CHECK (status IN ('Open', 'Closed', 'Restricted')),
    documentation_date TEXT,
    homologation TEXT,
    PRIMARY KEY("route_id")
);

-- Alternative versions of a main route.
CREATE TABLE VARIANT (
    variant_id INTEGER,
    main_route_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    reason TEXT,
    distance_km REAL NOT NULL CHECK (distance_km > 0),
    description TEXT,
    FOREIGN KEY (main_route_id) REFERENCES ROUTE(route_id)
        ON DELETE RESTRICT,
    PRIMARY KEY("variant_id")
);

-- Mountain peaks; each peak is assigned to one primary massif.
CREATE TABLE MASSIF (
    massif_id INTEGER,
    name TEXT NOT NULL,
    description TEXT,
    region TEXT,
    country TEXT,
    PRIMARY KEY("massif_id")
);

CREATE TABLE PEAK (
    peak_id INTEGER,
    name TEXT NOT NULL,
    latitude REAL NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude REAL NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    altitude_m INTEGER NOT NULL,
    prominence_m INTEGER NOT NULL CHECK (prominence_m >= 0),
    massif_id INTEGER NOT NULL,
    FOREIGN KEY (massif_id) REFERENCES MASSIF(massif_id)
        ON DELETE RESTRICT,
    PRIMARY KEY("peak_id")
);

-- Mountain huts and their service and location information.
CREATE TABLE MOUNTAIN_HUT (
    hut_id INTEGER,
    name TEXT NOT NULL,
    latitude REAL NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude REAL NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    altitude_m INTEGER NOT NULL,
    service_type TEXT NOT NULL
        CHECK (service_type IN ('Guarded', 'Unguarded', 'Emergency')),
    capacity INTEGER CHECK (capacity >= 0),
    seasonal_availability TEXT,
    PRIMARY KEY("hut_id")
);

-- Species that may be observed along hiking routes.
CREATE TABLE SPECIES (
    species_id INTEGER,
    common_name TEXT NOT NULL,
    scientific_name TEXT NOT NULL UNIQUE,
    conservation_status TEXT,
    species_type TEXT NOT NULL
        CHECK (species_type IN ('Animal', 'Plant', 'Fungus', 'Other')),
    ecosystem TEXT,
    PRIMARY KEY("species_id")
);

-- A user may record the same route on multiple occasions.
CREATE TABLE USER_ROUTE (
    user_route_id INTEGER,
    user_id INTEGER NOT NULL,
    route_id INTEGER NOT NULL,
    activity_date TEXT NOT NULL, -- Store dates as YYYY-MM-DD.
    status TEXT NOT NULL CHECK (status IN ('Completed', 'Abandoned', 'Attempted')),
    description TEXT,
    actual_distance_km REAL CHECK (actual_distance_km >= 0),
    actual_elevation_gain_m INTEGER CHECK (actual_elevation_gain_m >= 0),
    duration_min INTEGER CHECK (duration_min >= 0),
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    visibility TEXT NOT NULL DEFAULT 'Public'
        CHECK (visibility IN ('Public', 'Private')),
    FOREIGN KEY (user_id) REFERENCES USERS(user_id)
        ON DELETE CASCADE,
    FOREIGN KEY (route_id) REFERENCES ROUTE(route_id)
        ON DELETE RESTRICT,
    PRIMARY KEY("user_route_id")
);

-- Many-to-many relationship between routes and peaks.
CREATE TABLE ROUTE_PEAK (
    route_id INTEGER NOT NULL,
    peak_id INTEGER NOT NULL,
    FOREIGN KEY (route_id) REFERENCES ROUTE(route_id)
        ON DELETE CASCADE,
    FOREIGN KEY (peak_id) REFERENCES PEAK(peak_id)
        ON DELETE RESTRICT
);

-- Many-to-many relationship between routes and massifs.
CREATE TABLE ROUTE_MASSIF (
    route_id INTEGER NOT NULL,
    massif_id INTEGER NOT NULL,
    FOREIGN KEY (route_id) REFERENCES ROUTE(route_id)
        ON DELETE CASCADE,
    FOREIGN KEY (massif_id) REFERENCES MASSIF(massif_id)
        ON DELETE RESTRICT
);

-- Many-to-many relationship between mountain huts and routes.
CREATE TABLE MOUNTAIN_HUT_ROUTE (
    hut_id INTEGER NOT NULL,
    route_id INTEGER NOT NULL,
    distance_from_start_km REAL CHECK (distance_from_start_km >= 0),
    FOREIGN KEY (hut_id) REFERENCES MOUNTAIN_HUT(hut_id)
        ON DELETE RESTRICT,
    FOREIGN KEY (route_id) REFERENCES ROUTE(route_id)
        ON DELETE CASCADE
);

-- Many-to-many relationship between routes and species.
CREATE TABLE ROUTE_SPECIES (
    route_id INTEGER NOT NULL,
    species_id INTEGER NOT NULL,
    observations TEXT,
    FOREIGN KEY (route_id) REFERENCES ROUTE(route_id)
        ON DELETE CASCADE,
    FOREIGN KEY (species_id) REFERENCES SPECIES(species_id)
        ON DELETE RESTRICT
);

-- Indexes for foreign keys used in joins and lookups.
-- USER.email is already indexed by its UNIQUE constraint.
CREATE INDEX idx_variant_main_route
    ON VARIANT(main_route_id);

CREATE INDEX idx_peak_massif
    ON PEAK(massif_id);

CREATE INDEX idx_user_route_user
    ON USER_ROUTE(user_id);
CREATE INDEX idx_user_route_route
    ON USER_ROUTE(route_id);

CREATE INDEX idx_route_peak_route
    ON ROUTE_PEAK(route_id);
CREATE INDEX idx_route_peak_peak
    ON ROUTE_PEAK(peak_id);

CREATE INDEX idx_route_massif_route
    ON ROUTE_MASSIF(route_id);
CREATE INDEX idx_route_massif_massif
    ON ROUTE_MASSIF(massif_id);

CREATE INDEX idx_hut_route_hut
    ON MOUNTAIN_HUT_ROUTE(hut_id);
CREATE INDEX idx_hut_route_route
    ON MOUNTAIN_HUT_ROUTE(route_id);

CREATE INDEX idx_route_species_route
    ON ROUTE_SPECIES(route_id);
CREATE INDEX idx_route_species_species
    ON ROUTE_SPECIES(species_id);

-- View of public activity records from users with public profiles.
-- Filter both profile and activity visibility to respect privacy settings.
CREATE VIEW public_user_activity AS
SELECT
    hiker.user_id,
    hiker.name AS user_name,
    route.route_id,
    route.name AS route_name,
    activity.activity_date,
    activity.status AS activity_status,
    activity.actual_distance_km,
    activity.duration_min,
    activity.rating,
    activity.description AS activity_description
FROM USER_ROUTE AS activity
JOIN USERS AS hiker ON hiker.user_id = activity.user_id
JOIN ROUTE AS route ON route.route_id = activity.route_id
WHERE hiker.profile_visibility = 'public'
  AND activity.visibility = 'Public';

-- View summarizing route details and their basic attributes.
CREATE VIEW route_details AS
SELECT
    route_id,
    name,
    distance_km,
    elevation_gain_m,
    elevation_loss_m,
    difficulty,
    estimated_time_min,
    route_type,
    max_altitude_m,
    min_altitude_m,
    status
FROM ROUTE;
