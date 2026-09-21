# Práctica 1 — Vagrant + Docker (Grupo 6)

**Autores:** Laura Munera Vahos · Yanira Porras Gago
**Asignatura:** Administración de Sistemas Informáticos
**Curso:** 2026/2027

## Descripción
Aprovisionamiento automatizado de dos VMs Ubuntu con Vagrant y despliegue
de un servicio Nginx con Docker Compose en la VM `web`.

## Cómo reproducir
```bash
git clone [URL_DEL_REPO]
cd practica1-vagrant-docker
vagrant up
vagrant ssh web
cd /vagrant && docker-compose up -d