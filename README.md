# secrets.sh

A simple secrets manager in bash using GPG.

This is mostly intended for use in your dotfiles, in order to load API keys and
such into your environment, without having to store them in plain text on disk
anywhere. It makes no effort to make its usage of GPG non-interactive; the idea
is that you'll have your GPG agent prompt for your key once the first time it
runs in a session and then cache it for a while so it doesn't bother you all the
time.

## Installation

It's just a shell script; just copy the script somewhere you can find it later.
If anyone else actually ends up liking this I may package it in the future.

## Usage

### Store a secret
```secrets.sh set my_secret_key my_secret```

### Retrieve a secret
```secrets.sh get my_secret_key```

### List all secrets
```secrets.sh list```

### Dump "database"
```secrets.sh dump```

This is mainly intended for debugging, or if you need to do something cool
enough that you need access to the raw data. The decrypted form of the database
is three shell-quoted strings (ala `printf "%q"`) separated by spaces and
followed by a newline. The first string is the key, the second string is
the time the key was set in seconds-since-the-epoch, and the third string is
the value.

## License

MIT License

Copyright (c) 2018 Jordan Webb

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
