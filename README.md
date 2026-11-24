# Ocarina of Termina

A *Majora's Mask* music player and 6-note ocarina homebrew for the **PS Vita**, built with `lpp-vita`.

## Melodies (Ocarina Solo)

Play these 7-note sequences in **Ocarina Solo** mode to trigger the matching soundtrack:

| Track | Sequence |
| :--- | :--- |
| **Clock Town (First Day)** | `L  R  O  X  Up  X  Down` |
| **Song of Healing** | `O  X  Down  O  X  Down  O` |
| **Astral Observatory** | `L  Up  O  R  O  X  Up` |

## Controls

- **Menu:** `L` / `R` switch tabs · `Up` / `Down` select · `X` confirm
- **Ocarina Notes (6):** `L`, `Down`, `Up`, `X`, `O`, `R`
- **Player:** `TRIANGLE` next track · `SQUARE` pause/resume
- **Solo:** `SQUARE` clear staff
- **Global:** `SELECT` back to menu · `START` exit

<img width="960" height="544" alt="2026-11-24-052810" src="https://github.com/user-attachments/assets/eb15ea04-23f4-4cb3-91d7-1b9f26e555f8" />

## Installation

### Method 1: Using the `.vpk` file (Recommended)
1. Download the latest `.vpk` file from the **Releases** tab.
2. Transfer the `.vpk` to your PS Vita via **VitaShell** (USB or FTP).
3. Install the file by pressing `X` in VitaShell, then launch the bubble from the LiveArea.

**OR:**

### Method 2: Using the `.zip` archive (Install Folder)
1. Download the `.zip` archive from the **Releases** tab (or click **Code → Download ZIP** on this repository).
2. Extract the `.zip` on your PC so you have a folder containing `eboot.bin`, `index.lua`, and `sce_sys/`.
3. Transfer the extracted folder to `ux0:` on your PS Vita via **VitaShell** (USB or FTP).
4. Highlight the folder in VitaShell, press `△` (Triangle) → **More** → **Install folder**, then confirm with `X`.
