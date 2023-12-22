### Misc Linux Scripting Projects

---

Various scripts I have written for projects.  

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
