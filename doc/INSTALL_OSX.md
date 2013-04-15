Installing on Mac OSX
=====================


Installing node.js and npm
---

### From Sources (recommended approach)



Get node source code (tar.gz archive, bottom of the list):
http://nodejs.org/download/

Download the Universal installer for Mac OS X
Note: buttercoin requires node >= 10.4

Run the installer and install node.

### Using Homebrew (not recommended, but sometimes works)

Homebrew (http://mxcl.github.io/homebrew/)

#### Install Homebrew

To install homebrew, if you have not already, try this command:

    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"

then, check that it is working and update it:

    brew update

#### Install the node.js runtime and node packaged modules

    brew install node npm


#### Installing git

    brew install git

Cloning the buttercoin repository to a local copy
-------------------------------------------------
Note: If you do not have git installed, use the process above with homebrew, skipping the node.js/npm part. 

    git clone https://github.com/buttercoin/buttercoin

Installing the remaining dependencies 
-------------------------------------

    cd buttercoin
    npm install 

The `npm install` command will use the package.json file in buttercoin to find all node dependencies

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

Smooth as butter. 