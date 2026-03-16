-- ============================================================
-- BASE DE DATOS: Canchas La 103
-- Ejecutar este script en el servidor de BD antes del deploy
-- ============================================================

-- NOTA AIVEN: Comenta las dos líneas de abajo si usas Aiven (solo existe "defaultdb").
-- En Aiven ejecuta este script desde el Query Editor mientras estás en "defaultdb".
-- CREATE DATABASE IF NOT EXISTS la_103 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE la_103;

-- -----------------------------------------------------------
-- TABLA: Usuarios
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS Usuarios (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100)  NOT NULL,
    correo      VARCHAR(150)  UNIQUE NOT NULL,
    contrasena  VARCHAR(255)  NOT NULL,
    password    VARCHAR(255)  DEFAULT NULL,
    telefono    VARCHAR(20)   DEFAULT NULL,
    rol         ENUM('admin','cliente') NOT NULL DEFAULT 'cliente',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- TABLA: Canchas
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS Canchas (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    nombre_cancha  VARCHAR(100) NOT NULL,
    estado         ENUM('disponible','mantenimiento') NOT NULL DEFAULT 'disponible'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- TABLA: Implementos
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS Implementos (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    nombre_objeto   VARCHAR(100) NOT NULL,
    cantidad_total  INT          NOT NULL DEFAULT 0,
    estado_objeto   ENUM('bueno','regular','malo') NOT NULL DEFAULT 'bueno'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- TABLA: Reservas
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS Reservas (
    id                   INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario           INT            NOT NULL,
    id_cancha            INT            NOT NULL,
    fecha_reserva        DATE           NOT NULL,
    hora_inicio          TIME           NOT NULL,
    hora_fin             TIME           NOT NULL,
    precio_total_cancha  DECIMAL(10,2)  NOT NULL DEFAULT 0,
    estado_reserva       ENUM('pendiente','confirmada','finalizada') NOT NULL DEFAULT 'pendiente',
    created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (id_cancha)  REFERENCES Canchas(id)  ON DELETE CASCADE,
    UNIQUE KEY uk_horario (id_cancha, fecha_reserva, hora_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- TABLA: Prestamos
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS Prestamos (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva     INT NOT NULL,
    id_implemento  INT NOT NULL,
    cantidad       INT NOT NULL DEFAULT 1,
    FOREIGN KEY (id_reserva)    REFERENCES Reservas(id)    ON DELETE CASCADE,
    FOREIGN KEY (id_implemento) REFERENCES Implementos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- TABLA: Pagos
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS Pagos (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    id_reserva   INT           NOT NULL,
    monto_pagado DECIMAL(10,2) NOT NULL,
    metodo_pago  ENUM('efectivo','nequi','daviplata','transferencia') NOT NULL,
    fecha_pago   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_reserva) REFERENCES Reservas(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------------
-- DATOS INICIALES
-- -----------------------------------------------------------
INSERT IGNORE INTO Canchas (id, nombre_cancha, estado) VALUES
(1, 'Sintética #1 (Fútbol 5)',  'disponible'),
(2, 'Sintética #2 (Fútbol 7)',  'disponible'),
(3, 'Sintética #3 (Fútbol 11)', 'disponible');

INSERT IGNORE INTO Implementos (id, nombre_objeto, cantidad_total, estado_objeto) VALUES
(1, 'Balón Profesional',          5, 'bueno'),
(2, 'Juego de Petos (10 unid.)',  3, 'bueno'),
(3, 'Guantes de Portero',         4, 'bueno'),
(4, 'Tula de Conos',              3, 'bueno');

-- Admin por defecto  →  correo: admin@la103.com | clave: admin123
-- IMPORTANTE: Cambia la contraseña después del primer login en producción.
INSERT IGNORE INTO Usuarios (id, nombre, correo, contrasena, password, telefono, rol) VALUES
(1, 'Administrador', 'admin@la103.com', 'admin123', 'admin123', '3000000000', 'admin');
