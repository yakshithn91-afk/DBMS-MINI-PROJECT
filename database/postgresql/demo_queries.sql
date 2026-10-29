-- DIGITAL TWIN - SMART BUILDINGS
-- Read-only PostgreSQL queries for the project demonstration.
-- Run each query separately in pgAdmin's Query Tool.

-- 1. Building and floor inventory with room and seat totals.
SELECT b.building_name, f.floor_number, f.floor_name,
       COUNT(r.room_id) AS room_count,
       COALESCE(SUM(r.capacity), 0) AS total_seats
FROM buildings b
LEFT JOIN floors f ON f.building_id = b.building_id
LEFT JOIN rooms r ON r.floor_id = f.floor_id
GROUP BY b.building_id, b.building_name, f.floor_id, f.floor_number, f.floor_name
ORDER BY b.building_name, f.floor_number;

-- 2. Full room directory with its parent building and floor.
SELECT b.building_name, f.floor_name, r.room_number, r.room_name,
       r.room_type, r.capacity, r.area_sqft
FROM rooms r
JOIN floors f ON f.floor_id = r.floor_id
JOIN buildings b ON b.building_id = f.building_id
ORDER BY b.building_name, f.floor_number, r.room_number;

-- 3. Room-type summary: count and average seating capacity.
SELECT room_type, COUNT(*) AS room_count,
       ROUND(AVG(capacity), 1) AS average_capacity, SUM(capacity) AS total_seats
FROM rooms
GROUP BY room_type
ORDER BY room_count DESC, room_type;

-- 4. Facility inventory by building, facility, and availability.
SELECT b.building_name, fa.facility_name, fa.status,
       SUM(fa.quantity) AS total_quantity
FROM facilities fa
JOIN rooms r ON r.room_id = fa.room_id
JOIN floors f ON f.floor_id = r.floor_id
JOIN buildings b ON b.building_id = f.building_id
GROUP BY b.building_name, fa.facility_name, fa.status
ORDER BY b.building_name, fa.facility_name, fa.status;

-- 5. Facilities not marked available (may return no rows with current sample data).
SELECT r.room_number, r.room_name, fa.facility_name, fa.quantity, fa.status
FROM facilities fa
JOIN rooms r ON r.room_id = fa.room_id
WHERE fa.status <> 'Available'
ORDER BY fa.status, r.room_number;

-- 6. Rooms with seating capacity of at least 50, largest first.
SELECT b.building_name, r.room_number, r.room_name, r.room_type, r.capacity
FROM rooms r
JOIN floors f ON f.floor_id = r.floor_id
JOIN buildings b ON b.building_id = f.building_id
WHERE r.capacity >= 50
ORDER BY r.capacity DESC, b.building_name, r.room_number;

-- 7. Referential-integrity check; the foreign keys mean this should return zero rows.
SELECT r.room_id, r.room_number
FROM rooms r
LEFT JOIN floors f ON f.floor_id = r.floor_id
LEFT JOIN buildings b ON b.building_id = f.building_id
WHERE f.floor_id IS NULL OR b.building_id IS NULL;