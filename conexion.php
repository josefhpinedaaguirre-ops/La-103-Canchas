<?php
// 1. Cargar .env solo en local (Railway ya inyecta las variables directamente)
if (file_exists(__DIR__ . '/.env')) {
    $lines = file(__DIR__ . '/.env', FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        if (strpos($line, '=') === false) continue;
        [$key, $value] = explode('=', $line, 2);
        putenv(trim($key) . "=" . trim($value));
    }
}

// 2. Detectar si estamos en producción (Railway suele definir variables de entorno)
$is_production = getenv('RAILWAY_ENVIRONMENT') || getenv('APP_ENV') === 'production';

ini_set('display_errors', $is_production ? 0 : 1);
error_reporting($is_production ? 0 : E_ALL);

// 3. Mapeo de Variables: Railway usa nombres específicos (MYSQLHOST, etc.)
// Usamos los nombres de Railway por defecto, y si no existen, los que tenías o local
$host = getenv('MYSQLHOST') ?: (getenv('DB_HOST') ?: 'localhost');
$user = getenv('MYSQLUSER') ?: (getenv('DB_USER') ?: 'root');
$pass = getenv('MYSQLPASSWORD') ?: (getenv('DB_PASS') ?: '');
$db   = getenv('MYSQLDATABASE') ?: (getenv('DB_NAME') ?: 'la_103');
$port = (int)(getenv('MYSQLPORT') ?: (getenv('DB_PORT') ?: 3306));

$conexion = mysqli_init();

// 4. SSL: Railway no siempre lo exige como Aiven, pero dejamos la lógica por si acaso
if (getenv('DB_SSL') === 'true') {
    mysqli_ssl_set($conexion, NULL, NULL, NULL, NULL, NULL);
    mysqli_options($conexion, MYSQLI_OPT_SSL_VERIFY_SERVER_CERT, false);
}

// 5. Intentar conexión
$connected = mysqli_real_connect(
    $conexion, $host, $user, $pass, $db, $port,
    NULL,
    getenv('DB_SSL') === 'true' ? MYSQLI_CLIENT_SSL : 0
);

if (!$connected) {
    if ($is_production) {
        die("Error de conexión a la base de datos.");
    } else {
        die("Error de conexión: " . mysqli_connect_error());
    }
}

mysqli_set_charset($conexion, 'utf8mb4');
?>
