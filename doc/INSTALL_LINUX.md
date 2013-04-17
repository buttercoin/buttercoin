Installing on Linux
===================

Install git, the node.js runtime and node package manager
-----------

#### On Debian-based systems:

    apt-get install git node npm

#### On Arch Linux:

    pacman -S git nodejs

Cloning the buttercoin repository to a local copy
-------------------------------------------------

    git clone https://github.com/buttercoin/buttercoin

Installing the remaining dependencies 
-------------------------------------

    cd buttercoin
    npm install

The `npm install` command will use the package.json file in buttercoin
to find all node dependencies, and install them locally to node_modules.

The command might fail if a `https_proxy` environment variable is set.
If this is the case, a workaround is to `unset` it.


Test and Run
------------

#### To test:

    npm test

If all goes well, it will end with a status report:

>  1 test complete (36 ms)

#### To start:

    npm start

If all goes well, you will see the address for the main user interface:

>info: Buttercoin front-end server started on http://localhost:3000

Point your browser at the URL reported and you will see the front-end.

Smooth as butter. 
