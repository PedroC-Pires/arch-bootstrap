###  Arch Linux Post-Install Bootstrap
This script is a comprehensive "one-shot" solution to transform a fresh Arch Linux installation into a fully optimized workstation for Development, Gaming, and Creative Work.

#### Prerequisites & Dependencies
Before running the script, ensure your system meets these requirements:
- **Base Arch Linux:** A working installation (preferably with KDE - Plasma already active).
- **Sudo Privileges:** Your user must be in the `wheel` group and able to execute `sudo` commands.
- **Internet Connection:** A stable connection is required to download approximately 2-4GB of packages.
- **Git:** Recommended for cloning, but the script will auto-install it if you run it via `curl`.
- **Permissions:** Do **not** run the script using `sudo ./arch-bootstrap.sh`. Run it as a normal user; the script will elevate itself when necessary. This is required for AUR package building.

#### Key Features
- **Dynamic GPU Detection:** Automatically identifies Nvidia, AMD, or Intel hardware. For Nvidia, it installs **DKMS** drivers to ensure compatibility across different Linux kernels (LTS, Zen, etc.).
- **Gaming Optimized:** Pre-configures sysctl tweaks (e.g., max_map_count) and installs the essential Steam/Wine stack.
- **Smart KDE Setup:** Adds essential Plasma utilities (KDE Connect, Okular) without the bloat of a full meta-package.
- **Dev Ready:** Installs Docker, Node.js, Python, and C++ toolchains out of the box.
- **AUR Integration:** Installs yay and handles proprietary software like Google Chrome, VS Code, and Spotify.
- **Windows App Support:** Installs the Wine environment and automatically configures `.exe` and `.msi` files to launch on double-click via the file manager.

#### What the Script Does
| Category | Actions | 
| :--- | :--- |
| System | Refreshes mirrors via Reflector, enables `multilib`, and optimizes `pacman.conf` (Parallel downloads, Color, ILoveCandy). |
| Drivers | Probes your hardware to install specific Vulkan, Mesa, or Nvidia proprietary packages. |
| Software | Installs 50+ curated packages via `pacman`, `yay`, and `flatpak`. |
| Services | Enables and starts NetworkManager, Bluetooth, Docker, CUPS, and GameMode. |
| Performance | Tweaks kernel parameters (`sysctl`) for lower latency and better memory management in high-end games. |
| Wine/Compat | Installs Wine (64/32-bit), Mono, and Gecko; registers XDG MIME types to enable double-click execution for `.exe` files. |

#### Wine & Windows Apps
The script installs a full Wine compatibility layer.
-- **Double-Click:** You can now run most Windows installers (.exe) directly from Dolphin/your file manager.
-- **First Run:** The first time you run a Windows app, Wine will take a moment to "Update the configuration." This is normal.
-- **Advanced Gaming:** For heavy games, it is still recommended to use the included Lutris or Heroic Games Launcher for better prefix management.

#### How to Run
- Open your terminal (ensure you have an active internet connection).
- Make the script executable and run it: 
`chmod +x arch-bootstrap.sh`
`./arch-bootstrap.sh`
_(Note: Do not use sudo to launch the script!)_

**Important notes**
_the script should ask you for your password only **once**, so it's alright to execute it and let it run for a while._

_When the script finishes, it will start a 5 seconds countdown to reboot. If you need to check the logs or stay in the terminal, simply press any key to abort the automatic reboot._

#### Gaming Optimization Tips
To get the absolute best performance and monitoring in Steam, right-click any game → Properties → Launch Options and paste:
`gamemoderun mangohud %command%`

##### What this activates:
- **GameMode:** Forces the CPU into "High Performance" mode and prioritizes the game process.
- **MangoHud:** Displays a high-fidelity FPS, temperature, and usage overlay.

#### Important Notes
- **Environment:** This script is designed to be run on an already existing KDE Plasma environment. It focuses on adding functionality rather than replacing your desktop.
- **Reboot Required:** You must reboot your system immediately after the script finishes. This ensures kernel tweaks are applied and your user is correctly added to the docker group. The script will try to reboot your system, however you still can cancel it by pressing any key before it finishes the 5 seconds countdown.

