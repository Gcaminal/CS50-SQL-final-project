# Design Document

By Gerard Caminal Altimir

Video overview: [CS50 SQL Final Project, by Gerard Caminal](https://youtu.be/PzaR5GoQKQg)

## Scope

* **What is the purpose of your database?**
Given my interest in hiking and the mountains, I came up with the idea of creating a database of all the trails and their characteristics in the Pyrenees, since that’s where I’m from. Shortly after the idea came to me, I realized it didn’t have to be limited to the Pyrenees, that I could include any trails worldwide, since that would make the scope more complete.
From there, several areas of interest emerged. The first was to learn in detail about every possible route, no matter how small. Then came tracking the activity of users who hike these trails and identifying the amenities available along the way. On these types of routes, the main amenities are basically mountain huts.

* **Which people, places, things, etc. are you including in the scope of your database?**

| Entity | Category |
|---|---|
| `USER` | People |
| `MASSIF` | Place |
| `PEAK` | Natural feature |
| `MOUNTAIN_HUT` | Facility |
| `ROUTE` | Activity |
| `VARIANT` | Route feature |
| `SPECIES` | Wildlife |
| `USER_ROUTE` | User activity |
| `ROUTE_PEAK` | Relationship |
| `ROUTE_MASSIF` | Relationship |
| `MOUNTAIN_HUT_ROUTE` | Relationship |
| `ROUTE_SPECIES` | Relationship |

* **Which people, places, things, etc. are *outside* the scope of your database?**

| Entity | Category |
|---|---|
| `TOURIST` | People |
| `HOTEL` | Accommodation |
| `HOSTEL` | Accommodation |
| `CAMPSITE` | Accommodation |
| `RESTAURANT` | Commercial establishment |
| `SHOP` | Commercial establishment |
| `TRANSPORT_SERVICE` | Transport |
| `CAR_PARK` | Facility |
| `WEATHER_FORECAST` | Weather data |
| `MOUNTAIN_RESCUE_SERVICE` | Emergency service |
| `HOSPITAL` | Healthcare facility |
| `HIKING_EQUIPMENT` | Equipment |
| `TOUR_GUIDE` | People |
| `TOUR_OPERATOR` | Organization |
| `GPS_TRACKING` | Navigation service |
| `BOOKING` | Reservation |
| `PAYMENT` | Financial transaction |
| `GEOLOGICAL_DATA` | Environmental data |
| `CLIMATE_DATA` | Environmental data |

## Functional Requirements

* **What should a user be able to do with your database?**
    1. Register and manage an account - create an account and update personal information.
    2. Search for routes - find routes by name, location, difficulty, distance, elevation gain, or estimated duration.
    3. View route details - consult route descriptions, altitude, distance, difficulty, current status, and estimated completion time.
    4. Explore route variants - find alternative paths associated with a main route.
    5. Discover peaks and mountains - view information about peaks, including coordinates, altitude, prominence, and massif.
    6. Find mountain huts - locate huts along routes and view their altitude, services, and distance from the route's starting point.
    7. Explore massifs and mountain areas - identify the geographical areas crossed by routes.
    8. Discover local wildlife and plant species - view species associated with routes and their conservation status.
    9. Record hiking activities - save routes attempted or completed, including the date, actual distance, duration, and elevation gain.
    10. Rate and review routes - submit ratings and descriptions based on personal hiking experiences.
    11. Track personal hiking history - view previously recorded activities and compare hiking performance over time.
    12. Explore relationships between geographical features and routes - identify which peaks, mountain huts, massifs, and species are associated with each route.
    13. Check route status - determine whether a route is recorded as open or closed, based on the latest information available in the database.
    14. View other users' profiles - consult other users' public profiles to discover their hiking activities, completed routes, ratings, and reviews, depending on their privacy settings.

* **What's beyond the scope of what a user should be able to do with your database?**
    1. Book accommodation - make reservations at mountain huts, hotels, hostels, or campsites.
    2. Make payments - purchase services, pay for accommodation, or process financial transactions.
    3. Book guided tours - hire mountain guides or organize excursions with tour operators.
    4. Access real-time weather forecasts - obtain live weather updates or detailed meteorological predictions.
    5. Request mountain rescue services - contact emergency services or manage rescue operations directly through the database.
    6. Use real-time GPS navigation - receive turn-by-turn directions or track a user's live location during a hike.
    7. Buy or sell hiking equipment - purchase, sell, or rent clothing, boots, and other outdoor gear.
    8. Manage public transport - book buses, trains, taxis, or other transport to reach hiking routes.
    9. Manage hotels and restaurants - create business listings, manage bookings, or process customer orders.
    10. Access private user information - view other users' passwords, email addresses, private activities, or other restricted personal data.
    11. Modify other users' profiles or activities - edit or delete another user's personal information, hiking records, or reviews without authorization.
    12. Conduct scientific environmental research - manage detailed geological surveys, climate models, or environmental monitoring systems unrelated to the route catalogue.

## Representation

### Entities

* **Which entities will you choose to represent in your database?**
The database includes the following entities: USER, ROUTE, VARIANT, PEAK, MASSIF, MOUNTAIN_HUT, and SPECIES, plus five junction tables (USER_ROUTE, ROUTE_PEAK, ROUTE_MASSIF, MOUNTAIN_HUT_ROUTE, and ROUTE_SPECIES) that model the many-to-many relationships between them.

* **What attributes will those entities have?**
#### User
The `USER` table includes:
- `user_id`, the unique identifier of each user, stored as INTEGER and defined as the PRIMARY KEY.
- `name`, the user's name, stored as TEXT with a NOT NULL constraint because every user must have a name.
- `registration_date`, the date the user registered, stored as TEXT with NOT NULL DEFAULT CURRENT_TIMESTAMP because registration dates are required and should be generated automatically.
- `email`, the user's email address stored as TEXT with NOT NULL UNIQUE because every user must have an email address and each email must be unique.
- `password_hash`, the securely hashed password, stored as TEXT with a NOT NULL constraint because authentication requires a stored password hash.
- `profile_description`, a short description of the user, stored as TEXT and allowed to be NULL because providing a biography is optional.
- `profile_visibility`, whether the user's profile is public or private, stored as TEXT with NOT NULL DEFAULT 'public' and a CHECK(profile_visibility IN ('public','private')) constraint.

#### Route
The `ROUTE` table includes:
- `route_id`, the unique identifier of each route, stored as INTEGER and defined as the PRIMARY KEY.
- `name`, the name of the route, stored as TEXT with a NOT NULL constraint because every route must have a name.
- `distance_km`, the total route distance in kilometres, stored as REAL with NOT NULL CHECK(distance_km > 0).
- `elevation_gain_m`, the total positive elevation gain in metres, stored as INTEGER with NOT NULL CHECK(elevation_gain_m >= 0).
- `elevation_loss_m`, the total negative elevation loss in metres, stored as INTEGER with NOT NULL CHECK(elevation_loss_m >= 0).
- `difficulty`, the route's difficulty level, stored as TEXT with NOT NULL CHECK(difficulty IN ('Easy','Moderate','Hard','Very difficult','Expert')).
- `estimated_time_min`, the estimated time needed to complete the route in minutes, stored as INTEGER with NOT NULL CHECK(estimated_time_min > 0).
- `route_type`, the type of route, stored as TEXT with NOT NULL CHECK(route_type IN ('Circular','Linear')).
- `description`, a description of the route, stored as TEXT and allowed to be NULL.
- `max_altitude_m`, the maximum altitude reached in metres, stored as INTEGER with NOT NULL.
- `min_altitude_m`, the minimum altitude reached in metres, stored as INTEGER with NOT NULL CHECK(min_altitude_m <= max_altitude_m).
- `status`, whether the route is open, closed, or temporarily restricted, stored as TEXT with NOT NULL DEFAULT 'Open' and a CHECK(status IN ('Open','Closed','Restricted')).
- `documentation_date`, the date the route information was last documented or updated, stored as TEXT and allowed to be NULL.
- `homologation`, the route's official homologation or classification, stored as TEXT and allowed to be NULL.

#### Variant
The `VARIANT` table includes:
- `variant_id`, the unique identifier of each variant, stored as INTEGER and defined as the PRIMARY KEY.
- `main_route_id`, the identifier of the main route associated with the variant, stored as INTEGER with NOT NULL and FOREIGN KEY REFERENCES ROUTE(route_id).
- `name`, the name of the variant, stored as TEXT with NOT NULL.
- `reason`, the reason for the alternative route, stored as TEXT and allowed to be NULL.
- `distance_km`, the total distance of the variant in kilometres, stored as REAL with NOT NULL CHECK(distance_km > 0).
- `description`, a description of the alternative path, stored as TEXT and allowed to be NULL.

#### Peak
The `PEAK` table includes:
- `peak_id`, the unique identifier of each peak, stored as INTEGER and defined as the PRIMARY KEY.
- `name`, the name of the peak, stored as TEXT with NOT NULL.
- `latitude`, the geographical latitude of the peak, stored as REAL with NOT NULL CHECK(latitude BETWEEN -90 AND 90).
- `longitude`, the geographical longitude of the peak, stored as REAL with NOT NULL CHECK(longitude BETWEEN -180 AND 180).
- `altitude_m`, the peak's altitude in metres, stored as INTEGER with NOT NULL.
- `prominence_m`, the peak's topographic prominence in metres, stored as INTEGER with NOT NULL CHECK(prominence_m >= 0).
- `massif_id`, the identifier of the massif to which the peak primarily belongs, stored as INTEGER with NOT NULL and FOREIGN KEY REFERENCES MASSIF(massif_id).

#### Massif
The `MASSIF` table includes:
- `massif_id`, the unique identifier of each massif, stored as INTEGER and defined as the PRIMARY KEY.
- `name`, the name of the massif, stored as TEXT with NOT NULL.
- `description`, a description of the massif, stored as TEXT and allowed to be NULL.
- `region`, the geographical region where the massif is located, stored as TEXT and allowed to be NULL.
- `country`, the country or countries where the massif is located, stored as TEXT and allowed to be NULL. If a massif can span several countries, a separate country relationship could be introduced.

#### Mountain Hut
The `MOUNTAIN_HUT` table includes:
- `mountain_hut_id`, the unique identifier of each mountain hut, stored as INTEGER and defined as the PRIMARY KEY.
- `name`, the name of the mountain hut, stored as TEXT with NOT NULL.
- `latitude`, the geographical latitude of the hut, stored as REAL with NOT NULL CHECK(latitude BETWEEN -90 AND 90).
- `longitude`, the geographical longitude of the hut, stored as REAL with NOT NULL CHECK(longitude BETWEEN -180 AND 180).
- `altitude_m`, the hut's altitude in metres, stored as INTEGER with NOT NULL.
- `service_type`, the type of services available at the hut, stored as TEXT with NOT NULL CHECK(service_type IN ('Guarded','Unguarded','Emergency')).
- `capacity`, the maximum number of people the hut can accommodate, stored as INTEGER with NOT NULL CHECK(capacity >= 0).
- `seasonal_availability`, the periods during which the hut is open or available, stored as TEXT and allowed to be NULL.

#### Species
The `SPECIES` table includes:
- `species_id`, the unique identifier of each species, stored as INTEGER and defined as the PRIMARY KEY.
- `common_name`, the species' common name, stored as TEXT with NOT NULL.
- `scientific_name`, the species' scientific name, stored as TEXT with NOT NULL UNIQUE.
- `conservation_status`, the species' conservation category, stored as TEXT and allowed to be NULL.
- `species_type`, whether the species is an animal, plant, fungus, or another type of organism, stored as TEXT with NOT NULL CHECK(species_type IN ('Animal','Plant','Fungus','Other')).
- `ecosystem`, the type of ecosystem in which the species is found, stored as TEXT and allowed to be NULL.

#### User Route
The `USER_ROUTE` table includes:
- `user_route_id`, the unique identifier of each hiking activity, stored as INTEGER and defined as the PRIMARY KEY.
- `user_id`, the identifier of the user who performed the activity, stored as INTEGER with NOT NULL and FOREIGN KEY REFERENCES USER(user_id).
- `route_id`, the identifier of the route associated with the activity, stored as INTEGER with NOT NULL and FOREIGN KEY REFERENCES ROUTE(route_id).
- `activity_date`, the date the user attempted or completed the route, stored as TEXT with NOT NULL.
- `status`, whether the route was completed, abandoned, or attempted, stored as TEXT with NOT NULL CHECK(status IN ('Completed','Abandoned','Attempted')).
- `description`, the user's description of the hiking experience, stored as TEXT and allowed to be NULL.
- `actual_distance_km`, the actual distance covered in kilometres, stored as REAL with CHECK(actual_distance_km >= 0) because distance cannot be negative, it may be NULL.
- `actual_elevation_gain_m`, the actual positive elevation gain in metres, stored as INTEGER with CHECK(actual_elevation_gain_m >= 0), it may be NULL.
- `duration_min`, the actual time spent hiking in minutes, stored as INTEGER with CHECK(duration_min >= 0), it may be NULL.
- `rating`, the user's rating of the route, stored as INTEGER with CHECK(rating BETWEEN 1 AND 5), it may be NULL.
- `visibility`, whether the activity is public or private, stored as TEXT with NOT NULL DEFAULT 'Public' and a CHECK(visibility IN ('Public','Private')) constraint.

#### Route Peak
The `ROUTE_PEAK` table includes:
- `route_id`, the identifier of the route, stored as INTEGER with NOT NULL and FOREIGN KEY REFERENCES ROUTE(route_id).
- `peak_id`, the identifier of the peak, stored as INTEGER with NOT NULL and FOREIGN KEY REFERENCES PEAK(peak_id).

Together, these attributes identify which peaks are included in or associated with each route.

#### Route Massif
The `ROUTE_MASSIF` table includes:
- `route_id`, the identifier of the route, stored as INTEGER with NOT NULL and FOREIGN KEY REFERENCES ROUTE(route_id).
- `massif_id`, the identifier of the massif, stored as INTEGER with NOT NULL and FOREIGN KEY REFERENCES MASSIF(massif_id).

Together, these attributes identify which massifs are crossed by each route.

#### Mountain Hut Route
The `MOUNTAIN_HUT_ROUTE` table includes:
- `mountain_hut_id`, the identifier of the mountain hut, stored as INTEGER with NOT NULL and FOREIGN KEY REFERENCES MOUNTAIN_HUT(mountain_hut_id).
- `route_id`, the identifier of the route, stored as INTEGER with NOT NULL and FOREIGN KEY REFERENCES ROUTE(route_id).
- `distance_from_start_km`, the distance from the route's starting point to the mountain hut in kilometres, stored as REAL with CHECK(distance_from_start_km >= 0), it may be NULL if unknown.

Together, these attributes identify which mountain huts are located along or associated with each route.

#### Route Species
The `ROUTE_SPECIES` table includes:
- `route_id`, the identifier of the route, stored as INTEGER with NOT NULL and FOREIGN KEY REFERENCES ROUTE(route_id).
- `species_id`, the identifier of the species, stored as INTEGER with NOT NULL and FOREIGN KEY REFERENCES SPECIES(species_id).
- `observations`, additional information about the species' presence along the route, stored as TEXT and allowed to be NULL.

Together, these attributes identify which species have been documented along each route.

* **Why did you choose the types you did?**
- INTEGER was chosen for identifiers because they are whole numbers and can be used as primary and foreign keys. It is also used for values measured in whole metres, durations in minutes, ratings, and capacity.
- TEXT was chosen for names, descriptions, email addresses, passwords stored as hashes, difficulty levels, route types, statuses, and other categorical information because these values contain characters or words rather than numerical quantities.
- REAL was chosen for distances in kilometres and geographical coordinates (latitude and longitude) because these values may contain decimal places and require fractional precision.
- TEXT was also used for dates. SQLite has no dedicated date type, so dates are stored as TEXT in the ISO format YYYY-MM-DD, which makes them easy to read and compare. CURRENT_TIMESTAMP can be used as a default for registration dates when the date and time are required.

* **Why did you choose the constraints you did?**
- PRIMARY KEY constraints were chosen to uniquely identify each record in the main tables and the USER_ROUTE table.
- FOREIGN KEY constraints were chosen to connect related tables and ensure that relationships reference existing records, such as linking a hiking activity to a user and a route.
- NOT NULL constraints were chosen for essential attributes, such as names, email addresses, and required relationships, to prevent incomplete records.
- UNIQUE constraints were chosen for attributes that should not be duplicated, such as user email addresses and scientific species names.
- CHECK constraints were chosen to restrict values to valid ranges or permitted categories.
- DEFAULT values were chosen when a reasonable initial value can be assigned automatically.

### Relationships

![Entity Relationship Diagram](ER-Diagram.png)

#### One-to-many
- `MASSIF - PEAK`: One massif can contain multiple peaks, but each peak is associated with one massif. The massif_id foreign key in PEAK identifies the massif to which the peak belongs.
- `ROUTE - VARIANT`: One main route can have multiple variants, but each variant belongs to one main route. The main_route_id foreign key identifies the main route to which each variant belongs.

#### Many-to-many
- `USER - ROUTE`: One user can record multiple hiking activities, but each activity belongs to one user. They are connected indirectly through USER_ROUTE. This allows users to record their hiking activities and share them according to their chosen visibility settings.
- `ROUTE - PEAK`: One route can pass by multiple peaks, and one peak can appear on multiple routes. The ROUTE_PEAK junction table connects routes and peaks using the route_id and peak_id foreign keys.
- `ROUTE - MASSIF`: One route can cross multiple massifs, and one massif can contain multiple routes. The ROUTE_MASSIF junction table connects routes and massifs.
- `ROUTE - MOUNTAIN_HUT`: One route can pass by multiple mountain huts, and one mountain hut can be associated with multiple routes. The MOUNTAIN_HUT_ROUTE junction table connects the two entities and includes distance_from_start_km, which records the distance from the route's starting point to the hut.
- `ROUTE - SPECIES`: One route can be associated with multiple species, and one species can appear on multiple routes. The ROUTE_SPECIES junction table connects routes and species. It also includes an observations attribute for storing additional information about a species along a route.

## Optimizations

* **Which optimizations (e.g., indexes, views) did you create? Why?**
#### Indexes
- USER (email): The UNIQUE constraint already creates an index in SQLite, making it faster to find users by email. Therefore, a separate index on this attribute is unnecessary.
- USER_ROUTE (user_id, route_id): Indexes on both columns make it faster to retrieve all hiking activities for a user or all activities associated with a route.
- ROUTE_PEAK (route_id, peak_id): Separate indexes on both foreign keys make it faster to find the peaks associated with a route and the routes that pass by a particular peak.
- ROUTE_MASSIF (route_id, massif_id): Separate indexes on both foreign keys improve searches for the massifs crossed by a route and the routes associated with a particular massif.
- MOUNTAIN_HUT_ROUTE (mountain_hut_id, route_id): Separate indexes on both foreign keys make it faster to find the routes associated with a mountain hut and the mountain huts associated with a route.
- ROUTE_SPECIES (route_id, species_id): Separate indexes on both foreign keys improve searches for species associated with a route and routes associated with a particular species.

#### Views
- Public user activity view: Combines USER, USER_ROUTE, and ROUTE to display public hiking activities, including the user's name, route name, activity date, and rating. It should respect both the user's profile visibility and the activity's visibility.
- Route details view: Combines ROUTE with related information from MASSIF, PEAK, and MOUNTAIN_HUT_ROUTE to make it easier to retrieve geographical details about a route.
- Route species view: Combines ROUTE, ROUTE_SPECIES, and SPECIES to display the species associated with each route.

## Limitations

* **What are the limitations of your design?**
- Limited route information: The ROUTE table stores general information such as distance, difficulty, elevation gain, and estimated duration. However, it does not store the detailed GPS track, individual waypoints, or the exact path followed by a hiker.
- Limited hiking activity tracking: The USER_ROUTE table records information about hiking activities, such as the date, duration, and actual distance. However, it does not track a user's live location, GPS history, or progress along a route in real time.
- Limited geographical relationships: Each peak belongs to a single massif through the massif_id foreign key. If a peak needs to be associated with multiple massifs, the design would require a separate junction table.
- Limited mountain hut information: The MOUNTAIN_HUT table stores basic information about mountain huts, such as their location, altitude, service type, and capacity. It does not manage reservations, prices, payments, or detailed services.
- Limited temporal information: Route status is stored as a single value, such as Open, Closed, or Restricted. The database does not maintain a history of status changes or automatically update route availability according to weather conditions.
- Limited social features: Users can record hiking activities and control their visibility, but the design does not include comments, direct messages, friendships, or a dedicated review system separate from the activity rating.
- Dependence on data accuracy: The database can apply constraints to prevent invalid values, but it cannot guarantee that all information entered is factually correct. For example, route distances, hut locations, and species observations may be inaccurate or outdated.

* **What might your database not be able to represent very well?**
- Detailed geographical information: The database stores the coordinates of peaks and mountain huts, but it cannot accurately represent the complete shape of a route, its GPS track, or the precise location of every waypoint.
- Wildlife and plant distribution: The database can associate species with routes, but it cannot represent their exact distribution, population sizes, seasonal movements, or changes in their habitats.
- Individual hiking experiences: The USER_ROUTE table records basic activity information, but it does not capture a complete hiking experience, such as GPS history, weather encountered, photographs.
- Uncertain or incomplete information: Some information, such as a mountain hut's capacity or a species observation, may be unknown or uncertain. The database can allow missing values, but it does not explicitly represent confidence levels or the reliability of the information.
