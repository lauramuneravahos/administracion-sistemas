<!-- markdownlint-disable MD033 MD022 MD042 MD060 -->
<!-- markdownlint-disable -->

# Memoria Práctica 1 — Vagrant + Docker

| Campo | Valor |
|---|---|
| **Asignatura** | Administración de Sistemas Informáticos |
| **Título** | Práctica 1 — Vagrant y Docker |
| **Grado** | Grado en Ingeniería Informática en Sistemas de Información |
| **Centro** | Escuela Politécnica Superior de Zamora — Universidad de Salamanca |
| **Curso académico** | 2026/2027 |
| **Grupo** | **Grupo 6** |
| **Autores** | Laura Munera Vahos · Yanira Porras Gago |
| **Fecha de entrega** | **29 de septiembre de 2026** |
| **Repositorio Git** | https://github.com/lauramuneravahos/administracion-sistemas |
| **Vídeo defensa** | [apellidos_nombre_practica1.mp4] |

<!--
CAPTURA 1 (opcional): captura de la página principal del repositorio en GitHub.
Aquí se ve que el repositorio está creado y con los ficheros subidos.
Sugerencia de nombre de archivo: capturas/01-repositorio-github.png
-->

---

## 1. Introducción

En esta práctica hemos creado dos máquinas virtuales con **Vagrant** y, dentro de una de ellas, hemos puesto un servicio web (Nginx) usando **Docker**.

La idea principal es que **todo se cree solo** con un par de comandos, sin tener que instalar ni configurar nada a mano. Eso se llama "infraestructura como código", porque en lugar de hacer clic en botones, escribimos ficheros de texto que describen lo que queremos.

Pasos que seguimos al realizar esta práctica:

- Crear dos máquinas virtuales Ubuntu con Vagrant:
  - **web** → donde va el servicio web.
  - **cliente** → para probar que se puede acceder al servicio desde otra máquina.
- Instalar Docker y Docker Compose automáticamente dentro de la máquina **web**.
- Poner un contenedor con **Nginx** (un servidor web muy típico) que se levanta con Docker Compose.
- Comprobar que:
  - Desde el ordenador donde trabajamos, se ve la página de Nginx.
  - Desde la máquina **cliente**, se puede hacer `ping` y `curl` a la máquina **web**.

---

## 2. Objetivos

- [x] Entender la diferencia entre una **máquina virtual** y un **contenedor**.
- [x] Aprender a describir una máquina virtual con un fichero llamado **Vagrantfile**.
- [x] Automatizar la instalación de programas dentro de la máquina virtual con un script.
- [x] Desplegar un servicio real dentro de un **contenedor Docker** usando **Docker Compose**.
- [x] Crear una segunda máquina Ubuntu y comprobar que las dos se comunican.
- [x] Ver que el servicio no solo se ve desde nuestro ordenador, sino también desde la otra máquina.
- [x] Comprobar que todo el proceso se puede repetir desde cero.
- [x] Usar **Git** para subir el trabajo a un repositorio.

---

## 3. Fundamentos teóricos

### 3.1 Máquina virtual y contenedor

Son dos formas de tener "un ordenador dentro de otro", pero se diferencian en varias cosas:

| | Máquina virtual | Contenedor |
|---|---|---|
| Qué incluye | Un sistema operativo completo | Solo la aplicación |
| Cuánto tarda en arrancar | Minutos | Segundos |
| Cuánto ocupa | Mucho (varios GB) | Poco (unos MB) |
| Aislamiento | Total | Más ligero |
| Herramienta | VirtualBox + Vagrant | Docker |

En esta práctica **usamos las dos cosas a la vez**: una máquina virtual como base (creada por Vagrant) y, dentro de ella, un contenedor con el servicio.

<!--
CAPTURA 2 (recomendada): captura de la ventana de VirtualBox mostrando las dos VMs
"practica1-web" y "practica1-cliente" en estado "Running".
Esto evidencia que las máquinas virtuales existen y están funcionando.
Sugerencia de nombre de archivo: capturas/02-virtualbox-vms.png
-->

### 3.2 Hipervisor

Es el programa que permite tener máquinas virtuales. Hay dos tipos:

- **Tipo 1**: se instala directamente sobre el hardware (por ejemplo, VMware ESXi).
- **Tipo 2**: se instala como un programa más dentro de nuestro sistema (por ejemplo, **VirtualBox**, que es el que usamos).

### 3.3 Vagrant

Es una herramienta que sirve para **crear máquinas virtuales automáticamente** a partir de un fichero de texto llamado `Vagrantfile`. En lugar de crear la máquina a mano en VirtualBox, la describimos en ese fichero y con un solo comando ya se crea.

