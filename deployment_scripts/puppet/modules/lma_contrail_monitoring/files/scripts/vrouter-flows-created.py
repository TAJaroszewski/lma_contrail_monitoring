#!/usr/bin/python

import signal
import sys
import urllib2
import xml.dom.minidom

plugin_name = "vrouter-flows-created"
plugin_instance = "lma-contrail-extension"
plugin_interval = 60
plugin_type = 'gauge'
plugin_request = 'created'

def restore_sigchld():
    signal.signal(signal.SIGCHLD, signal.SIG_DFL)


def log_verbose(msg):
    collectd.info('%s plugin [verbose]: %s' % (plugin_name, msg))


def payload():
    url = 'http://127.0.0.1:8085/Snh_AgentStatsReq'
    req = urllib2.Request(url)
    response = urllib2.urlopen(req)
    p = response.read()
    px = xml.dom.minidom.parseString(p)
    itemlist = px.getElementsByTagName('FlowStatsResp')
    return itemlist[0].getElementsByTagName("flow_" + plugin_request)[0].childNodes[0].toxml()


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
