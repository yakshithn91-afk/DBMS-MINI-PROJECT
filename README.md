# DBMS-MINI-PROJECT

## Digital Twin for Smart Buildings

This project combines PostgreSQL building, floor, room, and facility records with MongoDB room-status readings, served through an Express API and a React dashboard.

## Run locally

1. Start the PostgreSQL and MongoDB services.
2. In the backend folder, run node server.js. The API listens on http://localhost:5000.
3. In the frontend folder, run npm install once, then npm run dev. Open the local URL printed by Vite.
4. For the SQL review, open database/postgresql/demo_queries.sql in pgAdmin and run the read-only queries one at a time.

The dashboard calls GET /api/rooms for the directory and GET /api/rooms/:id for a room's current MongoDB status. Set the API address with VITE_API_URL in frontend/.env if needed.