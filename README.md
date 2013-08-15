App/Sqitch/GUI version 0.002
============================
Ștefan Suciu <stefan@s2i2.ro>
2013-08-15

GUI for Sqitch - Simple SQL change management.

Please see [Sqitch](sqitch.org) for a detailed description of the
command line application.

Requirements
------------

- Perl v5.10.01 or newer;
- Sqitch v0.973 or newer;
- wxPerl, Moose and other modules;

Status
------

Draft - Limited functionality:

- Add repository and set a default one;
- Load project and change details;

Installation
------------

This is a Perl application:

    % cd sqitch-gui

    # Install prereqs
    % cpanm --installdeps .

    % perl Makefile.PL
    % make
    % make test
    % make install

Implementation notes
--------------------

Sqitch is a command line program.  The user runs `sqitch`, with the
appropriate parameters each time he wants to execute a command.  This
is very different from a graphical user interface.  A program with a
GUI once started expects and executes the commands from the user until
it is closed.

To integrate Sqitch into Sqitch::GUI there are a few problems that
have to be solved:

The `sqitch` command is executed from a repository directory from
where it reads some configurations and the plan file.  To be useful
Sqitch::GUI needs to keep the list of repositories in a configuration
file located in standard places in order to be able to find, read and
update it.

Command line parameter options, technically, can be used for GUI
executable but is better to use only configurations instead.

Each command from the Sqitch interface should have a dedicated button
in the GUI, but some of the commands take options (sometimes required
ones, like `sqitch show`).

User Interaction - some commands require confirmation from the user.
This can be implemented by using custom dialogs for each command.

License And Copyright
---------------------

Copyright (C) 2012-2013 iovation Inc.

Copyright (C) 2013 Ștefan Suciu.

The license is the same as for Sqitch:

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
