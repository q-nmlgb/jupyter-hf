#!/bin/bash
cd /root
git clone https://github.com/0x4m4/hexstrike-ai.git
cd hexstrike-ai

# 2. Create virtual environment
python3 -m venv hexstrike-env
source hexstrike-env/bin/activate  # Linux/Mac
# hexstrike-env\Scripts\activate   # Windows

# 3. Install Python dependencies
pip3 install -r requirements.txt
python3 hexstrike_server.py --port 8888  >> 123.log  2>&1 &