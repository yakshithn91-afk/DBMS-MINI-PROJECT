-- ============================================
-- DIGITAL TWIN - SMART BUILDINGS
-- DBMS Verification Queries
-- ============================================

-- ============================================
-- Verify Triggers Exist and Are Correctly Defined
-- ============================================

-- Check all triggers on the facilities table
SELECT trigger_name, event_manipulation, action_statement, action_timing, event_object_table
FROM information_schema.triggers
WHERE event_object_table = 'facilities'
ORDER BY trigger_name;

-- Check the facility_audit table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'facility_audit'
ORDER BY ordinal_position;

-- ============================================
-- Verify Trigger Functions Exist and Their Definitions
-- ============================================

-- List trigger functions related to facilities
SELECT proname, prosrc
FROM pg_proc
WHERE proname LIKE 'log_facility%' OR proname LIKE 'validate_facility%'
ORDER BY proname;

-- ============================================
-- Verify Triggers Are Functional (Test INSERT)
-- ============================================

-- This insert should automatically create an audit log entry
INSERT INTO facilities (room_id, facility_name, quantity, status)
VALUES (1, 'Test Trigger Facility', 1, 'Available')
RETURNING *;

-- Check if the audit log was created
SELECT * FROM facility_audit WHERE facility_name = 'Test Trigger Facility' ORDER BY audit_id DESC LIMIT 5;

-- Clean up test record
DELETE FROM facility_audit WHERE facility_name = 'Test Trigger Facility' AND quantity = 1;
DELETE FROM facilities WHERE facility_name = 'Test Trigger Facility';

-- ============================================
-- Verify Stored Procedures Exist and Their Definitions
-- ============================================

-- List all stored procedures (functions with OUT parameters or PROCEDURE type)
-- In PostgreSQL, procedures are created with CREATE PROCEDURE
SELECT proname, prosrc
FROM pg_proc
WHERE prosrc LIKE '%CREATE PROCEDURE%' OR proname IN (
    'add_building_with_floors',
    'register_facility',
    'update_facility_availability',
    'validate_room_capacity'
)
ORDER BY proname;

-- ============================================
-- Verify Procedures Are Functional (Test add_building_with_floors)
-- ============================================

-- Add a new building with 3 floors
CALL add_building_with_floors(
    'Test Building',
    'TB',
    'Test Location',
    3,
    'Test building for DBMS verification'
);

-- Verify the building was added
SELECT building_name, total_floors FROM buildings WHERE building_code = 'TB';

-- Verify floors were created
SELECT floor_number, floor_name FROM floors WHERE building_id = (SELECT building_id FROM buildings WHERE building_code = 'TB');

-- Clean up: remove the building (cascades to floors and rooms/facilities)
DELETE FROM buildings WHERE building_code = 'TB';

-- ============================================
-- Verify Procedures Are Functional (Test register_facility)
-- ============================================

-- Register a facility for room 1 (MAB-G01)
CALL register_facility(1, 'Test Procedure Facility', 2);

-- Verify the facility was registered
SELECT * FROM facilities WHERE room_id = 1 AND facility_name = 'Test Procedure Facility';

-- Register the same facility again (should update quantity)
CALL register_facility(1, 'Test Procedure Facility', 1);

-- Verify updated quantity
SELECT facility_name, quantity, status FROM facilities WHERE room_id = 1 AND facility_name = 'Test Procedure Facility';

-- Clean up
DELETE FROM facilities WHERE room_id = 1 AND facility_name = 'Test Procedure Facility';

-- ============================================
-- Verify Procedures Are Functional (Test update_facility_availability)
-- ============================================

-- First, register a facility to test with
CALL register_facility(2, 'Availability Test', 1);

-- Update its status to Maintenance
CALL update_facility_availability((SELECT facility_id FROM facilities WHERE facility_name = 'Availability Test'), 'Maintenance');

-- Verify the status was updated
SELECT facility_name, status FROM facilities WHERE facility_name = 'Availability Test';

-- Clean up
DELETE FROM facilities WHERE facility_name = 'Availability Test';

-- ============================================
-- Verify Functions Exist and Return Correct Results
-- ============================================

-- Test get_building_seating_capacity function
SELECT 
    b.building_name,
    get_building_seating_capacity(b.building_id) AS total_capacity,
    get_building_room_count(b.building_id) AS room_count
FROM buildings b
LIMIT 3;

-- Test get_room_available_facilities function
SELECT 
    r.room_number,
    r.room_name,
    get_room_available_facilities(r.room_id) AS available_facilities
FROM rooms r
LIMIT 5;

-- Test get_facility_availability_stats function
SELECT * FROM get_facility_availability_stats();

-- ============================================
-- Verify Foreign Key Relationships Remain Intact
-- ============================================

-- Check that all rooms reference valid floors
SELECT r.room_id, r.room_number, f.floor_id
FROM rooms r
LEFT JOIN floors f ON f.floor_id = r.floor_id
WHERE f.floor_id IS NULL;

-- Check that all facilities reference valid rooms
SELECT f.facility_id, f.facility_name, r.room_id
FROM facilities f
LEFT JOIN rooms r ON r.room_id = f.room_id
WHERE r.room_id IS NULL;

-- ============================================
-- Final: List All Created Database Objects
-- ============================================

-- Triggers
SELECT trigger_name, event_object_table, action_timing
FROM information_schema.triggers
WHERE event_object_table IN ('buildings', 'floors', 'rooms', 'facilities')
ORDER BY event_object_table, trigger_name;

-- Functions
SELECT proname, prosrc
FROM pg_proc
WHERE proname LIKE 'get_%'
ORDER BY proname;

-- Procedures
SELECT proname, prosrc
FROM pg_proc
WHERE prosrc LIKE '%CREATE PROCEDURE%'
   OR proname IN ('add_building_with_floors', 'register_facility', 'update_facility_availability', 'validate_room_capacity')
ORDER BY proname;