Algunas partes que aparecen en el fichero:

- **Box**: la imagen base del sistema operativo que se descarga (en nuestro caso `ubuntu/jammy64`).
- **Provisioner**: el script que se ejecuta solo al crear la máquina, para instalar cosas.
- **Red privada**: una red interna que conecta nuestras máquinas virtuales entre sí con una IP fija que elegimos nosotros.

### 3.4 Docker y Docker Compose

- **Imagen**: la plantilla que sirve para crear contenedores. En esta práctica usamos la imagen oficial **`nginx:latest`**, que se descarga automáticamente desde Docker Hub.
- **Contenedor**: una imagen que ya está funcionando.
- **Dockerfile**: un fichero que explica cómo crear una imagen (en esta práctica no lo usamos).
- **Docker Compose**: una herramienta que permite describir varios contenedores en un solo fichero (`docker-compose.yml`).
- **Kubernetes**: otro programa más grande que sirve para manejar contenedores en muchos servidores a la vez. Aquí solo lo mencionamos, no lo usamos.

---

## 4. Requisitos previos

### 4.1 Software

| Programa | Para qué sirve |
|---|---|
| VirtualBox | Es el programa que crea las máquinas virtuales. |
| Vagrant | Sirve para crear esas máquinas automáticamente. |
| Git | Para subir el trabajo a GitHub. |
| VS Code | Para escribir los ficheros. |

<!--
CAPTURA 3 (opcional): captura de la terminal mostrando las versiones instaladas.
Comandos sugeridos: `VBoxManage --version`, `vagrant --version`, `git --version`
Sugerencia de nombre de archivo: capturas/03-versiones.png
-->

### 4.2 Hardware

- Tener la **virtualización activada** en la BIOS (es un ajuste del ordenador; sin él, las máquinas virtuales no arrancan).
- Al menos **4 GB de RAM libres**.
- Conexión a Internet (para descargar la imagen de Ubuntu y para instalar programas).

### 4.3 Cuentas

- Una cuenta en **GitHub** con el correo institucional `lauramuneravahos@usal.es`.

<!--
CAPTURA 4 (opcional): captura de Settings → Emails en GitHub,
donde se ve que el correo @usal.es está "Primary" y "Verified".
Esto evidencia que el correo está bien configurado.
Sugerencia de nombre de archivo: capturas/04-github-email.png
-->

---

## 5. Estructura del repositorio

```
administracion-sistemas/
├── .gitattributes        → Para que los ficheros tengan los saltos de línea correctos.
├── .gitignore            → Para que Git ignore cosas que no queremos subir.
├── README.md             → Página principal del repositorio.
├── memoria.md            → Este documento.
├── Vagrantfile           → Describe las dos máquinas virtuales.
├── provisioning.sh       → Script que instala Docker y Docker Compose.
└── docker-compose.yml    → Describe el servicio Nginx.
```

<!--
CAPTURA 5 (recomendada): captura del explorador de archivos de VS Code
mostrando la carpeta del proyecto con todos los ficheros.
Sugerencia de nombre de archivo: capturas/05-estructura-proyecto.png
-->

### 5.1 Fichero `.gitignore`

```gitignore
.vagrant/
*.log
```

Con esto hacemos que la carpeta `.vagrant/` (que se crea sola) y los ficheros de log no se suban a GitHub.

### 5.2 Fichero `.gitattributes`

```
* text=auto eol=lf
*.sh text eol=lf
Vagrantfile text eol=lf
*.yml text eol=lf
```

Este fichero sirve para que los ficheros se guarden siempre con **saltos de línea de Linux (LF)**. Si se guardaran con saltos de Windows, los scripts fallarían dentro de Ubuntu.

---

## 6. Control de versiones con Git

### 6.1 Configuración inicial

Primero creamos una cuenta en **GitHub** con el correo de la universidad (`lauramuneravahos@usal.es`) y desde ahí creamos un repositorio llamado **`administracion-sistemas`**.

Después, en nuestro ordenador, configuramos Git con nuestro nombre y correo:

```bash
git config --global user.name "LMunera"
git config --global user.email "lauramuneravahos@usal.es"
git config --global core.autocrlf input
```

El último comando sirve para que no se cambien los saltos de línea de los ficheros.

<!--
CAPTURA 6 (opcional): captura de la terminal mostrando el resultado de
`git config --global user.email` (debe salir el correo de la USAL).
Sugerencia de nombre de archivo: capturas/06-git-config.png
-->

### 6.2 Subida del proyecto

Luego, desde la carpeta del proyecto, hicimos:

