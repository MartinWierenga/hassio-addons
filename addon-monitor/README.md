# Addon Monitor

Monitors configured Home Assistant add-ons for CPU and memory usage, and can auto-restart them if thresholds are exceeded.

## Configuration

Edit the add-on options in the Home Assistant UI or `config.json`:

- `slug`: Add-on slug (e.g., `core_mosquitto`)
- `cpu_threshold`: CPU usage percent threshold
- `memory_threshold`: Memory usage percent threshold
- `interval`: Check interval in seconds
- `cpu_failures`: Number of consecutive CPU threshold breaches before restart
- `memory_failures`: Number of consecutive memory threshold breaches before restart
- `auto_restart`: Enable or disable auto-restart

## Supervisor API

This add-on uses the Home Assistant Supervisor API and requires the `SUPERVISOR_TOKEN` environment variable (provided automatically in add-ons).