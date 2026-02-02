#!/bin/bash
# Installation script for RLM Skill

# Create state directory relative to the skill location
mkdir -p state

# Ensure the python script is executable
chmod +x scripts/rlm-repl.py

echo "RLM Skill installed. State directory created at ./state"