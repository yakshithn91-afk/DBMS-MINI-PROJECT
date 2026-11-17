const pool = require("../config/postgres");
const mongoose = require("mongoose");

// MongoDB collection
const roomStatusCollection = mongoose.connection.collection("room_status");

// Get all rooms
const getAllRooms = async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT
                r.room_id,
                r.room_number,
                r.room_name,
                r.room_type,
                r.capacity,
                f.floor_number,
                b.building_name
            FROM rooms r
            JOIN floors f ON r.floor_id = f.floor_id
            JOIN buildings b ON f.building_id = b.building_id
            ORDER BY r.room_id
        `);

        res.json({
            success: true,
            count: result.rows.length,
            rooms: result.rows
        });

    } catch (error) {
        console.error("Error fetching rooms:", error.message);

        res.status(500).json({
            success: false,
            message: "Failed to fetch rooms"
        });
    }
};

// Stored procedure: Add a new building with initial floor records
const addBuildingWithFloors = async (req, res) => {
    try {
        const { building_name, building_code, location, total_floors, description } = req.body;

        if (!building_name || !building_code || !total_floors) {
            return res.status(400).json({
                success: false,
                message: "Missing required parameters: building_name, building_code, total_floors"
            });
        }

        await pool.query(
            `CALL add_building_with_floors(
                $1, $2, $3, $4, $5
            )`,
            [building_name, building_code, location, total_floors, description]
        );

        res.json({
            success: true,
            message: "Building with floors added successfully"
        });
    } catch (error) {
        console.error("Error adding building with floors:", error.message);
        res.status(500).json({
            success: false,
            message: "Failed to add building with floors",
            error: error.message
        });
    }
};

// Register a facility for an existing room
const registerFacility = async (req, res) => {
    try {
        const { room_id, facility_name, quantity } = req.body;

        if (!room_id || !facility_name) {
            return res.status(400).json({
                success: false,
                message: "Missing required parameters: room_id, facility_name"
            });
        }

        await pool.query(
            `CALL register_facility(
                $1, $2, $3
            )`,
            [parseInt(room_id), facility_name, quantity || 1]
        );

        res.json({
            success: true,
            message: "Facility registered successfully"
        });
    } catch (error) {
        console.error("Error registering facility:", error.message);
        res.status(500).json({
            success: false,
            message: "Failed to register facility",
            error: error.message
        });
    }
};

// Update facility availability/status
const updateFacilityAvailability = async (req, res) => {
    try {
        const { facility_id, new_status } = req.body;

        if (!facility_id || !new_status) {
            return res.status(400).json({
                success: false,
                message: "Missing required parameters: facility_id, new_status"
            });
        }

        await pool.query(
            `CALL update_facility_availability(
                $1, $2
            )`,
            [parseInt(facility_id), new_status]
        );

        res.json({
            success: true,
            message: "Facility availability updated successfully"
        });
    } catch (error) {
        console.error("Error updating facility availability:", error.message);
        res.status(500).json({
            success: false,
            message: "Failed to update facility availability",
            error: error.message
        });
    }
};

// Get room available facilities count using function
const getRoomAvailableFacilities = async (req, res) => {
    try {
        const roomId = parseInt(req.params.id);

        if (isNaN(roomId)) {
            return res.status(400).json({
                success: false,
                message: "Invalid room ID"
            });
        }

        const result = await pool.query(
            `SELECT get_room_available_facilities($1) AS available_facilities`,
            [roomId]
        );

        res.json({
            success: true,
            room_id: roomId,
            available_facilities: result.rows[0].available_facilities
        });
    } catch (error) {
        console.error("Error getting available facilities:", error.message);
        res.status(500).json({
            success: false,
            message: "Failed to get available facilities",
            error: error.message
        });
    }
};

// Get facility availability stats using function
const getFacilityAvailabilityStats = async (req, res) => {
    try {
        const result = await pool.query(`SELECT * FROM get_facility_availability_stats()`);

        res.json({
            success: true,
            stats: result.rows
        });
    } catch (error) {
        console.error("Error getting facility availability stats:", error.message);
        res.status(500).json({
            success: false,
            message: "Failed to get facility availability stats",
            error: error.message
        });
    }
};

// Get building seating capacity using function
const getBuildingSeatingCapacity = async (req, res) => {
    try {
        const buildingId = parseInt(req.params.id);

        if (isNaN(buildingId)) {
            return res.status(400).json({
                success: false,
                message: "Invalid building ID"
            });
        }

        const result = await pool.query(
            `SELECT get_building_seating_capacity($1) AS total_capacity`,
            [buildingId]
        );

        res.json({
            success: true,
            building_id: buildingId,
            total_capacity: result.rows[0].total_capacity
        });
    } catch (error) {
        console.error("Error getting building seating capacity:", error.message);
        res.status(500).json({
            success: false,
            message: "Failed to get building seating capacity",
            error: error.message
        });
    }
};

// Get building room count using function
const getBuildingRoomCount = async (req, res) => {
    try {
        const buildingId = parseInt(req.params.id);

        if (isNaN(buildingId)) {
            return res.status(400).json({
                success: false,
                message: "Invalid building ID"
            });
        }

        const result = await pool.query(
            `SELECT get_building_room_count($1) AS room_count`,
            [buildingId]
        );

        res.json({
            success: true,
            building_id: buildingId,
            room_count: result.rows[0].room_count
        );
    } catch (error) {
        console.error("Error getting building room count:", error.message);
        res.status(500).json({
            success: false,
            message: "Failed to get building room count",
            error: error.message
        });
    }
};

module.exports = {
    getAllRooms,
    getRoomById,
    addBuildingWithFloors,
    registerFacility,
    updateFacilityAvailability,
    getRoomAvailableFacilities,
    getFacilityAvailabilityStats,
    getBuildingSeatingCapacity,
    getBuildingRoomCount
};