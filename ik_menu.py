import telnetlib, time, sys

def connect():
    tn = telnetlib.Telnet('127.0.0.1', 12323, timeout=10)
    time.sleep(0.3)
    tn.read_very_eager()
    tn.write(b'admin\n')
    time.sleep(0.3)
    tn.read_very_eager()
    tn.write(b'shenlan.123\n')
    time.sleep(0.5)
    tn.read_very_eager()
    return tn

def menu(tn, key, wait=1):
    tn.write(f'{key}\n'.encode())
    time.sleep(wait)
    data = tn.read_very_eager()
    clean = bytes(b for b in data if b >= 32 or b in (10,13,27)).decode('gbk', errors='ignore')
    return clean

def goback(tn):
    tn.write(b'q\n')
    time.sleep(0.4)
    tn.read_very_eager()

tn = connect()

# Option 2: LAN/WAN addresses
print("=== OPTION 2: LAN/WAN ADDRESSES ===")
out = menu(tn, '2', 1.5)
# The menu might have sub-options
print(out[-2000:])

# Show LAN config
print("=== SHOW LAN CONFIG ===")
out = menu(tn, '1', 1.5)
print(out[-1500:])

goback(tn)

# Option 1: Network card binding
print("=== OPTION 1: NETWORK CARD BINDING ===")
goback(tn)
out = menu(tn, '1', 1)
print(out[-1500:])

tn.close()
