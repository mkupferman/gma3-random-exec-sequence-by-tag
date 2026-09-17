# Random bump by tag (grandMA3)

Hold a button, get a **random** look from a pool of sequences, release and it
goes off. You choose the pool with a [tag](https://help.malighting.com/grandMA3/2.2/HTML/tags.html)
(for example `Bumps`). Add or remove sequences from the tag whenever you like;
you do not have to edit the button.

Plugin name: `randexecseqtag`. Requires grandMA3 2.2.1.1 or later. Use plugin
**0.0.3.0** (or later) on grandMA3 2.5, including when you Temp the dummy
sequence over OSC.

## How it works

You use **one** dummy sequence set to **Temp**. Cue 1 tells the plugin to
start (`op` on): it picks a tagged sequence and temps that sequence on.
OffCue tells the plugin to stop (`op` off): it offs the sequence it last
started.

The rest of this guide uses the tag name `Bumps`.

One dummy sequence per tag. Two buttons that use the same tag share the
same last-started sequence.

## Setup

### 1. Import the plugin

Download **randexecseqtag-vX.Y.Z.W.zip** from the
[latest release](https://github.com/mkupferman/gma3-random-exec-sequence-by-tag/releases/latest),
unzip it, and import the `.xml` into the Plugins pool (keep the matching `.lua`
file next to it). You can also use the `.xml` and `.lua` files in this repo.

### 2. Tag the sequences that should be in the random pool

Create a tag named `Bumps` (or any name you prefer). Assign every sequence
that should be eligible for the random bump to that tag.

### 3. Build the dummy sequence you will actually press

Store a new sequence with **one empty cue** (Cue 1 only). Do not add a
second cue.

**Cue 1 command:**

```text
Call Plugin "randexecseqtag" '{"op": "on", "tag": "Bumps"}'
```

**OffCue command:**

```text
Call Plugin "randexecseqtag" '{"op": "off", "tag": "Bumps"}'
```

Use the same tag in both lines. Assign this dummy sequence to the executor  
you will bump, and set that key to **Temp**. You can also Temp the dummy  
sequence from OSC (press and release), the same as a handle.

### 4. Use it

Hold the dummy Temp button: a random `Bumps` sequence plays. Release: it
should go off, with nothing left running.

If you use a different tag, change it in both Cue 1 and OffCue.

## Plugin command

```text
Call Plugin "randexecseqtag" '{"op": "on", "tag": "Bumps"}'
```

| Setting | Required | Meaning                                                                                    |
| ------- | -------- | ------------------------------------------------------------------------------------------ |
| `tag`   | Yes      | Tag name of the sequences to pick from (for example `Bumps`)                               |
| `op`    | No       | `on` starts a random bump (default if omitted). `off` stops the last one this tag started. |

`'{"tag": "Bumps"}'` is the same as `op` on. Older Cue 1 lines that still
include `"exec"` or `"page"` still run; those keys are ignored.

If no sequences have the tag, `on` does nothing and prints a message in  
the command line history. `off` with nothing stored yet also does nothing.

## Updating to 0.0.3.0

1. Import plugin **0.0.3.0** over the existing `randexecseqtag` plugin.
2. Set Cue 1 to:

  ```text
   Call Plugin "randexecseqtag" '{"op": "on", "tag": "Bumps"}'
  ```

3. **Delete Cue 2** if it still `Temp On`s an executor.
2. Set OffCue to:

  ```text
   Call Plugin "randexecseqtag" '{"op": "off", "tag": "Bumps"}'
  ```

   Replace a 0.0.2.0 OffCue that used `SetUserVariable` and
   `Off Sequence $randexecseqtag_last_…`. You can drop `Off Page 1.115`.
5. Delete or ignore the old hidden playback executor (for example 115).
  The dummy Temp sequence is the only handle you need.
