#!/bin/bash

# -----------------------------------------------------------------------------
# GITEA Uninstaller
# Written by Evariste Gwanulaga @bl4ckarch
# Version 0.1
# -----------------------------------------------------------------------------
# This script is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation in version 2.
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with GNU Make; see the file COPYING. If not, write
# to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor,
# Boston, MA 02110-1301 USA.
# -----------------------------------------------------------------------------

# Prompt for confirmation
read -p "This will uninstall Gitea and remove related data. Are you sure? (y/n) " -n 1 -r
echo    # move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Stop services
    systemctl stop gitea
    systemctl stop apache2

    # Remove Gitea binary and directories
    rm -rf /usr/local/bin/gitea
    rm -rf /var/lib/gitea/
    rm -rf /etc/gitea
    rm -rf /home/git

    # Remove Gitea systemd service file
    rm -f /etc/systemd/system/gitea.service
    systemctl daemon-reload

    # Drop Gitea database and user
    # NOTE: This requires the MariaDB root password
    read -sp "Enter MariaDB root password: " SQLROOT
    echo
    mysql -u root -p"$SQLROOT" -Bse "DROP DATABASE IF EXISTS giteadb;"
    mysql -u root -p"$SQLROOT" -Bse "DROP USER IF EXISTS 'gitea'@'localhost';"
    mysql -u root -p"$SQLROOT" -Bse "FLUSH PRIVILEGES;"

    # Remove Apache configuration
    a2dissite $FQDN.conf
    rm -f /etc/apache2/sites-available/$FQDN.conf
    systemctl reload apache2

    # Optionally, uninstall Apache2 and MariaDB
    # apt-get remove --purge -y apache2 mariadb-server

    # Optionally, reset UFW settings
    # ufw delete allow 80/tcp
    # ufw delete allow 443/tcp

    echo "Gitea and related data have been uninstalled."
else
    echo "Uninstall cancelled."
fi
