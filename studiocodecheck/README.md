# Studio Code Server Checker

The Studio Code Server Checker is a Home Assistant add-on that monitors your Studio Code Server add-on (or any Docker container) for CPU and memory leaks. When resource usage exceeds defined thresholds for a configurable number of consecutive checks, it sends a repair notification using Home Assistant persistent notifications and, optionally, automatically restarts the problematic container.

## Features

- **Resource Monitoring:**  
  Monitors CPU and memory usage of the specified Docker container.
  
- **Configurable Options:**  
  Adjust CPU/memory thresholds, check intervals, allowed consecutive failures, and more via the add-on options.
  
- **Repair Notifications:**  
  Uses Home Assistant's persistent notification service to alert you when repairs are required.
  
- **Auto Restart:**  
  Optionally restart the monitored container automatically if resource usage remains high.
  
- **Logging:**  
  Choose between local logging (with rotation) or MQTT logging (with authentication).
  
- **Historical Tracking:**  
  Records timestamped CPU and memory usage data into a CSV file for later analysis.
  
- **Health Check:**  
  A built-in HTTP endpoint (`/health`) allows you or the Supervisor to verify that the add-on is running.

## Installation

1. **Add the Repository to Home Assistant:**

   In Home Assistant, navigate to **Supervisor** > **Add-on Store**. Click the three dots in the top right corner and select **Repositories**.  
   Then add the following URL: https://github.com/MartinWierenga/hassio-addons

   
2. **Install the Add-on:**

Once the repository is added, you will see the **Studio Code Server Checker** (slug: `studiocodecheck`) in the add-on list. Click it and then click **Install**.

3. **Configure the Add-on:**

Edit the add-on options as needed (e.g., set CPU/memory thresholds, enable MQTT logging and authentication if desired, configure the check interval, auto restart, and historical tracking).

4. **Start the Add-on:**

After configuration, click **Start**. You can monitor logs from the add-on page.

## Usage

- **Repair Notifications:**  
When the add-on detects sustained high resource usage for the target container, it sends a repair notification to Home Assistant's persistent notifications.

- **Historical Data:**  
Historical CPU and memory usage data is saved to `/data/historical_usage.csv`. You can import this CSV into your preferred graphing or analysis tool.

- **Health Check:**  
Visit `http://<ADDON_IP>:8080/health` (or your configured port) to verify that the add-on is running.

## Repository

This add-on is maintained in the [hassio-addons GitHub repository](https://github.com/MartinWierenga/hassio-addons) under the folder `studiocodecheck`.

---

## License

This add-on is distributed under the MIT License. See the [LICENSE](LICENSE) file for more details.