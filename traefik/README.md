In the secrets folder place docker secrets for Traefik

- `usersfile.txt`: Should have user:hashed passwords pairs
- `cert.crt`: SSL Certificate to encrypt traefik
- `cert.key`: SSL certificate key

To create the usersfile.txt you need first to install `apache-utils2`

```
apt-get install apache2-utils
```

Then run the following command inside the `secrets` subfolder

```
htdigest -c usersfile traefik admin
```

You'll be asked for the password for the admin user

To create the self-signed certificates, run the following commands inside the secrets folder

```
openssl req -newkey rsa:4096 -nodes -keyout cert.key -x509 -days 365 -out cert.crt
```
