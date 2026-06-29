import subprocess
import time

def connect_bluetooth_and_set_sink(device_id):
    p1 = subprocess.Popen(['bluetoothctl'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
    p1.communicate(input=f'pair {device_id}\nconnect {device_id}\n')
    p1.wait()
    
    time.sleep(3)
    
    try:
        pactl_list = subprocess.run(['pactl', 'list', 'sinks'], capture_output=True, text=True)
        sinks = pactl_list.stdout.split('\n\n')
        
        for sink in sinks:
            if device_id.replace(':', '_') in sink:
                lines = sink.split('\n')
                for line in lines:
                    if line.strip().startswith('Name:'):
                        sink_name = line.split(':')[1].strip()
                        subprocess.run(['pactl', 'set-default-sink', sink_name])
                        print(f"Successfully set {sink_name} as default audio sink")
                        return
        
        print("Could not find matching audio sink. Please check pavucontrol manually.")
    except Exception as e:
        print(f"Error setting audio sink: {e}")

choice = input("Press 1 for speaker OR 0 for earbuds 2 for Headphones : ")

if choice == '1':
    id = "5F:2D:F8:44:CE:29"
elif choice == '0':
    id = "AC:5C:49:14:2A:17"
elif choice == '2':
    id = "2C:BE:EE:71:E1:E4"
else:
    print("\nInvalid input")
    exit()

connect_bluetooth_and_set_sink(id)
