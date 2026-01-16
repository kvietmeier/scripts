#!/usr/bin/env python3
# A simple TCP probe script that attempts to connect to a specified IP and port at regular intervals.
# It logs the success or failure of each connection attempt along with the time taken.
# Configuration is done via environment variables:
# TARGET_IP: The target IP address to connect to (default: 127.0. 1)
# TARGET_PORT: The target port to connect to (default: 49001)
# INTERVAL: Time interval between connection attempts in seconds (default: 0.5)
# TIMEOUT: Connection timeout in seconds (default: 1.0) 
# Usage: Set the environment variables as needed and run the script.
# Example:
#   export TARGET_IP=
#   export TARGET_PORT=8080
#   export INTERVAL=1.0
#   export TIMEOUT=2.0
#   python3 myip.sh



import socket
import time
import os
import sys

# Get config from Env Vars (defaults provided)
TARGET_IP = os.getenv('TARGET_IP', '127.0.0.1')
TARGET_PORT = int(os.getenv('TARGET_PORT', '49001'))
INTERVAL = float(os.getenv('INTERVAL', '0.5')) # 500ms
TIMEOUT = float(os.getenv('TIMEOUT', '1.0'))   # 1 second

print(f"Starting TCP Probe to {TARGET_IP}:{TARGET_PORT} every {INTERVAL}s")

def probe():
    while True:
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(TIMEOUT)
            start = time.time()
            
            result = sock.connect_ex((TARGET_IP, TARGET_PORT))
            
            duration = (time.time() - start) * 1000
            timestamp = time.strftime('%Y-%m-%d %H:%M:%S')

            if result == 0:
                print(f"[{timestamp}] OK | {duration:.2f}ms")
            else:
                print(f"[{timestamp}] FAIL | Error Code: {result}")
            
            sock.close()
        except Exception as e:
            print(f"[{timestamp}] ERROR | {e}")

        time.sleep(INTERVAL)

if __name__ == "__main__":
    probe()