#! /bin/bash
#
systemctl stop kiosk
systemctl disable kiosk
systemctl daemon-reload
echo "Update kiosk"
systemctl enable kiosk
systemctl start kiosk

