#!/bin/bash
awk -F'["<>]' '/<rpm|cve/{print $3}' rpm-to-cve.xml
