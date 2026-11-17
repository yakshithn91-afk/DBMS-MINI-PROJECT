-- ============================================
-- DIGITAL TWIN - SMART BUILDINGS
-- PostgreSQL Stored Procedures
-- ============================================

-- ============================================
-- PROCEDURE: Add a new building with initial floor records
-- ============================================

CREATE OR REPLACE PROCEDURE add_building_with_floors(
    p_building_name VARCHAR(100),
    p_building_code VARCHAR(20),
    p_location VARCHAR(200),
    p_total_floors INTEGER,
    p_description TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_building_id INTEGER;
    v_floor_number INTEGER;
BEGIN
    -- Insert the building and get the generated ID
    INSERT INTO buildings (building_name, building_code, location, total_floors, description)
    VALUES (p_building_name, p_building_code, p_location, p_total_floors, p_description)
    RETURNING building_id INTO v_building_id;

    -- Create ground floor record (floor_number = 0)
    INSERT INTO floors (building_id, floor_number, floor_name)
    VALUES (v_building_id, 0, 'Ground Floor');

    -- Create additional floor records if total_floors > 1
    FOR v_floor_number IN 1..(p_total_floors - 1) LOOP
        INSERT INTO floors (building_id, floor_number, floor_name)
        VALUES (v_building_id, v_floor_number,
                CASE WHEN v_floor_number = 1 THEN 'First Floor'
                      WHEN v_floor_number = 2 THEN 'Second Floor'
                      ELSE 'Floor ' || v_floor_number END);
    END LOOP;
END;
$$;

-- ============================================
-- PROCEDURE: Register a facility for an existing room
-- ============================================

CREATE OR REPLACE PROCEDURE register_facility(
    p_room_id INTEGER,
    p_facility_name VARCHAR(100),
    p_quantity INTEGER DEFAULT 1
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if the room exists
    IF NOT EXISTS (SELECT 1 FROM rooms WHERE room_id = p_room_id) THEN
        RAISE EXCEPTION 'Room with ID % does not exist', p_room_id;
    END IF;

    -- Check if facility already exists for this room
    IF EXISTS (SELECT 1 FROM facilities WHERE room_id = p_room_id AND facility_name = p_facility_name) THEN
        -- Update existing facility quantity
        UPDATE facilities
        SET quantity = quantity + p_quantity,
            status = COALESCE(status, 'Available')
        WHERE room_id = p_room_id AND facility_name = p_facility_name;
    ELSE
        -- Insert new facility
        INSERT INTO facilities (room_id, facility_name, quantity, status)
        VALUES (p_room_id, p_facility_name, p_quantity, 'Available');
    END IF;
END;
$$;

-- ============================================
-- PROCEDURE: Update facility availability/status
-- ============================================

CREATE OR REPLACE PROCEDURE update_facility_availability(
    p_facility_id INTEGER,
    p_new_status VARCHAR(30)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if the facility exists
    IF NOT EXISTS (SELECT 1 FROM facilities WHERE facility_id = p_facility_id) THEN
        RAISE EXCEPTION 'Facility with ID % does not exist', p_facility_id;
    END IF;

    -- Validate status value
    IF p_new_status NOT IN ('Available', 'Maintenance', 'Out of Service') THEN
        RAISE EXCEPTION 'Invalid status. Must be Available, Maintenance, or Out of Service';
    END IF;

    UPDATE facilities
    SET status = p_new_status
    WHERE facility_id = p_facility_id;
END;
$$;

-- ============================================
-- PROCEDURE: Validate room capacity before insert/update
-- ============================================

CREATE OR REPLACE PROCEDURE validate_room_capacity(
    p_room_id INTEGER,
    p_min_capacity INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_capacity INTEGER;
BEGIN
    -- Get current room capacity
    SELECT capacity INTO v_current_capacity
    FROM rooms
    WHERE room_id = p_room_id;

    IF v_current_capacity IS NULL THEN
        RAISE EXCEPTION 'Room with ID % does not exist', p_room_id;
    END IF;

    -- Validate that capacity meets minimum requirement
    IF v_current_capacity < p_min_capacity THEN
        RAISE EXCEPTION 'Room capacity % is below minimum required %', v_current_capacity, p_min_capacity;
    END IF;
END;
$$;