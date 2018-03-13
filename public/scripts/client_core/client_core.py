#!/usr/bin/env python
#encoding: utf-8

import Queue, thread, subprocess
import requests, psutil
import getopt, sys, os, stat
import fcntl
import datetime, time, json
import random
import StringIO, gzip
from dateutil import parser

DEBUG = True
MAX_PROCESS = 5
PROCESS_TIMEOUT = 60 * 1
WAIT_STEP_TIME = 3
RETRY_TIME = 30
DEEP_SLEEP_TIME = 60 * 2

#root_url = 'http://spider.fishtrip.cn'
#root_url = 'http://lvh.me:3000'
#root_url = 'http://localhost:3000'
root_url = 'http://localhost:8082'

task_url = "%s/api/v1/tasks" % root_url
results_url = "%s/api/v1/results" % root_url
proxy_url = "%s/api/v1/proxy" % root_url
script_url = "%s/scripts" % root_url
self_url = "%s/client_core/client_core.py" % script_url
script_version_url = "%s/versions.json" % script_url

proc_queue = Queue.Queue()

"""
script index sample:
[{
    "name": 'mafengwo/demo.py',
    "modified_at": '2015-02-01 18:23:00',
}]
"""

"""
script result:
{
  'status': 200,

  "task": [
    {'url': 'http://xxxx', 'script_name': 'demo', 'project': '', category: 'normal', context: ''},
    {'url': 'http://xxxx', 'script_name': 'demo', 'project': '', category: 'normal', context: ''},
  ],

  "result": {
    'house_name':'fff',
    'price':1233
  }
}
"""

"""
task fetch:
[
    {'url': 'http://xxxx', },
]
"""

"""
client script result:
{
    'task': [
        {'status':}
    ],

    'data': {...}
}
"""

"""
client core send result:

"""

def log(s):
    if DEBUG:
        print s

def update_self():
    #print os.path.dirname(os.path.abspath(__file__))

    try:
        r = requests.get(self_url)
        if r.status_code != requests.codes.ok:
            log("update self failed: %d" % (r.status_code))
            return
    except:
        log("update self has an exception.")
        return

    agree = raw_input("is write override %s? [Y/N] " % (__file__))
    if agree.upper() == "Y":
        open(__file__, 'wb').write(r.content)

def update_script():
    try:
        log("fetch script index...")
        r = requests.get(script_version_url)
        if r.status_code != requests.codes.ok:
            log("get script list error: %d" % (r.status_code))
            return False
    except:
        log("get script list has an exception.")
        return False

    script_file_json = r.json()

    for item in script_file_json:
        script_path = "scripts/%s" % (item['name'])

        try:
            os.makedirs(os.path.normpath(script_path + "/../"))
        except:
            None

        modified_at = (int)(parser.parse(item['modified_at']).strftime("%s"))
        if os.path.exists(script_path):
            if os.stat(script_path).st_mtime == modified_at:
                log("%s sciprt is exist and not need update..." % (item['name']))
                continue

        log("update the %s script..." % item['name'])
        r = requests.get("%s/%s" % (script_url, item['name']))
        if r.status_code != requests.codes.ok:
            return False

        try:
            f = open(script_path, 'wb')
            if f == None:
                return False

            f.write(r.content)
            f.close()
        except:
            return False

        os.chmod(script_path, stat.S_IEXEC | stat.S_IREAD | stat.S_IWRITE)
        os.utime(script_path, (modified_at, modified_at))

        if item['name'] == 'client_core/client_core.py':
            f = open(__file__, 'wb')
            f.write(r.content)
            f.close()

            subprocess.call([__file__] + sys.argv[1:], env = os.environ.copy())
            sys.exit(0)

