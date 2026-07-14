#!/bin/sh

unset LD_LIBRARY_PATH
unset LD_PRELOAD

LOADER=ld.so.1
GLIBC=2.27

echo -e "Info: Removing old directories..."
rm -rf /opt
rm -rf /usr/data/opt

echo -e "Info: Creating directory..."
mkdir -p /usr/data/opt

echo -e "Info: Linking folder..."
ln -nsf /usr/data/opt /opt

echo -e "Info: Creating subdirectories..."
for folder in bin etc lib/opkg tmp var/lock
do
  mkdir -p /usr/data/opt/$folder
done

echo -e "Info: Downloading opkg package manager..."
primary_URL="https://bin.entware.net/mipselsf-k3.4/installer"
secondary_URL="http://www.openk1.org/static/entware/mipselsf-k3.4/installer"

# Improved download helper using system wget/curl dynamically
download_files() {
  local url="$1"
  local output_file="$2"
  if command -v wget >/dev/null 2>&1; then
    wget -q "$url" -O "$output_file"
  elif command -v curl >/dev/null 2>&1; then
    curl -sL "$url" -o "$output_file"
  elif [ -f /usr/data/helper-script/files/fixes/curl ]; then
    chmod 755 /usr/data/helper-script/files/fixes/curl
    /usr/data/helper-script/files/fixes/curl -sL "$url" -o "$output_file"
  else
    return 1
  fi
  return $?
}

if download_files "$primary_URL/opkg" "/opt/bin/opkg"; then
  download_files "$primary_URL/opkg.conf" "/opt/etc/opkg.conf"
else
  echo -e "Info: Unable to download from Entware repo. Attempting to download from openK1 repo..."
  if download_files "$secondary_URL/opkg" "/opt/bin/opkg"; then
    download_files "$secondary_URL/opkg.conf" "/opt/etc/opkg.conf"
  else
    echo "Info: Failed to download from openK1 repo..."
    rm -rf /opt
    rm -rf /usr/data/opt
    exit 1
  fi
fi

echo -e "Info: Applying permissions..."
chmod 755 /opt/bin/opkg
chmod 777 /opt/tmp

echo -e "Info: Installing basic packages..."
/opt/bin/opkg update
/opt/bin/opkg install entware-opt

echo -e "Info: Installing SFTP server support..."
/opt/bin/opkg install openssh-sftp-server
[ -d /usr/libexec ] || mkdir -p /usr/libexec
ln -sf /opt/libexec/sftp-server /usr/libexec/sftp-server

echo -e "Info: Configuring files..."
for file in passwd group shells shadow gshadow; do
  if [ -f /etc/$file ]; then
    ln -sf /etc/$file /opt/etc/$file
  else
    [ -f /opt/etc/$file.1 ] && cp /opt/etc/$file.1 /opt/etc/$file
  fi
done

[ -f /etc/localtime ] && ln -sf /etc/localtime /opt/etc/localtime

echo -e "Info: Applying changes in system profile..."
mkdir -p /etc/profile.d
echo 'export PATH="/opt/bin:/opt/sbin:$PATH"' > /etc/profile.d/entware.sh
export PATH="/opt/bin:/opt/sbin:$PATH"

# ============================================================
# FIXED: Safe Git integration & Permission Patching
# ============================================================
echo -e "Info: Installing and configuring Git..."
/opt/bin/opkg install git-http git

# Replace system git with Entware's updated git
if [ -L /usr/bin/git ] || [ -f /usr/bin/git ]; then
     [ ! -f /usr/bin/git.bak ] && mv /usr/bin/git /usr/bin/git.bak 2>/dev/null || rm -f /usr/bin/git
fi
ln -sf /opt/bin/git /usr/bin/git

# Configure safe.directory for root and system users
/opt/bin/git config --global --add safe.directory "*"
for user in meson printer klipper; do
    id "$user" >/dev/null 2>&1 && su - "$user" -c \
'/opt/bin/git config --global --add safe.directory "*"' 2>/dev/null
done

# ============================================================
# FIXED: Startup Service (Using rc.local instead of init.d)
# ============================================================
echo -e "Info: Adding startup execution to rc.local..."
RC=/etc/rc.local
[ ! -f "$RC" ] && echo "#!/bin/sh" > "$RC"

# Clean up any duplicate commands & re-write rc.local cleanly
sed -i '/rc.unslung start/d' "$RC"
sed -i '/exit 0/d' "$RC"
echo "/opt/etc/init.d/rc.unslung start" >> "$RC"
echo "exit 0" >> "$RC"
chmod +x "$RC"

# Execute startup command immediately to activate services now
/opt/etc/init.d/rc.unslung start 2>/dev/null

# Clean up installer script remnants
rm -rf /usr/data/helper-script

echo -e "Info: Installation finished successfully!"
