# gma3-random-exec-sequence-by-tag

GrandMA3 Random Executor Sequence by Tag

## What is this?

Given a [Tag](https://help.malighting.com/grandMA3/2.2/HTML/tags.html) name,
this Lua plugin for GrandMA3 randomly selects a tagged sequence and assigns
it to a specified executor handle.

## Why?

This could be useful if you want to, for example, create a "random effect"
temp key, that uses a random effect from a pool of temp sequences.

## Requirements

- GrandMA3 >= 2.2.1.1

## Usage

The plugin accepts a JSON string containing the arguments passed to it.

        call plugin <number|'name'> '{<json args}>}'

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
3. Create a sequence with at least two blank cues.
   In the first cue, add a command like:

        call plugin "randexecseqtag" '{"exec": 115, "tag": "Bumps"}'
    In the second cue, add a command like:

        Temp On Executor 115

    _Note: Don't try to put both commands in the same cue with a `;`. It causes a race condition.._

    In the OffCue, add a command like:

        Temp Off Executor 115

4. Make the sequence a "Temp" action and fire it repeatedly. It will swap out the sequence
   assigned to the executor button each time the command sequence is triggered, and then
   fire the chosen sequence, honoring the _Temp_ timings.

## To Do

- Implement caching of tagged sequences. In GMA 2.2.1.1, there does not appear to be
  an efficient way to query for all tagged sequences. Holding out hope that a future
  release will allow use of `ShowData().Tags` or a filter to use
  with `ObjectList("sequence")`. In the mean time, it's still pretty performant with
  reasonable numbers of sequences in a show file.
