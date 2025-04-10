#!/bin/bash
count=$(ps -e --no-headers | wc -l)
echo "Total: $count"
