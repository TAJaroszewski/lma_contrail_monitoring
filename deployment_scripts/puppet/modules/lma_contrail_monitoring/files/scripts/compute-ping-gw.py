#!/usr/bin/env python

import sys
import subprocess
import signal

CONFIG = {}

plugin_name = 'compute-ping'
plugin_instance = "lma-contrail-extension"
plugin_interval = 10


def restore_sigchld():
    signal.signal(signal.SIGCHLD, signal.SIG_DFL)


def payload():
    contrail_gw = CONFIG['host'].split()
    for gw in contrail_gw:
        try:
            command = 'ping -n -c1 -w %s %s' % (CONFIG['timeout'], gw)
            process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE,
                                       stderr=subprocess.PIPE,
                                       cwd='/var/tmp',
                                       executable='/bin/bash')
            output, err = process.communicate()
            if process.returncode != 0:
                return '-1'
        except subprocess.CalledProcessError as e:
            return '-1'

        return output.splitlines()[-1].split("/")[4]


def configure_callback(conf):
    collectd.info(' --> CONFIG <-- ')

    for node in conf.children:
        key = node.key.lower()
        val = node.values[0]
        if key == 'host':
            CONFIG['host'] = val
        elif key == 'timeout':
            CONFIG['timeout'] = int(val)
        elif key == 'type_instance':
            CONFIG['type_instance'] = val
        else:
            collectd.info('No plugin configurations detected %s' % key)


def payload_callback(meta=None):
    collectd.info('Read callback called')

    value = payload()
    # collectd.info(
    #    'Sending value: %s.%s=%s' % (plugin_name, '-'.join([val.plugin, val.type]), value))
    val = collectd.Values(
        plugin=plugin_name,
        plugin_instance=plugin_instance,
        type='gauge',
        type_instance=CONFIG['type_instance'],
        interval=plugin_interval,
        meta=meta or {'0': True},
        values=[value]
    )

    val.dispatch()


if __name__ == '__main__':
    print "Plugin: " + plugin_name
    payload = payload()
    print("%s" % (payload))
    sys.exit(0)
else:
    try:
        import collectd
    except ImportError as e:
        print e

    collectd.register_init(restore_sigchld)
    collectd.register_config(configure_callback)
    collectd.register_read(payload_callback, plugin_interval)
