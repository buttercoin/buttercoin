Installing on Mac OSX
=====================


Installing node.js and npm
---

Download the Universal installer for Mac OS X:

http://nodejs.org/download/

_Note: buttercoin requires node version 0.8 or newer_

Run the installer and install node.

Install git
---

Download the installer (DMG) and run it to install git:

http://git-scm.com/download/mac

Cloning the buttercoin repository to a local copy
-------------------------------------------------

    git clone https://github.com/buttercoin/buttercoin

Installing the remaining dependencies 
-------------------------------------

    cd buttercoin
    npm install 

_Note: The `npm install` command will use the package.json file in buttercoin to find all node dependencies_

Test and Run
------------

#### To test:

    ./test.sh

If all goes well, it will end with a status report:

>  1 test complete (36 ms)

#### To run:

    ./start.sh

If all goes well, you will see the address for the main user interface:

>info: Buttercoin front-end server started on http://0.0.0.0:3000

Point your browser at the URL reported and you will see the front-end

Smooth as butter
