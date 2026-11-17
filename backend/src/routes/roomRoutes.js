const express = require("express");

const {
    getAllRooms,
    getRoomById,
    addBuildingWithFloors,
    registerFacility,
    updateFacilityAvailability,
    getRoomAvailableFacilities,
    getFacilityAvailabilityStats,
    getBuildingSeatingCapacity,
    getBuildingRoomCount
} = require("../controllers/roomController");

const router = express.Router();

// Get all rooms
router.get("/", getAllRooms);

// Get one room by ID
router.get("/:id", getRoomById);

// Stored procedure: Add a new building with initial floor records
router.post("/add-building", addBuildingWithFloors);

// Register a facility for an existing room
router.post("/register-facility", registerFacility);

// Update facility availability/status
router.post("/update-facility-availability", updateFacilityAvailability);

// Get room available facilities count using function
router.get("/:id/available-facilities", getRoomAvailableFacilities);

// Get facility availability stats using function
router.get("/availability-stats", getFacilityAvailabilityStats);

// Get building seating capacity using function
router.get("/:id/seating-capacity", getBuildingSeatingCapacity);

// Get building room count using function
router.get("/:id/room-count", getBuildingRoomCount);

module.exports = router;