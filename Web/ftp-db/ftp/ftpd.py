import os
import logging

from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer
from pyftpdlib.log import config_logging

config_logging(level=logging.DEBUG)

FTP_ROOT = '/ftp_root'


user_dir = os.path.join(FTP_ROOT, "user")
if not os.path.isdir(user_dir):
    os.mkdir(user_dir)

authorizer = DummyAuthorizer()
authorizer.add_user("admin", os.getenv("ADMIN_FTP_PASSWORD"), user_dir, perm="lrw")
authorizer.add_anonymous(user_dir)

handler = FTPHandler
handler.authorizer = authorizer
handler.permit_foreign_addresses = True
handler.passive_ports = range(30000, 30009)

server = FTPServer(("0.0.0.0", 2121), handler)
server.serve_forever()
