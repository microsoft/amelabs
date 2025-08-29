#!/bin/bash


REDHAT_PRIVATE_IP=$1
echo "Received RedHatIP: $REDHAT_PRIVATE_IP"


# Configuration
CEF_SCRIPT="/opt/cef_sender.sh"
CRON_MARKER="# CEF message sender"


# Use this IP when configuring Ubuntu to send logs to Red Hat
# For example: logger -n
# Create the script that sends CEF messages
sudo tee "$CEF_SCRIPT" > /dev/null <<EOF
#!/bin/bash

REMOTE_IP="$REDHAT_PRIVATE_IP"
REMOTE_PORT=514
HOSTNAME=\$(hostname)

generate_cef() {
  local vendor=\$((RANDOM % 3))
  case \$vendor in
    0)
      echo "CEF:0|PaloAlto|PAN-OS|10.1|THREAT|Threat Detected|5|src=10.0.0.1 dst=10.0.0.5 spt=443 dpt=514 proto=TCP act=blocked msg=Virus detected deviceInboundInterface=ethernet1/1 deviceOutboundInterface=ethernet1/2"
      ;;
    1)
      echo "CEF:0|CyberArk|Vault|12.2|ACCEPT|User Login|3|src=10.0.0.2 suser=admin cs1Label=Safe cs1=Root cs2Label=Account cs2=Domain\\\\Administrator msg=Successful login to Vault"
      ;;
    2)
      echo "CEF:0|Fortinet|FortiGate|7.0|utm-1|Blocked Web Page|6|src=10.0.0.3 dst=8.8.8.8 spt=52456 dpt=80 request=http://example.com act=blocked deviceFacility=proxy"
      ;;
  esac
}

for i in {1..5}; do
  cef_msg=\$(generate_cef)
  logger -n "\$REMOTE_IP" -P "\$REMOTE_PORT" -d -t CEF "\$cef_msg"
  sleep 0.5  # Small delay between messages
done
EOF

# Make it executable
sudo chmod +x "$CEF_SCRIPT"

# Add cron job with 30-second interval 
(crontab -l 2>/dev/null | grep -v "$CRON_MARKER" | grep -v "$CEF_SCRIPT" ; cat <<EOF
$CRON_MARKER
* * * * * $CEF_SCRIPT
* * * * * sleep 30 && $CEF_SCRIPT
EOF
) | sudo crontab -

echo "CEF sender script and cron job installed."
