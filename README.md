# Awesome Window Manager Config and Theme
Config I wrote for the Awesome Window Manager for Linux-based OS's.

## Installation
There will soon be an installation script for all this that I should test, but until then, you need the following packages:
- `awesome`
- `terminal` || This is your choice, but I recommend `alacritty`, you just have to build it from source and not change the config
- `rofi`
- `blueman`
- `pavucontrol`
- `network-manager-applet`, or `nm-applet`
- `lxappearance`
- `brightnessctl`
- `amixer`
- `arandr` or `xrandr` if you prefer the command line (script included in config)
- `evolution` || calendar application 
- `nitrogen` || wallpaper
- `betterlockscreen` || This will require `i3lock` and `i3lock-color` to be installed
- `picom` || compositor
- `A nerd font of your choice, if you install Mononoki Nerd Font it should work out of the box`

You can install some of these packages with the following command:
```bash
# The package manager is, in the most cases, either apt, pacman, or dnf, depending on your distro
sudo <package_manager_install_command> awesome alacritty rofi blueman pavucontrol network-manager lxappearance brightnessctl amixer
```


## IMPORTANT
Keep in mind that this was only tested on Ubuntu and Fedora, each on their latest versions.

## Next Steps
- [ ] Create an installation script
- [ ] Test the installation script
