#!/bin/bash
echo -e "\n\e[2;32mWelcome to the CogniPilot installer - Ctrl-c at any time to exit.\e[0m\n"

PS3=$'\n\e[2;33mEnter a CogniPilot release (number) to use: \e[0m'
select opt in airy main; do
  case $opt in
  airy)
    release=airy
    echo -e "\e[2;32mUsing CogniPilot release airy alicanto.\n\e[0m"
    break;;
  main)
    release=main
    echo -e "\e[2;32mUsing CogniPilot main development branch.\n\e[0m"
    break;;
  *)
    echo -e "\e[31mInvalid option $REPLY\n\e[0m";;
  esac
done

PS3=$'\n\e[2;33mEnter a CogniPilot installer type (number) to use: \e[0m'
select opt in native navqplus; do
  case $opt in
  native)
    installer=native_install.sh
    echo -e "\e[2;32mUsing CogniPilot installer for native.\n\e[0m"
    break;;
  navqplus)
    installer=navqplus_install.sh
    echo -e "\e[2;32mUsing CogniPilot installer for navqplus.\n\e[0m"
    break;;
  *)
    echo -e "\e[31mInvalid option $REPLY\n\e[0m";;
  esac
done

mkdir -p ~/cognipilot/installer

wget -O ~/cognipilot/installer/navqplus_install.sh https://raw.githubusercontent.com/CogniPilot/helmet/$release/install/$installer
chmod a+x ~/cognipilot/installer/$installer
/bin/bash ~/cognipilot/installer/$installer
