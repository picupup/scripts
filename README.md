# scripts
This repository contains scripts that could be useful for local computer or for a server, while attempting to e.g create or delete a user, create a group, create a git bare repo etc.

# usage
- run `./deploy.sh server` or `./deploy.sh local`
- In the config file there is a default set of lists.
- Scripts are divided between commen script, server scripts and local scripts for the personal computer.
- Run deploy with either 'server' or 'local' as argument to deploy all scripts to your envirment.


# Note
- I'm considering to remove the personal scripts to make this repo server specific. 

# One Time scripts 
There are also some script for installing some commands etc. You can find them under one-time-bin





# Running a simple http server locally:

npm: Starts a server in the current dir.

```npm
npm install -g live-server
live-server
```

python: 

```bash
python -m http.server 8000 --directory ./my_dir
```

docker: Set alias.

```bash
    alias apache-start="docker run -d --name apache2-container -p 8080:80 -v $(pwd):/usr/local/apache2/htdocs/ httpd:2.4"
    alias apache-stop="docker rm -f apache2-container"
```

