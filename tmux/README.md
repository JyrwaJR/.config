# tmux, nested over SSH

## What this is

Nesting tmux inside an SSH connection was ambiguous. Both layers use `C-a` as the
prefix, and `C-h/j/k/l` meant two different things depending on which layer you
were in: navigate a pane, or reach the far end and switch the editor's window.
Nothing on screen told you which layer had your keystrokes, and a key that failed
to forward had no visible cause.

This config fixes that with two ideas.

The first is a visible nesting cue. Three of them, in fact: a badge in the local
status bar that appears only when the focused pane is sshed out, a literal
`[ REMOTE ]` marker on the far end, and a different active-pane border colour per
layer. See [The nesting cues](#the-nesting-cues).

The second is key forwarding that only activates when the pane's foreground
process is something that actually needs the keys. `C-h/j/k/l` are matched
against the pane's foreground process; if it is an editor or an ssh session the
key is sent into the pane, and if it is anything else the key moves the
selection. See [Key reference](#key-reference).

Files in this directory:

| File | Role |
| ---- | ---- |
| `tmux.conf` | Local layer. Also the one that gets the helper script and the plugin stack. |
| `remote-tmux.conf` | The far end of the SSH connection. A near-complete mirror, minus plugins. |
| `check-ssh` | Status-bar helper. Two unrelated questions about SSH; see [The nesting cues](#the-nesting-cues). |

## Key reference

| Keys | What happens |
| ---- | ------------ |
| `C-a` | The prefix, on **both** the local and the remote layer. Deliberate. It keeps one muscle memory, and the nesting cues tell you which layer is currently answering. Do not give the remote a different prefix: `send-prefix` emits *this* server's prefix key, so a mismatch makes the passthrough below type a literal `C-a` into whatever the remote pane is running. |
| `C-h` / `C-j` / `C-k` / `C-l` | Navigate panes. If the focused pane's foreground process is `nvim`, `vim`, `view`, `ssh`, or `mosh`, the key is **forwarded into the pane** instead, and the far end forwards it again. Any other foreground process, and the key does plain pane selection. |
| `C-a C-a` | Passes the next key through to the remote layer. The first `C-a` enters the prefix table; the second fires `send-prefix`, which emits `C-a` to the pane and leaves the key table, so whatever you type next is delivered to the far end untouched. |
| `C-a d` | Detaches the **local** tmux only. |
| `C-a C-a d` | Passes `d` through, so it detaches the **remote** tmux and you land back in a local pane. See below; this is the one that catches people. |
| `C-a r` | Re-sources the config that layer is running. Local sources `tmux.conf` and says `tmux config reloaded`; remote sources `remote-tmux.conf` and says `tmux remote config reloaded`. Each names itself, so the message tells you which server you just reloaded. |

### The forwarding list is end-anchored

The matcher is:

```sh
ps -o state= -o comm= -t '#{pane_tty}' | \
    grep -iqE '^[^TXZ ]+( +|:).*?(n?vim|vim|view|ssh|mosh)(diff)?(-wrapped)?$'
```

Three things follow from that, and all three matter at 2am.

The list is `nvim`, `vim`, `view`, `ssh`, `mosh`, each with an optional `diff` or
`-wrapped` suffix. It is **not** `*ssh*`. Anything that merely contains "ssh" is
excluded: `ssh-agent`, `ssh-add`, `sshfs`, `sshd` do not match, and a pane running
a bare `ssh-agent` does not forward and does not get the badge. That is the
intended behaviour, not a gap. Under-reporting is the safe direction because the
fallback for a key that is not forwarded is plain pane selection, which is what
this config did before the feature existed.

The `ssh` arm is the whole point of the feature. Without it this server sees
`ssh` as the pane's foreground process rather than `nvim`, concludes nothing owns
the key, and eats it as `select-pane`, so the key never reaches the editor on the
far side of the connection.

A forwarded key stops at the far end. It crosses one SSH hop. If there is no tmux
on the remote, the key lands in a bare remote shell. Always connect with
[`tssh`](#tssh--connecting-to-a-remote).

### The detach asymmetry

This asymmetry is the single easiest thing in this file to get wrong, so it is
worth stating twice:

**`C-a d` detaches the local layer. `C-a C-a d` detaches the remote layer.**

They differ by one `C-a`, and the outcome is the opposite of what the prefix
sequence suggests.

- `C-a d`. The local server consumes both keys. The local client detaches and you
  are at a bare shell on this machine. The SSH connection and the remote tmux are
  untouched and still running.
- `C-a C-a d`. The second `C-a` fires `send-prefix`, which hands `C-a` to the pane
  and steps out of the key table. The `d` follows it across the wire to the remote
  server's prefix table and runs *its* `detach-client`. You land back in a local
  pane, on this machine, with the local tmux still attached and still running.

The general rule: to act on the remote layer, you owe the remote layer a prefix
of its own. One `C-a` reaches the local prefix table; two reach the remote one.

The same asymmetry applies to every other prefixed key, not just `d`. `C-a c`
makes a local window; `C-a C-a c` makes a remote window. `C-a C-a r` reloads
`remote-tmux.conf`, not `tmux.conf`.

## The nesting cues

Three cues, and they answer different questions. Do not collapse them into one.

### Teal badge in the local status bar

The ` ⇉ C-a C-a → remote ` segment, produced by `check-ssh p` in `status-right`.
It appears only when `#{pane_current_command}` is `ssh` or `mosh`, and it collapses
to nothing otherwise, so the bar is unchanged on a non-ssh pane.

It is the cue that says *your keys are about to cross the wire; type `C-a C-a`
first.* It is teal `#94e2d5` on purpose, not red or green: the red/green segments
in the same bar ask a different question. `check-ssh u` and `check-ssh n` walk the
parent-process chain from `#{client_pid}` looking for an `sshd` or `mosh-server`
ancestor, which answers "am I sshed *into* this box". The teal badge reads
`#{pane_current_command}`, which answers "is this pane sshed *out* of it". The two
must never look alike. The status bar runs on a 1s interval (`status-interval 1`),
so the badge is live, not a snapshot from when the pane started.

### `[ REMOTE ]` in the remote status bar

A literal, unconditional string in `remote-tmux.conf`'s `status-left`. No script
call, no `#{...}` expansion, no detection.

That is the point. It is the one cue that cannot fail. `check-ssh` may not be
installed on the remote, and a remote is not guaranteed to have this repo at all.
There is also nothing to detect: being at the far end of a connection *is* the
fact, so there is no condition to test. The badge is teal and bracketed rather
than the local peach rounded pill, so the two levels never read alike even with
both bars on screen at once.

If you replace it with a `#()` call that returns nothing when the condition is
false, the failure mode is that the remote looks exactly like the local box and you
type into the wrong machine.

### Active-pane border colour

Blue `#8aadf4` locally, teal `#94e2d5` on the remote.

This is the primary at-a-glance cue that you are on a different layer, because with
a nested pair on screen there are two active borders drawn at once and you cannot
use "there is a highlighted border" to tell them apart. Only the hue does. Do not
harmonise the two into one colour.

It is a weaker cue than the badge, since it is a hue difference in the same
position and position is not evidence. Read the badge first, the border second.

## `tssh` — connecting to a remote

Defined in `.zshrc`. Usage is `tssh <host>`:

```zsh
tssh box
```

It runs:

```sh
ssh -t -- "$1" 'tmux -f ~/.config/tmux/remote-tmux.conf new-session -d -s main 2>/dev/null; tmux source-file ~/.config/tmux/remote-tmux.conf; tmux new-session -A -s main'
```

### Why it is three steps

The obvious one-liner is wrong, and wrong silently:

```sh
tmux -f ~/.config/tmux/remote-tmux.conf new-session -A -s main
```

`-f` is read **only when the server starts**. `-A` means "create the session if it
does not exist, otherwise attach to the existing one". So on a host that already
has a tmux server running, `-A` attaches to the existing session and `-f` is
never applied. The remote keeps `prefix=C-b`, has no forwarded keys, shows no
`[ REMOTE ]` marker, and nothing errors. You are attached to a stock tmux that
looks like a broken one.

So the function splits the two cases:

1. **Start a server with the right config, discarding the failure that means one is
   already running.** `new-session -d -s main 2>/dev/null`. On a cold remote this
   creates the server and reads `-f`. On a warm remote it fails, and the failure
   is exactly the signal that step 2 is needed, so it is thrown away.
2. **Apply the config to whatever server is there.** `source-file`. This is the
   step that repairs a warm or pre-existing server, and the reason the function is
   three steps rather than one. Sourcing twice is safe: every option in the file
   is `set -g`, which replaces rather than appends, and `bind-key` replaces a key
   in place rather than stacking a second copy. The one directive that could
   accumulate, the RGB entry in `terminal-features`, therefore uses `set -sg`
   carrying tmux's own defaults forward, so the replace is lossless.
3. **Create-or-attach.** `new-session -A -s main` without `-d`, so you get
   attached, and a second connection to the same box rejoins the existing session
   rather than stacking another layer on top of it.

Without step 1 a cold remote gets a stock bar. Without step 2 a warm one does.
Both cases are ordinary, so both cases are handled.

### Precondition

`~/.config/tmux/remote-tmux.conf` must already exist on the remote.

`tssh` does not ship the file and does not check for it. A missing file makes
step 2's `source-file` fail loudly and visibly, which is the right default: a
remote running a stock tmux with no marker and no forwarding looks like a working
setup that is quietly ignoring your arrow keys.

Be precise about what the loudness buys you, though, because it does not stop the
connection. With the file missing, step 1 still starts a server (its stderr is
sent to `/dev/null`), step 2 prints `No such file or directory`, and step 3
attaches you to a stock tmux with `prefix C-b`. Verified against tmux 3.7c. So
you get one error line and then a perfectly usable-looking session that forwards
nothing. If you see that error scroll past and a bar with no `[ REMOTE ]`
marker, that is this, not a config problem.

The fix is to copy the file across:

```sh
scp ~/.config/tmux/remote-tmux.conf box:~/.config/tmux/remote-tmux.conf
```

If that path is awkward, put it wherever you like on the remote and edit step 2 of
`tssh` to match. Note that `bind r` in `remote-tmux.conf` re-sources
`~/.config/tmux/remote-tmux.conf` by a hardcoded path, so if you move the file you
must move that path too, or prefix-plus-`r` errors on the remote.

## Known limitations

### Scrolling does not cross the connection

The local config sets `mouse on`. In an SSH pane the local tmux captures the
wheel and will not forward it to the remote program, so the far-end scrollback is
unreachable by mouse.

The escape hatch is `set -g mouse off` in the local config. The trade-off is that
everything the mouse was doing has to be done from the keyboard instead:
click-to-select-pane, click-to-select-window, scrollbar dragging, and resizing by
dragging a pane edge. This is a local-only change. Do not put it in
`remote-tmux.conf`, where the mouse is not what is in the way, and re-run the
[drift check](#the-drift-check) afterwards, since it will show up as a fifth
difference.

### Key forwarding depends on `ps -t`, and that form is unverified on Linux

This is the most important limitation in the file, and the one most likely to be
misattributed when you are debugging it.

`is_forwardable` is the string that decides whether `C-h/j/k/l` forward or select
a pane. It reads the pane's foreground process with:

```sh
ps -o state= -o comm= -t '#{pane_tty}'
```

On macOS `pane_tty` is a device path like `/dev/ttys001`, and macOS `ps -t`
accepts it (verified against a live server on this box). On Linux the tty is
`/dev/pts/N` and GNU procps matches `-t` against the **short** tty name. That
combination was not verifiable during development, because no Linux box was
available. If the two do not agree, the whole feature is inert on the remote.

`check-ssh` is **not** part of this risk, which is the natural misdiagnosis. Its
`u` and `n` modes walk the process table with `ps -o comm= -p` and
`ps -o ppid= -p`, keyed on `#{client_pid}`, so they are PID-based and platform
independent. `check-ssh` never passes `-t` and never sees `pane_tty`. Its `p` and
`i` modes do not run `ps` at all; they are a `case` glob over
`#{pane_current_command}`. So if the red/green SSH indicator keeps working while
the arrow keys stop forwarding, that is expected and is not evidence that the
matcher is fine.

Check it on the remote, from inside a pane running something the matcher should
accept, such as `nvim` or an `ssh` session:

```sh
# On the remote. Exit status 0 means the arrow keys WILL forward in this pane.
ps -o state= -o comm= -t "$(tmux display-message -p '#{pane_tty}')" | \
    grep -iqE '^[^TXZ ]+( +|:).*?(n?vim|vim|view|ssh|mosh)(diff)?(-wrapped)?$'
echo "exit=$?"
```

If that prints `exit=1` in a pane where you can see `nvim` in the process list,
the `-t` form is the problem. Test the short name as the second guess:

```sh
tty="$(tmux display-message -p '#{pane_tty}')"
echo "full:  $tty"
ps -o state= -o comm= -t "$tty" | head -3
ps -o state= -o comm= -t "${tty#/dev/}" | head -3
```

If the short name works and the full path does not, the fix is to strip the
`/dev/` prefix in the `is_forwardable` string in **both** config files. It sits in
the byte-identical region, so change it in both or in neither, and re-run the
[drift check](#the-drift-check) to confirm the region is still identical.

The failure mode is silent and it is the pre-existing behaviour: keys fall back to
local pane selection, so nothing looks broken and nothing errors. That is a
degradation rather than an outage, but it means "the arrow keys select panes in
that ssh pane" is a bug report with a known suspect, not a configuration choice.

### `vim-tmux-navigator` is inert here

`christoomey/vim-tmux-navigator` is declared via TPM in `tmux.conf`, and it does
nothing. The tmux **root** bindings shadow it, because root bindings take
precedence, and this config binds the arrow keys at root on purpose.

It is left declared so that removing it is a one-line change, not because it does
anything. Do not assume arrow keys are working because it is in the plugin list.

### `mosh` is listed but may never match in practice

The matcher and the badge both match `mosh` exactly. The real mosh network process
is `mosh-client`, which ends in neither, so if a mosh session reports
`mosh-client` as its pane's foreground command then that pane gets no badge and
does not forward. `check-ssh` records this on purpose: both sides miss it
together, which is the safe direction, because a missing badge is a lost cue
whereas an over-broad one is a false promise.

This is an inference from the command names, not an observation, because mosh was
not available during development. If you use mosh, check it before trusting either
way. Do not widen the badge to cover `mosh-client` without widening the matcher to
match, or the badge starts advertising a passthrough that is not happening.

### Untested territory

Real nesting was not exercised end to end during development. Real mosh, and any
triple nesting, were not tested at all. The reasoning in the config comments is
sound but it is reasoning, not a transcript.

## Keeping `remote-tmux.conf` in sync

`remote-tmux.conf` is a near-complete mirror of `tmux.conf`, on purpose. A remote
has no TPM, no `check-ssh`, and the only safe way to configure a remote tmux is to
hand it a file that stands alone. A file that `source-file`s the local one, or that
expects a helper from this repo, breaks the moment the remote does not have this
repo. The cost of that choice is that the keymap is duplicated rather than shared,
and that duplication is the main maintenance cost of this design.

The thing that must not drift is the **49-line navigation region**: the arrow key
bindings, the `is_forwardable` matcher and its comment block, and the
`set-environment -gu is_vim` stale guard. Find it by its first line beginning
`# Navigation keys are forwarded`, not by line number. It is lines 112 to 160 in
`tmux.conf` and 128 to 176 in `remote-tmux.conf` right now, but those numbers move
whenever a comment is edited.

The `is_vim` guard belongs in the region because both files have to make the same
statement about it. It exists because sourcing a config does not unset variables
it stops setting, so a server started before this change keeps the stale regex in
its global environment and hands it to every new pane. Inert, but unreclaimable
without a server restart.

The hook unhooking that guards the same class of problem is deliberately *not* in
the region, and is local-only instead. Unhooking on a remote would clobber hooks
that the remote already has, which is a worse bug than the one it prevents.

### The drift check

Do not use a line-by-line `grep` comparison for this. It is blind to multi-line
values. A directive written as `set -g status-left \` on one line and its value on
the next is seen by `grep` as the identical string `set -g status-left \` in both
files, so the real difference in the value is invisible. Measured on this repo
just now: a naive grep comparison reports 14 differences (17 lines) and **misses
four real intentional differences**, all of them multi-line values:
`status-left`, `status-right`, and both `window-status` formats. The normalizer
below joins continuations first, so the values are compared whole, and those four
show up.

```bash
# Drift check: must print ONLY the intentional differences listed below.
# Run from ~/.config.
cat > /tmp/tmux-drift.py <<'PY'
import re, sys
def norm(p):
    out, buf = [], None
    for line in open(p):
        s = line.rstrip('\n')
        if buf is not None:
            buf = buf.rstrip() + s.strip()
        if s.rstrip().endswith('\\'):
            buf = (buf + s.rstrip()[:-1]) if buf else s.rstrip()[:-1]
        else:
            if buf is not None:
                out.append(buf.strip()); buf = None
            if s.strip():
                out.append(s.strip())
    if buf is not None:
        out.append(buf.strip())
    return sorted(x for x in out if re.match(
        r'^(bind|unbind|set|setw|set-hook|set-environment|run|if-shell)\b', x))
a, b = norm(sys.argv[1]), norm(sys.argv[2])
for l in [x for x in a if x not in b]:
    print("  L|", l)
for l in [x for x in b if x not in a]:
    print("  R|", l)
PY
python3 /tmp/tmux-drift.py ~/.config/tmux/tmux.conf ~/.config/tmux/remote-tmux.conf
```

`L|` marks a directive present only in the local file, `R|` one present only in the
remote. Nothing from the navigation region should ever print. The comparison is
membership-based rather than a count, so a directive that appears anywhere in both
files is silent, and only directives that exist on one side alone are reported.

### What it is expected to print

**18 intentional differences, on 25 printed lines.** The line count is higher than
the difference count because a directive that exists in both files with a different
value prints twice, once with each prefix. Anything the check prints that is not in
the four groups below is real drift.

**Self-reference (1 difference, 2 lines).** `bind r`. Each file re-sources itself,
so the path and the confirmation message differ:

```
  L| bind r source-file ~/.config/tmux/tmux.conf \;display-message "tmux config reloaded"
  R| bind r source-file ~/.config/tmux/remote-tmux.conf \;display-message "tmux remote config reloaded"
```

**Local-only plugin stack (9 differences, 9 lines).** All on the local side:

```
  L| if-shell '[ ! -d "$HOME/.tmux/plugins/tpm" ]''run-shell "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"'
  L| run '~/.tmux/plugins/tpm/tpm'
  L| set -g @continuum-restore 'on'
  L| set -g @plugin 'tmux-plugins/tpm'
  L| set -g @plugin 'tmux-plugins/tmux-sensible'
  L| set -g @plugin 'tmux-plugins/tmux-resurrect'
  L| set -g @plugin 'tmux-plugins/tmux-continuum'
  L| set -g @plugin 'tmux-plugins/tmux-yank'
  L| set -g @plugin 'christoomey/vim-tmux-navigator'
```

That is nine lines because there are **six** `@plugin` declarations, not five. A
remote must not clone or run TPM, so the whole block is local-only.

**Local-only hook hygiene (2 differences, 2 lines).** Also local-only:

```
  L| set-hook -gu client-attached
  L| set-hook -gu pane-focus-in
```

These unhang hooks before re-setting them, so that re-sourcing replaces rather than
appends. Sourcing a config does not clear hooks it no longer sets, so a server
started before this change keeps running the old status switcher. Both hooks are
pointless on a remote that has no such hooks, and unhooking them there could
clobber hooks the remote already has. Hence deliberately absent.

**Visual cues (6 differences, 12 lines).** The only group that is mirrored, so the
only one that prints both prefixes. Abridged and aligned here for reading; the real
output puts each `L|` and `R|` pair on its own line. Four of these six are the ones
a naive `grep` misses, because their values sit on a continuation line.

```
  L| set -g pane-active-border-style "fg=#8aadf4"      R| ... "fg=#94e2d5"
  L| set -g status-left "...peach pill..."             R| "... [ REMOTE ] ..."
  L| set -g status-right "...check-ssh segments..."    R| "... clock and date ..."
  L| set -g status-right-length 180                    R| set -g status-right-length 60
  L| setw -g window-status-format "...glyphs..."       R| ... no glyphs ...
  L| setw -g window-status-current-format "...glyphs"  R| ... no glyphs ...
```

* `pane-active-border-style`: local blue `#8aadf4`, remote teal `#94e2d5`. The
  layer tell. Do not harmonise.
* `status-left`: the remote's leads with the literal `[ REMOTE ]` badge; the local's
  is the peach session pill.
* `status-right`: the local carries the three `check-ssh` segments, the remote has
  no helper and carries only the clock and date.
* `status-right-length`: 180 locally, 60 on the remote, to fit.
* Both `window-status` formats: the local wraps each pill in the Nerd Font
  rounded-edge glyphs U+E0B6 and U+E0B4, the remote has none, because a remote is
  not guaranteed to have a patched font and they render as tofu. Note both files
  open with the same no-op `#[fg=#363a4f]` prefix segment, so that is not the
  difference. Do not "restore" the glyphs in the remote file.

### The rule

**Anything the check prints that is not in those four groups is real drift and
should not be there.** That is the whole reason for shipping the check rather than
a convention. If you edit one file, run it before you assume you are done.
