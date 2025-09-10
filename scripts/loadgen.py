#!/usr/bin/env python3
"""
loadgen.py — Generate sample load against ToDo service
Simulates ToDo creation and read requests to test scaling & alerts.
"""

import argparse
import json
import random
import string
import time
import requests
from concurrent.futures import ThreadPoolExecutor

def random_todo():
    return {
        "title": "Task-" + ''.join(random.choices(string.ascii_letters, k=6)),
        "description": "Auto-generated task",
        "completed": False
    }

def worker(api_url, token=None):
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"

    todo = random_todo()
    try:
        # Create ToDo
        requests.post(f"{api_url}/todos", data=json.dumps(todo), headers=headers, timeout=3)
        # Read ToDos
        requests.get(f"{api_url}/todos", headers=headers, timeout=3)
    except Exception as e:
        print(f"[ERROR] {e}")

def main():
    parser = argparse.ArgumentParser(description="Load generator for ToDo service")
    parser.add_argument("--url", required=True, help="Base URL of ToDo service, e.g. http://localhost:8080")
    parser.add_argument("--token", help="JWT token if auth is enabled")
    parser.add_argument("--workers", type=int, default=10, help="Concurrent workers")
    parser.add_argument("--duration", type=int, default=60, help="Duration in seconds")
    args = parser.parse_args()

    print(f"Starting load generation on {args.url} for {args.duration}s with {args.workers} workers")
    end_time = time.time() + args.duration
    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        while time.time() < end_time:
            executor.submit(worker, args.url, args.token)
            time.sleep(0.1)

    print("Load test completed.")

if __name__ == "__main__":
    main()
