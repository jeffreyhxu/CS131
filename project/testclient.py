import asyncio
import time

class EchoClientProtocol(asyncio.Protocol):
    def __init__(self, message, loop):
        self.message = message
        self.loop = loop

    def connection_made(self, transport):
        transport.write(self.message.encode())
        print('Data sent: {!r}'.format(self.message))

    def data_received(self, data):
        print('Data received: {}'.format(data.decode()))

    def connection_lost(self, exc):
        print('The server closed the connection')
        print('Stop the event loop')
        self.loop.stop()

loop = asyncio.get_event_loop()
when = time.time()
message = f'IAMAT kiwi.cs.ucla.edu +34.068930-118.445127 {when}\n'
coro = loop.create_connection(lambda: EchoClientProtocol(message, loop),
                              '127.0.0.1', 9001)
loop.run_until_complete(coro)
loop.run_forever()
message = 'WHATSAT kiwi.cs.ucla.edu 10 5\n'
coro = loop.create_connection(lambda: EchoClientProtocol(message, loop),
                              '127.0.0.1', 9002)
loop.run_until_complete(coro)
loop.run_forever()
message = f'IAMAT kiwi.cs.ucla.edu +50.068930-118.445127 {when+1}\n'
coro = loop.create_connection(lambda: EchoClientProtocol(message, loop),
                              '127.0.0.1', 9001)
loop.run_until_complete(coro)
loop.run_forever()
message = 'WHATSAT kiwi.cs.ucla.edu 10 5\n'
coro = loop.create_connection(lambda: EchoClientProtocol(message, loop),
                              '127.0.0.1', 9002)
loop.run_until_complete(coro)
loop.run_forever()
loop.close()
