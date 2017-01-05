#!/bin/bash
set -x

LOG="../openmaize_phoenixauth_test.log"

function new_project {
    cd alibaba || exit $?
    sed -i 's/username: "postgres"/username: "dev"/g' config/dev.exs config/test.exs
    sed -i 's/password: "postgres"/password: System.get_env("POSTGRES_PASS")/g' config/dev.exs config/test.exs
    sed -i 's/:postgrex]/:postgrex, :openmaize]/g' mix.exs
    #sed -i 's/{:postgrex, ">= 0.0.0"},/{:postgrex, ">= 0.0.0"},\n     {:openmaize, "~> 2.5"},/g' mix.exs
    sed -i 's/{:postgrex, ">= 0.0.0"},/{:postgrex, ">= 0.0.0"},\n     {:openmaize, git: "https:\/\/github.com\/riverrun\/openmaize.git"},/g' mix.exs
}

function enter_cave {
    mix deps.get
    echo -e "\nDATE: $(date) OPTIONS: $1\n" >> $LOG
    echo y | mix openmaize.gen.phoenixauth $@
}

function run_tests {
    mix test >> $LOG
    MIX_ENV=test mix ecto.drop
}

function clean {
    cd ..
    rm -rf alibaba
}

function openmaize_project {
    new_project
    enter_cave $@
    run_tests
    clean
}

cd $(dirname "$0")/../tmp
echo y | mix phoenix.new alibaba
openmaize_project
echo y | mix phoenix.new alibaba
openmaize_project --confirm
echo y | mix phoenix.new alibaba --no-html --no-brunch
openmaize_project --api
echo y | mix phoenix.new alibaba --no-html --no-brunch
openmaize_project --api --confirm
