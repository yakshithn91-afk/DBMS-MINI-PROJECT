const express = require("express");

const {
    getAllRooms,
    getRoomById
} = require("../controllers/roomController");

const router = express.Router();

// Get all rooms
router.get("/", getAllRooms);

// Get one room by ID
router.get("/:id", getRoomById);

module.exports = router;