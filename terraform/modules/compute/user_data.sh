#!/bin/bash
set -euxo pipefail

# Install required packages and management agents
dnf install -y python3 ruby wget amazon-ssm-agent

# Start SSM Agent so private instances can be accessed through Session Manager.
systemctl enable --now amazon-ssm-agent

# Install CodeDeploy Agent
cd /tmp

wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install

chmod +x install

./install auto

systemctl enable --now codedeploy-agent

# NOTE: Application code, the systemd service file, and starting the app
# are intentionally NOT done here. CodeDeploy owns that lifecycle via
# appspec.yml + app/scripts/*.sh (install_dependencies.sh, setup_service.sh,
# start_server.sh, stop_server.sh, validate_service.sh). Starting the app
# here as well causes it to conflict with CodeDeploy's ApplicationStop/Start
# hooks during blue/green deployments, which fails the deployment.

# Just make sure the target directory exists so CodeDeploy has somewhere
# to place files on first deploy.
mkdir -p /opt/aws-ha-app
