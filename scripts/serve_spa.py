import http.server
import socketserver
import os
import sys

PORT = 8085
DIRECTORY = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else 'build/web')

class SPAHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_GET(self):
        # Resolve filesystem path
        fs_path = self.translate_path(self.path)
        # If the file does not exist, fall back to index.html for SPA routing
        if not os.path.exists(fs_path):
            self.path = '/index.html'
        elif os.path.isdir(fs_path) and not os.path.exists(os.path.join(fs_path, 'index.html')):
            self.path = '/index.html'
        return super().do_GET()

if __name__ == '__main__':
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), SPAHandler) as httpd:
        print(f"Serving SPA from {DIRECTORY} on http://localhost:{PORT}")
        httpd.serve_forever()
