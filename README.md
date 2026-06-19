# Modxium Docker Images for MODX CMS

Production-ready Docker images for **MODX CMS**, maintained by **Modxium**.

This project provides lightweight, modern Docker images that make deploying MODX simple across local development, VPS servers and self-hosted platforms such as **Coolify**, **Portainer**, **Dockge** and **Dokploy**.

## Quick Start

### Option 1 - Use Docker Compose

```bash
git clone https://github.com/modxium/modx.git

cd modx/installer/docker/apache

docker compose up -d
```

### Option 2 - Run directly

```bash
docker run --rm \
    -p 8080:80 \
    -e MODX_VERSION=3.2.1-pl \
    modxium/modx:installer
```

### Option 3 - Pull the image first

```
docker pull modxium/modx:installer
docker run -p 8080:80 modxium/modx:installer
```

Open your browser and complete the standard MODX installation:

`http://localhost:8080/setup`


> **Note:** The `latest` tag currently points to the **Installer** image. In a future release, `latest` will become the recommended **Headless** deployment while the `standard` image will remain available for traditional MODX installations.

## Core Principles

Every Modxium Docker image is built around a common set of principles, ensuring a consistent, modern and production-ready experience regardless of the MODX version or deployment scenario.

* Build from official MODX release archives
* Support both current and historic MODX releases
* Use the latest stable supported PHP release for each image
* Use the latest stable Apache or Nginx release
* Use the latest stable MariaDB release where applicable
* Keep images lightweight, secure and production-ready
* Follow Docker best practices
* Provide sensible defaults while remaining flexible

## Image Variants

The Modxium Docker collection is designed around two deployment philosophies:

| Image                 | Description                                                                                                                   |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `installer`           | A conventional MODX installation with the standard `/setup` installer ready to use. |
| `headless` *(future)* | An opinionated deployment using MODX as a Headless Content Engine, including curated defaults and additional Modxium tooling. |

Each image may be published with Apache and Nginx variants:

| Tag                | Description                                         |
| -----------------  | --------------------------------------------------- |
| `installer`        | Alias for the recommended Installer image (Apache)  |
| `installer-apache` | Standard MODX installation using Apache             |
| `installer-nginx`  | Standard MODX installation using Nginx *(future)*   |
| `headless`         | Alias for the recommended Headless image *(future)* |
| `headless-apache`  | Headless deployment using Apache *(future)*         |
| `headless-nginx`   | Headless deployment using Nginx *(future)*          |

## Current Status

🚧 This project is under active development.

The initial release focuses on the **Installer** image and provides:

* Apache
* PHP
* Required PHP extensions
* `mod_rewrite` enabled
* Automatic `ht.access` → `.htaccess` renaming
* Official MODX release extracted into the web root
* Standard `/setup` installer ready to use

## Roadmap

- [x] Installer Apache image
- [x] Docker Hub publishing
- [x] GitHub Container Registry publishing
- [ ] Installer Nginx image
- [ ] Versioned MODX image tags
- [ ] Headless image family
- [ ] Automated installation variants
- [ ] External database support
- [ ] Manifest-driven provisioning
- [ ] Coolify templates

## Contributing

Contributions, suggestions and bug reports are welcome.

## Disclaimer

This project is maintained independently by **Modxium** and is **not affiliated with or endorsed by the MODX project**.

MODX is a trademark of its respective owners.
