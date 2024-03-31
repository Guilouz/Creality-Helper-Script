#!/bin/sh

set -e

function simplyprint_message(){
  top_line
  title 'SimplyPrint' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}SimplyPrint allows you to start those prints that you just   ${white}│"
  echo -e " │ ${cyan}need to be done sooner rather than later. You can send print ${white}│"
  echo -e " │ ${cyan}jobs to your printer from anywhere in the world.             ${white}│"
  hr
  bottom_line
}

function install_simplyprint(){
  simplyprint_message
  local yn
  while true; do
    install_msg "SimplyPrint" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if ! grep -q "\[simplyprint\]" "$MOONRAKER_CFG"; then
          echo -e "Info: Enabling SimplyPrint configurations in moonraker.conf file..."
          sed -i -e '/\[simplyprint\]/!{ $s/$/\n\n[simplyprint]/;}' "$MOONRAKER_CFG"
        else
          echo -e "Info: SimplyPrint configurations are already enabled in moonraker.conf file..."        
        fi
        echo -e "Info: Restarting Moonraker service..."
        stop_moonraker
        start_moonraker
        ok_msg "SimplyPrint has been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_simplyprint(){
  simplyprint_message
  local yn
  while true; do
    remove_msg "SimplyPrint" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if grep -q "\[simplyprint\]" "$MOONRAKER_CFG"; then
          echo "Info: Removing SimplyPrint configurations in moonraker.conf file..."
          sed -i -e '/\[simplyprint\]/{x;d;};x' "$MOONRAKER_CFG"
        else
          echo "Info: SimplyPrint configurations are already removed in moonraker.conf file."
        fi
        echo -e "Info: Restarting Moonraker service..."
        stop_moonraker
        start_moonraker
        ok_msg "SimplyPrint has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}