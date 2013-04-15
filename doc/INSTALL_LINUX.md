Installing on Linux
===================

Install git, the node.js runtime and node package manager
-----------

    apt-get install git node npm

Cloning the buttercoin repository to a local copy
-------------------------------------------------

    git clone https://github.com/buttercoin/buttercoin

Installing the remaining dependencies 
-------------------------------------

    cd buttercoin
    npm install
    sudo npm install -g coffee-script

The `npm install` command will use the package.json file in buttercoin to find all node dependencies

Test and Run
------------

#### To test:

    npm test

If all goes well, it will end with a status report:

>  1 test complete (36 ms)

#### To start:

    npm start

If all goes well, you will see the address for the main user interface:

>info: Buttercoin front-end server started on http://0.0.0.0:3000

Point your browser at the URL reported and you will see the front-end

Smooth as butter. 