```bash
git init
git add .
git commit -m "Práctica 1: Vagrant + Docker (Grupo 6)"
git branch -M main
git remote add origin https://github.com/lauramuneravahos/administracion-sistemas.git
git push -u origin main
```

La primera vez que hicimos `git push` nos pidió iniciar sesión y se abrió el navegador para autorizarlo. Después ya no hizo falta más.

<!--
CAPTURA 7 (recomendada): captura de la terminal con el resultado del `git push`
donde se ve "new branch main -> main" y "branch 'main' set up to track 'origin/main'".
Sugerencia de nombre de archivo: capturas/07-git-push.png
-->

---

## 7. Desarrollo de la práctica

### 7.1 Creación del proyecto

```bash
mkdir practica1-vagrant-docker
cd practica1-vagrant-docker
vagrant init ubuntu/jammy64
```

El último comando crea un `Vagrantfile` básico.

### 7.2 Definición de las máquinas virtuales

```ruby
Vagrant.configure("2") do |config|

  config.vm.define "web" do |web|
    web.vm.box = "ubuntu/jammy64"
    web.vm.hostname = "web"
    web.vm.network "private_network", ip: "192.168.56.10"

    web.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus   = 1
      vb.name   = "practica1-web"
      vb.gui    = false
    end

    web.vm.provision "shell", path: "provisioning.sh"
  end

  config.vm.define "cliente" do |cli|
    cli.vm.box = "ubuntu/jammy64"
    cli.vm.hostname = "cliente"
    cli.vm.network "private_network", ip: "192.168.56.11"

    cli.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus   = 1
      vb.name   = "practica1-cliente"
      vb.gui    = false
    end
  end

end
```

Lo importante de este fichero:

- `config.vm.define "web"` sirve para definir la primera máquina.
- `web.vm.box` es la imagen de Ubuntu que se descarga.
- `web.vm.network "private_network"` le pone una IP fija.
- `web.vm.provider "virtualbox"` le dice cuánta memoria y cuántas CPU tiene.
- `web.vm.provision "shell"` indica que se ejecute el script `provisioning.sh` al crearla.

La segunda máquina (`cliente`) es igual, pero con otra IP y sin script, porque no necesita instalar nada.

<!--
CAPTURA 8 (recomendada): captura del fichero Vagrantfile abierto en VS Code,
donde se vean los dos bloques config.vm.define.
Sugerencia de nombre de archivo: capturas/08-vagrantfile.png
-->

### 7.3 Script de aprovisionamiento

```bash
#!/usr/bin/env bash
set -e

apt-get update
apt-get upgrade -y

curl -fsSL https://get.docker.com | sh

apt-get install -y docker-compose

usermod -aG docker vagrant
```

Este script hace cuatro cosas:

1. Actualiza el sistema.
2. Instala Docker.
3. Instala Docker Compose.
4. Añade el usuario `vagrant` al grupo de Docker.

Se ejecuta solo la primera vez que se crea la máquina.

<!--
CAPTURA 9 (recomendada): captura del fichero provisioning.sh abierto en VS Code.
Sugerencia de nombre de archivo: capturas/09-provisioning.png
-->

### 7.4 Creación y arranque de las máquinas

Con este único comando se crean las dos máquinas y se ejecuta el script:

```bash
vagrant up
```

La primera vez tarda bastante porque descarga la imagen de Ubuntu.

Para ver cómo están las máquinas:

```bash
vagrant status
```

<!--
CAPTURA 10 (MUY recomendada): captura de la terminal durante o después de `vagrant up`,
y otra captura de `vagrant status` mostrando las dos VMs como "running".
Sugerencia de nombre de archivo: capturas/10-vagrant-up-status.png
-->

### 7.5 Definición del servicio con Docker Compose

```yaml
version: "3"

services:
  nginx:
    image: nginx:latest
    ports:
      - "80:80"
    restart: unless-stopped
```

Este fichero dice:

- Que se descargue la imagen oficial de **Nginx**.
- Que se publique en el puerto 80.
- Que si el contenedor se cae, se reinicie solo.

<!--
CAPTURA 11 (recomendada): captura del fichero docker-compose.yml abierto en VS Code.
Sugerencia de nombre de archivo: capturas/11-docker-compose.png
-->

### 7.6 Despliegue del servicio

```bash
vagrant ssh web
cd /vagrant
docker-compose up -d
docker ps
exit
```

Con esto entramos en la máquina **web**, vamos a la carpeta donde está el fichero y levantamos el contenedor. El comando `docker ps` sirve para ver que está funcionando.

<!--
CAPTURA 12 (MUY recomendada): captura de la terminal dentro de la VM web
mostrando la salida de `docker-compose up -d` y de `docker ps`
(se debe ver el contenedor nginx con el puerto 80 publicado).
Sugerencia de nombre de archivo: capturas/12-docker-ps.png
-->

