#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ ! -f "$DIR/.env" ]]
then
    printf "\e[31mUnable to find '.env' file.\e[0m\n"
    exit 1
fi

source "$DIR/.env"

SERVICE_REGEX="^mysql|phpmyadmin$"
LOG_PATH="$DIR/logs.txt"


# Clear logs
echo "" > ${LOG_PATH}

# ----------------------------- HEADER -----------------------------

Title() {
    printf "\n\e[1;104m ----- $1 ----- \e[0m\n"
}

Warning() {
    printf "\n\e[31;43m$1\e[0m\n"
}

Help() {
    printf "\n\e[2m$1\e[0m\n";
}

Confirm () {
    printf "\n"
    choice=""
    while [ "$choice" != "n" ] && [ "$choice" != "y" ]
    do
        printf "Do you want to continue ? (N/Y)"
        read choice
        choice=$(echo ${choice} | tr '[:upper:]' '[:lower:]')
    done
    if [ "$choice" = "n" ]; then
        printf "\nAbort by user.\n"
        exit 0
    fi
    printf "\n"
}

# ----------------------------- NETWORK -----------------------------

NetworkCreate() {
    printf "Creating network \e[1;33m$1\e[0m ... "
    if [[ "$(docker network ls | grep $1)" ]]
    then
        printf "\e[36mexists\e[0m\n"
    else
        docker network create $1 >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mcreated\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
    fi
}

NetworkRemove() {
    printf "Removing network \e[1;33m$1\e[0m ... "
    if [[ "$(docker network ls | grep $1)" ]]
    then
        docker network rm $1 >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mremoved\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
    else
        printf "\e[35munknown\e[0m\n"
    fi
}

# ----------------------------- VOLUME -----------------------------

VolumeCreate() {
    printf "Creating volume \e[1;33m$1\e[0m ... "
    if [[ "$(docker volume ls | grep $1)" ]]
    then
        printf "\e[36mexists\e[0m\n"
    else
        docker volume create --name $1 >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mcreated\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
    fi
}

VolumeRemove() {
    printf "Removing volume \e[1;33m$1\e[0m ... "
    if [[ "$(docker volume ls | grep $1)" ]]
    then
        docker volume rm $1 >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mremoved\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
    else
        printf "\e[35munknown\e[0m\n"
    fi
}

# ----------------------------- COMPOSE -----------------------------

IsUpAndRunning() {
    if [[ "$(docker ps | grep $1)" ]]
    then
        return 1
    fi
    return 0
}

