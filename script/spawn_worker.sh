#!/bin/bash
source .env
nohup ruby ./images_queue_worker.rb > /var/www/rollfindr/shared/log/images_queue_worker.log 2>&1 & echo $! > /var/www/rollfindr/shared/tmp/pids/images_queue_worker.pid
