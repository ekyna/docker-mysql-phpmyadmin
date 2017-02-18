Docker MySql + PhpMyAdmin
=====

To get a local Mysql server with PhpMyAdmin using Docker Compose.

### Installation

1. Clone this repo.

2. Copy the "__.env.dist__" file, rename it to "__.env__" and configure your stack. 

    Refer to documentation pages for environment variable usage :
    - [Mysql](https://hub.docker.com/_/mysql/)
    - [PhpMyAdmin](https://hub.docker.com/r/phpmyadmin/phpmyadmin/)

3. Use the _manage.sh_ script to launch the stack.

    Windows users will need [gitbash](https://git-for-windows.github.io/) to use the _manage.sh_ script.
    
        ./manage.sh up

4. Once the stack is up and running, you can access PhpMyAdmin by visiting [http://127.0.0.1:8888](http://127.0.0.1:8888). 

    Fill the "_server_" field with "__mysql__".

### Usage

- Help:

        ./manage.sh

- Launch the stack:

        ./manage.sh up

- Stop the stack:

        ./manage.sh down

- Reset the stack:

        ./manage.sh reset

