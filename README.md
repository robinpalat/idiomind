# Idiomind

**Idiomind** is a language-learning application originally developed for Linux using **Bash and the Unix/Linux environment**.

It began with a very small idea: translate a word from the command line and have the result appear directly on the desktop.

From that first experiment, Idiomind gradually grew into a complete language-learning environment, combining Bash scripts, Unix utilities, HTML, local data and a small native component for desktop integration.

This repository contains the **original Bash version of Idiomind**.

---

## How it started

Idiomind began in **2013** as a small Bash script.

The original idea was simple: a command could take a word, translate it, and use Linux's `notify-send` to display the translation as a desktop notification.

```text
word
  ↓
translation command
  ↓
translated text
  ↓
notify-send
  ↓
Linux desktop notification
```

There was no large application behind it at the beginning. Just a shell script, a translation command and the desktop notification system.

That small utility eventually became the starting point for Idiomind.

As new ideas were added, the project grew organically: vocabulary management, language data, review mechanisms, HTML-based content and deeper integration with the Linux desktop gradually became part of the application.

The original Bash architecture is therefore closely tied to the way Idiomind evolved. Rather than beginning with a conventional application framework, the project grew **out of the Unix environment itself**.

---

## The idea

The underlying idea remained simple: language learning works better when the material becomes your own.

Instead of following only a predefined vocabulary or course, Idiomind allows the learner to build a personal collection of words and expressions and return to them repeatedly.

The application was designed to make that process immediate while keeping the user's language data local and accessible.

---

## Built around Linux

One of the defining characteristics of the original Idiomind is that **Linux is part of the application itself**.

Bash provides the main scripting environment, while the Unix/Linux ecosystem supplies many of the tools with which Idiomind works: filesystem operations, text processing, process management, desktop utilities and other small programs that can be combined to accomplish more complex tasks.

The application therefore brings together:

```text
Bash
+
Unix/Linux utilities
+
GTK+ desktop environment
+
HTML
+
local data
+
Idiomind_utils
```

Rather than trying to recreate everything from scratch, Idiomind makes use of what the operating system and its ecosystem already provide.

---

## Idiomind_utils

There is one important native component in the original application.

Idiomind includes a binary called **`Idiomind_utils`**, installed in:

```text
/usr/lib/Idiomind_utils
```

This utility provides functionality that is difficult or impractical to handle directly from Bash.

Among other things, it is responsible for displaying the **HTML-based elements of Idiomind** and for integrating the application with the Linux desktop, including the **Idiomind icon in the system panel/tray**.

This creates a hybrid architecture in which Bash remains the main application environment while `Idiomind_utils` provides selected native graphical functionality.

```text
                 Idiomind
                    │
                  Bash
                    │
          ┌─────────┴─────────┐
          │                   │
   Unix/Linux tools      Idiomind_utils
                              │
                       ┌──────┴──────┐
                       │             │
                     HTML       System icon
```

The native component is deliberately small. Most of the application remains in Bash and uses the Unix environment as its foundation.


---

## System Requirements

The original version of Idiomind was designed for a **GTK+-based Linux desktop environment**.

The main requirements are:

* GTK+-based desktop environment
* Bash
* YAD
* MPlayer
* ImageMagick
* wkhtmltopdf
* cURL
* xclip
* Python 3
* eSpeak
* SQLite 3
* SoX
* `Idiomind_utils`

These programs are not merely optional conveniences. They form part of the environment that the original application uses to provide its different functions.

Because Idiomind was developed around the Unix/Linux ecosystem, several of its features are implemented by combining these existing tools rather than by reproducing their functionality internally.

---

## Installing in Debian, Ubuntu and derivatives

The original Idiomind distribution for Debian, Ubuntu and derivatives was available through a **PPA**.

Add the Idiomind repository:

```bash
sudo add-apt-repository ppa:robinpalat/idiomind
```

Update the package information:

```bash
sudo apt-get update
```

Install Idiomind:

```bash
sudo apt-get install idiomind
```

The package installation provides the application and its required components, including the `Idiomind_utils` native utility.

> The PPA reflects the original distribution method of this version of Idiomind. Its availability may depend on the Ubuntu/Debian release being used.

---

## Local by design

The user's language material is kept locally.

The original application relies on files and SQLite rather than requiring a remote service or a permanently connected backend.

This makes the learning data easy to inspect, back up and move, while keeping the learner's vocabulary under their own control.

---

## A piece of the project's history

This repository preserves the **original Bash implementation of Idiomind**.

It represents the period in which the project grew directly from the Linux environment, beginning with a small translation notification in 2013 and gradually becoming a larger language-learning system.

Its architecture reflects that history. Bash, Unix utilities, GTK+, HTML and a small native binary were not simply technologies selected from a specification; they became the pieces from which the application was built as the project evolved.

The project later moved toward a more conventional desktop architecture with **Qt/C++**. That newer implementation provides a different foundation for continued development, while this repository preserves the original approach.

---

## Status

**Original Bash version — Legacy / Historical**

This version is no longer the main development direction of Idiomind, but it remains part of the project's history and provides a reference for understanding its original ideas and implementation.

---

## Author

**Robin**

Idiomind started in 2013 as a small experiment with language learning, Bash and the Linux desktop, and gradually grew into a larger project.

---

## License

See the `LICENSE` file for the licensing terms of this repository.