def process_callback(proc, queue, task_id):
    """
    try:
        proc.wait()
        #proc.returncode

        #queue.put((json.loads(proc.communicate())))
        queue.put(json.loads('{"status": 1}'))
    except:
        queue.put(None)
    #finally:
    """

    """
    try:
        timeout = 0

        while proc.poll() is None:
            time.sleep(WAIT_STEP_TIME)
            timeout += WAIT_STEP_TIME

            if PROCESS_TIMEOUT <= timeout:
                log("%s is timeout, will be kill..." % task_id)
                proc.terminate()
                queue.put((task_id, None))
                return

        result, err = proc.communicate()
        queue.put((task_id, json.loads(result)))
    except:
        queue.put((task_id, None))
    """

    fd = proc.stdout.fileno()
    fcntl.fcntl(fd, fcntl.F_SETFL, fcntl.fcntl(fd, fcntl.F_GETFL) | os.O_NONBLOCK)

    try:
        timeout = 0

        result = ""
        while proc.poll() is None:
            try:
                result += proc.stdout.read()
                continue
            except:
                time.sleep(WAIT_STEP_TIME)
                timeout += WAIT_STEP_TIME

            if PROCESS_TIMEOUT <= timeout:
                log("%s is timeout, pid: %d will be kill..." % (task_id, proc.pid))

                for n in psutil.Process(proc.pid).children(recursive=True):
                    try:
                        psutil.Process(n.pid).kill()
                    except:
                        pass

                try:
                    psutil.Process(proc.pid).kill()
                except:
                    pass

                queue.put((task_id, None))
                return

        try:
            result += proc.stdout.read()
        except:
            pass

        queue.put((task_id, json.loads(result)))
    except:
        queue.put((task_id, None))

def run_task(item, proxy):
    global proc_queue

    try:
        while psutil.virtual_memory().percent > 70:
            time.sleep(RETRY_TIME)

        log("task detail: %s" % item)
        log("create process: scripts/%s %s" % (item['script_name'], item['url']))

        force_proxy = False
        disable_proxy = True 
        if 'context' in item:
            try:
                context_params = json.loads(item['context'])

                if 'force_proxy' in context_params:
                    force_proxy = context_params['force_proxy']

                if 'disable_proxy' in context_params:
                    disable_proxy = context_params['disable_proxy']

            except:
                pass

        env = os.environ.copy()
        env['dayu_ua'] = get_random_ua()
        if (proxy and item['attempts'] == 0 and disable_proxy == False) or (proxy and force_proxy):
            env['http_proxy'] = "http://%s:%s" % (proxy['ip'], proxy['port'])

        exec_params = []
        if item['category'] == 'webkit':
            exec_params += ['xvfb-run', '-a']
        elif item['category'] == 'image':
            env['qwb_image_path'] = item['download_dir']

        exec_params += ["scripts/%s" % item['script_name'], item['url']]

        if 'context' in item:
            exec_params.append(item['context'])

        proc = subprocess.Popen(exec_params, env = env, stdout = subprocess.PIPE)
        thread.start_new_thread(process_callback, (proc, proc_queue, item['id']))

        return True
    except Exception, err:
        log("create process failed: %s..." % err)
        if 'id' in item:
            proc_queue.put((item['id'], None))
        else:
            return False

        return True

def wait_process(result):
    global proc_queue

    task_id, task_result = proc_queue.get()

    """
    task_result = {
      "status": 200,

      "result": {
        "house_name": "fff",
        'price': 1233
      }
    }
    """

    if task_result == None:
        result['results'].append({"task_id" : task_id, "error": {"code": 500}})
        return result

    if 'status' in task_result and task_result['status'] != 200:
        result['results'].append({"task_id" : task_id, "error": {"code": task_result['status']}})
        return result
    elif 'status' not in task_result:
        result['results'].append({"task_id" : task_id, "error": {"code": 500}})
        return result

    if 'result' in task_result:
        result['results'].append({"task_id" : task_id, "data": task_result['result']})

    if 'task' in task_result and type(task_result['task']) == list:
        result['new_tasks'] = result['new_tasks'] + task_result['task']

    return result

def clean():
    os.system('rm -rf /tmp/slimerjs.* > /dev/null 2>&1')
    os.system('rm -rf /tmp/xvfb-run.* > /dev/null 2>&1')
    os.system('rm -rf /tmp/.X*-lock > /dev/null 2>&1')
    os.system('rm -rf /tmp/.X11-unix/* > /dev/null 2>&1')
    os.system('rm -rf "%s/core."* > /dev/null 2>&1' % os.path.split(os.path.realpath(__file__))[0])

