import httpx
import time
import sys

def test_backend():
    base_url = "http://127.0.0.1:8001"
    print(f"Testing backend at {base_url}...")
    
    # 1. Check health
    try:
        r = httpx.get(f"{base_url}/health", timeout=5)
        print("Health status:", r.status_code, r.json())
    except Exception as e:
        print("Backend is NOT running or not reachable on port 8001.")
        print("Error details:", e)
        sys.exit(1)

    # 2. Trigger scenario 1
    print("\nTriggering Scenario 1 via POST /run-scenario/1...")
    try:
        r = httpx.post(f"{base_url}/run-scenario/1", timeout=5)
        if r.status_code != 200:
            print("Failed to run scenario. Status code:", r.status_code)
            print("Response:", r.text)
            sys.exit(1)
        data = r.json()
        plan_id = data.get("plan_id")
        print("Successfully triggered. Plan ID:", plan_id)
    except Exception as e:
        print("Error triggering scenario:", e)
        sys.exit(1)

    # 3. Poll logs for 15 seconds
    print(f"\nPolling /logs/{plan_id} for progress...")
    for i in range(10):
        time.sleep(2)
        try:
            r = httpx.get(f"{base_url}/logs/{plan_id}", timeout=5)
            log_data = r.json()
            print(f"Poll #{i+1} at {time.strftime('%H:%M:%S')}: Status = {log_data.get('status')}")
            print(f"  signals in log: {log_data.get('signals') is not None}")
            print(f"  insight in log: {log_data.get('insight_report') is not None}")
            print(f"  action plan in log: {log_data.get('action_plan') is not None}")
            if log_data.get("status") in ["pending_approval", "complete", "rejected"]:
                print("Pipeline reached end state or approval state!")
                break
        except Exception as e:
            print(f"Error polling logs: {e}")

if __name__ == "__main__":
    test_backend()
