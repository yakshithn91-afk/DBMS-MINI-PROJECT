# DBMS-MINI-PROJECT

## Digital Twin for Smart Buildings

This project combines PostgreSQL building, floor, room, and facility records with MongoDB room-status readings, served through an Express API and a React dashboard.

## DBMS Concepts Implementation

This project implements the following advanced DBMS concepts in PostgreSQL:

### 1. Database Triggers

Three types of triggers have been implemented on the `facilities` table:

- **trg_facility_audit_insert**: Automatically logs facility records when they are inserted
- **trg_facility_audit_update**: Automatically logs facility records when they are updated (captures old and new facility names)
- **trg_facility_audit_delete**: Automatically logs facility records when they are deleted

- **trg_validate_facility_quantity**: Validates that facility quantity is at least 1 and that status is one of 'Available', 'Maintenance', or 'Out of Service'

The triggers use a `facility_audit` table that records:
- The facility ID
- The action type (INSERT, UPDATE, DELETE)
- The old and new facility names
- Timestamp of the change

### 2. Stored Procedures

Four stored procedures have been implemented:

- **add_building_with_floors(p_building_name, p_building_code, p_location, p_total_floors, p_description)**: Adds a new building along with its initial floor records. Creates ground floor and additional floors up to the specified total.

- **register_facility(p_room_id, p_facility_name, p_quantity)**: Registers a facility for an existing room. If the facility already exists, it updates the quantity; otherwise, it inserts a new facility record.

- **update_facility_availability(p_facility_id, p_new_status)**: Updates the availability status of a facility. Validates that the facility exists and the status is valid.

- **validate_room_capacity(p_room_id, p_min_capacity)**: Validates that a room's capacity meets a minimum requirement.

### 3. User-Defined Functions

Four user-defined functions have been implemented:

- **get_building_seating_capacity(p_building_id)**: Calculates the total seating capacity of a building by summing the capacities of all its rooms. Returns an INTEGER.

- **get_building_room_count(p_building_id)**: Calculates the total number of rooms in a building. Returns an INTEGER.

- **get_room_available_facilities(p_room_id)**: Returns the number of available facilities in a room (facilities with status 'Available'). Returns an INTEGER.

- **get_facility_availability_stats()**: Returns a table with facility availability statistics including per-facility total quantity, available quantity, maintenance quantity, out-of-service quantity, and availability percentage.

### 4. Backend Integration

The Express backend has been integrated with the new stored procedures and functions:

- **POST /api/rooms/add-building**: Calls `add_building_with_floors` procedure
- **POST /api/rooms/register-facility**: Calls `register_facility` procedure
- **POST /api/rooms/update-facility-availability**: Calls `update_facility_availability` procedure
- **GET /api/rooms/:id/available-facilities**: Calls `get_room_available_facilities` function
- **GET /api/rooms/availability-stats**: Calls `get_facility_availability_stats` function
- **GET /api/rooms/:id/seating-capacity**: Calls `get_building_seating_capacity` function
- **GET /api/rooms/:id/room-count**: Calls `get_building_room_count` function

All uses parameterized queries and proper error handling.

### 5. Database Organization

SQL files are organized in `database/postgresql/`:
- `schema.sql` - Original table definitions
- `sample_data.sql` - Initial data population
- `triggers.sql` - Trigger implementations
- `procedures.sql` - Stored procedure implementations
- `functions.sql` - User-defined function implementations
- `dbms_verification.sql` - Verification and test queries

### 6. How to Execute

1. Ensure PostgreSQL is running
2. Create the database: `CREATE DATABASE dbms_mini_project;`
3. Run the schema: `psql -h /tmp -U <user> -d dbms_mini_project -f database/postgresql/schema.sql`
4. Run the sample data: `psql -h /tmp -U <user> -d dbms_mini_project -f database/postgresql/sample_data.sql`
5. Run the triggers: `psql -h /tmp -U <user> -d dbms_mini_project -f database/postgresql/triggers.sql`
6. Run the procedures: `psql -h /tmp -U <user> -d dbms_mini_project -f database/postgresql/procedures.sql`
7. Run the functions: `psql -h /tmp -U <user> -d dbms_mini_project -f database/postgresql/functions.sql`

### 7. Testing and Verification

Run the verification queries from `database/postgresql/dbms_verification.sql` to:
- Verify triggers exist and function correctly
- Verify procedures exist and perform their intended operations
- Verify functions return correct results
- Check foreign key relationships remain intact

Example verification queries:

```sql
-- Check triggers on facilities table
SELECT trigger_name, event_manipulation, action_timing, event_object_table
FROM information_schema.triggers
WHERE event_object_table = 'facilities';

-- Verify trigger function definitions
SELECT proname, prosrc FROM pg_proc WHERE proname LIKE 'log_facility%' OR proname LIKE 'validate_facility%';

-- Test insert trigger
INSERT INTO facilities (room_id, facility_name, quantity, status) VALUES (1, 'Test', 1, 'Available');
SELECT * FROM facility_audit WHERE action = 'INSERT';

-- Test procedure: add building with floors
CALL add_building_with_floors('Test', 'TB', 'Location', 3, 'Desc');

-- Test function: building capacity
SELECT get_building_seating_capacity(1);

-- Test function: room available facilities
SELECT get_room_available_facilities(1);

-- Check facility availability stats
SELECT * FROM get_facility_availability_stats();
```