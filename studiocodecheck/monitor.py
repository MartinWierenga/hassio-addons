import os
import time
import sys
import logging
import docker
import requests
import threading
import csv
from datetime import datetime
from logging.handlers import RotatingFileHandler
from http.server import HTTPServer, BaseHTTPRequestHandler

# If using MQTT logging, import paho-mqtt.
try:
    import paho.mqtt.client as mqtt
except ImportError:
    mqtt = None

# ----------------------------
# Read configuration from environment variables
# ----------------------------
CPU_THRESHOLD = float(os.getenv("CPU_THRESHOLD", "5"))
MEM_THRESHOLD = float(os.getenv("MEM_THRESHOLD", "5"))
CHECK_INTERVAL = int(os.getenv("CHECK_INTERVAL", "60"))
FAILURE_COUNT = int(os.getenv("FAILURE_COUNT", "3"))
CONTAINER_NAME = os.getenv("CONTAINER_NAME", "addon_a0d7b954_vscode")

# Boolean toggle – if true then use MQTT logging, else use local logging.
USE_MQTT_LOGGING = os.getenv("USE_MQTT_LOGGING", "false").lower() == "true"
LOG_FILE_MAX_BYTES = int(os.getenv("LOG_FILE_MAX_BYTES", "1048576"))
LOG_FILE_BACKUP_COUNT = int(os.getenv("LOG_FILE_BACKUP_COUNT", "3"))
MQTT_BROKER = os.getenv("MQTT_BROKER", "")
MQTT_PORT = int(os.getenv("MQTT_PORT", "1883"))
MQTT_TOPIC = os.getenv("MQTT_TOPIC", "homeassistant/studio_code_logs")
MQTT_USERNAME = os.getenv("MQTT_USERNAME", "")
MQTT_PASSWORD = os.getenv("MQTT_PASSWORD", "")

# Option to enable/disable automatic restart of the monitored container.
ENABLE_AUTO_RESTART = os.getenv("ENABLE_AUTO_RESTART", "true").lower() == "true"

# Enable notifications (repair notification) if set to true.
ENABLE_NOTIFICATIONS = os.getenv("ENABLE_NOTIFICATIONS", "false").lower() == "true"
NOTIFICATION_TITLE = os.getenv("NOTIFICATION_TITLE", "Studio Code Server Checker Repair")
HOMEASSISTANT_URL = os.getenv("HOMEASSISTANT_URL", "http://supervisor/core")
HASSIO_TOKEN = os.getenv("HASSIO_TOKEN", "")

# Health check port for the add-on container itself.
HEALTHCHECK_PORT = int(os.getenv("HEALTHCHECK_PORT", "8080"))

# Historical tracking options.
ENABLE_HISTORICAL_TRACKING = os.getenv("ENABLE_HISTORICAL_TRACKING", "true").lower() == "true"
HISTORICAL_TRACKING_FILE = os.getenv("HISTORICAL_TRACKING_FILE", "/data/historical_usage.csv")

# ----------------------------
# Setup Logging Handlers
# ----------------------------
logger = logging.getLogger("StudioCodeChecker")
logger.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s %(levelname)s: %(message)s')

# Console handler for output to stdout
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)
console_handler.setFormatter(formatter)
logger.addHandler(console_handler)

if not USE_MQTT_LOGGING:
    # Local logging using a rotating file handler.
    log_file = '/data/studio_code_checker.log'
    file_handler = RotatingFileHandler(
        log_file,
        maxBytes=LOG_FILE_MAX_BYTES,
        backupCount=LOG_FILE_BACKUP_COUNT
    )
    file_handler.setLevel(logging.INFO)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
else:
    if mqtt is None:
        logger.error("paho-mqtt library not found. Please install it.")
        sys.exit(1)
    
    # Custom MQTT logging handler.
    class MQTTLoggingHandler(logging.Handler):
        def __init__(self, broker, port, topic, username="", password=""):
            super().__init__()
            self.topic = topic
            self.client = mqtt.Client()
            # Set authentication credentials if provided.
            if username:
                self.client.username_pw_set(username, password)
            try:
                self.client.connect(broker, port, 60)
                self.client.loop_start()
            except Exception as e:
                logger.error(f"Error connecting to MQTT broker: {e}")

        def emit(self, record):
            try:
                msg = self.format(record)
                self.client.publish(self.topic, payload=msg)
            except Exception as e:
                logger.error(f"MQTT logging error: {e}")

    mqtt_handler = MQTTLoggingHandler(MQTT_BROKER, MQTT_PORT, MQTT_TOPIC, MQTT_USERNAME, MQTT_PASSWORD)
    mqtt_handler.setLevel(logging.INFO)
    mqtt_handler.setFormatter(formatter)
    logger.addHandler(mqtt_handler)

# ----------------------------
# Health Check HTTP Server
# ----------------------------
class HealthCheckHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.send_header("Content-type", "text/plain")
            self.end_headers()
            self.wfile.write(b"OK")
        else:
            self.send_response(404)
            self.end_headers()

    # Suppress the default HTTP server logging.
    def log_message(self, format, *args):
        return

