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

-- Using spatial functions on Point

SET @campus = ST_GeomFromText('Point(37.7749 -122.4194)', 4326); -- lat/lng

SELECT name,
    ST_Distance_Sphere(location, campus) AS distance_meters
FROM restaurants_spatial;

-- T.2.b

-- Float version

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

-- Using spatial functions on Point
-- Note: this requires @campus variable.

SELECT name,
    ST_Distance_Sphere(location, campus) AS distance_meters
FROM
    restaurants_spatial
ORDER BY
    distance_meters
LIMIT 3;
