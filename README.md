# chicon

**chicon** is a simple command-line utility for modifying Finder (macOS)
thumb-nail icons.

## Usage

```
Usage:
  chicon [-h|-V] [-q|-v] [-c|-r|-t] [--] <iconfile> [<destfile> ...]
Operands:
  iconfile       Path to icon file, or file type
  destfile       Path to destination file(s)
Options:
  -h, --help     Display this usage help
  -V, --version  Display version information
  -q, --quiet    Reduce output verbosity
  -v, --verbose  Increase output verbosity
  -c, --copy     Copy icon set on iconfile instead of using its contents
  -r, --remove   Remove icons from specified files
  -t, --type     Treat iconfile as a file type whose icon should be used
```

### Examples

```
# Use contents of `foo.icns` to set icon on `bar` and `baz`
chicon foo.icns bar baz

# Use contents of `foo.icns` to set icon on itself
chicon foo.icns

# Copy icon already set on `foo` to `bar` and `baz`
chicon -c foo bar baz

# Set icon on `foo` and `bar` to icon associated with file extension `mp3`
chicon -t mp3 foo bar

# Set icon on `foo` and `bar` to icon associated with UTI `public.mp3`
chicon -t public.mp3 foo bar

# Remove icons from `foo`, `bar`, and `baz`
chicon -r foo bar baz
```

## Installation

* Download a pre-compiled binary from the
[Releases](https://github.com/okdana/chicon/releases) page, or
* clone the repo and run `make` (or `sudo make install`)

## Rationale

Why use **chicon** when all Macs ship with `sips` and Automator? Because `sips`
and Automator don't apply icons correctly. Specifically, they subtly break
colours and shadows, which might be fine for random little one-off icons, but
it's very noticeable if you're applying a custom folder icon for example.

**chicon** uses `NSWorkspace`'s `setIcon()` method, which doesn't seem to have
this problem.

## Licence

MIT.

## See also

* [vasi/osxutils](https://github.com/vasi/osxutils) —
  Contains a very similar utility (written in ObjC) called `seticon`.
* [NSWorkspace class reference](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSWorkspace_Class/) —
  Apple's `NSWorkspace` reference.

