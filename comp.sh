#!/bin/bash
cd compiler
python -c "from compile import *; comp_file('$1')"
