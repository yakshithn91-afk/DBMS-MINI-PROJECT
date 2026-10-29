import { useEffect, useMemo, useState } from "react";

const API = import.meta.env.VITE_API_URL || "http://localhost:5000";
const floorLabel = (value) => Number(value) === 0 ? "Ground floor" : "Floor " + value;
const titleCase = (value) => value.split("_").map((part) => part.charAt(0).toUpperCase() + part.slice(1)).join(" ");

export default function App() {
  const [rooms, setRooms] = useState([]);
  const [building, setBuilding] = useState("all");
  const [floor, setFloor] = useState("all");
  const [search, setSearch] = useState("");
  const [selectedId, setSelectedId] = useState(null);
  const [details, setDetails] = useState(null);
  const [loading, setLoading] = useState(true);
  const [loadingDetails, setLoadingDetails] = useState(false);
  const [apiStatus, setApiStatus] = useState("connecting");
  const [error, setError] = useState("");

  useEffect(() => {
    const controller = new AbortController();
    fetch(API + "/api/rooms", { signal: controller.signal })
      .then((response) => {
        if (!response.ok) throw new Error("Room list request failed.");
        return response.json();
      })
      .then((payload) => {
        if (!payload.success) throw new Error(payload.message || "Room list request failed.");
        setRooms(payload.rooms || []);
        setApiStatus("online");
      })
      .catch((reason) => {
        if (reason.name !== "AbortError") {
          setError(reason.message || "Unable to reach the backend.");
          setApiStatus("offline");
        }
      })
      .finally(() => { if (!controller.signal.aborted) setLoading(false); });
    return () => controller.abort();
  }, []);

  const buildings = useMemo(() => [...new Set(rooms.map((room) => room.building_name))].sort(), [rooms]);
  const buildingRooms = useMemo(
    () => building === "all" ? rooms : rooms.filter((room) => room.building_name === building),
    [rooms, building]
  );
  const floors = useMemo(
    () => [...new Set(buildingRooms.map((room) => Number(room.floor_number)))].sort((a, b) => a - b),
    [buildingRooms]
  );
  const visibleRooms = useMemo(
    () =>
    buildingRooms.filter((room) => {
      const matchesFloor =
        floor === "all" || Number(room.floor_number) === Number(floor);

      const searchableText = [
        room.room_name,
        room.room_number,
        room.building_name,
        room.room_type,
      ].join(" ").toLowerCase();

      const matchesSearch = searchableText.includes(search.trim().toLowerCase());
      return matchesFloor && matchesSearch;
    }),
  [buildingRooms, floor, search]
);
  

 useEffect(() => {
  if (visibleRooms.length === 0) {
    if (selectedId !== null) setSelectedId(null);
    return;
  }

  if (!visibleRooms.some((room) => room.room_id === selectedId)) {
    setSelectedId(visibleRooms[0].room_id);
  }
}, [visibleRooms, selectedId]); 
  useEffect(() => {
    if (selectedId === null) { setDetails(null); return undefined; }
    const controller = new AbortController();
    setLoadingDetails(true);
    fetch(API + "/api/rooms/" + selectedId, { signal: controller.signal })
      .then((response) => {
        if (!response.ok) throw new Error("Room status request failed.");
        return response.json();
      })
      .then((payload) => setDetails(payload.success ? payload : null))
      .catch((reason) => { if (reason.name !== "AbortError") setDetails(null); })
      .finally(() => { if (!controller.signal.aborted) setLoadingDetails(false); });
    return () => controller.abort();
  }, [selectedId]);

  const selectedRoom = rooms.find((room) => room.room_id === selectedId) || null;
  const current = details?.room?.room_id === selectedId ? details : null;
  const status = current?.current_status || null;
  const capacity = Number(current?.room?.capacity || selectedRoom?.capacity || 0);
  const occupancy = status?.occupancy;
  const occupancyPercent = occupancy === undefined || !capacity ? 0 : Math.min(100, Math.round(Number(occupancy) * 100 / capacity));
  const devices = Object.entries(status?.devices || {});
  const floorCount = new Set(rooms.map((room) => room.building_name + ":" + room.floor_number)).size;
  const lastReading = status?.timestamp
    ? new Intl.DateTimeFormat(undefined, { dateStyle: "medium", timeStyle: "short" }).format(new Date(status.timestamp))
    : "No recent reading";

  return <div className="app-shell">
    <aside className="sidebar">
      <div className="brand"><div className="brand-mark">H<i /></div><div><strong>Habitat</strong><small>BUILDING TWIN</small></div></div>
      <div className="side-label">WORKSPACE</div>
      <div className="workspace"><b>DT</b><span><strong>Smart buildings</strong><small>Campus portfolio</small></span><i>⌄</i></div>
      <div className="side-label monitor-label">MONITOR</div>
      <nav className="side-nav" aria-label="Main navigation">
        <a className="active" href="#overview"><span>▦</span>Overview</a>
        <a href="#spaces"><span>⌂</span>Spaces</a>
        <a href="#room-details"><span>◉</span>Room status</a>
      </nav>
      <div className="sidebar-bottom"><span className={"dot " + apiStatus} />API {apiStatus}<small>Digital Twin for Smart Buildings</small></div>
    </aside>

    <div className="main-area" id="overview">
      <header className="topbar">
        <div className="breadcrumb">PORTFOLIO <b>/</b> <strong>OVERVIEW</strong></div>
        <div className={"connection " + apiStatus}><i />{apiStatus === "online" ? "Backend connected" : apiStatus === "offline" ? "Backend unavailable" : "Connecting"}</div>
      </header>

      <main className="content">
        <section className="intro">
          <div><p className="eyebrow"><i /> SMART BUILDING OPERATIONS</p><h1>Building overview</h1><p>Explore campus spaces and their latest simulated sensor readings.</p></div>
          <span className="snapshot">◷ &nbsp; LIVE SNAPSHOT</span>
        </section>

        <section className="stats">
          <article><div>BUILDINGS <b>B</b></div><strong>{loading ? "—" : buildings.length}</strong><small>Across the campus</small></article>
          <article><div>FLOORS <b>F</b></div><strong>{loading ? "—" : floorCount}</strong><small>Organized by building</small></article>
          <article className="highlight"><div>ROOMS TRACKED <b>R</b></div><strong>{loading ? "—" : rooms.length}</strong><small>Structured in PostgreSQL</small></article>
        </section>

        {error && <div className="error" role="alert"><strong>Could not connect to the room API.</strong><span>{error} Start the backend on localhost:5000 and refresh.</span></div>}

        <section className="dashboard">
          <article className="explorer" id="spaces">
            <div className="panel-head">
              <div><p className="kicker">SPACE DIRECTORY</p><h2>Explore rooms <span className="count">{visibleRooms.length}</span></h2></div>
              <label className="building-select"><small>BUILDING</small>
                <select value={building} onChange={(event) => setBuilding(event.target.value)}>
                  <option value="all">All buildings</option>
                  {buildings.map((name) => <option key={name} value={name}>{name}</option>)}
                </select>
              </label>
            </div>
            
            <div className="floor-filter"><small>FLOOR</small><div>
              <button className={floor === "all" ? "chip selected" : "chip"} onClick={() => setFloor("all")}>All floors</button>
              {floors.map((value) => <button key={value} className={Number(floor) === value ? "chip selected" : "chip"} onClick={() => setFloor(String(value))}>{floorLabel(value)}</button>)}
            </div></div>

            {loading ? <div className="room-grid"><div className="skeleton" /><div className="skeleton" /><div className="skeleton" /></div> :
              visibleRooms.length ? <div className="room-grid">{visibleRooms.map((room) =>
                <button key={room.room_id} className={selectedId === room.room_id ? "room selected" : "room"} onClick={() => setSelectedId(room.room_id)}>
                  <span className="room-top"><small>{room.room_number}</small><i>↗</i></span>
                  <strong>{room.room_name || "Unnamed room"}</strong><span className="type">{room.room_type}</span>
                  <span className="room-bottom">{floorLabel(room.floor_number)}<b>{room.capacity || "—"} seats</b></span>
                </button>
              )}</div> : <div className="empty"><b>⌂</b><strong>No rooms in this view</strong><span>Choose another building or floor.</span></div>}
            <div className="panel-note"><i />Room records are loaded from PostgreSQL.</div>
          </article>

          <aside className="details" id="room-details">
            <div className="details-head"><div><p className="kicker">LIVE ROOM VIEW</p><h2>Room details</h2></div>{status && <span className="live"><i /> LIVE</span>}</div>
            {!selectedRoom ? <div className="empty detail-empty"><b>⌂</b><strong>Select a room</strong><span>Choose a room to inspect its latest status.</span></div> : <>
              <div className="identity"><b>⌂</b><div><small>{selectedRoom.building_name} · {floorLabel(selectedRoom.floor_number)}</small><h3>{selectedRoom.room_name || selectedRoom.room_number}</h3><span>{selectedRoom.room_number} · {selectedRoom.room_type}</span></div></div>
              {status ? <>
                <div className="occupancy">
                  <div><small>OCCUPANCY</small><strong>{occupancy ?? "—"} <i>/ {capacity} seats</i></strong></div><b>{occupancyPercent}%</b>
                  <div className="progress"><span style={{ width: occupancyPercent + "%" }} /></div>
                  <footer><span>Simulated room activity</span><span>{occupancyPercent >= 80 ? "High use" : occupancyPercent > 0 ? "In use" : "Available"}</span></footer>
                </div>
                <div className="telemetry">
                  <div><i className="temp">°</i><small>TEMPERATURE</small><strong>{status.environment?.temperature ?? "—"}<em>°C</em></strong></div>
                  <div><i className="humid">≈</i><small>HUMIDITY</small><strong>{status.environment?.humidity ?? "—"}<em>%</em></strong></div>
                  <div className="energy"><i>ϟ</i><small>ENERGY CONSUMPTION</small><strong>{status.energy?.consumption_kwh ?? "—"}<em>kWh</em></strong></div>
                </div>
                <div className="devices"><header><strong>Connected devices</strong><small>{devices.length} reported</small></header>
                  {devices.length ? devices.map(([name, value]) => <div className="device" key={name}><span>⌁ &nbsp;{titleCase(name)}</span><b className={String(value).toLowerCase() === "on" ? "on" : ""}><i />{String(value)}</b></div>) : <p>No device readings stored for this room.</p>}
                </div>
                <div className="last-reading"><span>Last reading</span><strong>{lastReading}</strong></div>
              </> : <div className="no-status"><b>{loadingDetails ? "…" : "—"}</b><strong>{loadingDetails ? "Loading room status" : "No live status record"}</strong><span>{loadingDetails ? "Reading the latest room document." : "No status document exists for this room in MongoDB yet."}</span></div>}
            </>}
          </aside>
        </section>
        <footer className="page-footer"><span><i />Digital Twin for Smart Buildings</span><span>PostgreSQL · MongoDB · Express · React</span></footer>
      </main>
    </div>
  </div>;
}