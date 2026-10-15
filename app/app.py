import os
import sqlite3
from contextlib import contextmanager
from datetime import datetime, timezone
from flask import Flask, jsonify, request, render_template

app = Flask(__name__)

DATABASE_PATH = os.environ.get(
    "DATABASE_PATH",
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "incidents.db")
)


@contextmanager
def get_db():
    connection = sqlite3.connect(DATABASE_PATH)
    connection.row_factory = sqlite3.Row
    try:
        yield connection
        connection.commit()
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()


def initialize_database():
    with get_db() as db:
        db.execute("""
            CREATE TABLE IF NOT EXISTS incidents (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT NOT NULL DEFAULT '',
                severity TEXT NOT NULL DEFAULT 'Medium',
                status TEXT NOT NULL DEFAULT 'Open',
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
        """)


@app.get("/")
def home():
    return render_template("index.html")


@app.get("/health")
def health():
    return jsonify({"status": "healthy", "application": "IncidentFlow Lite"})


@app.get("/api/incidents")
def list_incidents():
    with get_db() as db:
        rows = db.execute(
            "SELECT * FROM incidents ORDER BY id DESC"
        ).fetchall()
    return jsonify([dict(row) for row in rows])


@app.post("/api/incidents")
def create_incident():
    data = request.get_json(silent=True) or {}
    title = str(data.get("title", "")).strip()
    description = str(data.get("description", "")).strip()
    severity = data.get("severity", "Medium")

    if not title:
        return jsonify({"error": "Incident title is required."}), 400
    if severity not in ("Low", "Medium", "High", "Critical"):
        return jsonify({"error": "Invalid severity."}), 400

    now = datetime.now(timezone.utc).isoformat()
    with get_db() as db:
        cursor = db.execute("""
            INSERT INTO incidents
            (title, description, severity, status, created_at, updated_at)
            VALUES (?, ?, ?, 'Open', ?, ?)
        """, (title, description, severity, now, now))
        row = db.execute(
            "SELECT * FROM incidents WHERE id = ?", (cursor.lastrowid,)
        ).fetchone()
        result = dict(row)

    return jsonify(result), 201


@app.patch("/api/incidents/<int:incident_id>")
def update_incident(incident_id):
    data = request.get_json(silent=True) or {}
    status = data.get("status")

    if status not in ("Open", "In Progress", "Resolved"):
        return jsonify({"error": "Invalid incident status."}), 400

    with get_db() as db:
        cursor = db.execute(
            "UPDATE incidents SET status = ?, updated_at = ? WHERE id = ?",
            (status, datetime.now(timezone.utc).isoformat(), incident_id)
        )
        if cursor.rowcount == 0:
            return jsonify({"error": "Incident not found."}), 404

        row = db.execute(
            "SELECT * FROM incidents WHERE id = ?", (incident_id,)
        ).fetchone()
        result = dict(row)

    return jsonify(result)


@app.delete("/api/incidents/<int:incident_id>")
def delete_incident(incident_id):
    with get_db() as db:
        cursor = db.execute(
            "DELETE FROM incidents WHERE id = ?", (incident_id,)
        )
        if cursor.rowcount == 0:
            return jsonify({"error": "Incident not found."}), 404

    return jsonify({"message": "Incident deleted successfully."})


initialize_database()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", "5000")))
