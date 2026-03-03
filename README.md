"# playsofth-API-Performance-Testing" 
API Performance Testing Project
Author: Zsolt Hábeller

Overview
This project performs automated API performance testing on the JSONPlaceholder endpoints using Robot Framework. It measures response times across multiple requests and provides a detailed statistical analysis of the API's behavior.

Key Features
Response Time Measurement: Calculates the time taken for each GET request in milliseconds.

Statistical Analysis: Automatically computes the Mean (Average), Maximum, and Standard Deviation of response times using Python's statistics module.

Performance Validation: Validates that both individual and average response times stay below a defined threshold (e.g., 500ms).

Multi-Endpoint Support: Executes tests against /users, /posts, and /comments.

Prerequisites
To run this project, you need Python installed along with the following libraries:

Robot Framework

RequestsLibrary

Installation
Install the necessary dependencies via terminal:

Bash
pip install robotframework robotframework-requests
Folder Structure
pythontest.robot: The main test suite containing the performance logic.

results/: Directory for the generated report.html and log.html files.

Usage
Run the performance tests using the following command:

Bash
robot -d results pythontest.robot
Expected Console Output
During execution, the project logs the following metrics to the console for each endpoint:
Average: 124.50 ms | Max: 210.15 ms | StdDev: 12.40 ms

