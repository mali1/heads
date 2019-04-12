#!/bin/sh
#
set -e -o pipefail
. /etc/functions
. /tmp/config

mount_usb(){
# Mount the USB boot device
  if ! grep -q /media /proc/mounts ; then
    mount-usb "$CONFIG_USB_BOOT_DEV" || USB_FAILED=1
    if [ $USB_FAILED -eq 1 ]; then
      if [ ! -e "$CONFIG_USB_BOOT_DEV" ]; then
        whiptail --title 'USB Drive Missing' \
          --msgbox "Insert your USB drive and press Enter to continue." 16 60 USB_FAILED=0
        mount-usb "$CONFIG_USB_BOOT_DEV" || USB_FAILED=1
      fi
      if [ $USB_FAILED -eq 1 ]; then
        whiptail $CONFIG_ERROR_BG_COLOR --title 'ERROR: Mounting /media Failed' \
          --msgbox "Unable to mount $CONFIG_USB_BOOT_DEV" 16 60
      if (whiptail $CONFIG_WARNING_BG_COLOR --clear --title 'Select a new device to flash BIOS image from?' \
  --yesno "You can select an alternative disk to flash your BIOS image from.\n Choose a different device then:\n Current USB device: $CONFIG_USB_BOOT_DEV\n Current system boot device: $CONFIG_BOOT_DEV \n\n Now is not a good timing to flash those changes permanently.\n PLEASE SELECT EXIT AFTER YOU ARE DONE, DO NOT SAVE CHANGES." 30 90) then
        /bin/config-gui.sh
      else
        die "Please prepare a device that this computer will identify as $CONFIG_USB_BOOT_DEV"
      fi 
      fi
    fi
  fi
}

file_selector() {
  FILE=""
  FILE_LIST=$1
  MENU_MSG=${2:-"Choose the file"}
# create file menu options
  if [ `cat "$FILE_LIST" | wc -l` -gt 0 ]; then
    option=""
    while [ -z "$option" ]
    do
      MENU_OPTIONS=""
      n=0
      while read option
      do
        n=`expr $n + 1`
        option=$(echo $option | tr " " "_")
        MENU_OPTIONS="$MENU_OPTIONS $n ${option}"
      done < $FILE_LIST

      MENU_OPTIONS="$MENU_OPTIONS a Abort"
      whiptail --clear --title "Select your File" \
        --menu "${MENU_MSG} [1-$n, a to abort]:" 20 120 8 \
        -- $MENU_OPTIONS \
        2>/tmp/whiptail || die "Aborting"

      option_index=$(cat /tmp/whiptail)

      if [ "$option_index" = "a" ]; then
        option="a"
        return
      fi

      option=`head -n $option_index $FILE_LIST | tail -1`
      if [ "$option" == "a" ]; then
        return
      fi
    done
    if [ -n "$option" ]; then
      FILE=$option
    fi
  else
    whiptail $CONFIG_ERROR_BG_COLOR --title 'ERROR: No Files Found' \
      --msgbox "No Files found matching the pattern. Aborting." 16 60
    exit 1
  fi
}

while true; do
  unset menu_choice
  whiptail --clear --title "BIOS Management Menu" \
    --menu 'Select the BIOS function to perform' 20 90 10 \
    'f' ' Flash the BIOS with a new ROM' \
    'c' ' Flash the BIOS with a new cleaned ROM' \
    'x' ' Exit' \
    2>/tmp/whiptail || recovery "GUI menu failed"

  menu_choice=$(cat /tmp/whiptail)

  case "$menu_choice" in
    "x" )
      exit 0
    ;;
    f|c )
      if (whiptail --title 'Flash the BIOS with a new ROM' \
          --yesno "This requires you insert a USB drive containing:\n* Your BIOS image (*.rom)\n\nAfter you select this file, this program will reflash your BIOS\n\nDo you want to proceed?" 16 90) then
        mount_usb || die "Unable to mount USB device."
        if grep -q /media /proc/mounts ; then
          find /media -name '*.rom' > /tmp/filelist.txt
          file_selector "/tmp/filelist.txt" "Choose the ROM to flash"
          if [ "$FILE" == "" ]; then
            return
          else
            ROM=$FILE
          fi

          if (whiptail --title 'Flash ROM?' \
              --yesno "This will replace your old ROM with $ROM\n\nDo you want to proceed?" 16 90) then
            if [ "$menu_choice" == "c" ]; then
              /bin/flash.sh -c "$ROM"
            else
              /bin/flash.sh "$ROM"
            fi
            whiptail --title 'ROM Flashed Successfully' \
              --msgbox "$ROM flashed successfully. Press Enter to reboot" 16 60
            umount /media
            /bin/reboot
          else
            exit
          fi
        fi
      fi
    ;;
  esac

done
exit 0
