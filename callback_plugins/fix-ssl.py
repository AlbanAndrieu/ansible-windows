import ssl
if hasattr(ssl, '_create_default_https_context') and hasattr(ssl, '_create_unverified_context'):
    ssl._create_default_https_context = ssl._create_unverified_context

class CallbackModule(object):
    pass

# needed to bypass self-signed certificates for winrm
