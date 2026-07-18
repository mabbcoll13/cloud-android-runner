# Cloud Android Runner

> Run Android applications in Docker containers with Kubernetes-ready orchestration

## Overview

Cloud Android Runner provides a lightweight, reproducible environment for running Android apps in cloud infrastructure. Built on top of [Docker](https://www.docker.com/) and designed to integrate with Kubernetes, this project lets you package, deploy, and scale Android workloads without traditional emulators.

**Key Features:**
- Single-node Docker-based Android runtime (no emulator overhead)
- Kubernetes manifest templates for horizontal scaling
- VNC + noVNC web interface for live interaction
- ADB access over network
- ARM-native performance on AArch64 hosts
- Docker Compose for local development

## Architecture

`
┌─────────────────────────────────────────────────────┐
│                   Kubernetes Cluster                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │ cloud-android│  │ cloud-android│  │ cloud-android│  │
│  │  pod-1       │  │  pod-2       │  │  pod-N       │  │
│  │  :5555       │  │  :5555       │  │  :5555       │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
│        ↓               ↓               ↓             │
│  ┌─────────────────────────────────────────────┐   │
│  │           Kubernetes Service (LoadBalancer)   │   │
│  │              adb.qtphone.com : 5037           │   │
│  └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
`

## Quick Start

### Prerequisites

- Docker 20.10+
- Docker Compose v2+
- (Optional) Kubernetes 1.25+ for cloud deployment

### Run with Docker Compose

Clone the repository and start the container:

\\\ash
git clone https://github.com/mabbcoll13/cloud-android-runner.git
cd cloud-android-runner
docker compose up -d
\\\

Access the Android container:
- **Web VNC**: http://localhost:6080 (no password)
- **ADB**: Connect to \localhost:5555\

### Build and Run Manually

\\\ash
docker build -t cloud-android-runner .
docker run -d --name android-cloud \
  -p 6080:6080 \
  -p 5555:5555 \
  -e ANDROID_VERSION=14 \
  cloud-android-runner
\\\

### Deploy to Kubernetes

\\\ash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
\\\

## Project Structure

\\\
cloud-android-runner/
├── Dockerfile           # Multi-stage Android container build
├── docker-compose.yml  # Local development setup
├── entrypoint.sh       # Container startup script
├── k8s/
│   ├── deployment.yaml # Kubernetes deployment manifest
│   └── service.yaml    # LoadBalancer service
├── scripts/
│   └── install-apk.sh  # Remote APK installer via ADB
└── README.md
\\\

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| \ANDROID_VERSION\ | \14\ | Android API level |
| \SCREEN_WIDTH\ | \1080\ | Display width in pixels |
| \SCREEN_HEIGHT\ | \1920\ | Display height in pixels |
| \VNC_PASSWORD\ | *(empty)* | VNC access password |
| \ENABLE_ADB\ | \	rue\ | Start ADB server on port 5555 |

## Remote APK Installation

Use the provided script to install APKs from a remote URL into the running container:

\\\ash
./scripts/install-apk.sh http://example.com/app.apk
\\\

## Cloud Deployment

This project is designed for cloud-native workloads. For production deployment on cloud infrastructure, visit:

**🌐 Website**: https://www.qtphone.com/

QtPhone provides managed cloud Android environments with dedicated resources, global CDN, and 24/7 support for enterprise mobile testing and CI/CD pipelines.

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Contact

- **Website**: https://www.qtphone.com/
- **WhatsApp**: @along915
- **Telegram**: @Alongyun
- **Email**: ailong9281@gmail.com