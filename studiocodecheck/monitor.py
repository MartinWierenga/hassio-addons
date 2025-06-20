#!/usr/bin/env python3
import docker
import time
import logging
import json

logging.basicConfig(level=logging.INFO)

def load_config():
    # Home Assistant add-on configuration is usually provided via /data/options.json.
    config_path = "/data/options.json"
    try:
        with open(config_path, "r") as f:
            config = json.load(f)
        logging.info("Loaded configuration: %s", config)
    except Exception as e:
        logging.error("Error reading configuration: %s", e)
        config = {}
    return config

def get_containers(client, monitored_names):
    # Get all containers running on the host.
    all_containers = client.containers.list(all=True)
    if monitored_names:
        logging.info("Filtering containers based on configuration: %s", monitored_names)
        # Only include containers whose names are in the configured list.
        selected = [c for c in all_containers if c.name in monitored_names]
    else:
        # Fallback: select containers with a specific label that identifies Home Assistant add-ons.
        selected = [c for c in all_containers if "io.hass.addon" in c.labels]
    return selected

def get_stats(container):
    stats = container.stats(stream=False)
    # CPU stats are complex. Here we simply grab the total usage value.
    cpu_total = stats.get("cpu_stats", {}).get("cpu_usage", {}).get("total_usage", 0)
    mem_usage = stats.get("memory_stats", {}).get("usage", 0)
    return cpu_total, mem_usage

def main():
    config = load_config()
    # Expecting a list of container names in configuration.
    monitored_names = config.get("monitor_containers", [])
    
    client = docker.from_env()
    logging.info("Total containers on host: %s", len(client.containers.list(all=True)))
    
    while True:
        containers = get_containers(client, monitored_names)
        for container in containers:
            try:
                cpu, mem = get_stats(container)
                logging.info("Container: %s | CPU: %s | Memory: %s", container.name, cpu, mem)
            except Exception as e:
                logging.error("Error fetching stats for container %s: %s", container.name, e)
        time.sleep(10)  # Delay between measurements.

if __name__ == '__main__':
    main()
