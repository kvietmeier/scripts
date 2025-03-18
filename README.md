### Misc Linux Scripting Projects

---

Various scripts I have written for Linux projects.  

The OpenStack scripts were created for a Cinder project.
They are for displaying functionality more than being useful for practical work.

NOTE: dstat has been replaced by "dool" - csv output is broken and dstat is no longer active.

* [Dool GitHub](https://github.com/scottchiefbaker/dool/blob/master/README.md)
* [Use Alien](https://www.serverlab.ca/tutorials/linux/administration-linux/how-install-rpm-packages-on-ubuntu-using-alien/)

---

Install dool with Ansible

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

Run tools in the background - this small function lets you put a command into the background and logout:

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

Using FIO:

* [FIO](https://fio.readthedocs.io/en/latest/fio_doc.html)
* [FIO Git Repo](https://github.com/axboe/fio)
* [FIO-plot Git Repo](https://github.com/louwrentius/fio-plot)

The FIO directory has bash scripts and FIO job files for testing attached disks and mounted storage.

Note on FIO - You should always download and compile the latest version, like iperf and sockperf: the versions in the online repos are old and never have the right libraries compiled in.

Drop this in your cloud-init file:

``` yaml
  #
  ###------------ Compile Software ------------###
  # dool
  # FIO
  # iperf3
  # sockperf
  #
  - cd /root/git
  #
  ## Compile dool
  - git clone https://github.com/scottchiefbaker/dool.git
  - cd dool
  - ./install.py
  - cd ..
  #
  ## Compile FIO
  - git clone https://github.com/axboe/fio.git
  - cd fio
  - ./configure
  - make
  - make install
  - cd ..
  #
  # Compile/install iperf3
  - git clone "https://github.com/esnet/iperf.git"
  - cd iperf
  - ./configure
  - make
  - make install
  - /usr/sbin/ldconfig
  - cd ..
  #  
  ## Compile/install sockperf
  - git clone "https://github.com/mellanox/sockperf"
  - cd sockperf
  - ./autogen.sh
  - ./configure
  - make
  - make install
  - cd .. 
#
```

---


