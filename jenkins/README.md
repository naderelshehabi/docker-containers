This Jenkins image used on local development machine. It's setup to be behind a traefik reverse proxy under the `'/jenkins'` prefix, so that you can access it from https://localhost/jenkins/.

Admin user and password should be provided up as docker secrets inside the secrets subfolder. The secrets subfolder is gitignored for security reasons.

The image has basic plugins preinstalled, and startup.groovy enables you to automate initial configuration.
