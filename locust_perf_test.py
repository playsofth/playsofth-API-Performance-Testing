import statistics
from locust import HttpUser, task, between

class JsonPlaceholderUser(HttpUser):
    host = "https://jsonplaceholder.typicode.com"
    wait_time = between(1, 2)  # Felhasználók közötti várakozási idő (szimulált "think time")

    def on_start(self):
        """A teszt elején fut le (hasonló a Create Session-höz)"""
        self.max_avg_time_ms = 500

    @task
    def test_users_endpoint(self):
        self._measure_performance("/users")

    @task
    def test_posts_endpoint(self):
        self._measure_performance("/posts")

    @task
    def test_comments_endpoint(self):
        self._measure_performance("/comments")

    def _measure_performance(self, endpoint):
        with self.client.get(endpoint, catch_response=True) as response:
            if response.status_code == 200:
                # A Locust automatikusan méri a válaszidőt (response.elapsed.total_seconds())
                response_time_ms = response.elapsed.total_seconds() * 1000
                
                if response_time_ms > self.max_avg_time_ms:
                    response.failure(f"Slow response: {response_time_ms}ms on {endpoint}")
            else:
                response.failure(f"Failed with status code: {response.status_code}")