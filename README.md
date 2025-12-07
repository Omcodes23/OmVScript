# OmVScript

**OmVScript** is a modular, script-first provisioning toolkit by **Om Vataliya (Omcodes23)**.  
It lets you convert an existing Linux system into different roles:

- Server (CasaOS, custom server stacks)
- NAS (OpenMediaVault – future)
- Developer environment (VS Code, Python, Node, JDK, etc.)

Future phase → **OmVOS** (a full Linux-based OS built using these scripts).

---

## 🚀 Quickstart

> ⚠️ Always inspect scripts before running them.

```bash
# Download + inspect
curl -fsSL https://raw.githubusercontent.com/Omcodes23/OmVScript/main/install.sh -o /tmp/omvscript-install.sh
less /tmp/omvscript-install.sh

# Run (after inspection)
sudo bash /tmp/omvscript-install.sh
