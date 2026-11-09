# Gestión de Trabajos de Grado

Aplicación web en Java y JSP para la gestión académica de trabajos de grado, con vistas para estudiantes, directores, evaluadores, coordinación y administración.

## Tecnologías

- Java y JSP
- Apache Tomcat
- HTML, CSS y JavaScript
- Docker

## Organización

| Ruta | Contenido |
| --- | --- |
| `estudiante/` | Vistas para estudiantes |
| `director/` | Vistas para directores |
| `evaluador/` | Vistas para evaluadores |
| `coordinacion/` | Vistas de coordinación |
| `admin/` | Vistas de administración |
| `assets/` | Recursos de la interfaz |
| `includes/` | Componentes compartidos |
| `WEB-INF/` | Configuración y recursos de la aplicación Java |
| `ROOT.war` | Aplicación empaquetada para Tomcat |

También incluye páginas de inicio, acceso, calendario, formatos y dashboard.

## Ejecución con Docker

El `Dockerfile` utiliza Tomcat 10 con JDK 17 y despliega el archivo `ROOT.war` incluido.

```bash
git clone https://github.com/Andres76798/GestionTrabajosGrado.git
cd GestionTrabajosGrado
docker build -t gestion-trabajos-grado .
docker run --rm -p 8080:8080 gestion-trabajos-grado
```

Abre `http://localhost:8080/`.

> Esta guía describe el despliegue del WAR existente. La configuración de base de datos y otros servicios debe revisarse antes de ejecutar la aplicación. Los cambios en las páginas del repositorio requieren reconstruir el WAR para verse reflejados en este despliegue.
