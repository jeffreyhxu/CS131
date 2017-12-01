import sys
import time
import asyncio
import json

server_name = 'Alford'
if(len(sys.argv) == 2):
    server_name = sys.argv[1]
connections = []
if(server_name == 'Alford'):
    connections = ['Hamilton', 'Welsh']
elif(server_name == 'Ball'):
    connections = ['Holiday', 'Welsh']
elif(server_name == 'Hamilton'):
    connections = ['Alford', 'Holiday']
elif(server_name == 'Holiday'):
    connections = ['Ball', 'Hamilton']
elif(server_name == 'Welsh'):
    connections = ['Alford', 'Ball']
else:
    raise Exception('Invalid server name, must be Alford, Ball, Hamilton, Holiday, or Welsh')
port_of = {'Alford':9001, 'Ball':9002, 'Hamilton':9003, 'Holiday':9004, 'Welsh':9005}
api_key = 'AIzaSyAhrRJv0snlGB90Pytq8OCrVSgL3ozVNN4'
place_of = {}
time_skew = {}
time_of = {}

class PlacesProtocol(asyncio.Protocol):
    def __init__(self, loop, log):
        self.loop = loop
        self.buf = ''
        self.log = log
        
    def connection_made(self, transport):
        self.transport = transport
        self.peername = transport.get_extra_info('peername')
        print('Connection from {}'.format(self.peername))
        if(self.peername[0] == '127.0.0.1' and self.peername[1] in port_of.values()):
            for other in port_of:
                if(port_of[other] == self.peername[1]):
                    self.peername = other
        self.log.write(f'Connection from {self.peername}\n')

    def data_received(self, data):
        self.buf = self.buf + data.decode()
        print(self.buf)
        if('\n' in self.buf):
            message = self.buf[:self.buf.index('\n')]
            self.respond(message)
            self.buf = self.buf[self.buf.index('\n'):]

    def eof_received(self):
        self.respond(self.buf)

    def check_valid_loc(self, location):
        nums = location.replace('+', ' ').replace('-', ' -').split()
        if(len(nums) != 2):
            return False
        try:
            if(float(nums[0]) < -90 or float(nums[0]) > 90):
                return False
            if(float(nums[1]) < -180 or float(nums[1]) > 180):
                return False
        except ValueError:
            return False
        return True

    def respond(self, buf):
        print(f'responding to {buf}')
        self.log.write(f'Input from {self.peername}:\n{buf.strip()}\n')
        when = time.time()
        message = buf.split()
        if(len(message) == 0):
            return
        if(message[0] == 'IAMAT'):
            if(len(message) != 4 or not self.check_valid_loc(message[2])):
                self.respond_to_invalid(buf)
                return
            try:
                float(message[3])
            except ValueError:
                self.respond_to_invalid(buf)
                return
            print('IAMAT processing')
            self.who = message[1]
            if(self.who not in time_of or float(message[3]) > float(time_of[self.who])):
                place_of[self.who] = message[2]
                time_skew[self.who] = when - float(message[3])
                time_of[self.who] = message[3]
            at_message = (f'AT {server_name} {time_skew[self.who]:+.9f} {self.who} '
                          f'{message[2]} {message[3]}')
            self.transport.write(at_message.encode())
            self.log.write(f'Output to {self.peername}:\n{at_message}\n')
            self.transport.close()
            self.log.write(f'Closing connection from {self.peername}\n')
            for other in connections:
                factory = self.loop.create_connection(lambda: MessageProtocol(at_message
                                                                              + f' {server_name}\n',
                                                                              self.log),
                                                      '127.0.0.1', port_of[other])
                print('Scheduled a friend')
                self.log.write(f'Connecting to {other}\n')
                self.loop.create_task(factory)
        elif(message[0] == 'AT'):
            self.transport.close()
            self.log.write(f'Closing connection from {self.peername}\n')
            self.who = message[3]
            if(self.who not in time_of or float(message[5]) > float(time_of[self.who])):
                place_of[self.who] = message[4]
                time_skew[self.who] = float(message[2])
                time_of[self.who] = message[5]
            at_message = f'AT {server_name} {message[2]} {message[3]} {message[4]} {message[5]} {message[6]}'
            for other in connections:
                if(other != message[1] and other != message[6]):
                    # since the only cycle visits every server, we only need to ensure
                    # we don't send to the one we just heard from or the originator of the
                    # AT message.
                    factory = self.loop.create_connection(lambda: MessageProtocol(at_message, self.log),
                                                          '127.0.0.1', port_of[other])
                    self.log.write(f'Connecting to {other}\n')
                    self.loop.create_task(factory)
        elif(message[0] == 'WHATSAT'):
            if(len(message) != 4):
                self.respond_to_invalid(buf)
                return
            try:
                if(float(message[2]) > 50):
                    self.respond_to_invalid(buf)
                    return
                if(int(message[3]) > 20):
                    self.respond_to_invalid(buf)
                    return
            except:
                self.respond_to_invalid(buf)
                return
            self.who = message[1]
            if(self.who not in place_of):
                self.respond_to_invalid(buf)
                return
            print('WHATSAT processing')
            location = place_of[self.who]
            glocation = location.replace('+', ',').replace('-', ',-').lstrip(',')
            radius = message[2]
            self.bound = int(message[3])
            query = f'key={api_key}&location={glocation}&radius={radius}'
            uri = f'/maps/api/place/nearbysearch/json?{query}'
            host = 'maps.googleapis.com'
            request = (f'GET {uri} HTTP/1.1\r\nHost: {host}\r\n'
                       'Content-Type: text/plain; charset=utf-8\r\n\r\n')
            factory = self.loop.create_connection(lambda: GoogleProtocol(request, self.loop, self, self.log),
                                                  host, 'https', ssl=True)
            self.log.write(f'Connecting to Google\n')
            self.loop.create_task(factory)
        else:
            self.respond_to_invalid(buf)

    def respond_to_invalid(self, buf):
        print('Bad command')
        self.transport.write(f'? {buf}'.encode())
        self.log.write(f'Output to {self.peername}:\n? {buf}\n')
        self.transport.close()
        self.log.write(f'Closing connection from {self.peername}\n')

    def respond_to_whatsat(self, response):
        rawjson = response[response.index('{'):response.rindex('}')+1]
        pjson = json.loads(rawjson)
        del pjson['results'][self.bound:]
        strjson = json.dumps(pjson, indent=3)
        snew = ''
        while(snew != strjson):
            snew = strjson
            strjson = strjson.replace('\n\n', '\n')
        strjson = strjson + '\n\n'
        fullresponse = 'AT {} {:+.9f} {} {} {}\n{}'.format(server_name,
            time_skew[self.who], self.who, place_of[self.who], time_of[self.who],
            strjson)
        self.transport.write(fullresponse.encode())
        self.log.write(f'Output to {self.peername}:\n{fullresponse}\n')
        self.transport.close()
        self.log.write(f'Closing connection from {self.peername}\n')

