# Modxium Installer (Apache)

The **Modxium Installer (Apache)** provides a lightweight Docker image that automatically downloads and extracts a specified version of MODX, leaving the standard MODX setup wizard ready to complete in your browser.

The image is intended for local development, VPS deployments and self-hosted platforms such as Coolify, Portainer, Dockge and Dokploy.

## Features

* Apache web server
* PHP 8.x (version selectable at build time)
* Required PHP extensions for MODX
* Automatic download of official MODX release packages
* Automatic extraction into the web root
* Persistent Docker volume support
* Standard MODX `/setup` installer ready to use

## Quick Start

```bash
docker run \
    -p 8080:80 \
    -e MODX_VERSION=3.2.1-pl \
    modxium/modx:installer
```

Then open:

```
http://localhost:8080/setup
```

## Environment Variables

| Variable       | Description                                          |
| -------------- | ---------------------------------------------------- |
| `MODX_VERSION` | The MODX version to download and prepare (required). |
| `HTTP_PORT`    | Optional port used for informational output only.    |

## Persistent Storage

The image is designed to work with a persistent Docker volume mounted to:

```
/var/www/html
```

On first startup, the requested MODX version is downloaded and extracted into the volume.

On subsequent restarts, if MODX already exists, the download step is skipped and Apache starts immediately.

## Download Behaviour

On first startup, the installer will attempt to download the requested MODX release package.

If the download fails (for example because an invalid `MODX_VERSION` was specified or the remote server is temporarily unavailable), the installer will automatically retry up to **three times** before exiting.

If the container is configured with a Docker restart policy such as `unless-stopped`, it may subsequently restart and repeat the download process. This behaviour is intentional, allowing the container to recover automatically from temporary network or remote server failures.

If an invalid `MODX_VERSION` has been specified, the container will continue to fail until the configuration is corrected or the container is manually stopped.


## Supported PHP Versions

The following image variants are available:

* `installer`
* `installer-apache`
* `installer-php8.5-apache`
* `installer-php8.4-apache`
* `installer-php8.3-apache`

The `installer` and `installer-apache` tags always point to the current recommended PHP release.

## Licence

See the repository licence for details.
