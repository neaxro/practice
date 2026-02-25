import socket

HOST = 'localhost'
PORT = 50007
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    message = ""
    while message != "exit":
        message = input("Message: ")
        s.sendall(message.encode())
        data = s.recv(1024)
        if data:
            print("Recieved: ", data.decode())
