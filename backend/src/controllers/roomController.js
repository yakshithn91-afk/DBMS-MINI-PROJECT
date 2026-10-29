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


// Get one room with its current MongoDB status
const getRoomById = async (req, res) => {
    try {
        const roomId = parseInt(req.params.id);

        if (isNaN(roomId)) {
            return res.status(400).json({
                success: false,
                message: "Invalid room ID"
            });
        }

        // Get static room information from PostgreSQL
        const roomResult = await pool.query(`
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
            WHERE r.room_id = $1
        `, [roomId]);

        if (roomResult.rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: "Room not found"
            });
        }

        // Get current status from MongoDB
        const status = await roomStatusCollection.findOne({
            room_id: roomId
        });

        res.json({
            success: true,
            room: roomResult.rows[0],
            current_status: status || null
        });

    } catch (error) {
        console.error("Error fetching room:", error.message);

        res.status(500).json({
            success: false,
            message: "Failed to fetch room information"
        });
    }
};


module.exports = {
    getAllRooms,
    getRoomById
};