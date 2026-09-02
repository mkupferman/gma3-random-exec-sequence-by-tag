# Random bump by tag (grandMA3)

Hold a button, get a **random** look from a pool of sequences, release and it
goes off. You choose the pool with a [tag](https://help.malighting.com/grandMA3/2.2/HTML/tags.html)
(for example `Bumps`). Add or remove sequences from the tag whenever you like;
you do not have to edit the button.

Plugin name: `randexecseqtag`. Requires grandMA3 2.2.1.1 or later. Use plugin
**0.0.1.0** on grandMA3 2.5 so the look does not stay on after you release.

## How it is wired

You use **two** executors:

| Role | What it is | What you do with it |
| --- | --- | --- |
| The button you press | A small dummy sequence set to **Temp** | Hold to bump, release to off |
| Hidden playback | A free executor, also **Temp** | Stays out of the way; the plugin parks the random sequence here and plays it |

You never need to press the hidden executor. Each press of the dummy button
picks a tagged sequence, assigns it to the hidden executor, and temps it on
until you let go.

The rest of this guide uses **tag `Bumps`**, **Page 1**, **Executor 115** as
the hidden playback. Use your own numbers; they must match in every command
below.

## Setup

### 1. Import the plugin

Import `randexecseqtag` into the Plugins pool (the `.xml` file in this repo,
with the matching `.lua` file).

### 2. Tag the sequences that should be in the random pool

Create a tag named `Bumps` (or any name you prefer). Assign every sequence
that should be eligible for the random bump to that tag.

### 3. Prepare the hidden playback executor

Pick a free executor, for example **Executor 115 on Page 1**. Set its key
to **Temp**. Assign any sequence to it for now; the plugin will overwrite
that assignment.

Put this executor on a page you will not grab during a show.

### 4. Build the dummy sequence you will actually press

Store a new sequence with **one empty cue** (Cue 1 only). Do not add a
second cue.

**Cue 1 command** — call the plugin, pointing at the hidden executor and
the tag:

```text
Call Plugin "randexecseqtag" '{"exec": 115, "tag": "Bumps"}'
```

**OffCue command** — tell the plugin you released the button, then Off the
hidden executor. Use `Off`, not `Temp Off`. The variable name must use the
same page and executor as above (`randexecseqtag_held_PAGE_EXEC`):

```text
Lua "SetVar(UserVars(), 'randexecseqtag_held_1_115', '0')"; Off Page 1.115
```

Assign this dummy sequence to the executor you will bump, and set that key
to **Temp**.

Do not add a cue that says `Temp On Executor 115`. The plugin does that
after it has assigned the random sequence. A second cue (especially with a
Follow delay) can fire after you have already released and leave a look
stuck on.

### 5. Use it

Hold the dummy Temp button: a random `Bumps` sequence plays. Release: it
should go off, with nothing left running.

If you use a different page or executor, change the number in **three**
places: the `exec` (and optional `page`) in Cue 1, the
`randexecseqtag_held_…` name in OffCue, and `Off Page …` in OffCue.

## Plugin command

Cue 1 is a `Call Plugin` with a short settings string:

```text
Call Plugin "randexecseqtag" '{"exec": 115, "tag": "Bumps"}'
```

| Setting | Required | Meaning |
| --- | --- | --- |
| `exec` | Yes | Hidden playback executor number (for example `115`) |
| `tag` | Yes | Tag name of the sequences to pick from (for example `Bumps`) |
| `page` | No | Executor page of the hidden playback. Defaults to `1` |

Example on page 2:

```text
Call Plugin "randexecseqtag" '{"exec": 115, "tag": "Bumps", "page": 2}'
```

That would need OffCue:

```text
Lua "SetVar(UserVars(), 'randexecseqtag_held_2_115', '0')"; Off Page 2.115
```

If no sequences have the tag, the plugin does nothing and prints a message
in the command line history.

This plugin is meant for **buttons**, not faders.

## Updating from plugin 0.0.0.1 to 0.0.1.0

If the dummy sequence already worked on older grandMA3 (Cue 1 calls the
plugin, Cue 2 temps the hidden executor on, OffCue temps it off), change
three things for 2.5:

1. Import plugin **0.0.1.0** over the existing `randexecseqtag` plugin. You
   can leave the Cue 1 `Call Plugin` line as it is.
2. **Delete Cue 2** (`Temp On Executor 115`). The plugin now temps the
   hidden executor on by itself.
3. Change OffCue from `Temp Off Executor 115` to:

   ```text
   Lua "SetVar(UserVars(), 'randexecseqtag_held_1_115', '0')"; Off Page 1.115
   ```

   Match page and executor to your setup, as in the setup steps above.

Keep the tag, the hidden executor, Cue 1, and the dummy sequence’s Temp
key as they were.
