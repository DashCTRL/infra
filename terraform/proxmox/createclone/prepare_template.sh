#!/bin/bash
# Set the storage directory
STORAGE_DIR="/var/lib/vz/template/iso"

# Set the file name for the Ubuntu ISO
ISO_FILE="ubuntu-22.04.1-live-server-amd64.iso"

# Set the URL for the Ubuntu ISO
ISO_URL="https://releases.ubuntu.com/22.04/${ISO_FILE}"

# Set the file name for the custom ISO
CUSTOM_ISO_FILE="ubuntu-22.04.1-custom-amd64.iso"

# Check if the custom ISO file already exists in the storage directory
if [ -f "${STORAGE_DIR}/${CUSTOM_ISO_FILE}" ]; then
    echo "The custom ISO file ${CUSTOM_ISO_FILE} already exists in ${STORAGE_DIR}."
else
    # Download the Ubuntu ISO to the storage directory
    echo "Downloading ${ISO_FILE} to ${STORAGE_DIR}."
    wget -P "$STORAGE_DIR" "$ISO_URL"

    # Create a directory to extract the ISO
    mkdir -p "${STORAGE_DIR}/iso_extract"

    # Extract the ISO
    sudo mount -o loop "${STORAGE_DIR}/${ISO_FILE}" "${STORAGE_DIR}/iso_extract"

    # Create a directory to build the new ISO
    mkdir -p "${STORAGE_DIR}/iso_build"

    # Copy the extracted ISO contents to the build directory
    cp -rT "${STORAGE_DIR}/iso_extract" "${STORAGE_DIR}/iso_build"

    # Unmount the extracted ISO
    sudo umount "${STORAGE_DIR}/iso_extract"

    # Copy the preseed.cfg file to the build directory
    cp preseed.cfg "${STORAGE_DIR}/iso_build"

    # Modify the boot menu to use the preseed file for automatic installation
    sed -i "s/file=\/cdrom\/preseed\/ubuntu-server.seed/file=\/cdrom\/preseed.cfg/" "${STORAGE_DIR}/iso_build/boot/grub/grub.cfg"

    # Create the new ISO with the preseed file
    mkisofs -D -r -V "Custom Ubuntu Install" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "${STORAGE_DIR}/${CUSTOM_ISO_FILE}" "${STORAGE_DIR}/iso_build"

    # Remove temporary directories
    rm -rf "${STORAGE_DIR}/iso_extract" "${STORAGE_DIR}/iso_build"
    fi