# ComposeUp [env]
ComposeUp() {
    IsUpAndRunning "${COMPOSE_PROJECT_NAME}_mysql"
    if [[ $? -eq 1 ]]
    then
        printf "\e[31mAlready up and running.\e[0m\n"
        exit 1
    fi

    printf "Composing up ... "
    cd ${DIR} && \
        docker-compose -f compose.yml up -d >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ComposeDown [env]
ComposeDown() {
    printf "Composing down ... "
    cd ${DIR} && \
        docker-compose -f compose.yml down -v --remove-orphans >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ComposeBuild [env]
ComposeBuild() {
    printf "Building ... "

    cd ${DIR} && \
        docker-compose -f compose.yml build >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ComposeStart [env]
ComposeStart() {
    printf "Starting ... "

    cd ${DIR} && \
        docker-compose -f compose.yml start >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ComposeRestart [env]
ComposeRestart() {
    printf "Restarting ... "

    cd ${DIR} && \
        docker-compose -f compose.yml restart >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ComposeCreate [env]
ComposeCreate() {
    printf "Creating  ... "

    cd ${DIR} && \
        docker-compose -f compose.yml create --force-recreate >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ----------------------------- SERVICE -----------------------------


# ValidateServiceName [service]
ValidateServiceName() {
    if [[ ! $1 =~ $SERVICE_REGEX ]]
    then
        printf "\e[31mInvalid service name\e[0m\n"
        exit 1
    fi
}

# ServiceBuild [service]
ServiceBuild() {
    ValidateServiceName $1

    printf "Building service \e[1;33m$1\e[0m ... "

    cd ${DIR} && \
        docker-compose -f compose.yml build $1 >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ServiceStart [service]
ServiceStart() {
    ValidateServiceName $1

    printf "Starting service \e[1;33m$1\e[0m ... "

    cd ${DIR} && \
        docker-compose -f compose.yml start $1 >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ServiceStop [service]
ServiceStop() {
    ValidateServiceName $1

    printf "Stopping service \e[1;33m$1\e[0m ... "

    cd ${DIR} && \
        docker-compose -f compose.yml stop $1 >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ServiceRestart [service]
ServiceRestart() {
    ValidateServiceName $1

    printf "Restarting service \e[1;33m$1\e[0m ... "

    cd ${DIR} && \
        docker-compose -f compose.yml restart $1 >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ServiceCreate [service]
ServiceCreate() {
    ValidateServiceName $1

    printf "Creating service \e[1;33m$1\e[0m ... "

    cd ${DIR} && \
        docker-compose -f compose.yml create --force-recreate $1 >> ${LOG_PATH} 2>&1 \
            && printf "\e[32mdone\e[0m\n" \
            || (printf "\e[31merror\e[0m\n" && exit 1)
}

# ----------------------------- EXEC -----------------------------


# Execute [service] [command]
Execute() {
    ValidateServiceName $1

    IsUpAndRunning "${COMPOSE_PROJECT_NAME}_$1"
    if [[ $? -eq 0 ]]
    then
        printf "\e[31mService \e[1;33m$1\e[0m is not up and running.\e[0m\n"
        exit 1
    fi

    printf "Executing [$1] $2\n"

    printf "\n"
    if [[ "$(uname -s)" = \MINGW* ]]
    then
        winpty docker exec -it ${COMPOSE_PROJECT_NAME}_$1 $2
    else
        docker exec -it ${COMPOSE_PROJECT_NAME}_$1 $2
    fi
    printf "\n"
}

# Run [service] [command]
Run() {
    ValidateServiceName $1

    printf "\n"
    printf "Running \e[1;33m$2\e[0m on \e[1;33m$1\e[0m service:\n"

    cd ${DIR} && \
        docker-compose -f compose.yml \
        run --rm $1 $2
}

# ----------------------------- INTERNAL -----------------------------

CreateNetworkAndVolumes() {
    NetworkCreate "${COMPOSE_PROJECT_NAME}-network"
    VolumeCreate "${COMPOSE_PROJECT_NAME}-database"
    VolumeCreate "${COMPOSE_PROJECT_NAME}-sessions"
}

RemoveNetworkAndVolumes() {
    NetworkRemove "${COMPOSE_PROJECT_NAME}-network"
    VolumeRemove "${COMPOSE_PROJECT_NAME}-database"
    VolumeRemove "${COMPOSE_PROJECT_NAME}-sessions"
}

Reset() {
    ComposeDown
    RemoveNetworkAndVolumes

    sleep 3

    CreateNetworkAndVolumes
    ComposeUp
}

# ----------------------------- EXEC -----------------------------

case $1 in
    # -------------- UP --------------
    up)
        CreateNetworkAndVolumes

        ComposeUp
    ;;
    # ------------- DOWN -------------
    down)
        ComposeDown
    ;;
    # ------------- BUILD -------------
    build)
        if [[ "" != "$2" ]]
        then
            ServiceBuild $2
        else
            ComposeBuild
        fi
    ;;
    # ------------- CREATE -------------
    create)
        if [[ "" != "$2" ]]
        then
            ServiceCreate $2
        else
            ComposeCreate
        fi
    ;;
    # ------------- START -------------
    start)
        if [[ "" != "$2" ]]
        then
            ServiceStart $2
        else
            ComposeStart
        fi
    ;;
    # ------------- RESTART -------------
    restart)
        if [[ "" != "$2" ]]
        then
            ServiceRestart $2
        else
            ComposeRestart
        fi
    ;;
    # ------------- EXEC -------------
    exec)
        ValidateServiceName $2

        Execute $2 "${*:3}"
    ;;
    # ------------- RUN -------------
    run)
        ValidateServiceName $2

        Run $2 "${*:3}"
    ;;
    # ------------- RESET ------------
    reset)
        Title "Resetting stack"
        Warning "All data will be lost !"
        Confirm

        Reset
    ;;
    # ------------- HELP --------------
    *)
        Help "Usage:  ./manage.sh [action] [options]

\t\e[0mup\e[2m\t\t\t Create and start containers.
\t\e[0mdown\e[2m\t\t Stop and remove containers.
\t\e[0mbuild\e[2m [service]\t Build the service(s) images.
\t\e[0mcreate\e[2m [service]\t Create the service(s).
\t\e[0mrestart\e[2m [service]\t Restart the service(s).
\t\e[0mexec\e[2m service cmd\t Run the [command] in the running [service] container.
\t\e[0mrun\e[2m service cmd\t Run the [command] in a new detached [service] container.
\t\e[0mreset\e[2m env\t\t Reset the [env] environment's php container."
    ;;
esac

printf "\n"
