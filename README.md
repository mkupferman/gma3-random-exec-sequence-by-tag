# gma3-random-exec-sequence-by-tag

GrandMA3 Random Executor Sequence by Tag

## What is this?

Given a [Tag](https://help.malighting.com/grandMA3/2.2/HTML/tags.html) name,
this Lua plugin for GrandMA3 randomly selects a tagged sequence, assigns
it to a specified executor handle, and Temp-Ons that executor if the
caller is still held.

## Why?

This could be useful if you want to, for example, create a "random effect"
temp key, that uses a random effect from a pool of temp sequences.

## Requirements

- GrandMA3 >= 2.2.1.1 (2.5.0.3+ recommended for Temp bump use)

## Usage

The plugin accepts a JSON string containing the arguments passed to it.

        call plugin <number|'name'> '{<json args>}'

Required JSON arguments:

1. `exec` - _integer_: Playback executor number
2. `tag`  - _string_: Label of the tag with the sequences of interest assigned to it

Optional JSON arguments:

1. `page` - _integer_: Executor playback page (defaults to _1_)

## Example usage

1. Create a tag, in this case named `Bumps`, and assign a few sequences to it.
2. Choose a free playback executor button (this plugin wasn't built to handle
   fader positions elegantly), in this case Executor 115 on Page 1, and make it
   a "Temp" button. Assign any sequence to it; it will be overwritten.

   Note: You will not trigger the random sequence by pressing this button, so you
   may want to place it somewhere on an out-of-the-way page.
3. Create a sequence with a single blank cue (plus CueZero / OffCue).

   In Cue 1, add a command like:

        Call Plugin "randexecseqtag" '{"exec": 115, "tag": "Bumps"}'

   Do **not** add a second cue that `Temp On`s the executor, and do **not** delay
   Cue 2 with Follow time. The plugin assigns on the Main task, then Temp-Ons
   itself. A delayed Follow cue can fire after you have already released and
   leave the look stuck on.

   In the OffCue, clear the hold flag and Off the executor (not `Temp Off`).
   The variable name must match page and executor (`randexecseqtag_held_<page>_<exec>`):

        Lua "SetVar(UserVars(), 'randexecseqtag_held_1_115', '0')"; Off Page 1.115

   `Off` the executor rather than `Temp Off`, so AutoStop / Temp-fader state cannot
   leave playback running. `Off Page 1.115` cannot kill a sequence that is no longer
   assigned to that executor; the plugin turns off the previous sequence object
   before it assigns a new one for that reason.

4. Make the sequence a "Temp" action and fire it repeatedly. Each press picks a
   tagged sequence, assigns it, and Temps it on for as long as you hold. Release
   runs OffCue, which cancels an in-flight plugin Temp On and Offs the executor.

## Migration from 0.0.0.1 to 0.0.1.0

For shows that already followed the 0.0.0.1 instructions (Cue 1 calls the
plugin, Cue 2 `Temp On`s the target executor, OffCue `Temp Off`s it). Needed
for grandMA3 2.5 so a previous bump sequence is not left running after release.

1. Import plugin 0.0.1.0 over the existing `randexecseqtag` plugin (or replace
   the Lua component). The JSON `Call Plugin` arguments do not change.
2. On the dummy Temp sequence, **delete Cue 2** (`Temp On Executor 115`). The
   plugin now Temp-Ons the executor itself after Assign.
3. Change the OffCue from `Temp Off Executor 115` to (page and executor must
   match your JSON `page` / `exec`):

        Lua "SetVar(UserVars(), 'randexecseqtag_held_1_115', '0')"; Off Page 1.115

Leave the tag, the hidden target executor, Cue 1, and the dummy sequence's
Temp key action as they were.

## To Do

- Implement caching of tagged sequences. In GMA 2.2.1.1, there does not appear to be
  an efficient way to query for all tagged sequences. Holding out hope that a future
  release will allow use of `ShowData().Tags` or a filter to use
  with `ObjectList("sequence")`. In the mean time, it's still pretty performant with
  reasonable numbers of sequences in a show file.
