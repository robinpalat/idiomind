# Idiomind

**Idiomind** is a language-learning application originally developed for Linux using **Bash, YAD and the Unix/Linux environment**.

This repository contains the **original Bash version of Idiomind**.


---

## Bash and YAD

Two technologies are particularly central to the original version of Idiomind.

**Bash** provides the main application logic, orchestration and data processing.

**YAD (Yet Another Dialog)** provides much of the graphical interface, allowing Bash scripts to create dialogs, forms, lists, menus and other interactive elements.

Together, they form the core of the original desktop application:

```text
                 Idiomind
                    │
             ┌──────┴──────┐
             │             │
           Bash           YAD
             │             │
     application logic   GUI
             │             │
             └──────┬──────┘
                    │
          Unix/Linux environment
```

The rest of the application is built by combining these with the tools and services available in the Linux environment.

---

## Architecture

The original Idiomind combines:

* **Bash** — application logic and orchestration
* **YAD** — graphical interface
* **Unix/Linux utilities** — system integration and text/file processing
* **SQLite** — structured local data
* **HTML** — content presentation
* **audio tools** — speech and audio processing
* **Python** — selected supporting functionality
* **`Idiomind_utils`** — native desktop and HTML integration

This architecture allowed Idiomind to remain relatively small while taking advantage of existing Linux tools instead of reimplementing their functionality inside the application.

### Idiomind_utils

The original application also includes a small native component called **`Idiomind_utils`**.

It is installed at:

```text
/usr/lib/Idiomind_utils
```

It provides functionality that is difficult or impractical to handle directly from Bash, including displaying HTML-based elements and integrating Idiomind with the Linux desktop, such as its system tray/panel icon.

This creates a hybrid architecture: most of the application remains implemented in Bash and YAD, while `Idiomind_utils` provides selected native functionality where needed.

---

## Local Data

Idiomind keeps the user's language-learning material locally.

The original version uses files and SQLite rather than relying on a permanent remote service.

This makes the learning data accessible to the user and relatively straightforward to inspect, back up or move.

---

## System Requirements

The original version was designed for a **GTK+-based Linux desktop environment**.

Its main dependencies include:

* Bash
* YAD
* MPlayer
* ImageMagick
* cURL
* xclip
* Python 3
* eSpeak
* SQLite 3
* SoX
* libnotify-bin
* weasyprint
* `Idiomind_utils`

Several of these tools are used directly by the application, while others provide specific functionality such as audio playback, speech synthesis, image processing or document generation.

---

## Installation

The original Debian/Ubuntu distribution was provided through a **PPA**.

```bash
sudo add-apt-repository ppa:robinpalat/idiomind
sudo apt-get update
sudo apt-get install idiomind
```

The PPA represents the original distribution method for this version of Idiomind. Its availability may depend on the Debian or Ubuntu release being used.

---

## Project History

Idiomind began in 2013 as a small experiment with language learning, Bash and the Linux desktop.

Over time, that experiment became a larger application while retaining its original Unix-oriented approach. The resulting architecture is a reflection of that history: Bash and YAD at its core, surrounded by the tools and capabilities of the Linux environment.

The project later moved toward a **Qt/C++ implementation**, providing a different foundation for continued development.

This repository preserves the original implementation and the ideas from which the project evolved.

---

## Status

**Legacy / Historical**

This repository contains the original Bash version of Idiomind and is no longer the primary development direction of the project.

It is preserved as part of the project's history and as a reference for its original architecture and implementation.

---

## Author

**Robinpalat**

---

## License

See the `LICENSE` file for the licensing terms of this repository.
