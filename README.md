# ⚽ Canchas La 103 — Sistema de Reservas

Aplicación web en PHP + MySQL para gestionar reservas de canchas sintéticas, inventario deportivo, pagos y reportes PDF.

---

## Stack Tecnológico

- **Backend:** PHP 8.1 (sin framework)
- **Base de datos:** MySQL 8
- **PDF:** FPDF (incluido en `fpdf.php`)
- **Frontend:** HTML/CSS/JS puro

---

## Flujo de la Aplicación

```
registro.html / nuevo_registro.html
        ↓
  validar_login.php / procesar_nuevo_usuario.php
        ↓
     index.php  (panel según rol)
      /        \
  Cliente      Admin
  reservar.php  admin_reservas.php
  ver_reserva   admin_inventario.php
                generar_reporte.php (PDF)
```

### Roles
| Rol | Acceso |
|-----|--------|
| `cliente` | Reservar cancha, ver mis reservas |
| `admin` | Todo lo anterior + gestión de pagos, inventario y reportes PDF |

---

## Credenciales por defecto (cambiar en producción)

| Campo | Valor |
|-------|-------|
| Correo | `admin@la103.com` |
| Contraseña | `admin123` |

---

## Variables de Entorno

Crea un archivo `.env` en la raíz (nunca lo subas al repo):

```env
APP_ENV=production
DB_HOST=<host de tu BD>
DB_USER=<usuario>
DB_PASS=<contraseña>
DB_NAME=la_103
```

---

## 🗄️ Configurar la Base de Datos

Ejecuta `schema.sql` en tu servidor MySQL **antes del primer deploy**:

```bash
mysql -u root -p < schema.sql
```

O importa el archivo desde phpMyAdmin / Adminer.

---

## 🚀 Deploy en Render (Recomendado para PHP)

Render ejecuta la app como servidor persistente con Docker — las sesiones PHP funcionan normalmente.

### Pasos

1. **Base de datos MySQL externa**
   Render no ofrece MySQL gestionado. Usa uno de estos servicios gratuitos:
   - [PlanetScale](https://planetscale.com) *(recomendado)*
   - [Railway](https://railway.app)
   - [Aiven](https://aiven.io)

   Crea la BD y ejecuta `schema.sql` ahí.

2. **Subir el código a GitHub**
   ```bash
   git init
   git add .
   git commit -m "deploy: preparar proyecto para producción"
   git remote add origin https://github.com/TU_USUARIO/canchas103.git
   git push -u origin main
   ```

3. **Crear el servicio en Render**
   - Entra a [render.com](https://render.com) → **New → Web Service**
   - Conecta tu repositorio GitHub
   - Render detecta el `Dockerfile` automáticamente
   - **Runtime:** Docker
   - **Plan:** Free

4. **Configurar variables de entorno en Render**
   En el dashboard del servicio → **Environment** → agrega:
   ```
   APP_ENV    = production
   DB_HOST    = <host de PlanetScale/Railway>
   DB_USER    = <usuario>
   DB_PASS    = <contraseña>
   DB_NAME    = la_103
   ```

5. Click en **Deploy** → Render construye la imagen Docker y despliega.

> **URL resultado:** `https://canchas-la-103.onrender.com`

---

## ▲ Deploy en Vercel

Vercel usa PHP como funciones serverless (`vercel-php@0.7.1`).

> ⚠️ **Limitación importante:** Las sesiones PHP son efímeras en serverless.
> Funcionan para uso individual/demo, pero en alta concurrencia distintas
> instancias no comparten sesión. Para producción real, usa Render.

### Pasos

1. **Instalar Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **Base de datos MySQL externa** (igual que en Render — usa PlanetScale o Railway)

3. **Subir a GitHub** (ver paso 2 de Render)

4. **Deploy desde la CLI**
   ```bash
   vercel
   ```
   Sigue el asistente interactivo. Vercel detecta `vercel.json` automáticamente.

5. **Configurar variables de entorno en Vercel**
   ```bash
   vercel env add APP_ENV
   vercel env add DB_HOST
   vercel env add DB_USER
   vercel env add DB_PASS
   vercel env add DB_NAME
   ```
   O configúralas en [vercel.com](https://vercel.com) → tu proyecto → **Settings → Environment Variables**

6. **Re-deploy con variables activas**
   ```bash
   vercel --prod
   ```

> **URL resultado:** `https://canchas103.vercel.app`

---

## 🗂️ Archivos de Configuración Generados

| Archivo | Propósito |
|---------|-----------|
| `conexion.php` | Lee credenciales desde env vars |
| `schema.sql` | Estructura completa de la BD + datos iniciales |
| `.env.example` | Plantilla de variables de entorno |
| `.gitignore` | Excluye `.env` y archivos sensibles del repo |
| `Dockerfile` | Imagen PHP 8.1 + Apache para Render |
| `render.yaml` | Infraestructura como código para Render |
| `vercel.json` | Rutas y runtime PHP para Vercel |
| `composer.json` | Declara la versión de PHP requerida |
| `php.ini` | Configuración PHP para entorno serverless (Vercel) |
| `.htaccess` | Configuración Apache: página de inicio + seguridad |

---

## 🐛 Bugs Corregidos en Esta Versión

| Archivo | Bug | Fix |
|---------|-----|-----|
| `index.php` | Redirigía a `reservar.html` (no existe) | → `registro.html` |
| `ver_reserva.php` | Redirigía a `reservar.html` | → `registro.html` |
| `reservar_cancha.php` | Redirigía a `reservar.html` | → `registro.html` |
| `guardar_usuario.php` | Redirigía a `login.html` (no existe) | → `registro.html` |
| `conexion.php` | Credenciales hardcodeadas | → Variables de entorno |
| `conexion.php` | `display_errors = ON` en producción | → Desactivado en `APP_ENV=production` |

---

## ⚠️ Advertencias de Seguridad (Pendientes)

Estos problemas existen en el código actual y se recomienda corregirlos antes de un deploy de producción real:

1. **SQL Injection** — La mayoría de archivos insertan `$_POST` directamente en SQL. Usar `mysqli_prepare()` con parámetros en todos los archivos.
2. **Contraseñas en texto plano** — `validar_login.php` y `procesar_nuevo_usuario.php` usan contraseñas sin hash. Migrar a `password_hash()` / `password_verify()`.
3. **Sin CSRF** — Los formularios no tienen token anti-CSRF.

Para un proyecto universitario de demostración el deploy funciona. Para producción real, corregir los puntos anteriores.

---

## Desarrollado por

**La 103 — Sistema de Canchas Sintéticas**  
Proyecto académico — Semestre 7
