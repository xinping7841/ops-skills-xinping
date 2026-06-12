import telnetlib, time

tn = telnetlib.Telnet('127.0.0.1', 12323, timeout=10)
time.sleep(0.3)
tn.read_very_eager()
tn.write(b'admin\n')
time.sleep(0.3)
tn.read_very_eager()
tn.write(b'shenlan.123\n')
time.sleep(0.5)
data = tn.read_very_eager()

def send(cmd, wait=1.5):
    tn.write(f'{cmd}\n'.encode())
    time.sleep(wait)
    data = tn.read_very_eager()
    clean = bytes(b for b in data if b >= 32 or b in (10,13)).decode('gbk', errors='ignore')
    return clean

# Navigate to "Other Options" (o)
print("=== OTHER OPTIONS ===")
out = send('o')
print(out[-1500:])

# Then check option 0 from other options (usually has more diag)
out = send('0')
print(out[-2000:])

tn.close()
