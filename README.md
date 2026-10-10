# 4.3BSD on the VAX780 (SIMH) — instant-instance package

Everything needed to spin up a fresh, fully-installed 4.3BSD MicroVAX 3900 system.
One script unpacks a pristine disk image and a working simh config into a new directory.

## Scripts

| script        | what it does                                                     |
|---------------|------------------------------------------------------------------|
| `create.sh`   | build a new instance directory from the packaged images           |
| `run.sh`      | inside an instance: boot it (`-t` telnet, `-s` single-user, `-n` no autoboot) |
| `destroy.sh`  | delete an instance and its disk (`-f` to skip the prompt)          |
| `snapshot.sh` | compress an instance's disk into `instances/<name>/`               |
| `pack.sh`     | rebuild this package (images + tarball) from a source 4.3BSD dir  |
| `list.sh`     | show every instance, its state and disk size                     |
| `justfile`    | the same operations as `just` recipes (see below)                |

With [`just`](https://github.com/casey/just) installed, everything is a recipe:

```sh
just                 # list instances and their state
just new work        # create
just run work        # boot (also: just console / just single / just simh)
just kill work       # stop it
just snap work       # snapshot its disk
just promote work    # make that snapshot the image new instances get
just rm work         # delete
just pack            # rebuild the package tarball
```

## Quick start

```sh
git clone https://github.com/isaiahpettingill/43BSD.git
cd 43BSD
./create.sh            # creates ./43bsd from the packaged disk image
cd 43bsd
./run.sh               # boots 4.3BSD; log in as root (no password)
```

Requires `xz` and a Linux x86-64 host. The SIMH `vax780` binary is included in
`bin/`; you do not need to build simh yourself.

Named instance, or replacing an existing one:

```sh
./create.sh work
./create.sh work -f
```

Every instance is independent — its own `rq.dsk`, so anything you break in
`work` does not affect the default `43bsd` instance or any other.

## Inside an instance

| file     | what it is                                          |
|----------|-----------------------------------------------------|
| `rq.dsk` | RA81 disk, 456 MB, fully installed 4.3BSD            |
| `43.tap` | distribution tape (attached by `boot.ini`)          |
| `boot42` | secondary bootstrap                                  |
| `boot.ini` | simh config: RA81 on rq0, tape, autoload + boot     |
| `run.sh` | boots it; `--telnet` moves the console to TCP 2323  |
| `vax780` | the SIMH VAX780 emulator (also as `simh`)           |

Use `./run.sh --telnet` if your terminal cannot hold a raw-mode console, then
`telnet localhost 2323`. Inside the emulator, `Ctrl-E` gets you a `simh>`
prompt (e.g. `show rq0`, `detach rq0`, `quit`).

## Package layout

```
43bsd-vax780/
  create.sh      build a new instance from the image
  run.sh.in      template turned into <instance>/run.sh
  pack.sh        rebuild the package (images + tarball) from a source dir
  snapshot.sh    capture an instance's disk into instances/
  destroy.sh     remove an instance
  list.sh        list instances and their state
  justfile       just recipes wrapping all of the above
  LICENSE        0BSD (public domain)
  bin/vax780     simh VAX780 binary (prebuilt, x86-64 Linux)
  files/*.xz     disk image, tape, boot42, boot.ini (compressed)
  extras/        the install tape contents as .tar.gz, if you ever need
                 to re-install or look at the source (new, src, srcsys,
                 usr, vfont, ingres, stand)
```

A clone is ~35 MB. An unpacked instance is ~570 MB on disk; `xz -d` takes a few
seconds, which is why the images ship compressed.

Inside an instance, `run.sh` writes a `.running` marker and refuses to start a
second copy on the same disk; `Ctrl-E` in the emulator gets you a `simh>`
prompt (`show rq0`, `detach rq0`, `quit`).

Refreshing the package after changing a system:

```sh
./snapshot.sh work                 # compress work/rq.dsk into instances/work/
cp instances/work/rq.dsk.xz files/rq.dsk.xz
./pack.sh                          # recompress everything and re-tar
```

## License

0BSD (`LICENSE`). The bundled SIMH VAX780 emulator binary is distributed under
its own permissive license; 4.3BSD and its distribution files are covered by
the BSD license as published by the University of California.
