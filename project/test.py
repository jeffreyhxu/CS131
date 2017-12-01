import asyncio

class EchoClientProtocol(asyncio.Protocol):
    def __init__(self, message, loop):
        self.message = message
        self.loop = loop

    def connection_made(self, transport):
        transport.write(self.message.encode())
        print('Data sent: {!r}'.format(self.message))

    def data_received(self, data):
        print('Data received: {}'.format(data.decode()))

    def eof_received(self):
        print('EOF')

    def connection_lost(self, exc):
        print('The server closed the connection')
        print('Stop the event loop')
        self.loop.stop()

loop = asyncio.get_event_loop()
api_key = 'AIzaSyAhrRJv0snlGB90Pytq8OCrVSgL3ozVNN4'
message = 'WHATSAT kiwi.cs.ucla.edu 10 5'.split()
place_of = {message[1]: '+34.068930-118.445127'}
location = place_of[message[1]]
glocation = location.replace('+', ',').replace('-', ',-').lstrip(',')
radius = message[2]
bound = message[3]
query = f'key={api_key}&location={glocation}&radius={radius}'
uri = f'/maps/api/place/nearbysearch/json?{query}'
host = 'maps.googleapis.com'
request = (f'GET {uri} HTTP/1.1\r\nHost: {host}\r\n'
           'Content-Type: text/plain; charset=utf-8\r\n\r\n')
coro = loop.create_connection(lambda: EchoClientProtocol(request, loop),
                              host, 'https', ssl=True)
loop.run_until_complete(coro)
try:
    loop.run_forever()
except KeyboardInterrupt:
    pass
loop.close()
