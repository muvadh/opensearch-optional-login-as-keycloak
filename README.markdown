# OpenSearch with Keycloak Integration

This project sets up an OpenSearch cluster with OpenSearch Dashboards, integrated with Keycloak for authentication, and a MySQL database for Keycloak’s data. The setup runs locally using Docker Compose, making it ideal for development and testing.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [Running the Project](#running-the-project)
- [Accessing the Services](#accessing-the-services)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Prerequisites
Ensure you have the following installed:
- **Docker** and **Docker Compose**: For running the containers.
- **Docker Desktop** (macOS): Configured with file sharing for the project directory.
- **Make**: For using the provided `Makefile`.
- **Git**: For cloning the repository (if applicable).

### System Requirements
- At least 8GB of RAM (Docker Desktop should allocate sufficient resources).
- Ports `9200`, `9600`, `5601`, `8080`, and `3306` must be available.

## Project Structure
```
opensearch-with-keycloak/
├── Makefile                  # Automates Docker Compose commands
├── opensearch.yml            # Docker Compose file for OpenSearch and Dashboards
├── db-keycloak.yml           # Docker Compose file for Keycloak and MySQL
├── volumes/
│   ├── custom-config/        # Custom OpenSearch security configurations
│   │   └── config.yml
│   ├── opensearch/           # Persistent data for OpenSearch
│   ├── opensearch-dashboard/ # Persistent data and configs for Dashboards
│   │   └── config/
│   │       └── opensearch_dashboards.yml
│   └── db/                   # Persistent data for MySQL
└── .env                      # Environment variables (create manually)
```

## Setup Instructions

### 1. Clone the Repository
If you haven’t already, clone the repository:
```bash
git clone <repository-url>
cd opensearch-with-keycloak
```

### 2. Configure Environment Variables
Create a `.env` file in the project root to define the OpenSearch admin password and other settings.

Example `.env`:
```
OPENSEARCH_INITIAL_ADMIN_PASSWORD=YourStrongPassword123!
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin
MYSQL_ROOT_PASSWORD=root
```

**Password Requirements**:
- `OPENSEARCH_INITIAL_ADMIN_PASSWORD` must be at least 8 characters, including uppercase, lowercase, numbers, and special characters.

### 3. Set Up Configuration Files
Ensure the following configuration files are correctly set up:

#### OpenSearch Dashboards Configuration
Create or update `volumes/opensearch-dashboard/config/opensearch_dashboards.yml`:
```yaml
opensearch.hosts: ["https://opensearch:9200"]
opensearch.ssl.verificationMode: none
opensearch.username: "admin"
opensearch.password: "YourStrongPassword123!"
```
Replace `YourStrongPassword123!` with the password from your `.env` file.

#### OpenSearch Security Configuration
Ensure `volumes/custom-config/config.yml` exists. This file customizes the OpenSearch Security Plugin (e.g., for Keycloak integration). If you’re using the default demo configuration, no changes are needed initially.

### 4. Fix File Permissions
Docker containers run as the `opensearch` user (UID `1000`). Adjust permissions to avoid access issues:

```bash
sudo chown -R 1000:1000 volumes/
sudo chmod -R 0700 volumes/custom-config/ volumes/opensearch-dashboard/config/
sudo chmod 0600 volumes/custom-config/config.yml volumes/opensearch-dashboard/config/opensearch_dashboards.yml
```

### 5. Configure Docker Desktop (macOS)
Ensure Docker Desktop allows file sharing for the project directory:
1. Open **Docker Desktop** > **Preferences** > **Resources** > **File Sharing**.
2. Add `/Users/<your-username>/PROJECTS/MIPU/opensearch-with-keycloak`.
3. Apply changes and restart Docker Desktop if needed.

## Running the Project

### Start All Services
Use the provided `Makefile` to start OpenSearch, OpenSearch Dashboards, Keycloak, and MySQL:
```bash
make all
```

This executes:
1. `docker-compose -f opensearch.yml down` (stops OpenSearch and Dashboards).
2. `docker-compose -f opensearch.yml up -d` (starts OpenSearch and Dashboards).
3. (Assumes Keycloak and MySQL are started separately or included in another compose file.)

### Start Keycloak and MySQL Separately (if needed)
If Keycloak and MySQL are defined in `db-keycloak.yml`:
```bash
docker-compose -f db-keycloak.yml up -d
```

### Verify Containers
Check that all containers are running:
```bash
docker ps
```

Expected output includes:
- `opensearch` (ports `9200`, `9600`)
- `opensearch-dashboards` (port `5601`)
- `keycloak` (port `8080`)
- `db` (port `3306`)

## Accessing the Services

- **OpenSearch**:
  - URL: `https://localhost:9200`
  - Credentials: `admin` / `YourStrongPassword123!`
  - Test: `curl -k -u admin:YourStrongPassword123! https://localhost:9200`

- **OpenSearch Dashboards**:
  - URL: `http://localhost:5601`
  - Credentials: `admin` / `YourStrongPassword123!`

- **Keycloak**:
  - URL: `http://localhost:8080`
  - Admin Console: `/admin`
  - Credentials: `admin` / `admin` (or as set in `.env`)

- **MySQL**:
  - Connect via a MySQL client to `localhost:3306`
  - Credentials: `root` / `root` (or as set in `.env`)

## Troubleshooting

### Permission Denied Errors
If you see errors like:
```
error while creating mount source path '.../opensearch_dashboards.yml': operation not permitted
```
- Ensure the directory exists:
  ```bash
  mkdir -p volumes/opensearch-dashboard/config
  ```
- Fix permissions:
  ```bash
  sudo chown -R 1000:1000 volumes/opensearch-dashboard/
  sudo chmod -R 0700 volumes/opensearch-dashboard/config/
  ```

### Authentication Failures
If OpenSearch logs show:
```
Authentication finally failed for admin
```
- Verify `OPENSEARCH_INITIAL_ADMIN_PASSWORD` in `.env` matches `opensearch.password` in `opensearch_dashboards.yml`.
- Initialize the security configuration:
  ```bash
  docker exec -it opensearch bash
  /usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh \
    -cd /usr/share/opensearch/config/opensearch-security \
    -icl -nhnv \
    -cacert /usr/share/opensearch/config/root-ca.pem \
    -cert /usr/share/opensearch/config/kirk.pem \
    -key /usr/share/opensearch/config/kirk-key.pem
  exit
  ```

### Connection Errors
If OpenSearch Dashboards logs show:
```
[ConnectionError]: connect ECONNREFUSED
```
- Ensure both services are on the same Docker network in `opensearch.yml`:
  ```yaml
  networks:
    - opensearch-net
  ```
- Verify `opensearch.hosts` in `opensearch_dashboards.yml` uses `https://opensearch:9200`.

### Unhealthy Containers
If `docker ps` shows containers as `unhealthy`:
- Check logs: `docker-compose -f opensearch.yml logs -f`.
- Fix healthcheck commands in `opensearch.yml`:
  ```yaml
  opensearch:
    healthcheck:
      test: ["CMD-SHELL", "curl -s -k -u admin:YourStrongPassword123! https://localhost:9200/_cluster/health | grep -q '\"status\":\"yellow\"'"]
  opensearch-dashboards:
    healthcheck:
      test: ["CMD-SHELL", "curl -s http://localhost:5601/api/status | grep -q '\"state\":\"green\"'"]
  ```

### Orphan Containers
If you see warnings about orphan containers (`keycloak`, `mysql-init-script`, `db`):
```bash
docker-compose -f opensearch.yml down --remove-orphans
```

## Contributing
Contributions are welcome! Please:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit changes (`git commit -m "Add your feature"`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a pull request.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.