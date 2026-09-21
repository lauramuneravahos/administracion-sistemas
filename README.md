<!-- markdownlint-disable MD033 MD022 MD042 MD060 -->
<!-- markdownlint-disable -->

# Práctica 1 — Vagrant + Docker

**Grupo 6** · Laura Munera Vahos · Yanira Porras Gago
Asignatura: Administración de Sistemas Informáticos
Grado en Ingeniería Informática en Sistemas de Información
Escuela Politécnica Superior de Zamora — Universidad de Salamanca
Curso 2026/2027

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

## Cómo reproducirlo

Requisitos: tener instalados **VirtualBox**, **Vagrant** y **Git**, y la virtualización activada en la BIOS.

```bash
git clone https://github.com/lauramuneravahos/administracion-sistemas.git
cd administracion-sistemas
vagrant up
vagrant ssh web
cd /vagrant && docker-compose up -d
```

Después, desde el navegador del equipo anfitrión:

```
http://192.168.56.10
```

Debería aparecer la página de bienvenida de Nginx.

---

## Cómo comprobar que funciona

Desde el equipo anfitrión, abre en el navegador:

```
http://192.168.56.10
```

Desde la máquina **cliente**:

```bash
vagrant ssh cliente
ping -c 3 192.168.56.10
curl http://192.168.56.10
```

Si el `ping` responde y el `curl` devuelve el HTML de Nginx, las dos máquinas se comunican correctamente.

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

> **Grupo 6** — Curso 2026/2027