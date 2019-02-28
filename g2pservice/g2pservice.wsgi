from g2pservice import g2pservice
import clam.clamservice
application = clam.clamservice.run_wsgi(g2pservice)