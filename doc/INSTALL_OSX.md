Installing on Mac OSX
=====================


Installing node.js and npm
---

Download the Universal installer for Mac OS X, for the latest version of node:

_Note: node >= 0.10.4_

http://nodejs.org/download/


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
    sudo npm install -g coffee-script

_Note: The `npm install` command will use the package.json file in buttercoin to find all node dependencies_

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

Point your browser at the URL reported and you will see the front-end

Smooth as butter
