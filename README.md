### Linux Scripting Projects

A collection of practical Bash and shell scripting tools designed to automate and streamline common system administration tasks across Linux environments.

Created and maintained by Karl Vietmeier / KCV Consulting
Licensed under the Apache License 2.0

---

Bash, ksh, csh, python, misc Linux and Macc OS tools.  

I may add my cloud-init scripts here as well but if you want to see them now they are in the Terraform repo.  

---

### NOTES

Recently added scripts for GCP, AWS, and VAST Data Clusters.


Folders:
```text
.
├── archive
├── aws
├── gcp
├── bash_env
├── sys_info
├── Examples
├── fio
└── vast
```


---

**dool**: dstat has been replaced by "dool" - csv output is broken and dstat is no longer active.

* [Dool GitHub](https://github.com/scottchiefbaker/dool/blob/master/README.md)
* [Use Alien](https://www.serverlab.ca/tutorials/linux/administration-linux/how-install-rpm-packages-on-ubuntu-using-alien/)

* Install dool with Ansible

   ```yaml
     # Install dool - multi-step - replaces dstat
     - name: Download dool dool-1.3.0-1.noarch.rpm
       get_url: 
         url: "{{ dool_url }}"
         dest: /tmp
       tags:
         - apt

     - name: Install dool with alien
       command: alien -i "{{ dool_pkg }}"
       args: 
         chdir: /tmp
       tags:
         - apt
  ```

* Run tools in the background - this small function lets you put a command into the background and logout:

   ```bash
     # Run dool in background
     bkground_dool () {
     run_dool="$@"
     ${run_dool} &>/dev/null &
     disown
   }

   # dool command line
   dool_io="dool $dool_io_flags --output $OUTPUTFILE_io $linterval $count"
   dool_process="dool $dool_proc_flags --output $OUTPUTFILE_proc $linterval $count"
   dool_sys="dool $dool_sys_flags --output $OUTPUTFILE_sys $linterval $count"

   ###-- Main 
   bkground_dool ${dool_process}
   bkground_dool ${dool_io}
   bkground_dool ${dool_sys}

   ```

---
In vast folder - 
**net_probe.py** -  Monitor Replication Links

In a VAST replication scenario across a cloud uplink, watch for these specific indicators in your CSV:

* **Latency Spikes**: If latency jumps from 5ms to 150ms consistently, you likely have congestion on the ExpressRoute.
* **Error Code 11** (Resource temporarily unavailable): Often indicates the local system can't open more sockets
* **Error Code 110** (Connection timed out): This is the "Link Down" indicator. If both ports (49001 and 49002) show this at the same timestamp, the uplink has failed.

Usage examples

49001:
```bash
export TARGET_IP=10.x.x.x TARGET_PORT=49001 LOG_FILE=vast_49001.csv
nohup python3 net_probe.py > monitor_49001.log 2>&1 &
```

49002:
```bash
export TARGET_IP=10.x.x.x TARGET_PORT=49002 LOG_FILE=vast_49002.csv
nohup python3 net_probe.py > monitor_49002.log 2>&1 &
```

**Catching Jitter**: Set export INTERVAL=0.1. Jitter often happens in millisecond bursts that a 1-second interval will miss.


---

Using FIO:

* [FIO](https://fio.readthedocs.io/en/latest/fio_doc.html)
* [FIO Git Repo](https://github.com/axboe/fio)
* [FIO-plot Git Repo](https://github.com/louwrentius/fio-plot)

The FIO directory has bash scripts and FIO job files for testing attached disks and mounted storage.

Note on FIO - You should always download and compile the latest version, like iperf and sockperf: the versions in the online repos are old and never have the right libraries compiled in.

---

### Linux Performance Lab Bootstrapper

A robust, idempotent bash script to provision a fresh Linux system (Debian/Ubuntu or RHEL/Rocky) into a fully equipped performance testing, benchmarking, and observability environment.

#### Overview

When setting up test environments, OS background tasks and missing dependencies can ruin benchmark runs. `compiletools_full.sh` automates the configuration of a base Linux OS by handling system locks, disabling automatic upgrades that interrupt testing, establishing a standard user environment, and installing critical benchmarking and deep-kernel eBPF analysis tools from source.

#### Key Features

* **Idempotent Execution:** Safe to run multiple times. Source builds use `.build_success` markers to avoid recompiling existing tools, while `.bashrc` modifications are checked for prior existence.
* **Cloud/OCI Aware Time Sync:** Automatically configures `chrony` by polling cloud metadata endpoints (e.g., `169.254.169.254`) for highly accurate timekeeping.
* **System Stability:** Disables automatic OS updates (`unattended-upgrades`, `dnf-automatic`) and firewalls (`ufw`, `firewalld`) to ensure consistent, interference-free benchmark results.
* **Standardized User Environment:** Creates a `labuser` account with passwordless sudo privileges. Deploys common shell aliases and vim settings for both `root` and `labuser`.
* **Deep Network Observability & eBPF:** Pre-installs essential networking tools (`mtr`, `tcpdump`, `tshark`, `ethtool`, `socat`) alongside advanced eBPF tracing utilities (`bpftrace`, `bcc-tools`/`bpfcc-tools`, and `pwru` from Cilium).
* **Robust Dependency Management:** Automatically handles tricky compilation dependencies across operating systems (including `libboost-all-dev` for Debian and RDMA core headers).
* **Source-Compiled Tools:** Automatically clones, configures, and installs the latest versions of:
  * [Dool](https://github.com/scottchiefbaker/dool) - Modern, Python 3 compatible `dstat` replacement.
  * [Fio](https://github.com/axboe/fio) - Flexible I/O Tester for storage benchmarking.
  * [iPerf3](https://github.com/esnet/iperf) - Network bandwidth measurement.
  * [Sockperf](https://github.com/mellanox/sockperf) - High-performance network latency testing.
  * [Elbencho](https://github.com/breuner/elbencho) - Distributed storage benchmark (includes automated RPM packaging fixes for RHEL/Rocky 9).

#### Supported Operating Systems

* **Debian-based:** Ubuntu 20.04 / 22.04 / 24.04, Debian 11 / 12
* **RHEL-based:** RHEL, Rocky Linux, AlmaLinux, CentOS Stream (Versions 8 & 9)

#### Usage

You can run this script directly on a fresh system via SSH, or inject it as a cloud-init user-data script during instance provisioning.

```bash
# Download the script
curl -O [https://raw.githubusercontent.com/](https://raw.githubusercontent.com/)<YOUR-USERNAME>/<YOUR-REPO>/main/compiletools_full.sh

# Make it executable
chmod +x compiletools_full.sh

# Execute as root
sudo ./compiletools_full.sh
