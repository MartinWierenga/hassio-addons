import os
import time
import requests

def get_env_var(name, default=None, cast=str):
    value = os.getenv(name, default)
    if value is not None:
        try:
            return cast(value)
        except Exception:
            return default
    return default

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

def monitor_addon():
    slug = get_env_var("ADDON_SLUG")
    cpu_threshold = get_env_var("CPU_THRESHOLD", 80, int)
    memory_threshold = get_env_var("MEMORY_THRESHOLD", 80, int)
    interval = get_env_var("INTERVAL", 60, int)
    cpu_failures_limit = get_env_var("CPU_FAILURES", 3, int)
    memory_failures_limit = get_env_var("MEMORY_FAILURES", 3, int)
    auto_restart = str(get_env_var("AUTO_RESTART", "true")).lower() == "true"

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

            print(f"[{slug}] CPU: {cpu}% ({cpu_failures}/{cpu_failures_limit}), "
                  f"Memory: {mem}% ({mem_failures}/{memory_failures_limit})")

            if auto_restart:
                if cpu_failures >= cpu_failures_limit or mem_failures >= memory_failures_limit:
                    print(f"[{slug}] Restarting due to threshold exceeded.")
                    restart_addon(slug)
                    cpu_failures = 0
                    mem_failures = 0
        else:
            print(f"[{slug}] Could not get stats.")

        time.sleep(interval)

if __name__ == "__main__":
    monitor_addon()