#!/bin/sh
#
set -e -o pipefail
. /etc/functions
. /tmp/config

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
  whiptail --clear --title "Config Management Menu" \
    --menu "This menu lets you change settings for the current BIOS session.\n\nAll changes will revert after a reboot,\n\nunless you also save them to the running BIOS." 20 90 10 \
    'b' ' Change the /boot device' \
    's' ' Save the current configuration to the running BIOS' \
    'x' ' Exit' \
    2>/tmp/whiptail || recovery "GUI menu failed"

  menu_choice=$(cat /tmp/whiptail)

  case "$menu_choice" in
    "x" )
      exit 0
    ;;
    "b" )
      CURRENT_OPTION=`grep 'CONFIG_BOOT_DEV=' /tmp/config | tail -n1 | cut -f2 -d '=' | tr -d '"'`
      find /dev -name 'sd*' -o -name 'nvme*' > /tmp/filelist.txt
      file_selector "/tmp/filelist.txt" "Choose the default /boot device.\n\nCurrently set to $CURRENT_OPTION."
      if [ "$FILE" == "" ]; then
        return
      else
        SELECTED_FILE=$FILE
      fi

      replace_config /etc/config.user "CONFIG_BOOT_DEV" "$SELECTED_FILE"
      combine_configs

      whiptail --title 'Config change successful' \
        --msgbox "The /boot device was successfully changed to $SELECTED_FILE" 16 60
    ;;
    "s" )
      /bin/flash.sh -r /tmp/config-gui.rom
      if [ ! -s /tmp/config-gui.rom ]; then
        whiptail $CONFIG_ERROR_BG_COLOR --title 'ERROR: BIOS Read Failed!' \
          --msgbox "Unable to read BIOS" 16 60
        exit 1
      fi

      if (cbfs -o /tmp/config-gui.rom -l | grep -q "heads/initrd/etc/config.user") then
        cbfs -o /tmp/config-gui.rom -d "heads/initrd/etc/config.user"
      fi
      cbfs -o /tmp/config-gui.rom -a "heads/initrd/etc/config.user" -f /etc/config.user

      if (whiptail --title 'Update ROM?' \
          --yesno "This will reflash your BIOS with the updated version\n\nDo you want to proceed?" 16 90) then
        /bin/flash.sh /tmp/config-gui.rom
        whiptail --title 'BIOS Updated Successfully' \
          --msgbox "BIOS updated successfully.\n\nIf your keys have changed, be sure to re-sign all files in /boot\nafter you reboot.\n\nPress Enter to reboot" 16 60
        /bin/reboot
      else
        exit 0
      fi
    ;;
  esac

done
exit 0