### 7.7 Verificación desde el equipo anfitrión

Abrimos el navegador y ponemos:

```
http://192.168.56.10
```

Debería aparecer la página de bienvenida de Nginx.

<!--
CAPTURA 13 (MUY recomendada): captura del navegador del equipo anfitrión
mostrando la página "Welcome to nginx!" en http://192.168.56.10.
Sugerencia de nombre de archivo: capturas/13-navegador-anfitrion.png
-->

### 7.8 Verificación de la comunicación entre máquinas

```bash
vagrant ssh cliente
ping -c 3 192.168.56.10
curl http://192.168.56.10
```

- El `ping` sirve para ver si las dos máquinas se ven.
- El `curl` sirve para ver si la máquina cliente puede acceder al servicio de la máquina web.

Esto demuestra que las dos máquinas están conectadas y que el servicio no depende de nuestro ordenador.

<!--
CAPTURA 14 (MUY recomendada): captura de la terminal dentro de la VM cliente
mostrando el resultado del `ping -c 3 192.168.56.10` (3 paquetes recibidos)
y del `curl http://192.168.56.10` (HTML de Nginx).
Sugerencia de nombre de archivo: capturas/14-ping-curl-cliente.png
-->

---

## 8. Verificación de resultados

| Qué comprobamos | Cómo | Resultado |
|---|---|---|
| Que las máquinas están encendidas | `vagrant status` | Las dos dicen "running" |
| Que tienen las IPs correctas | `ip a` dentro de cada una | `192.168.56.10` y `192.168.56.11` |
| Que el contenedor funciona | `docker ps` | Nginx en el puerto 80 |
| Que se ve desde nuestro ordenador | Navegador en `http://192.168.56.10` | Página de Nginx |
| Que las máquinas se ven | `ping` desde cliente | 3 paquetes recibidos |
| Que se ve desde la otra máquina | `curl` desde cliente | Página de Nginx |
| Que se puede repetir desde cero | `vagrant destroy -f` y `vagrant up` | Todo vuelve a funcionar |

<!--
CAPTURA 15 (opcional): captura del comando `vagrant destroy -f` seguido de `vagrant up`
para demostrar que todo el proceso se puede repetir desde cero.
Sugerencia de nombre de archivo: capturas/15-reproducibilidad.png
-->

---

## 9. Reproducibilidad

Para repetir la práctica desde cero, otra persona solo tiene que hacer:

```bash
git clone https://github.com/lauramuneravahos/administracion-sistemas.git
cd administracion-sistemas
vagrant up
vagrant ssh web
cd /vagrant && docker-compose up -d
```

Necesita tener instalado VirtualBox, Vagrant y Git.

---

## 10. Conclusiones

### 10.1 Dificultades encontradas

- Al principio, Git estaba configurado con un correo personal y tuvimos que cambiarlo al de la universidad para que los commits se vieran bien en GitHub.
- Nos salió un aviso sobre los saltos de línea (LF y CRLF) y lo solucionamos cambiando una configuración y añadiendo un fichero `.gitattributes`.
- La primera descarga de la imagen de Ubuntu tardó bastante.

### 10.2 Aprendizajes

- Que se puede describir todo un entorno en ficheros de texto y crearlo con un solo comando.
- Que Vagrant sirve para no tener que crear las máquinas virtuales a mano.
- Que Docker Compose hace mucho más fácil levantar un servicio.
- Que la red privada es lo que permite que las dos máquinas se vean entre ellas.
- Que usar bien Git (con el correo correcto y con los ficheros bien configurados) evita muchos problemas.

### 10.3 Aplicación en el mundo real

Cuando un equipo de trabajo quiere que cualquiera pueda tener el mismo entorno en su ordenador, usa herramientas como estas. Vagrant describe las máquinas y Docker describe el servicio. Así todos trabajan igual sin tener que instalar cosas a mano.

---

## 11. Bibliografía y referencias

### 11.1 Documentación oficial

- Vagrant: https://developer.hashicorp.com/vagrant/docs
- Docker: https://docs.docker.com/
- Docker Compose: https://docs.docker.com/compose/
- La imagen de Ubuntu que usamos: https://app.vagrantup.com/ubuntu/boxes/jammy64
- GitHub: https://docs.github.com/

### 11.2 Herramientas de apoyo utilizadas

- **Gemini** (Google): ayuda para resolver dudas puntuales durante la práctica.
- **NotebookLM** (Google): apoyo para consultar los apuntes de la asignatura.
- **DeepSeek**: ayuda para resolver errores en los comandos de Git y Docker.

---