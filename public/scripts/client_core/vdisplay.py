#!/usr/bin/env python
#encoding: utf-8

import sys, time, os, json
import subprocess
from xvfbwrapper import Xvfb

with Xvfb() as xvfb:
    params = json.loads(sys.argv[1])

    exec_params = []
    exec_params.append(os.path.normpath("%s/../../%s" % (__file__, params['script_name'])))

    for i in range(0, 100):
        param_str = "param%d" % i
        if param_str not in params:
            break

        exec_params.append(params[param_str])

    exec_params.append(params['url'])
    if "context" in params:
        exec_params.append(params['context'])

    subprocess.call(exec_params, env = os.environ.copy())
