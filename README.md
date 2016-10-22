% Converts various HTML5 slide decks to PDF
% Didier Richard
% rév. 0.0.1 du 10/09/2016
% rév. 0.0.2 du 20/10/2016

---

# Building #

```bash
$ docker build -t dgricci/deck2pdf:0.0.2 -t dgricci/deck2pdf:latest .
```

## Behind a proxy (e.g. 10.0.4.2:3128) ##

```bash
$ docker build \
    --build-arg http_proxy=http://10.0.4.2:3128/ \
    --build-arg https_proxy=http://10.0.4.2:3128/ \
    -t dgricci/deck2pdf:0.0.2 -t dgricci/deck2pdf:latest .
```

## Build command with arguments default values ##

```bash
$ docker build \
    --build-arg DECK2PDF_VERSION=RELEASE_0_3_0 \
    --build-arg DECK2PDF_URL=https://github.com/melix/deck2pdf/archive/RELEASE_0_3_0.zip \
    -t dgricci/deck2pdf:0.0.2 -t dgricci/pandoc:latest .
```

# Use #

See `dgricci/jessie` README for handling permissions with dockers volumes.


```bash
$ docker run --rm -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY -e USER_ID=$UID -e USER_GP=`id -g` -e USER_NAME=$USER -v`pwd`:/tmp -w/tmp dgricci/deck2pdf deck2pdf --profile=revealjs XML1-A-slides.html XML1-A-slides.pdf
libGL error: failed to open drm device: No such file or directory
libGL error: failed to load driver: i965
libGL error: No matching fbConfigs or visuals found
libGL error: failed to load driver: swrast
Prism-ES2 Error : GL_VERSION (major.minor) = 1.4
Exported slide 1
...
Exported slide 46
Export complete!
$ rmdir hsperfdata_ricci
```

# A shell to hide the container's usage #

```bash
#!/bin/bash
#
# Exécute le container docker dgricci/deck2pdf
#
# Constantes :
VERSION="1.0.0"
# Variables globales :
unset show
unset noMoreOptions
#
# Exécute ou affiche une commande
# $1 : code de sortie en erreur
# $2 : commande à exécuter
run () {
    local code=$1
    local cmd=$2
    if [ -n "${show}" ] ; then
        echo "cmd: ${cmd}"
    else
        eval ${cmd}
    fi
    [ ${code} -ge 0 -a $? -ne 0 ] && {
        echo "Oops #################"
        exit ${code#-} #absolute value of code
    }
    [ ${code} -ge 0 ] && {
        return 0
    }
}
#
# Affichage d'erreur
# $1 : code de sortie
# $@ : message
echoerr () {
    local code=$1
    shift
    echo "$@" 1>&2
    usage ${code}
}
#
# Usage du shell :
# $1 : code de sortie
usage () {
    cat >&2 <<EOF
usage: `basename $0` [--help -h] | [--show|-s] argumentsAndOptions

    --help, -h          : prints this help and exits
    --show, -s          : do not execute deck2pdf, just show the command to be executed

    argumentsAndOptions : arguments and/or options to be handed over to deck2pdf
EOF
    exit $1
}
#
# main
#
cmdToExec="docker run -v /tmp/.X11-unix:/tmp/.X11-unix:ro -e DISPLAY"
cmdToExec="${cmdToExec} -e USER_ID=${UID} -e USER_GP=`id -g` -e USER_NAME=${USER}"
cmdToExec="${cmdToExec} --name=\"deck2pdf$$\" --rm"
cmdToExec="${cmdToExec} -v `pwd`:/tmp -w/tmp dgricci/deck2pdf deck2pdf"
while [ $# -gt 0 ]; do
    # protect back argument containing IFS characters ...
    arg="$1"
    [ $(echo -n ";$arg;" | tr "$IFS" "_") != ";$arg;" ] && {
        arg="\"$arg\""
    }
    if [ -n "${noMoreOptions}" ] ; then
        cmdToExec="${cmdToExec} $arg"
    else
        case $arg in
        --help|-h)
            run -1 "${cmdToExec} --help"
            usage 0
            ;;
        --show|-s)
            show=true
            noMoreOptions=true
            ;;
        --)
            noMoreOptions=true
            ;;
        *)
            [ -z "${noMoreOptions}" ] && {
                noMoreOptions=true
            }
            cmdToExec="${cmdToExec} $arg"
            ;;
        esac
    fi
    shift
done

run 100 "${cmdToExec}"
cmdToExec="rmdir hsperfdata_${USER}"
run 200 "${cmdToExec}"

exit 0
```

__Et voilà !__


_fin du document[^pandoc_gen]_

[^pandoc_gen]: document généré via $ `pandoc -V fontsize=10pt -V geometry:"top=2cm, bottom=2cm, left=1cm, right=1cm" -s -N --toc -o deck2pdf.pdf README.md`{.bash}