def get_random_ua():
    ua_list = [
        "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36",
        "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36",
        "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36 SE 2.X MetaSr 1.0",
        "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36",
        "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.99 Safari/537.36 LBBROWSER",
        "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.118 UBrowser/5.2.2466.104 Safari/537.36",
        "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.89 Safari/537.36",
        "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36",
        "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36",
        "Mozilla/5.0 (Windows NT 6.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36",
        "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.95 Safari/537.36 SE 2.X MetaSr 1.0",
        "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36",
        "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36 SE 2.X MetaSr 1.0",
        "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36",
        "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36 SE 2.X MetaSr 1.0",
        "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/38.0.2125.122 BIDUBrowser/7.5 Safari/537.36",
        "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.71 Safari/537.36",
        "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.99 Safari/537.36 LBBROWSER",
        "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.118 Safari/537.36",
        "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36",
        "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.132 Safari/537.36",
        "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36",
    ]

    return random.choice(ua_list)

def main():
    global proc_queue
    global MAX_PROCESS

    opts, _ = getopt.getopt(sys.argv[1:], "", ["download_dir=", "max_process=", "webkit", "image", "upgrade", "without_proxy"])

    with_image = False
    with_webkit = False
    without_proxy = False 
    download_dir = None
    for n,i in opts:
        if n in ("--max_process"):
            MAX_PROCESS = int(i)

        if n in ("--upgrade"):
            return update_self()

        if n in ("--webkit"):
            with_webkit = True
        if n in ("--image"):
            with_image = True

        if n in ("--without_proxy"):
            without_proxy = True

        if n in ("--download_dir"):
            download_dir = os.path.abspath(i)

    if with_image and download_dir == None:
        log("please set --download_dir param.")
        return

    #print datetime.datetime.fromtimestamp(os.path.getmtime(__file__))
    #print parser.parse("Aug 28 1999 12:00AM").strftime("%s")

    #print os.path.exists(__file__)
    #print os.stat(__file__).st_mtime
    #return

    ref = 0
    while True:
        if update_script() == False:
            log('update script failed...')
            time.sleep(RETRY_TIME)
            continue

        try:
            log("fetch tasks...")
            if with_webkit:
                r = requests.get(task_url + "?category=webkit")
            elif with_image:
                r = requests.get(task_url + "?category=image")
            else:
                log("fetch task task_url %s" % task_url)
                r = requests.get(task_url)


            if r.status_code != requests.codes.ok:
                log("get task error: %d" % (r.status_code))
                time.sleep(RETRY_TIME)
                continue
        except:
            log("fetch tasks has an exception.")
            time.sleep(RETRY_TIME)
            continue

        task_json = r.json()
        if len(task_json) == 0:
            log("got nothing... waiting %d min..." % (DEEP_SLEEP_TIME / 60))
            time.sleep(DEEP_SLEEP_TIME)
            continue

        proxy_list = []
        try:
            if without_proxy == False:
                log("fetch proxy list...")
                r = requests.get(proxy_url)

                proxy_list = r.json()
        except:
            log("fetch proxy list has an exception.")
            continue

        result = {"results": [], "new_tasks": []}
        for task in task_json:
            if ref >= MAX_PROCESS:
                result = wait_process(result)
                ref -= 1

            if with_image:
                task['download_dir'] = "%s/%s" % (download_dir, task['project'])

            if run_task(task, random.choice(proxy_list) if len(proxy_list) > 0 else None):
                ref += 1

        while ref > 0:
            result = wait_process(result)
            ref -= 1

        #analytics
        succeed_count = 0
        failed_count = 0
        total_count = len(result['results'])
        for item in result['results']:
            if 'data' in item:
                succeed_count += 1

            if 'error' in item:
                failed_count += 1

        result = json.dumps(result)
        #print result           //crash

        if len(result) < 100:
            content_type = "application/json"
        else:
            content_type = "gzip/json"

            s = StringIO.StringIO()
            g = gzip.GzipFile(fileobj=s, mode='w')
            g.write(result)
            g.close()

            result = s.getvalue()


        log("total: %d, succeed: %d, failed: %d, post %d bytes to server ..." % (total_count, succeed_count, failed_count, len(result)))
        for i in range(0, 10):
            try:
                r = requests.post(results_url, result, headers = {'content-type': content_type})
                if r.status_code != 201:
                    log("post data failed: %d, %d sec will retry..." % (r.status_code, RETRY_TIME))
                    time.sleep(RETRY_TIME)
                    continue
            except Exception, err:
                log("post data failed: %s..." % err)
                time.sleep(RETRY_TIME)
                continue

            break

        clean()

if __name__ == '__main__':
    main()
