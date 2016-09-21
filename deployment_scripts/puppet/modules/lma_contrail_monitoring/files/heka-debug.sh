#!/usr/bin/env bash
echo "This snipped will create flow in which all messages processed by heka will be logged into /var/log/heka-debug.log"
echo "Please be aware that this file will became very large and.. it will be very soon"

FILE_CHECK=$(grep -c RstEncoder /etc/metric_collector/global.toml)
if [ ${FILE_CHECK} -eq 0 ]; then
cat < EOF >> /etc/metric_collector/global.toml
[RstEncoder]
[output_file]
type = "FileOutput"
message_matcher = "TRUE"
path = "/var/log/heka-debug.log"
perm = "666"
flush_count = 100
flush_operator = "OR"
encoder = "RstEncoder"
EOF
fi

if [ -f /etc/init/log_collector.conf ]; then
    service log_collector restart
fi
if [ -f /etc/init/metric_collector.conf ]; then
    service metric_collector restart
fi

if [ -f /usr/lib/ocf/resource.d/fuel/ocf-metric_collector ]; then
    crm resource restart clone_metric_collector
fi
if [ -f /usr/lib/ocf/resource.d/fuel/ocf-log_collector ]; then
    crm resource restart clone_log_collector
fi

#EOF