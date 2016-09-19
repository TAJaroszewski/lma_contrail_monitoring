#!/usr/bin/python

import time
import signal
import string
import subprocess
import sys
import platform
import re

plugin_name = "ntp-time-drift"
plugin_instance = "lma-contrail-extension"
plugin_interval = 90
plugin_type = 'gauge'

if re.match('Ubuntu|Debian', platform.linux_distribution()[0]):
    ntp_drift_file = "/var/lib/ntp/ntp.drift"
else:
    ntp_drift_file = "/var/lib/ntp/drift"


def restore_sigchld():
    signal.signal(signal.SIGCHLD, signal.SIG_DFL)


def log_verbose(msg):
    collectd.info('%s plugin [verbose]: %s' % (plugin_name, msg))


def payload():
    with open(ntp_drift_file, 'r') as f:
        drift_state_seconds = float(f.readline().split()[0])
    return drift_state_seconds


def configure_callback(conf):
    for node in conf.children:
        val = str(node.values[0])


def payload_callback():
    log_verbose('Read callback called')

    value = payload()
    # log_verbose(
    #    'Sending value: %s.%s=%s' % (plugin_name, '-'.join([val.plugin, val.type]), value))
    val = collectd.Values(
        plugin=plugin_name,  # metric source
        plugin_instance=plugin_instance,
        type=plugin_type,
        type_instance=plugin_name,
        interval=plugin_interval,
        meta={'0': True},
        values=[value]
    )

    val.dispatch()


if __name__ == '__main__':
    print "Plugin: " + plugin_name
    print("%s" % (payload()))
    sys.exit(0)
else:
    import collectd

    collectd.register_init(restore_sigchld)
    collectd.register_config(configure_callback)
    collectd.register_read(payload_callback, plugin_interval)
