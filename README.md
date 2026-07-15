# Sistema de Gestión de Ventas

Sistema de gestión de ventas desarrollado para el Obligatorio 2 de **Taller de Tecnologías 1** (Universidad ORT Uruguay), Desafío 18 — *Automatización del proceso de subida de código*.

## Descripción

Aplicación que permite:
- **Autenticación**: registro e inicio de sesión de usuarios.
- **Alta de productos**: un usuario logueado puede agregar productos (nombre, descripción, precio y stock).
- **Venta de productos**: un usuario logueado puede comprar un producto indicando nombre y cantidad.

El repositorio se gestiona con **Git + GitHub** siguiendo el flujo de trabajo **Gitflow** e incluye un script (`commit_semanal.sh`) que automatiza el commit y push semanal del código.

## Estructura de ramas (Gitflow)

| Rama | Propósito |
|------|-----------|
| `main` | Código estable, listo para producción. |
| `develop` | Integración de las funcionalidades terminadas. |
| `feature/autenticacion` | Registro e inicio de sesión de usuarios. |
| `feature/alta-productos` | Alta de productos al sistema. |
| `feature/venta-productos` | Venta de productos. |

## Requisitos

- Python 3.10 o superior
- Git
- (Opcional) Acceso configurado por SSH o token para el push automático.

## Cómo ejecutar

```bash
python3 sistema_ventas.py
```

La primera vez se crea automáticamente la base de datos SQLite `ventas.db`.

## Automatización del upload (script semanal)

El script `commit_semanal.sh` confirma los cambios del repositorio local y los envía a GitHub, mostrando la cantidad de líneas modificadas (o una alerta si no hubo cambios) y registrando esa información en este README.

```bash
./commit_semanal.sh /ruta/al/repo main
```

Para ejecutarlo de forma semanal, ver la configuración de `crontab` en el informe.

## Integrantes

- Facundo Recalt — [Nº estudiante: 378633]
- Santiago Muñoz — [Nº estudiante: 354222]
- Francisco Kehyaian — [Nº estudiante: 390704]

## Registro de commits automáticos
<!-- Esta sección la completa automáticamente el script commit_semanal.sh -->
- 2026-06-30 11:34:07 | Commit semanal: 1 líneas modificadas (+1 / -0).
- 2026-06-30 11:34:24 | ALERTA: no se realizaron commits (sin cambios en el repositorio).
- 2026-06-30 14:17:23 | Commit semanal: 1 líneas modificadas (+1 / -0).
- 2026-06-30 14:17:47 | ALERTA: no se realizaron commits (sin cambios en el repositorio).
- 2026-06-30 14:28:44 | Commit semanal: 1 líneas modificadas (+1 / -0).
- 2026-06-30 14:29:14 | ALERTA: no se realizaron commits (sin cambios en el repositorio).
- 2026-06-30 14:38:53 | Commit semanal: 1 líneas modificadas (+1 / -0).
- 2026-06-30 14:39:17 | ALERTA: no se realizaron commits (sin cambios en el repositorio).
- 2026-06-30 14:56:51 | Commit semanal: 1 líneas modificadas (+1 / -0).
- 2026-06-30 14:57:16 | ALERTA: no se realizaron commits (sin cambios en el repositorio).
- 2026-07-01 10:04:43 | Commit semanal: 1 líneas modificadas (+1 / -0).
- 2026-07-01 10:05:02 | Commit semanal: 2 líneas modificadas (+2 / -0).
- 2026-07-01 10:07:13 | Commit semanal: 3 líneas modificadas (+3 / -0).
- 2026-07-01 10:09:05 | Commit semanal: 1 líneas modificadas (+1 / -0).
- 2026-07-01 10:09:28 | ALERTA: no se realizaron commits (sin cambios en el repositorio).
- 2026-07-01 10:27:11 | Commit semanal: 1 líneas modificadas (+1 / -0).
- 2026-07-01 10:27:30 | ALERTA: no se realizaron commits (sin cambios en el repositorio).
- 2026-07-15 11:50:34 | Commit semanal: 0 líneas modificadas (+0 / -0).
- 2026-07-15 12:08:01 | ALERTA: no se realizaron commits (sin cambios en el repositorio).
- 2026-07-15 12:09:01 | ALERTA: no se realizaron commits (sin cambios en el repositorio).
- 2026-07-15 12:10:01 | ALERTA: no se realizaron commits (sin cambios en el repositorio).
