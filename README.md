# 🚀 Control.sh: The Efficient Environment Orchestrator

[![Documentation](https://img.shields.io/badge/docs-GitHub%20Pages-blue)](https://rebienkrdns.github.io/control.sh/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

`control.sh` is a minimalist and powerful wrapper for **Docker Compose v2** designed under high-efficiency engineering principles. It was born from the need to standardize microservices workflows, eliminating the friction of typing long commands and allowing fluid management of `profiles`.

---

## 💡 Why was it created?

In modern microservices architectures, the complexity of managing multiple execution profiles (development, testing, staging) often leads to:
1.  **Endless Commands:** Repeatedly typing `docker compose --profile dev --profile tools up -d`.
2.  **Permission Conflicts:** Write issues in mounted volumes due to UID/GID discrepancies between the host and the container.
3.  **Build Artifacts:** Corrupted `node_modules` or `dist` directories that require constant manual cleaning.

---

## ✅ What does it solve?

*   **Profile Abstraction:** Handles multiple Docker profiles transparently.
*   **Security & Permissions:** Automatically exports `CURRENT_UID` and `CURRENT_GID` so your containers respect host permissions.
*   **Cleanup Automation:** Integrates a deep `clean` command that destroys containers, volumes, and local artifact folders in a single step.
*   **Dry-Run Mode:** Allows previewing which commands will be executed without affecting the system.
*   **Native Environment Loading:** Automatically loads variables from `.env` before invoking Docker.

---

## 🛠️ Quick Installation

1.  Execute installer:
    ```bash
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/rebienkrdns/control.sh/main/install.sh)"
    ```
3.  (Optional) Create a `.env` file to customize behavior.

---

## 🚀 Main Commands

Get the most out of it with these standardized commands:

| Command | Action |
| :--- | :--- |
| `./control.sh up` | Starts the stack (default `develop` profile). |
| `./control.sh build` | Rebuilds images without cache (forces clean build). |
| `./control.sh logs` | Tails logs in real-time. |
| `./control.sh restart` | Quickly restarts services. |
| `./control.sh reset` | **Hard Reset**: Downs everything, wipes volumes, and starts up again. |
| `./control.sh clean` | **Deep Clean**: Downs the stack and removes folders like `dist` or `node_modules`. |

### Power Options:
*   `-p, --profile <name>`: Specify one or more profiles.
*   `-s, --service <name>`: Execute action only on a specific service.
*   `--dry-run`: See what would happen without executing anything.

---

## 📂 Configuration Examples

The project includes an `examples/` folder with ready-to-use configurations:

### 1. Multiple Profiles (Time Saver)
Imagine you need the backend and database tools for development:
```bash
# Without control.sh:
docker compose --profile backend --profile tools up -d

# With control.sh:
./control.sh up -p backend -p tools
```

### 2. Emergency Cleanup
When things aren't working and you want to start fresh and "clean":
```bash
./control.sh clean --dir app/dist --dir app/node_modules
```

### 3. Quick Debugging
View logs for a single service in a specific profile:
```bash
./control.sh logs -p stage -s api
```

---

## 📄 License

This project is distributed under the **MIT License**. It is free software: you can use, modify, and distribute it for personal or commercial projects without restrictions.

---

## ⚖️ Engineering Philosophy

This script follows **Core Engineering Standards**:
*   **Zero Waste:** Written in pure Bash for minimal latency.
*   **Immutability:** Designed to treat containers as ephemeral.
*   **Security:** Validates Docker's existence and daemon status before acting.

---
*Made for engineers who value their time.* ⚡
