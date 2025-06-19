import os
import json
import time
import requests
import threading

CONFIG_PATH = "/data/options.json"

def get_config():
    with open(CONFIG_PATH, "r") as f:
        return json.load(f)

def get_addon_stats(slug):
    url = f"http://supervisor/addons/{slug}/stats"
    headers = {"Authorization": f"Bearer {os.getenv('SUPERVISOR_TOKEN')}"}
    try:
        resp = requests.get(url, headers=headers, timeout=10)
        if resp.status_code == 200:
            return resp.json()["data"]
    except Exception as e:
        print(f"Error getting stats for {slug}: {e}")
    return None

def restart_addon(slug):
    url = f"http://supervisor/addons/{slug}/restart"
    headers = {"Authorization": f"Bearer {os.getenv('SUPERVISOR_TOKEN')}"}
    try:
        requests.post(url, headers=headers, timeout=10)
        print(f"Restart command sent to {slug}")
    except Exception as e:
        print(f"Error restarting {slug}: {e}")

def monitor_addon(addon):
    slug = addon["slug"]
    cpu_threshold = addon["cpu_threshold"]
    memory_threshold = addon["memory_threshold"]
    interval = addon["interval"]
    cpu_failures = 0
    mem_failures = 0

    while True:
        stats = get_addon_stats(slug)
        if stats:
            cpu = stats.get("cpu_percent", 0)
            mem = stats.get("memory_percent", 0)
            if cpu > cpu_threshold:
                cpu_failures += 1
            else:
                cpu_failures = 0
            if mem > memory_threshold:
                mem_failures += 1
            else:
                mem_failures = 0

            print(f"[{slug}] CPU: {cpu}% ({cpu_failures}/{addon['cpu_failures']}), "
                  f"Memory: {mem}% ({mem_failures}/{addon['memory_failures']})")

            if addon["auto_restart"]:
                if cpu_failures >= addon["cpu_failures"] or mem_failures >= addon["memory_failures"]:
                    print(f"[{slug}] Restarting due to threshold exceeded.")
                    restart_addon(slug)
                    cpu_failures = 0
                    mem_failures = 0
        else:
            print(f"[{slug}] Could not get stats.")

        time.sleep(interval)

def main():
    config = get_config()
    threads = []
    for addon in config["addons"]:
        t = threading.Thread(target=monitor_addon, args=(addon,), daemon=True)
        t.start()
        threads.append(t)
    # Keep main thread alive
    while True:
        time.sleep(60)

if __name__ == "__main__":
    main()