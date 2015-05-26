# daemovise 

Supervise from a daemon

# USAGE

    daemovise [--usage] [--help] [--man] [--version]

    daemovise [--append|--no-append]
              [--dir|-d directory]
              [--outputs|O filename]
              [--pidfile|-p filename]
              [--stderr|--err|-e filename]
              [--stdout|--out|-o filename]
              [--timeout|-t timeout]
              [--umask|-u umask]
              [--] command [arg [arg...]]

# EXAMPLES

    # write both stdout and stderr in sample.log
    # save PID in sample.pid for later reuse (sending commands)
    # set a timeout of 10 seconds for child to honor a TERM request
    shell$ daemovise -O sample.log -p sample.pid ./sample.sh -t 10
    
    # send HUP, this makes it possible to e.g. rotate logs.
    # HUP signal is propagated down to child, if it does not handle it
    # then it will exit and will be restarted by daemovise
    shell$ mv sample.log sample.log.1
    shell$ kill -HUP $(<sample.pid)

    # send TERM and then KILL after the timeout
    shell$ kill $(<sample.pid)

# DESCRIPTION

This program starts as a daemon and takes care to supervise the execution
of a child program.

When starting, daemovise will generate a daemon with the following
characteristics:

- change directory in what configured for `--dir` (if this is not set,
this step is skipped)
- reset the `umask` to whatever set via `--umask` (that is `077` by
default)
- `fork()` twice with `POSIX::setsid()` in between, so that the process
is properly detached from the TTY and will not be able to gain control
of a TTY again
- close all filehandles, then reopen stdin to read from `/dev/null` and
stdout/stderr to write to whatever configured (see options
`--stdout`, `--stderr` and `--outputs`)

After starting as a daemon as described above, daemovise repeatedly
runs the child program provided on the command line until an exit
condition is triggered.

It is possible to definitely terminate the process (both daemovise and
the child in current execution) by sending a TERM signal to daemovise. In
this case, daemovise will first send the TERM signal, then if a timeout is
set it will send a KILL signal if the child did not terminate after the
timeout itself.

It is also possible to send the HUP signal to daemovise. This signal will
be forwarded to the child too (this usually means that the child will
exit, unless the signal is properly trapped) and the output channels will
be reopened too. This makes it possible to use e.g. `logrotate` in order
to avoid log files filling up the whole filesystem.

# OPTIONS

- --append | --no-append

    by default, output files for stdout and stderr are opened in append
    mode. If you want to create a new file instead, pass `--no-append`.

- --dir | -d directory

    set the directory where to `chdir` before starting all operations. All
    relative paths are meant to be referred to this directory.

- --help

    print a somewhat more verbose help, showing usage, this description of
    the options and some examples from the synopsis.

- --man

    print out the full documentation for the script.

- --outputs | -O filename

    set an output filename for both stdout and stderr. This option overrides
    whatever is set for `--stdout` and `--stderr`.

- --pidfile | -p filename

    save the process identifier (PID) of the daemovise process in the
    specified filename. This will make it easier to interact with
    daemovise in a later stage.

- --stderr | --err | -e filename
- --stdout | --out | -o filename

    set the name for respectively the stderr and stdout channels. If set to
    the same value (e.g. via `--outputs`) only the new stdout will be opened,
    and stderr will be duplicated.

- --timeout | -t timeout

    set a timeout for the child to honor the `TERM` signal. If the child does
    not exit within the timeout, a `KILL` signal will be sent.

- --umask | -u umask

    set the new `umask` for file creation. By default it is `077`, i.e. files
    are created by default to be read/written/executed by the owner only.

- --usage

    print a concise usage line and exit.

- --version

    print the version of the script.

Considering that the executed child program might have its own options too,
it is suggested to always terminate the command line options for daemovise
with `--`, so that the options analyzer will stop interpreting further
in the command line.

# DIAGNOSTICS

Whatever operation that fails is usually fatal.

# CONFIGURATION AND ENVIRONMENT

daemovise requires no configuration files or environment variables.

# DEPENDENCIES

None.

# BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through http://rt.cpan.org/

# AUTHOR

Flavio Poletti `polettix@cpan.org`

# LICENSE AND COPYRIGHT

Copyright (c) 2015, Flavio Poletti `polettix@cpan.org`.

This module is free software.  You can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.
