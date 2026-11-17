-- ============================================
-- DIGITAL TWIN - SMART BUILDINGS
-- PostgreSQL User-Defined Functions
-- ============================================

-- ============================================
-- FUNCTION: Calculate total seating capacity of a building
-- ============================================

CREATE OR REPLACE FUNCTION get_building_seating_capacity(p_building_id INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_capacity INTEGER;
BEGIN
    SELECT COALESCE(SUM(r.capacity), 0) INTO v_total_capacity
    FROM rooms r
    JOIN floors f ON r.floor_id = f.floor_id
    WHERE f.building_id = p_building_id;

    RETURN v_total_capacity;
END;
$$;

-- ============================================
-- FUNCTION: Calculate total number of rooms in a building
-- ============================================

CREATE OR REPLACE FUNCTION get_building_room_count(p_building_id INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_room_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_room_count
    FROM rooms r
    JOIN floors f ON r.floor_id = f.floor_id
    WHERE f.building_id = p_building_id;

    RETURN v_room_count;
END;
$$;

-- ============================================
-- FUNCTION: Return the number of available facilities in a room
-- ============================================

CREATE OR REPLACE FUNCTION get_room_available_facilities(p_room_id INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_available_count INTEGER;
BEGIN
    SELECT COALESCE(SUM(quantity), 0) INTO v_available_count
    FROM facilities
    WHERE room_id = p_room_id AND status = 'Available';

    RETURN v_available_count;
END;
$$;

-- ============================================
-- FUNCTION: Calculate facility availability statistics
-- Returns a table with per-facility availability breakdown
-- ============================================

CREATE OR REPLACE FUNCTION get_facility_availability_stats()
RETURNS TABLE(
    facility_name VARCHAR(100),
    total_quantity INTEGER,
    available_quantity INTEGER,
    maintenance_quantity INTEGER,
    out_of_service_quantity INTEGER,
    availability_percentage NUMERIC(5,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.facility_name,
        SUM(f.quantity) AS total_quantity,
        SUM(CASE WHEN f.status = 'Available' THEN f.quantity ELSE 0 END) AS available_quantity,
        SUM(CASE WHEN f.status = 'Maintenance' THEN f.quantity ELSE 0 END) AS maintenance_quantity,
        SUM(CASE WHEN f.status = 'Out of Service' THEN f.quantity ELSE 0 END) AS out_of_service_quantity,
        ROUND(
            100.0 * SUM(CASE WHEN f.status = 'Available' THEN f.quantity ELSE 0 END) / NULLIF(SUM(f.quantity), 0),
            2
        ) AS availability_percentage
    FROM facilities f
    GROUP BY f.facility_name;
END;
$$;