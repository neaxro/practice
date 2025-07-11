# SSL/TLS Practice

In order to set this project up properly:
- add `127.0.0.1    www.foo.bar` line to `/etc/hosts` file.
- add `certs/test-root-ca.pem` (if needed rename it to `.crt`) to your browsers thrusted certificates.
  Unfortunately browsers not always gets the trusted CA certs from the OS, but via some network protocol.
