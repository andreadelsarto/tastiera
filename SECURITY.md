# 🛡️ Security Architecture & Privacy Policy

Plasma Touch Key (*Tastiera*) is designed with privacy-first and defense-in-depth principles. Because virtual input methods process sensitive credentials, passwords, and user input, the application enforces multiple security layers at the OS, Wayland, IPC, and memory levels.

---

## 🔒 Security Implementations

### 1. 🚫 Core Dump & RAM Protection (`PR_SET_DUMPABLE`)
* **Mechanism**: On startup (`src/main.cpp`), the process invokes `prctl(PR_SET_DUMPABLE, 0)` and sets `RLIMIT_CORE` to `0`.
* **Security Benefit**: Prevents OS core dumps or unprivileged process debuggers (`ptrace`, `/proc/$PID/mem`) from reading sensitive keystroke data or password buffers from RAM in the event of a crash.

### 2. 🔑 IPC Socket Isolation & Owner Access Control (`0600`)
* **Mechanism**: The single-instance IPC socket located at `$XDG_RUNTIME_DIR/plasma-keyboard-single-instance` is initialized with a strict `umask(0077)` and explicitly enforced `chmod 0600` permissions.
* **Security Benefit**: Prevents multi-user privilege escalation attacks. Only the exact OS user running the desktop session can send IPC signals (`--toggle`, `--show`, `--hide`) to the running keyboard process.

### 3. 🎯 Focus Isolation & Wayland Protocol Integrity
* **Mechanism**: Uses `LayerShellQt::Window::KeyboardInteractivityNone` and `Qt::WindowDoesNotAcceptFocus`. Keystrokes are injected exclusively via the official `zwp_virtual_keyboard_v1` Wayland protocol.
* **Security Benefit**: The virtual keyboard window **never steals window focus** or text input context. Keystrokes are directly routed by the Wayland compositor (KWin) to the active application without intermediary keylogging opportunities.

### 4. 🧹 Automatic Socket Clean-Up Signal Handlers
* **Mechanism**: Registers Linux `SIGTERM` and `SIGINT` signal handlers (`signalHandler`) alongside Qt's `aboutToQuit` hook to unlink the Unix IPC socket on process exit.
* **Security Benefit**: Mitigates socket squatting vulnerabilities and ensures seamless single-instance recovery.

### 5. 🙈 Zero Input Logging Guarantee
* **Mechanism**: No typed text, password buffers, or input histories are stored on disk or written to telemetry/log files. Memory buffers (such as predictive text prefixes) reside transiently in RAM and clear on word boundaries.

---

## 🛠️ Verification & Compliance

You can verify the security posture on a running instance using standard Linux utilities:

```bash
# Verify PR_SET_DUMPABLE protection (Dumpable: 0)
grep -i "nprocs\|coredump\|dumpable" /proc/$(pgrep plasma-keyboard)/status

# Verify IPC socket permissions (srwxr-xr-x / owner 0600 access)
ls -la $XDG_RUNTIME_DIR/plasma-keyboard-single-instance
```
