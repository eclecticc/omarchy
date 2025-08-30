#!/bin/bash

# First check that wireless-regdb is there
if [ ! -f "/etc/conf.d/wireless-regdom" ]; then
  exit
fi

# If the region is already set, we're done
unset WIRELESS_REGDOM
. /etc/conf.d/wireless-regdom
if [ -n "${WIRELESS_REGDOM}" ]; then
  exit 0
fi

# Get the current timezone
if [ -e "/etc/localtime" ]; then
  TIMEZONE=$(readlink -f /etc/localtime)
  TIMEZONE=${TIMEZONE#/usr/share/zoneinfo/}
else
  exit
fi

# Get the two letter country code using the timezone
if [ -f "/usr/share/zoneinfo/zone.tab" ]; then
  COUNTRY=$(awk -v tz="$TIMEZONE" '$3 == tz {print $1; exit}' /usr/share/zoneinfo/zone.tab)
else
  exit
fi

# Check if we have a two letter country code
if [[ "$COUNTRY" =~ ^[A-Z]{2}$ ]]; then
  # Append it to the wireless-regdom conf file that is used at boot
  echo "WIRELESS_REGDOM=\"$COUNTRY\"" | sudo tee -a /etc/conf.d/wireless-regdom > /dev/null

  # Also set it one off now
  if command -v iw &> /dev/null; then
    sudo iw reg set ${COUNTRY}
  fi
fi

exit 0