def run_healthcheck_server(port):
    server = HTTPServer(('', port), HealthCheckHandler)
    logger.info(f"Health check server starting on port {port}")
    server.serve_forever()

# Start health check server in a daemon thread.
health_thread = threading.Thread(target=run_healthcheck_server, args=(HEALTHCHECK_PORT,))
health_thread.daemon = True
health_thread.start()

# ----------------------------
# Function to send a repair notification using Home Assistant's persistent_notifications.
# ----------------------------
def send_repair_notification(message):
    if not ENABLE_NOTIFICATIONS:
        return

    url = f"{HOMEASSISTANT_URL}/api/services/persistent_notification/create"
    headers = {"Content-Type": "application/json"}
    if HASSIO_TOKEN:
        headers["Authorization"] = f"Bearer {HASSIO_TOKEN}"
    payload = {
        "title": NOTIFICATION_TITLE,
        "message": message,
        "notification_id": "studio_code_server_checker_repair"
    }
    try:
        response = requests.post(url, json=payload, headers=headers, timeout=10)
        if response.status_code == 200:
            logger.info("Repair notification sent successfully.")
        else:
            logger.error(f"Repair notification failed with status code {response.status_code}: {response.text}")
    except Exception as e:
        logger.error(f"Error sending repair notification: {e}")

# ----------------------------
# Function to calculate CPU usage percentage
# ----------------------------
def calculate_cpu_percent(cpu_stats, precpu_stats):
    cpu_delta = cpu_stats['cpu_usage']['total_usage'] - precpu_stats['cpu_usage']['total_usage']
    system_delta = cpu_stats.get('system_cpu_usage', 0) - precpu_stats.get('system_cpu_usage', 0)
    cpu_count = len(cpu_stats['cpu_usage'].get('percpu_usage', []))
    if system_delta > 0 and cpu_delta > 0:
        return (cpu_delta / system_delta) * cpu_count * 100.0
    return 0.0

# ----------------------------
# Record historical metrics to a CSV file.
# ----------------------------
def record_historical_metrics(timestamp, cpu, mem):
    try:
        file_exists = os.path.exists(HISTORICAL_TRACKING_FILE)
        with open(HISTORICAL_TRACKING_FILE, 'a', newline='') as csvfile:
            writer = csv.writer(csvfile)
            if not file_exists:
                writer.writerow(["timestamp", "cpu_percent", "memory_percent"])
            writer.writerow([timestamp, f"{cpu:.2f}", f"{mem:.2f}"])
    except Exception as e:
        logger.error(f"Error recording historical metrics: {e}")

# ----------------------------
# Main monitoring function
# ----------------------------
def monitor_container(container_name):
    client = docker.from_env()

    try:
        container = client.containers.get(container_name)
    except docker.errors.NotFound:
        logger.error(f"Container '{container_name}' not found. Exiting.")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Error accessing Docker daemon: {e}")
        sys.exit(1)

    logger.info(f"Monitoring container '{container_name}' every {CHECK_INTERVAL} seconds...")
    failure_counter = 0

    while True:
        try:
            # Retrieve a snapshot of container stats.
            stats = container.stats(stream=False)
            cpu_stats = stats.get('cpu_stats', {})
            precpu_stats = stats.get('precpu_stats', {})
            cpu_percent = calculate_cpu_percent(cpu_stats, precpu_stats)

            mem_stats = stats.get('memory_stats', {})
            mem_usage = mem_stats.get('usage', 0)
            mem_limit = mem_stats.get('limit', 1)  # Avoid division by zero.
            mem_percent = (mem_usage / mem_limit) * 100.0

            logger.info(f"Container: {container_name} | CPU: {cpu_percent:.2f}% | Memory: {mem_usage}/{mem_limit} bytes ({mem_percent:.2f}%)")
            
            # Record historical data if enabled.
            if ENABLE_HISTORICAL_TRACKING:
                timestamp = datetime.now().isoformat()
                record_historical_metrics(timestamp, cpu_percent, mem_percent)
            
            # Increase failure counter if thresholds are exceeded.
            if cpu_percent > CPU_THRESHOLD or mem_percent > MEM_THRESHOLD:
                failure_counter += 1
                logger.warning(f"Threshold exceeded ({failure_counter}/{FAILURE_COUNT}).")
            else:
                failure_counter = 0

            # If consecutive failures exceed the limit, send a repair notification and optionally restart.
            if failure_counter >= FAILURE_COUNT:
                alert_msg = (f"Repair required: High resource usage for {failure_counter} consecutive checks. "
                             f"CPU: {cpu_percent:.2f}%, Memory: {mem_percent:.2f}% on container '{container_name}'.")
                logger.warning(alert_msg)
                send_repair_notification(alert_msg)
                if ENABLE_AUTO_RESTART:
                    container.restart()
                    logger.info("Container restarted. Waiting 10 seconds for stabilization...")
                    time.sleep(10)
                else:
                    logger.info("Automatic restart is disabled. Please repair the container manually.")
                failure_counter = 0
        except Exception as e:
            logger.error(f"Error processing container stats: {e}")
        time.sleep(CHECK_INTERVAL)

if __name__ == '__main__':
    monitor_container(CONTAINER_NAME)
# ----------------------------