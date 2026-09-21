<!-- markdownlint-disable MD033 MD022 MD042 MD060 -->
<!-- markdownlint-disable -->

# Práctica 1 — Vagrant + Docker

**Grupo 6** · Laura Munera Vahos · Yanira Porras Gago
**Asignatura:** Administración de Sistemas Informáticos
**Grado:** Ingeniería Informática en Sistemas de Información
**Centro:** Escuela Politécnica Superior de Zamora — Universidad de Salamanca
**Curso:** 2026/2027

---

## ¿Qué hay en este repositorio?

En esta práctica hemos creado **dos máquinas virtuales Ubuntu** con **Vagrant** y, dentro de una de ellas, hemos desplegado un servicio web (**Nginx**) usando **Docker Compose**.

- **VM `web`** → `192.168.56.10` → aloja el contenedor Nginx.
- **VM `cliente`** → `192.168.56.11` → se usa para verificar que el servicio es accesible desde otra máquina.

Todo el entorno se levanta con **un solo comando** (`vagrant up`) y el servicio con **`docker-compose up -d`**.

---

## Ficheros del repositorio

| Fichero | Para qué sirve |
|---|---|
| `Vagrantfile` | Describe las dos máquinas virtuales y su red privada. |
| `provisioning.sh` | Script que instala Docker y Docker Compose en la VM `web`. |
| `docker-compose.yml` | Define el servicio Nginx y publica el puerto 80. |
| `.gitignore` | Evita subir la carpeta `.vagrant/` y los logs. |
| `.gitattributes` | Fuerza saltos de línea LF en los ficheros de texto. |

---

## Cómo reproducir el proyecto

Esta sección explica **paso a paso** cómo clonar el repositorio y levantar el entorno desde cero en cualquier ordenador.

### 1. Requisitos previos

Antes de empezar, hay que tener instalado:

| Programa | Para qué sirve | Dónde descargarlo |
|---|---|---|
| **VirtualBox** | Crea las máquinas virtuales. | https://www.virtualbox.org/wiki/Downloads |
| **Vagrant** | Crea las máquinas automáticamente. | https://developer.hashicorp.com/vagrant/downloads |
| **Git** | Para clonar el repositorio. | https://git-scm.com/downloads |

Además:

- **Virtualización activada** en la BIOS/UEFI (Intel VT-x o AMD-V).
- Al menos **4 GB de RAM libres** (la VM `web` usa 2 GB).
- **Conexión a Internet** (para descargar la imagen de Ubuntu y los paquetes de Docker).

### 2. Clonar el repositorio

Abre una terminal (PowerShell en Windows, bash en Linux/macOS) y ejecuta:

```bash
git clone https://github.com/lauramuneravahos/administracion-sistemas.git
cd administracion-sistemas
```

Con esto tendrás todos los ficheros del proyecto en tu ordenador.

### 3. Levantar las máquinas virtuales

Desde la carpeta del proyecto:

```bash
vagrant up
```

Este único comando hace **todo lo siguiente automáticamente**:

1. Descarga la imagen base de Ubuntu (`ubuntu/jammy64`) si no la tiene.
2. Crea y arranca las dos máquinas virtuales: **web** y **cliente**.
3. Ejecuta el script `provisioning.sh` en la máquina **web**, que instala Docker y Docker Compose.

> ⏳ **La primera vez puede tardar entre 10 y 25 minutos**, sobre todo por la descarga de la imagen de Ubuntu. Las siguientes veces tarda mucho menos.

Para comprobar que las máquinas están encendidas:

```bash
vagrant status
```

Debe mostrar las dos máquinas como `running`.

### 4. Desplegar el servicio con Docker Compose

Entra en la máquina **web**:

```bash
vagrant ssh web
```

Una vez dentro, ve a la carpeta sincronizada (donde está el `docker-compose.yml`) y levanta el servicio:

```bash
cd /vagrant
docker-compose up -d
```

Comprueba que el contenedor está corriendo:

```bash
docker ps
```

Debe aparecer un contenedor con la imagen `nginx` y el puerto `80` publicado.

Para salir de la máquina virtual:

```bash
exit
```

### 5. Verificar desde el equipo anfitrión

Abre el navegador del ordenador donde has ejecutado `vagrant up` y entra en:

```
http://192.168.56.10
```

Debería aparecer la página de bienvenida de Nginx.

### 6. Verificar la comunicación entre las dos máquinas

Entra en la máquina **cliente**:

```bash
vagrant ssh cliente
```

Dentro, haz un `ping` a la máquina **web** para comprobar que se ven:

```bash
ping -c 3 192.168.56.10
```

Y accede al servicio Nginx con `curl`:

```bash
curl http://192.168.56.10
```

- Si el `ping` responde con **3 paquetes recibidos**, las dos máquinas se comunican.
- Si el `curl` devuelve el HTML de Nginx, el servicio es accesible desde la máquina cliente.

Para salir:

```bash
exit
```

### 7. Parar y destruir el entorno

Cuando ya no necesites las máquinas:

**Apagarlas** (se conservan los datos):

```bash
vagrant halt
```

**Eliminarlas por completo** (se borra todo, y el siguiente `vagrant up` las recrea desde cero):

```bash
vagrant destroy -f
```

---

## Resumen de comandos

```bash
# 1. Clonar
git clone https://github.com/lauramuneravahos/administracion-sistemas.git
cd administracion-sistemas

# 2. Levantar las máquinas
vagrant up

# 3. Desplegar el servicio
vagrant ssh web
cd /vagrant && docker-compose up -d
exit

# 4. Verificar desde el navegador del anfitrión
# http://192.168.56.10

# 5. Verificar desde la máquina cliente
vagrant ssh cliente
ping -c 3 192.168.56.10
curl http://192.168.56.10
exit

# 6. Limpiar (opcional)
vagrant destroy -f
```

---

## Autores

- **Laura Munera Vahos** — [@lauramuneravahos](https://github.com/lauramuneravahos)
- **Yanira Porras Gago** — [@yanira-26](https://github.com/yanira-26)

---

## Bibliografía y referencias

- Vagrant: https://developer.hashicorp.com/vagrant/docs
- Docker: https://docs.docker.com/
- Docker Compose: https://docs.docker.com/compose/
- Box `ubuntu/jammy64`: https://app.vagrantup.com/ubuntu/boxes/jammy64
- GitHub: https://docs.github.com/

---