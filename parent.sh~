#!/bin/bash -xv

awk 'FNR==NR { a[FNR""] = $0; next } { print a[FNR""], $0 }' date_pin.csv sample_biometric.csv
