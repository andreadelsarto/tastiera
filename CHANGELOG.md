# Changelog

All notable changes to **Plasma Keyboard** will be documented in this file.

## [v0.92_sound] - 2026-08-08

### 🎵 Procedural Audio Engine (Zero-WAV RAM Synthesis)
- **RAM-Only Acoustic Synthesis**: Synthesizes 44.1 kHz / 16-bit Mono PCM audio waveforms directly in RAM on startup via `QAudioSink`. Zero disk I/O, zero `.wav` or `.ogg` files on disk, latency < 0.5 ms.
- **Differentiated Key Acoustic Signatures**:
  - *Standard Keys (Letters / Numbers)*: 880–900 Hz sine wave click (18ms).
  - *Spacebar*: 380–320 Hz multi-harmonic sweep thud (32ms).
  - *Backspace (Press / Release)*: Crisp 680–380 Hz pop on press; silent hold; single soft 520 Hz release click upon finishing hold deletion.
  - *Enter / Return*: 1100 + 1400 Hz double-harmonic clack (26ms).

### 🛡️ Security Hardening & Seccomp BPF Sandbox
- **Native Seccomp BPF System Call Filtering**: Integrates kernel `libseccomp` sandbox filter blocking dangerous syscalls (`execve`, `execveat`, `ptrace`, `process_vm_readv`, `process_vm_writev`).
- **Systemd User Unit Sandboxing**: Added `systemd/plasma-keyboard.service` with strict network isolation (`IPAddressDeny=any`), `ProtectSystem=strict`, `ProtectHome=read-only`, `MemoryDenyWriteExecute=true`.
- **IPC Socket Owner Isolation (`chmod 0600`)**: Enforces `umask(0077)` and `chmod 0600` permissions on single-instance Unix domain sockets.

### ⚡ Single-Instance IPC & CLI Flags
- **CLI Commands (`--show`, `--hide`, `--toggle`)**: Instant IPC control over Unix domain sockets without creating duplicate display windows or processes.
- **Multitouch Input Engine**: Replaced single-point `MouseArea` with `MultiPointTouchArea` in `KeyButton.qml` for independent multi-finger key press tracking.
- **Signal Cleanup Handlers**: Added `SIGTERM` and `SIGINT` signal handlers to unlink Unix IPC socket files cleanly on exit.
- **Automated Stress Testing**: Added 6-benchmark stress test suite (`stress_test.sh`) validating process memory footprint (~150 MB RSS) and zero zombie processes.

## [v0.91] - 2026-08-07

### 🛡️ Security & Process Protection
- **Process Memory Dump Protection**: Added `prctl(PR_SET_DUMPABLE, 0)` and `RLIMIT_CORE = 0` to prevent Linux kernel core dumps from writing process memory to disk on crashes.
- **RAM Key Lock Buffer (`SecureKeyBuffer`)**: Implemented `SecureKeyBuffer` utilizing `mlock()` to pin sensitive key buffers in physical RAM (preventing swap file exposure) and zeroing memory immediately after send via `explicit_bzero()`.
- **Sensitive Data & Password Mode Protection**: Automatically disables Italian word dictionary suggestions, swipe gesture tracking, and clipboard history logging during active password entries (`PASSWORD` or `SENSITIVE_DATA` input flags).

### 🪟 Window Manager & Tiling Integration (Krohnkite)
- **Tiling Window Manager Bypass**: Configured `Qt::BypassWindowManagerHint` in Qt C++ and QML alongside `Qt::FramelessWindowHint`, `Qt::WindowStaysOnTopHint`, and `Qt::WindowDoesNotAcceptFocus` to prevent Krohnkite and tiling WMs from capturing or resizing the floating keyboard.
- **LayerShell Overlay Enforcement**: Set LayerShell scope explicitly to `virtual-keyboard` and layer to `LayerOverlay` with `KeyboardInteractivityNone` and `AnchorBottom`.
- **Wayland App_ID Specification**: Configured desktop entry application ID to `org.kde.plasma-keyboard`.

### 📐 Layout, Sizing & Ergonomics
- **Giant Spacebar Restoration**: Removed global `Layout.fillWidth: true` from `KeyButton.qml` to allow the spacebar (`space`) to expand across ~500px under `z x c v b n m` matching the original layout design.
- **Extended Mode 100% Display Width**: Configured Extended mode (`full`) to take 100% of the display width (`parent.width`) with 17px side padding for comfortable thumb typing at screen edges.
- **One-Handed Mode Ergonomics**: Automatically hides the `▯▯ Split` pill in `1-Handed` size mode and auto-disables split mode.

### ⌨️ Input Engine, Gboard Shift & Accents
- **Gboard Style Shift & Caps Lock**: Single tap toggles temporary Shift (1 uppercase letter, auto-reverts), double tap (within 300ms) locks Caps Lock (`⇪`), tap while active turns OFF.
- **Instant Accented Characters**: Resolved asynchronous clipboard race conditions in `WaylandVirtualKeyboard::sendEmoji` via `QGuiApplication::processEvents()` and thread synchronization, inserting accented letters (`ì`, `é`, `è`, `à`, `ù`, `ò`) instantly.

### 🎯 Directional Controls & Navigation
- **Kernel Evdev / Uinput Input Dispatching**: Directional keys (▲, ▼, ◄, ►, Home, End, Del) use direct `/dev/uinput` kernel injection, guaranteeing 100% compatibility across GTK, Qt, Firefox, Chrome, and terminals.
- **Accelerating Hold Repeat**: Holding down any directional key performs 1 initial step, then continuously accelerates repeat intervals from 80ms down to 12ms for smooth cursor gliding across long documents.
- **Shift + Tab Backward Navigation**: Tapping `Tab` while Shift is active dynamically converts to `Shift+Tab`, enabling backward focus navigation in forms and code editors.

### 🎨 UI & Localizing
- **English UI Labels**: Unified labels across all buttons to clean English (`Normal`, `Extended`, `1-Handed`, `space`, `Del`, `Sel All`).
- **Clean Header TouchBar**: Removed redundant `IT` and `Emoji` pills from top TouchBar.
- **Default Theme**: Initialized default theme to `BreezeDark`.
- **Dynamic Font Scaling**: Added automatic `font.pixelSize` scaling in `KeyButton.qml` based on label length to prevent text overflow.
