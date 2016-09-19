#!/usr/bin/python

import time
import signal
import string
import subprocess
import sys
import urllib2
import sys
import xml
import xmltodict

plugin_name = "xmpp-number-of-sessions"
plugin_instance = "lma-contrail-extension"
plugin_interval = 90
plugin_type = 'gauge'


def restore_sigchld():
    signal.signal(signal.SIGCHLD, signal.SIG_DFL)


def log_verbose(msg):
    collectd.info('%s plugin [verbose]: %s' % (plugin_name, msg))


def payload():
    ShowXmppServerRespRequest = 'http://127.0.0.1:8083/Snh_ShowXmppServerReq'
    ShowXmppServerRespXML = urllib2.urlopen(ShowXmppServerRespRequest).read()
    try:
        ShowXmppServerRespCurrentConnection = \
            xmltodict.parse(ShowXmppServerRespXML)['ShowXmppServerResp']['current_connections']['#text']
    except ImportError as e:
        print e

    return ShowXmppServerRespCurrentConnection


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
    payload = payload()
    print("%s" % (payload))
    sys.exit(0)
else:
    import collectd

    collectd.register_init(restore_sigchld)
    collectd.register_config(configure_callback)
    collectd.register_read(payload_callback, plugin_interval)
