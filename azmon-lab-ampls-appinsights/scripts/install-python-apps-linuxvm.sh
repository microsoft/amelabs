#!/usr/bin/env bash
set -euo pipefail

# Set HOME if not already set (needed for VM custom script extension)
export HOME=${HOME:-/home/azureuser}

if [[ $# -lt 1 ]]; then
  cat <<EOF
Usage: $0 <APPLICATION_INSIGHTS_CONNECTION_STRING>
Deploys Flask Sample App with Azure Monitor OpenTelemetry Distro
EOF
  exit 1
fi

AI_CONN_STR="$1"

BASE_DIR="/home/azureuser/flask-sample"
echo "Creating base directory at $BASE_DIR"
mkdir -p "$BASE_DIR"

echo "→ Deploying Flask Sample App to $BASE_DIR"

# Base deps
sudo apt-get update -y
sudo apt-get install -y python3-venv python3-pip curl unzip cron
sudo systemctl enable --now cron

# Python venv + libs
python3 -m venv "$BASE_DIR/.venv"
source "$BASE_DIR/.venv/bin/activate"
pip install --upgrade pip
pip install \
  flask \
  azure-monitor-opentelemetry

# Flask app
cat > "$BASE_DIR/flask_app.py" <<'EOF'
from azure.monitor.opentelemetry import configure_azure_monitor

from random import randint
import logging, os
from opentelemetry import trace

conn_str = os.environ["APPLICATIONINSIGHTS_CONNECTION_STRING"]

configure_azure_monitor(
    connection_string=conn_str,
    enable_live_metrics=True
)

from flask import Flask, request

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route("/rolldice")
def roll_dice():
    player = request.args.get('player', default=None, type=str)
    result = str(roll())
    if player:
        logger.warning("%s is rolling the dice: %s", player, result)
    else:
        logger.warning("Anonymous player is rolling the dice: %s", result)
    return result

@app.route("/exception")
def exception():
    raise Exception("Hit an exception")

def roll():
    return randint(1, 6)

if __name__ == "__main__":
    # Bind explicitly to loopback (your cron calls 127.0.0.1)
    app.run(host="127.0.0.1", port=5000)
EOF

# Put env vars in a systemd-friendly place (/etc/environment reads KEY=VALUE)
# Quote the connection string to be safe with special chars/spaces.
AI_ESC="${AI_CONN_STR//\"/\\\"}"  # escape any double-quotes just in case
sudo sed -i '/^APPLICATIONINSIGHTS_CONNECTION_STRING/d' /etc/environment
sudo sed -i '/^OTEL_RESOURCE_ATTRIBUTES/d' /etc/environment
sudo sed -i '/^OTEL_SERVICE_NAME/d' /etc/environment
sudo tee -a /etc/environment >/dev/null <<EOF
APPLICATIONINSIGHTS_CONNECTION_STRING="$AI_ESC"
OTEL_RESOURCE_ATTRIBUTES=service.instance.id=azmon-ubuntu-vm
OTEL_SERVICE_NAME=flaskapp-rolldice
EOF

# Ensure the files are owned by the runtime user
sudo chown -R azureuser:azureuser "$BASE_DIR"

# systemd unit
sudo tee /etc/systemd/system/flaskapp.service >/dev/null <<'EOF'
[Unit]
Description=Flask Sample App (flaskapp-rolldice)
After=network-online.target
Wants=network-online.target
[Service]
Type=simple
User=azureuser
Group=azureuser
WorkingDirectory=/home/azureuser/flask-sample
EnvironmentFile=/etc/environment
Environment=PYTHONUNBUFFERED=1
ExecStart=/home/azureuser/flask-sample/.venv/bin/python /home/azureuser/flask-sample/flask_app.py
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Start now and on every boot
sudo systemctl daemon-reload
sudo systemctl enable --now flaskapp.service

# Show brief status
systemctl status flaskapp --no-pager || true

echo "→ Waiting for Flask app to become ready on 127.0.0.1:5000 …"
for i in {1..30}; do
  if curl -fsS "http://127.0.0.1:5000/rolldice" >/dev/null; then
    echo "Flask app is responding."
    break
  fi
  sleep 1
  if (( i == 30 )); then
    echo "WARNING: Flask app didn't respond within 30s. Check logs: sudo journalctl -u flaskapp -n 200 --no-pager" >&2
  fi
done
# ─── Traffic generator via /etc/cron.d ──────────────────────────────────────
echo "Creating jobs to call Flask app every 15s via /etc/cron.d."

sudo tee /etc/cron.d/call_flask_app >/dev/null <<'EOF'
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# CALL_FLASK_APP_15S: hit Flask endpoints 4/min (every 15s)
* * * * * root . /etc/environment; for i in {1..4}; do curl -s "http://127.0.0.1:5000/rolldice?player=Player1" >/dev/null; curl -s "http://127.0.0.1:5000/exception" >/dev/null; sleep 15; done
EOF

sudo chmod 644 /etc/cron.d/call_flask_app
sudo systemctl reload cron || true

echo "Cron job installed at /etc/cron.d/call_flask_app"
echo "→ Flask Sample App should be up on port 5000."