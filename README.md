# crpr — **CR**eate **PR**oyect

A tiny, dependency-free command-line tool that scaffolds a new project in one step:

```sh
crpr my-api py
```

…creates `~/Desktop/proyectos/my-api/`, drops in a **ready-to-run** Python starter (plus a `README.md`), and opens the folder in your editor.

The name is short for **CReate PRoyect** — and it's exactly that: one command instead of the usual *make a folder → `cd` into it → create the entry file → write boilerplate → open the editor*.

---

## Why it's useful

- **Zero friction to start.** Going from idea to a running file is a single command. No templates to copy, no boilerplate to remember.
- **One mental model for 47 languages.** The same `crpr <name> <lang>` works whether you're starting Python, Rust, Go, C++, Haskell, or Solidity. You don't need to recall each toolchain's project layout.
- **Real starters, not empty files.** Each template is a small idiomatic program (a `greet()` function, a loop, command-line argument handling, formatted output) — something that compiles/runs immediately and gives you a place to build from.
- **Per-project README.** Every scaffold includes a `README.md` with the exact command to run that language.
- **Customizable & portable.** Configure the projects directory and editor with environment variables. Ships with a Bash version (macOS/Linux) and a PowerShell version (Windows, plus a `cmd.exe` launcher), so it drops into virtually any terminal.

---

## Install

### macOS / Linux (Bash)

```sh
git clone https://github.com/tanodev0/crpr.git
cd crpr
./install.sh            # installs to ~/.local/bin
```

If `~/.local/bin` isn't on your `PATH`, the installer prints the line to add to your `~/.zshrc` / `~/.bashrc`.

> Prefer a system-wide install? `PREFIX=/usr/local ./install.sh` (may require `sudo`).

### Windows (PowerShell)

```powershell
git clone https://github.com/tanodev0/crpr.git
cd crpr
./install.ps1           # installs to %LOCALAPPDATA%\Programs\crpr and updates PATH
```

This makes `crpr` available in **both** PowerShell and the classic command prompt (`cmd.exe`) via the bundled `crpr.cmd` launcher. Open a new terminal afterwards.

### Manual

Copy `crpr` (Bash) or `crpr.ps1` + `crpr.cmd` (Windows) to any directory on your `PATH`.

---

## Usage

```sh
crpr <project-name> [language]
```

| Command | Result |
| --- | --- |
| `crpr notes` | Creates the folder only (no template) and opens it. |
| `crpr my-api py` | Folder + Python starter + `README.md`. |
| `crpr landing html` | Folder + `index.html` / `style.css` / `script.js`. |
| `crpr engine cpp` | Folder + `main.cpp` starter. |

Flags:

```sh
crpr --help       # show help
crpr --langs      # list supported language codes
crpr --version    # print version
```

If the second argument is omitted, only the folder is created. If it isn't a recognized language, `crpr` warns and still creates/open the folder.

---

## Configuration

Everything is configured through environment variables — no config file needed.

| Variable | Default | Purpose |
| --- | --- | --- |
| `CRPR_PROJECTS_DIR` | `~/Desktop/proyectos` | Base directory where projects are created. |
| `CRPR_EDITOR` | `code` | Command used to open the project. Set to `none` to skip opening. |

Examples:

```sh
# Keep projects in ~/code and open with Sublime Text
export CRPR_PROJECTS_DIR="$HOME/code"
export CRPR_EDITOR="subl"

# Just scaffold, never open an editor
CRPR_EDITOR=none crpr scratch py
```

On Windows (PowerShell):

```powershell
$env:CRPR_PROJECTS_DIR = "C:\code"
$env:CRPR_EDITOR = "code"
```

---

## Supported languages (47)

`py` · `js` · `ts` · `c` · `cpp` · `java` · `go` · `rs` · `rb` · `sh` · `html` · `php` · `swift` · `kt` · `cs` · `dart` · `scala` · `pl` · `lua` · `r` · `jl` · `hs` · `ex` · `erl` · `clj` · `groovy` · `m` · `fs` · `pas` · `f90` · `nim` · `cr` · `zig` · `v` · `d` · `ml` · `rkt` · `scm` · `lisp` · `tcl` · `sql` · `ps1` · `bat` · `sol` · `elm` · `coffee` · `vb`

Common aliases work too (`python`, `node`, `rust`, `golang`, `csharp`, `kotlin`, `objc`, …) and matching is case-insensitive.

Languages that have an idiomatic project layout also get the right config file, e.g. Rust → `Cargo.toml` + `src/main.rs`, Go → `go.mod`, C#/F# → a `.csproj`/`.fsproj`, Node/TS → `package.json`.

---

## How it works

`crpr` is a single self-contained script (no runtime dependencies beyond a POSIX shell or PowerShell). It:

1. Resolves the projects directory (`CRPR_PROJECTS_DIR`).
2. Creates `<projects-dir>/<name>` (idempotent — reuses an existing folder).
3. If a language is given, writes the template files and a `README.md`.
4. Opens the folder with `CRPR_EDITOR`.

---

## License

[MIT](LICENSE) © tanodev0
