#!/bin/bash

while [ "$(curl -o /dev/null -s -w '%{http_code}\n' http://localhost)" != "200" ]; do
    echo "Mete not yet up!"
    sleep 1
done

env MOZ_ENABLE_WAYLAND=1 MOZ_USE_XINPUT2=1 firefox -kiosk http://localhost