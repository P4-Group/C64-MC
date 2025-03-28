#   C64-MC: Chiptune Music Generator for Commodore 64

In the fourth semester, we've been tasked to create a compiler. The compiler was choosen to translate a custom music langauge into 6502 assembly code, which then can be executed on the commodore 64. The commodore would then utilies the SID 6581 sound chip to produce authentic 8-bit chiptune music.

## Table of Contents

-   [Introduction](#introduction)
-   [Features](#current-features)
-   [Music Theory](#music-theory)
-   [Commodore 64 and SID 6581](#commodore-64-and-sid-6581)
-   [Getting Started](#getting-started)
-   [Prerequisites](#prerequisites)
-   [Installation](#installation)
-   [Usage](#usage)
-   [Language Design](#language-design)
-   [Compiler Architecture](#compiler-architecture)
-   [Contributing](#contributing)
-   [License](#license)
-   [Acknowledgments](#acknowledgments)

## Introduction

Chiptune music finds it's root in the sound chips of vintage arcade machines and older computers such as the Commodore 64, for many which holds a nostalgic sound and for others is interesting in the sense of retro hardware hobbies. This project tries to create authentic chiptune music using the Commodore 64 by developing a specialized compiler which makes the process of developing chiptune music easier.

The Commodore 64 and it's SID 6581 sound chip were crucial in the chiptune genre's rise to fame. However, programming the SID 6581 chip directly in assembly or basic can be very complex and time consuming. Thus this project is meant to brigde that gap by introducing a higher-level langauge music description langauge that abstracts the complexities that comes with writing assembly code or basic. The goal is therefore to make programming for the Commodore and in particular the SID 6581 chip more accessible.


## Current Features

| **Category**           | **Features**                                                                 |
|-------------------------|-----------------------------------------------------------------------------|
| **Must Have**           | - TODO                                                                      |
|                         | - TODO                                                                      |
|                         | - TODO                                                                      |
| **Should Have**         | - TODO                                                                      |
|                         | - TODO                                                                      |
|                         | - TODO                                                                      |
| **Could Have**          | - TODO                                                                      |
|                         | - TODO                                                                      |
|                         | - TODO                                                                      |
| **Won't Have (for now)**| - TODO                                                                      |
|                         | - TODO                                                                      |
|                         | - TODO                                                                      |

##  Music Theory

The project's music description language is designed around concepts from Western music theory. Key elements include:

* **Note Types:** Representation of note durations (whole, half, quarter, etc.) within the language.
* **Time Signatures:** How time signatures (e.g., 4/4, 3/4) are defined in the language to structure music.
* **Tempo:** Controlling the speed of the music (BPM) through the language.
* **Tones and Pitch:** Defining notes (C, D, E, F, G, A, B) and accidentals (#, b) in the language, including octave notation.
* **Volume/Dynamics:** Language syntax for specifying volume levels (pianissimo, forte, etc.) and changes (crescendo, decrescendo).
   [cite: 861, 862, 863, 864, 865, 866, 867, 869, 870, 871, 872, 873, 875, 876, 877, 878, 879, 880, 881, 882, 883, 884, 885, 886, 887, 888, 889, 890, 891, 892, 893, 894, 895, 896, 897, 898, 899, 900, 901, 902, 903, 904, 909, 910, 911, 912, 913, 914]

##  Commodore 64 and SID 6581

This section provides background on the hardware that your compiler targets:

* **Commodore 64:** Brief overview of the C64 and its importance in chiptune. [cite: 969, 970, 971, 972, 973, 974, 975, 976, 977, 978, 979, 980, 981, 982, 983, 984, 985, 986, 987, 988, 989, 990, 991, 992, 993, 994, 995, 996, 997, 998, 999, 1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, 1023, 1024, 1025, 1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1040, 1041, 1042, 1043, 1044, 1045, 1046, 1047, 1048, 1049, 1050, 1051, 1052, 1053, 1054, 1055, 1056, 1057, 1058, 1059, 1060, 1061, 1062, 1063, 1064, 1065, 1066, 1067, 1068, 1069]
* **SID 6581:** Details about the SID chip's capabilities (voices, waveforms, envelopes, filters) and how your compiler leverages them.


##  Getting Started

This section explains how to set up and use the C64-MC compiler.

### Prerequisites

List any software or hardware requirements:

* A Commodore 64 or a C64 emulator (e.g., Vice)
* Supported operative systems: Mac OS, Linux(Tested on Arch and Ubuntu), and Windows



### Installation Steps

1.  **Clone the Repository:**

    Open your terminal or command prompt and clone the C64-MC repository from GitHub:

    ```bash
    git clone https://github.com/P4-Group/C64-MC/
    cd C64-MC
    ```

2.  **Install Dependencies:**

    This project might have additional dependencies beyond the tools listed above.

    * **Check Dependency Documentation:** Ensure you review the documentation for each dependency (e.g., Dune, opam) to find OS-specific installation instructions. These details are often available on the official websites or in the project's own documentation.

3.  **Compile the Compiler:**

    Use Dune to build the compiler:

    ```bash
    dune build
    ```

    * This command compiles the C64-MC compiler. The resulting executable will be located in the `_build/default/` directory or a similar path, depending on your Dune configuration.

### Post-Installation

After successful installation, you can proceed to use the compiler to generate chiptune music for the Commodore 64. See the "Usage" section for instructions.


### Usage

To use the C64-MC compiler, follow these steps:

1. **Create a Music File:**
    Write your music in the custom music description language. Save it with a `.c64mc` extension. Below is an example:

    ```c64mc
    TITLE Coolest song ever
    COMPOSER Jens jensen

    tempo = 121
    timeSignature = (3, 4)
    standardPitch = 441

    // This is a comment

    sequence newSequenceMoody = { 
      c4:5 c c# | d_ e' e, e2 d4 d d e c2 c
    }
    channel1 = [(newSequenceMoody; VPulse), (newSequence; Sawtooth), (newSequence4, Triangle)]

    generate(channel1,)
    ```

2. **Compile the Music File:**
    Use the C64-MC compiler to translate your `.c64mc` file into 6502 assembly code. Run the following command:

    ```bash
    ./_build/default/c64mc your_music_file.c64mc
    ```

    Replace `your_music_file.c64mc` with the path to your music file.

3. **Load the Output on a Commodore 64:**
    The compiler will generate an `.asm` file containing the 6502 assembly code. You can assemble this file using an assembler like `ca65` to produce a `.prg` file.

4. **Play the Music:**
    Once you have the `.prg` file, load it onto a Commodore 64 or an emulator like Vice to play your chiptune music.
    Run the `.prg` file on your Commodore 64 or emulator to hear your chiptune music.

For more details on the music description language syntax, refer to the "Language Design" section.

##  Language Design

The tests folder of the GitHub repository. These samples demonstrate various features of the language and serve as a reference for creating your own music files. You can find them in the `tests/` directory of the project repository.

### Language Keywords Documentation

| **Keyword** | **Usage Example**       | **Description**                          |
|-------------|-------------------------|------------------------------------------|
| `TITLE`     | `TITLE My Song`         | Specifies the title of the music piece.  |
| `COMPOSER`  | `COMPOSER John Doe`     | Defines the composer of the music.       |
| `tempo`     | `tempo = 120`           | Sets the tempo of the music in BPM.      |



##  Compiler Architecture

This section provides an overview of the C64-MC compiler's architecture.

* **Compiler Stages:** Describe the main stages of the compilation process:
    * Lexical analysis (scanning)
    * Syntax analysis (parsing)
    * Code generation (6502 assembly)
* **Key Components:** <!-- TODO -->
* **Data Structures:** <!-- TODO -->

##  Contributing

## Contributing

We welcome your interest in the C64-MC project! Here's how you can engage with the project:

### Reporting Bugs
If you encounter any bugs or issues, please report them using the GitHub Issues feature. When submitting a bug report, include the following details:
- A clear and descriptive title.
- Steps to reproduce the issue.
- Expected and actual behavior.
- Any relevant logs, screenshots, or error messages.

### Suggesting Features
We encourage you to suggest new features or improvements via GitHub Issues. When submitting a feature request, please provide:
- A clear description of the feature.
- The problem it solves or the value it adds.
- Any relevant examples or use cases.

### Code Contributions
As this is a university project, we are not accepting code contributions until a few months after Summer 2025. Once contributions are open, we will provide detailed guidelines for submitting pull requests.

### Coding Style Guidelines
To ensure consistency across the codebase, contributors will be required to follow the project's coding style guidelines. These guidelines will be shared when contributions are open.

❤️ Thank you for your interest and support! ❤️

##  License

This project is licensed under the GNU General Public License v3.0. You can find the full license text in the `LICENSE` file or at [https://www.gnu.org/licenses/gpl-3.0.en.html](https://www.gnu.org/licenses/gpl-3.0.en.html).

##  Acknowledgments

We would like to express our heartfelt gratitude to the incredible lecturers at Aalborg University Copenhagen. Their dedication, expertise, and passion for teaching have been instrumental in shaping our understanding of compiler design and retro computing. Their guidance and support have been invaluable throughout this project. Thank you for inspiring us to push the boundaries of our knowledge and creativity!
