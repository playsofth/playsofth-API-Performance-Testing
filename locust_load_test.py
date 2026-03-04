from locust import HttpUser, task, between

class JsonPlaceholderUser(HttpUser):
    """
    Simulates a user interacting with the JSONPlaceholder API.
    """
    # Setting a long wait time to avoid being blocked by the server
    wait_time = between(5, 10)
    
    # Target host URL
    host = "https://jsonplaceholder.typicode.com"

    @task(3)
    def fetch_posts(self):
        """Fetches the list of posts and validates the response."""
        with self.client.get("/posts", catch_response=True) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Request failed with status: {response.status_code}")

    @task(1)
    def fetch_users(self):
        """Fetches the list of users."""
        self.client.get("/users")

    @task(1)
    def fetch_comments(self):
        """Fetches comments for a specific post."""
        self.client.get("/comments?postId=1")