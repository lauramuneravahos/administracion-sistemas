<!-- markdownlint-disable MD033 MD022 MD042 MD060 -->
<!-- markdownlint-disable -->

<style>
@page { margin: 2.5cm 2cm; }

table {
  width: 100%;
  border-collapse: collapse;
  font-size: 10pt;
}
th, td {
  border: 1px solid #ccc;
  padding: 6px 8px;
}
th { background: #eaeaea; }
</style>

## Memoria Práctica 1 — Vagrant + Docker

| Campo | Valor |
|---|---|
| **Asignatura** | Administración de Sistemas Informáticos |
| **Título** | Práctica 1 — Aprovisionamiento automatizado de una máquina virtual con Vagrant y despliegue de un servicio con Docker y Docker Compose |
| **Grado** | Grado en Ingeniería Informática en Sistemas de Información |
| **Centro** | Escuela Politécnica Superior de Zamora — Universidad de Salamanca |
| **Curso académico** | 2026/2027 |
| **Grupo** | **Grupo 6** |
| **Autores** | Laura Munera Vahos · Yanira Porras Gago |
| **Fecha de entrega** | [dd/mm/aaaa] |
| **Repositorio Git** | [https://github.com/usuario/practica1-vagrant-docker] |
| **Vídeo defensa** | [apellidos_nombre_practica1.mp4] |

---

## 1. Resumen ejecutivo

Esta práctica tiene como objetivo **describir infraestructura como código (IaC)** usando dos herramientas estándar en administración de sistemas:

- **Vagrant**: describe y crea máquinas virtuales de forma automatizada a partir de un `Vagrantfile`.
- **Docker + Docker Compose**: despliega el servicio real dentro de un contenedor.

Se definen **dos máquinas virtuales Ubuntu (`ubuntu/jammy64`)** dentro de un mismo `Vagrantfile`:

- `web` (IP `192.168.56.10`): aloja el contenedor Nginx.
- `cliente` (IP `192.168.56.11`): se usa para verificar la conectividad y el acceso al servicio.

Toda la infraestructura se levanta con **un único comando (`vagrant up`)** y el servicio con **`docker-compose up -d`**, demostrando que el proceso es **reproducible** por cualquiera.

---

## 2. Objetivos

- [x] Comprender la diferencia entre **máquina virtual** y **contenedor**.
- [x] Describir el aprovisionamiento de una VM con un **Vagrantfile**.
- [x] Automatizar la instalación de software dentro de la VM mediante un **script de aprovisionamiento**.
- [x] Desplegar un servicio real dentro de un **contenedor Docker** con **Docker Compose**.
- [x] Desplegar una **segunda VM Ubuntu** en la misma red privada y comprobar la comunicación entre ambas.
- [x] Verificar que el servicio es accesible **desde otra VM**, no solo desde el anfitrión.
- [x] Verificar que todo el proceso es **reproducible** desde cero.
- [x] Practicar **Git** como mecanismo de entrega.

---

## 3. Conceptos clave

### 3.1 Máquina virtual vs. contenedor

| Aspecto | Máquina virtual | Contenedor |
|---|---|---|
| Qué virtualiza | Hardware completo (CPU, RAM, disco…) | Solo el espacio de usuario |
| Kernel | Propio | Compartido con el host |
| Arranque | Minutos | Segundos |
| Peso | GB | MB |
| Aislamiento | Total | A nivel de proceso |
| Herramienta | VirtualBox + Vagrant | Docker |

**En esta práctica se combinan**: una VM (creada por Vagrant) como base, y **dentro de ella** un contenedor (Docker) con el servicio real.

### 3.2 Hipervisor

Software que hace posible la virtualización. Los de **tipo 1** (bare-metal, como VMware ESXi) se instalan sobre el hardware. Los de **tipo 2** (como **VirtualBox**, el usado aquí) se instalan como una aplicación del sistema anfitrión.

### 3.3 Vagrant

- **Box**: imagen base de SO (`ubuntu/jammy64`).
- **Provisioner**: script que se ejecuta automáticamente al crear la VM.
- **Vagrantfile multi-máquina**: un mismo fichero describe varias VMs con `config.vm.define`.
- **Red privada (`private_network`)**: segmento aislado con IP fija, que permite a las VMs verse entre sí.

### 3.4 Docker y Docker Compose

- **Imagen**: plantilla de solo lectura.
- **Contenedor**: instancia en ejecución de una imagen.
- **Dockerfile**: describe cómo construir una imagen (no se usa en esta práctica).
- **Docker Compose**: define varios contenedores en un único `docker-compose.yml`.
- **Kubernetes** (mención): orquestador para múltiples hosts; Compose resuelve un solo host.

---

## 4. Entorno de trabajo

### 4.1 Software

| Herramienta | Versión | Comprobación |
|---|---|---|
| VirtualBox | [7.0.x] | `VBoxManage --version` |
| Vagrant | [2.4.x] | `vagrant --version` |
| Git | [2.x] | `git --version` |
| Editor | VS Code [1.xx] | — |

### 4.2 Hardware

- Virtualización por hardware (Intel VT-x / AMD-V) **activada en BIOS/UEFI**.
- Al menos **4 GB de RAM libres** (la VM `web` consume 2 GB).
- Conexión a Internet (descarga de la box + instalación de paquetes).

### 4.3 Cuentas

- Cuenta en [GitHub / GitLab] con el repositorio público o con acceso al profesor.

---

## 5. Estructura del repositorio

```
practica1-vagrant-docker/
├── .gitignore
├── Vagrantfile
├── provisioning.sh
├── docker-compose.yml
└── README.md
```

### 5.1 `.gitignore`

```gitignore
.vagrant/
*.log
```

> Excluye la carpeta `.vagrant/` (estado local de las VMs) y logs. **No se debe subir** al repositorio.

---

## 6. Desarrollo de la práctica

### 6.1 Paso 1-2 — Preparar el entorno e iniciar el proyecto

```bash
mkdir practica1-vagrant-docker
cd practica1-vagrant-docker
git init
vagrant init ubuntu/jammy64
```

### 6.2 Paso 3 — Definir las dos VMs y la red privada

`Vagrantfile`:

```ruby
Vagrant.configure("2") do |config|

  # ---------- Máquina WEB ----------
  config.vm.define "web" do |web|
    web.vm.box = "ubuntu/jammy64"
    web.vm.hostname = "web"
    web.vm.network "private_network", ip: "192.168.56.10"

    web.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus   = 1
      vb.name   = "practica1-web"
      vb.gui    = false
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end

    web.vm.provision "shell", path: "provisioning.sh"
  end

  # ---------- Máquina CLIENTE ----------
  config.vm.define "cliente" do |cli|
    cli.vm.box = "ubuntu/jammy64"
    cli.vm.hostname = "cliente"
    cli.vm.network "private_network", ip: "192.168.56.11"

    cli.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus   = 1
      vb.name   = "practica1-cliente"
      vb.gui    = false
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end
  end

end
```

**Explicación de los bloques clave**:

| Línea | Función |
|---|---|
| `config.vm.define "web"` | Declara una VM con nombre lógico `web`. |
| `web.vm.box = "ubuntu/jammy64"` | Imagen base Ubuntu 22.04. |
| `web.vm.network "private_network"` | Red privada con IP fija en la subred `192.168.56.0/24`. |
| `web.vm.provider "virtualbox"` | Configura recursos de VirtualBox (RAM, CPU, nombre). |
| `web.vm.provision "shell"` | Ejecuta `provisioning.sh` al crear la VM. |

### 6.3 Paso 4-5 — Automatizar la instalación

`provisioning.sh`:

```bash
#!/usr/bin/env bash
set -e

echo ">>> Actualizando sistema..."
apt-get update
apt-get upgrade -y

echo ">>> Instalando Docker..."
curl -fsSL https://get.docker.com | sh

echo ">>> Instalando Docker Compose..."
apt-get install -y docker-compose

echo ">>> Añadiendo usuario vagrant al grupo docker..."
usermod -aG docker vagrant

echo ">>> Provisioning completado."
```

> ⚠️ **Importante**: guardar el fichero con saltos de línea **LF** (no CRLF), o fallará con `\r: command not found`.

### 6.4 Paso 6 — Levantar ambas máquinas

```bash
vagrant up
```

Vagrant:
1. Descarga la box `ubuntu/jammy64` (solo la primera vez).
2. Crea y arranca las dos VMs.
3. Ejecuta `provisioning.sh` en la VM `web`.

Comprobación:

```bash
vagrant status
```

### 6.5 Paso 7-8 — Desplegar el servicio con Docker Compose

`docker-compose.yml`:

```yaml
version: "3"

services:
  nginx:
    image: nginx:latest
    ports:
      - "80:80"
    restart: unless-stopped
```

Despliegue:

```bash
vagrant ssh web
cd /vagrant
docker-compose up -d
docker ps
exit
```

### 6.6 Paso 9 — Verificar desde el anfitrión

Abrir en el navegador del equipo anfitrión:

```
http://192.168.56.10
```

Debe mostrarse la página de bienvenida de Nginx.

### 6.7 Paso 10 — Comprobar comunicación entre las dos VMs

```bash
vagrant ssh cliente
ping -c 3 192.168.56.10
curl http://192.168.56.10
```

Resultado esperado:
- `ping`: 3 paquetes recibidos, sin pérdida.
- `curl`: HTML de bienvenida de Nginx.

**Por qué esto demuestra la comunicación entre VMs**: el `ping` y el `curl` se ejecutan **desde dentro** de la VM `cliente`, no desde el anfitrión. Si responden, es porque ambas VMs están en el mismo segmento de red privada y se ven entre sí, con independencia del equipo anfitrión.

---

## 7. Verificación de resultados

| Comprobación | Comando | Resultado esperado |
|---|---|---|
| VMs arrancadas | `vagrant status` | Ambas `running` |
| IPs privadas | `ip a` dentro de cada VM | `192.168.56.10` / `192.168.56.11` |
| Contenedor Nginx | `docker ps` | `nginx:latest` corriendo, puerto `0.0.0.0:80->80/tcp` |
| Acceso desde anfitrión | Navegador → `http://192.168.56.10` | Página de bienvenida |
| Conectividad entre VMs | `ping -c 3 192.168.56.10` desde `cliente` | 3/3 paquetes |
| Servicio desde otra VM | `curl http://192.168.56.10` desde `cliente` | HTML de Nginx |
| Reproducibilidad | `vagrant destroy -f && vagrant up` | Todo se recrea solo |

---

## 8. Reproducibilidad

Cualquier persona puede reproducir la práctica desde cero:

```bash
git clone [URL_DEL_REPOSITORIO]
cd practica1-vagrant-docker
vagrant up
vagrant ssh web
cd /vagrant && docker-compose up -d
```

Requisitos: VirtualBox + Vagrant + Git instalados y virtualización por hardware activada.

---

## 9. Entrega en Git

```bash
git add Vagrantfile provisioning.sh docker-compose.yml .gitignore
git commit -m "Práctica 1: Vagrant + Docker"
git branch -M main
git remote add origin [URL_DEL_REPOSITORIO]
git push -u origin main
```

> La carpeta `.vagrant/` **no se sube** gracias al `.gitignore`.

---

## 10. Vídeo de defensa

### 10.1 Especificaciones del enunciado

| Requisito | Valor |
|---|---|
| Duración | 5–10 minutos |
| Formato | `.mp4` |
| Resolución mínima | 1080p |
| Audio | Claro, en primer plano, sin ruido de fondo |
| Pantalla | Completa (terminal + editor + navegador), no recortes |
| Nombre del archivo | `apellidos_nombre_practica1.mp4` |
| Entrega | Subir a Studium + enlace al repo en el propio envío |

### 10.2 Guion del vídeo (reparto Grupo 6)

| Tiempo | Contenido | Responsable |
|---|---|---|
| 0:00–0:15 | Presentación: nombres, Grupo 6, qué se va a mostrar | Laura / Yanira |
| 0:15–1:30 | Explicación de VM vs contenedor, Vagrant, Docker, Compose | Ambas |
| 1:30–3:30 | `Vagrantfile` + `provisioning.sh` bloque a bloque | Laura |
| 3:30–5:30 | `vagrant destroy -f && vagrant up` desde cero | Laura |
| 5:30–6:30 | `docker-compose.yml` + `docker-compose up -d` + `docker ps` | Yanira |
| 6:30–7:30 | Navegador del anfitrión → `http://192.168.56.10` | Yanira |
| 7:30–8:30 | `vagrant ssh cliente` → `ping` + `curl` | Yanira |
| 8:30–9:30 | Cierre: dificultades, aprendizajes, caso real | Ambas |

### 10.3 Checklist antes de grabar

- [ ] `vagrant up` funciona desde cero sin pasos manuales.
- [ ] `docker-compose up -d` levanta el servicio correctamente.
- [ ] El servicio es accesible desde el navegador del anfitrión.
- [ ] `ping` entre las dos VMs responde.
- [ ] `curl` desde la VM `cliente` llega al servicio de la VM `web`.
- [ ] `.vagrant/` no está incluida en el repositorio.
- [ ] `Vagrantfile`, `provisioning.sh` y `docker-compose.yml` están subidos a Git.
- [ ] Vídeo grabado explicando **cada fichero**, no solo el resultado final.

---

## 11. Criterios de evaluación (orientativos)

| Criterio | Peso | Estado |
|---|---|---|
| Automatización correcta (`vagrant up` sin pasos manuales) | 25 % | [ ] |
| Servicio Docker accesible y `docker-compose.yml` correcto | 20 % | [ ] |
| Comunicación entre las dos VMs verificada (`ping` y `curl`) | 20 % | [ ] |
| Claridad y corrección de las explicaciones en el vídeo | 20 % | [ ] |
| Calidad del repositorio (ficheros correctos, sin ruido) | 8 % | [ ] |
| Formato y duración del vídeo conforme al guion | 7 % | [ ] |

---

## 12. Conclusiones y dificultades

### 12.1 Dificultades encontradas

- [Ejemplo: la primera descarga de la box tardó X minutos.]
- [Ejemplo: el script `provisioning.sh` fallaba por CRLF; se solucionó cambiando a LF.]
- [Ejemplo: la red privada no aparecía hasta reiniciar VirtualBox.]

### 12.2 Aprendizajes

- La infraestructura como código permite **reproducir entornos con un solo comando**.
- Vagrant abstrae la GUI de VirtualBox y permite versionar la definición de la VM.
- Docker Compose simplifica el despliegue de servicios frente a `docker run` manual.
- La red privada es la clave para que dos VMs se comuniquen sin depender del anfitrión.

### 12.3 Paralelismo con un caso real

Este flujo es exactamente lo que hace un equipo de desarrollo cuando quiere que **cualquier compañero levante el entorno completo con un solo comando**: Vagrant describe la infraestructura y Docker describe el servicio. Esto es la base de la **Infrastructure as Code (IaC)** que se profundizará en bloques posteriores.

---

## 13. Referencias

- Documentación oficial de Vagrant: https://developer.hashicorp.com/vagrant/docs
- Documentación oficial de Docker: https://docs.docker.com/
- Docker Compose: https://docs.docker.com/compose/
- Box `ubuntu/jammy64`: https://app.vagrantup.com/ubuntu/boxes/jammy64

---

> **Nota final (Grupo 6)**: recuerda que el vídeo defensa es **parte de la evaluación**. El repositorio por sí solo no es suficiente; hay que demostrar que se entiende qué hace cada fichero y por qué.