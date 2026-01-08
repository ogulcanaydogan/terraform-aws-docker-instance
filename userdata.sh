#!/bin/bash
set -e

# Log all output
exec > >(tee /var/log/userdata.log) 2>&1
echo "Starting Docker instance setup at $(date)"

# Set hostname
hostnamectl set-hostname ${hostname}
echo "Hostname set to ${hostname}"

# Update system packages
echo "Updating system packages..."
dnf update -y

# Install Docker
echo "Installing Docker..."
dnf install -y docker

# Start and enable Docker service
echo "Starting Docker service..."
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -a -G docker ec2-user

# Install Docker Compose v2
echo "Installing Docker Compose v${docker_compose_version}..."
DOCKER_CONFIG=/usr/local/lib/docker
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL "https://github.com/docker/compose/releases/download/v${docker_compose_version}/docker-compose-linux-x86_64" \
  -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

# Create symlink for backward compatibility
ln -sf $DOCKER_CONFIG/cli-plugins/docker-compose /usr/local/bin/docker-compose

# Verify installations
echo "Verifying installations..."
docker --version
docker compose version

# Run additional user data if provided
%{ if user_data_extra != "" }
echo "Running additional user data..."
${user_data_extra}
%{ endif }

echo "Docker instance setup completed at $(date)"
