# Official 3X-UI wrapper for Ploi Cloud

This repository wraps the official `ghcr.io/mhsanaei/3x-ui:v3.9.0` image with Nginx and Supervisor for an HTTP application platform. The panel and Xray build remain upstream; the wrapper provides a Ploi-facing HTTP port, `/health`, and persistent storage paths.

Deploy with the Dockerfile on HTTP port `8080`, mount `/etc/x-ui`, and set `XUI_PORT=20530`. See [`README-fa.md`](README-fa.md) for the complete setup and the public TCP/UDP limitation.
