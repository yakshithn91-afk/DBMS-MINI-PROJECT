const roomRoutes = require("./src/routes/roomRoutes");
const connectMongoDB = require("./src/config/mongodb");
const express = require("express");
const cors = require("cors");
require("dotenv").config();

const pool = require("./src/config/postgres");
const app = express();

app.use(cors());
app.use(express.json());
app.use("/api/rooms", roomRoutes);

const PORT = process.env.PORT || 5000;

app.get("/", (req, res) => {
    res.json({
        message: "Digital Twin Smart Buildings API is running!"
    });
});

app.get("/api/test-postgres", async (req, res) => {
    try {
        const result = await pool.query("SELECT NOW() AS current_time");

        res.json({
            success: true,
            message: "PostgreSQL connection is working!",
            time: result.rows[0].current_time
        });
    } catch (error) {
        console.error("PostgreSQL test failed:", error.message);

        res.status(500).json({
            success: false,
            message: "PostgreSQL connection failed",
            error: error.message
        });
    }
});

connectMongoDB();
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});