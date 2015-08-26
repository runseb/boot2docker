#!/bin/bash
set -e

systemctl daemon-reload || true
systemctl start kubelet
