# -*- coding: utf-8 -*-
# coding=utf-8

import redis


# 利用pipeline批量查询key的idle time和size
def query_redis(conn, keys, output):
    if len(keys) == 0:
        return

    pipe = conn.pipeline(transaction=True)
    for key in keys:
        pipe.object('idletime', key)
        pipe.debug_object(key)

    pipe_ret = pipe.execute()
    for i in range(0, len(keys)):
        idle_time = pipe_ret[i * 2]
        debug_info = pipe_ret[i * 2 + 1]
        value_size = debug_info['serializedlength']
        output.write('%s,%s,%s\n' % (keys[i].decode('utf-8'), str(value_size), str(idle_time)))


output = open('output.csv', 'w')
output.write('key,size,idletime\n')

conn = redis.Redis(host='127.0.0.1', port=9527, password='passwd')
cursor = 0
count = 0
# 利用scan分页查询
while True:
    scan_ret = conn.scan(cursor, count=1000)
    cursor = scan_ret[0]
    keys = scan_ret[1]
    query_redis(conn, keys, output)

    count += len(keys)
    print('Got %s items now.' % str(count))

    if cursor == 0:
        print('Finish')
        break

output.close()
