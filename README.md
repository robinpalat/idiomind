# Idiomind

**Idiomind** is a language-learning application originally developed for Linux using **Bash and the Unix/Linux environment**.

It began in **2013** as a small Bash script that translated words from the command line and displayed the results through the Linux desktop notification system.

Over time, that experiment evolved into a complete language-learning environment for creating, organizing and reviewing personalized vocabulary and expressions.

This repository contains the **original Bash version of Idiomind**.

## Origins

The first version of Idiomind was deliberately small:

```text
word
  ↓
translation
  ↓
desktop notification
```

From there, the project grew organically, adding vocabulary management, language data, review mechanisms, audio, HTML-based content and desktop integration.

**Rather than being built initially as a conventional desktop application, Idiomind developed around the tools and conventions of the Unix/Linux environment.**

Its architecture reflects that history.

## Architecture

The original version combines:

* Bash
* Unix/Linux utilities
* GTK+ desktop tools
* HTML
* SQLite
* local language data
* a small native component, `Idiomind_utils`

`Idiomind_utils` provides functionality that is not practical to implement directly in Bash, including HTML display and desktop integration.

The result is a hybrid application in which **Bash remains the main application layer**, while native functionality is provided where necessary.

## Local Data

Idiomind stores the user's language-learning material locally using files and SQLite.

The original design does not depend on a permanent remote backend, keeping the learning data accessible to the user and straightforward to inspect or back up.

## System Requirements

The original version was designed for a GTK+-based Linux desktop environment and depends on several system utilities, including:

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
* wkhtmltopdf
* `Idiomind_utils`

## Installation

The original Debian/Ubuntu distribution was provided through a PPA:

```bash
sudo add-apt-repository ppa:robinpalat/idiomind
sudo apt-get update
sudo apt-get install idiomind
```

The PPA represents the original distribution method and may not be available for all current Debian or Ubuntu releases.

## Project History

This repository preserves the original Bash implementation of Idiomind.

The project later moved toward a **Qt/C++ desktop implementation**, providing a different foundation for continued development.

This repository remains as a record of the original architecture and the ideas from which the project evolved.

## Status

**Legacy / Historical**

This is the original Bash version of Idiomind and is no longer the primary development direction.

## Author

**Robin**

Idiomind started in 2013 as a small experiment with language learning, Bash and the Linux desktop, and gradually developed into a larger project.

## License

See the `LICENSE` file for the licensing terms of this repository.

