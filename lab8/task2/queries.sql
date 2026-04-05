-- T.2.a

-- Float version

SELECT
    name,
    (6371000 * ACOS(
        COS(RADIANS(37.7749)) * COS(RADIANS(lat)) *
        COS(RADIANS(lng) - RADIANS(-122.4194)) +
        SIN(RADIANS(37.7749)) * SIN(RADIANS(lat))
    )) AS distance_meters
FROM restaurants_float;

-- Using Spatial Functions on Point

SET @campus = Point(37.7749, -122.4194); -- lat/lng

SELECT name,
    ST_Distance_Sphere( -- expects Point(lng, lat)
        Point(ST_Y(@campus), ST_X(@campus)),
        Point(ST_Y(location), ST_X(location))
    ) AS distance_meters
FROM restaurants_spatial;

-- T.2.b

SELECT
    name,
    (6371000 * ACOS(
        COS(RADIANS(37.7749)) * COS(RADIANS(lat)) *
        COS(RADIANS(lng) - RADIANS(-122.4194)) +
        SIN(RADIANS(37.7749)) * SIN(RADIANS(lat))
    )) AS distance_meters
FROM
    restaurants_float
ORDER BY
    distance_meters
LIMIT 3;

-- Note: this requires @campus variable.

SELECT name,
    ST_Distance_Sphere( -- expects Point(lng, lat)
        Point(ST_Y(@campus), ST_X(@campus)),
        Point(ST_Y(location), ST_X(location))
    ) AS distance_meters
FROM
    restaurants_spatial
ORDER BY
    distance_meters
LIMIT 3;
