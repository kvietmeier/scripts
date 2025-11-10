import subprocess
import sys
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

IMAGE_FOLDER = '/mnt/vast/gns_demo/images'

class ReloadHandler(FileSystemEventHandler):
    def __init__(self, command):
        self.command = command
        self.process = None
        self.start_process()

    def start_process(self):
        if self.process:
            self.process.kill()
            self.process.wait()
        print("Starting Flask app...")
        self.process = subprocess.Popen(self.command)

    def on_created(self, event):
        if not event.is_directory:
            print(f"Detected new file: {event.src_path}, restarting app...")
            self.start_process()

    def on_deleted(self, event):
        if not event.is_directory:
            print(f"Detected file deletion: {event.src_path}, restarting app...")
            self.start_process()

if __name__ == "__main__":
    command = [sys.executable, 'app.py']  # adjust if your app file is named differently
    event_handler = ReloadHandler(command)
    observer = Observer()
    observer.schedule(event_handler, IMAGE_FOLDER, recursive=False)
    observer.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
