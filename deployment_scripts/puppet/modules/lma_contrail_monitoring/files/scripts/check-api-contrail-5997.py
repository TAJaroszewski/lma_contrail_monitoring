# !/usr/bin/python
#
#    Copyright 2016 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
import urllib2
import sys
import simplejson as json
import ConfigParser
import signal
import time


CONF_FILE = '/etc/check_api.conf'

plugin_name = "check-api-contrail-5997"
plugin_instance = "lma-contrail-extension"
plugin_interval = 90
plugin_type = 'gauge'
plugin_request = 'active'

url = "http://127.0.0.1:5997"


class OSAPI(object):
    def __init__(self, config):
        self.config = config
        self.username = self.config.get('api', 'user')
        self.password = self.config.get('api', 'password')
        self.tenant_name = self.config.get('api', 'tenant')
        self.endpoint_keystone = self.config.get('api',
                                                 'keystone_endpoints'
                                                 ).split(',')
        self.token = None
        self.tenant_id = None
        self.get_token()

    def get_timeout(self, service):
        try:
            return int(self.config.get('api', '%s_timeout' % service))
        except ConfigParser.NoOptionError:
            return 1

    def get_token(self):
        data = json.dumps({
            "auth":
                {
                    'tenantName': self.tenant_name,
                    'passwordCredentials':
                        {
                            'username': self.username,
                            'password': self.password
                        }
                }
        })
        for keystone in self.endpoint_keystone:
            try:
                request = urllib2.Request(
                    '%s/tokens' % keystone,
                    data=data,
                    headers={
                        'Content-type': 'application/json'
                    })
                data = json.loads(
                    urllib2.urlopen(
                        request, timeout=self.get_timeout('keystone')).read())
                self.token = data['access']['token']['id']
                self.tenant_id = data['access']['token']['tenant']['id']
                return
            except Exception as e:
                print("Got exception '%s'" % e)
        sys.exit(1)

    def check_api(self, url, service):
        try:
            request = urllib2.Request(
                url,
                headers={
                    'X-Auth-Token': self.token,
                })
            start_time = time.time()
            p = urllib2.urlopen(request, timeout=self.get_timeout(service))
            end_time = time.time()

        except urllib2.HTTPError, e:
            return

        except Exception as e:
            print e
            sys.exit(1)

        return "%.3f" % (end_time - start_time)


def configure_callback(conf):
    for node in conf.children:
        val = str(node.values[0])


def restore_sigchld():
    signal.signal(signal.SIGCHLD, signal.SIG_DFL)


def log_verbose(msg):
    collectd.info('%s plugin [verbose]: %s' % (plugin_name, msg))


def payload():
    config = ConfigParser.RawConfigParser()
    config.read(CONF_FILE)

    API = OSAPI(config)

    payload = API.check_api(url, "contrail")

    return payload


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
    if sys.argv[1]:
        url = sys.argv[1]
    else:
        print "Please provide URL"
        sys.exit(1)

    print "Plugin: " + plugin_name
    payload = payload()
    print("%s" % (payload))
    sys.exit(0)
else:
    import collectd

    collectd.register_init(restore_sigchld)
    collectd.register_config(configure_callback)
    collectd.register_read(payload_callback, plugin_interval)
