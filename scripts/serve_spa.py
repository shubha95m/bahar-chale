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
        # Normalize /bahar-chale prefix if requested
        if self.path.startswith('/bahar-chale'):
            self.path = self.path[len('/bahar-chale'):]
            if not self.path:
                self.path = '/'

        # Clean query string and fragment for filesystem lookup
        clean_path = self.path.split('?')[0].split('#')[0]
        fs_path = self.translate_path(clean_path)

        # If file does not exist, rewrite to index.html for SPA routing
        if not os.path.exists(fs_path) or (os.path.isdir(fs_path) and not os.path.exists(os.path.join(fs_path, 'index.html'))):
            ext = os.path.splitext(clean_path)[1].lower()
            if ext in ['.js', '.wasm', '.json', '.png', '.jpg', '.svg', '.ico', '.map']:
                self.send_error(404, f"Asset not found: {clean_path}")
                return
            self.path = '/index.html'

        return super().do_GET()

    def do_HEAD(self):
        if self.path.startswith('/bahar-chale'):
            self.path = self.path[len('/bahar-chale'):]
            if not self.path:
                self.path = '/'
        clean_path = self.path.split('?')[0].split('#')[0]
        fs_path = self.translate_path(clean_path)
        if not os.path.exists(fs_path):
            self.path = '/index.html'
        return super().do_HEAD()

    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        super().end_headers()

if __name__ == '__main__':
    socketserver.TCPServer.allow_reuse_address = True
    print(f"Starting SPA server for {DIRECTORY} on port {PORT}")
    with socketserver.TCPServer(("", PORT), SPAHandler) as httpd:
        httpd.serve_forever()
