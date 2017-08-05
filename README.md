# elementos derivaciones

Aplicación de validación de derivaciones lógicas

Version: 1.0.0

### docker environment

crear imagen desde archivo docker
> docker build --tag derivaciones-image -f Dockerfile .    

crear contenedor desde imagen
> docker run -d -it --name derivaciones-container -v $PWD:/derivaciones -p 3001:3001 -p 3002:3002 -p 35730:35730 -p 35729:35729 derivaciones-image    

listar procesos activos
> docker ps

asociar consola a proceso activo
> docker attach derivaciones-container    

inicial el contenedor si no está activo
> docker start -ia derivaciones-container    

detener el contenedor para finalizar actividad
> docker stop derivaciones-container    

### nvm environment

Para instalar nvm, puede obtener el script de instalación con `curl`
y ejectuarlo automaticamente:

> curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash

tambien puede realizar la operación con `wget`:

> wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash

para setear la version 6 de nodejs

> nvm install 6
> nvm use 6

#### install compass    

> apt-get install ruby-dev    
> apt-get install rubygems    
> gem update --system    
> gem install compass    

### deploy

#### instalar dependencias node
> npm install

#### instalar dependencias bower
> npm run bower -- install

en entorno docker

> npm run bower -- install --allow-root

#### ejecutar entorno de desarrollo en modo lireload
> npm run grunt -- server

#### ejecutar servidor markdown
> npm run markserv -- -p 3002 -a 0.0.0.0