class MessageProtocol(asyncio.Protocol):
    def __init__(self, message, log):
        print(f'MP made for {message}')
        self.message = message
        self.log = log

    def connection_made(self, transport):
        self.peername = transport.get_extra_info('peername')
        print('Connection from {}'.format(self.peername))
        if(self.peername[0] == '127.0.0.1' and self.peername[1] in port_of.values()):
            for other in port_of:
                if(port_of[other] == self.peername[1]):
                    self.peername = other
        print(f'Connection for {self.message}')
        self.log.write(f'Connected to {self.peername}')
        transport.write(self.message.encode())
        self.log.write(f'Output to {self.peername}:\n{self.message}\n')

    def connection_lost(self, exc):
        self.log.write(f'Connection to {self.peername} closed')
            
class GoogleProtocol(asyncio.Protocol):
    def __init__(self, message, loop, mainprotocol, log):
        self.message = message
        self.loop = loop
        self.prot = mainprotocol
        self.log = log
        self.buf = ''
        
    def connection_made(self, transport):
        self.transport = transport
        self.log.write(f'Connected to Google')
        transport.write(self.message.encode())
        self.log.write(f'Output to Google:\n{self.message}')

    def data_received(self, data):
        self.buf = self.buf + data.decode()
        if(self.buf[len(self.buf) - 4:] == '\r\n\r\n'):
            self.log.write(f'Input from Google:\n{self.buf}\n')
            self.transport.close()
            self.log.write(f'Closing connection to Google\n')
            self.loop.call_soon(self.prot.respond_to_whatsat, self.buf)

with open(f'{server_name}.log', 'w') as log:
    loop = asyncio.get_event_loop()
    sercor = loop.create_server(lambda: PlacesProtocol(loop, log), '127.0.0.1', port_of[server_name])
    server = loop.run_until_complete(sercor)

    # Serve requests until Ctrl+C is pressed
    print('Serving on {}'.format(server.sockets[0].getsockname()))
    try:
        loop.run_forever()
    except KeyboardInterrupt:
        pass

    # Close the server
    server.close()
    loop.run_until_complete(server.wait_closed())
    loop.close()
