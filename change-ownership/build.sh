#!/bin/bash

OUTPUT=/bin/change-ownership
g++ -o $OUTPUT source/change-ownership.cpp '-DCHANGE_OWNERSHIP_GROUP="warehouse-shell"'
chown root:change-ownership $OUTPUT
chmod 6750 $OUTPUT
