import os
import tempfile
import unittest

import app.app as application


class IncidentFlowTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.original_path = application.DATABASE_PATH
        application.DATABASE_PATH = os.path.join(self.temp_dir.name, "test.db")
        application.initialize_database()
        self.client = application.app.test_client()

    def tearDown(self):
        application.DATABASE_PATH = self.original_path
        self.client = None
        self.temp_dir.cleanup()

    def test_health_endpoint(self):
        response = self.client.get("/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json["status"], "healthy")

    def test_create_and_list_incident(self):
        response = self.client.post("/api/incidents", json={
            "title": "Test service outage",
            "description": "Automated test incident",
            "severity": "High",
        })
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.json["title"], "Test service outage")

        listing = self.client.get("/api/incidents")
        self.assertEqual(listing.status_code, 200)
        self.assertEqual(len(listing.json), 1)

    def test_title_is_required(self):
        response = self.client.post(
            "/api/incidents", json={"title": " "}
        )
        self.assertEqual(response.status_code, 400)

    def test_update_incident_status(self):
        created = self.client.post(
            "/api/incidents", json={"title": "Status test"}
        )
        incident_id = created.json["id"]

        response = self.client.patch(
            f"/api/incidents/{incident_id}",
            json={"status": "Resolved"},
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json["status"], "Resolved")


if __name__ == "__main__":
    unittest.main()
