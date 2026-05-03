#!/bin/bash
set -e
swiftc main.swift -framework Cocoa -framework Carbon -o GitMacro
echo "Built. Run with: ./GitMacro"
