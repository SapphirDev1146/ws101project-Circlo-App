<?php
declare(strict_types=1);

/**
 * Circlo - central PDO database connection.
 *
 * Local XAMPP defaults are for development only.
 * Change credentials before deploying to a real server.
 */

$host = getenv('CIRCLO_DB_HOST') ?: '127.0.0.1';
$port = getenv('CIRCLO_DB_PORT') ?: '3306';
$dbname = getenv('CIRCLO_DB_NAME') ?: 'circlo_db';
$username = getenv('CIRCLO_DB_USER') ?: 'root';
$password = getenv('CIRCLO_DB_PASS') !== false ? getenv('CIRCLO_DB_PASS') : ''; // Password sa inyong local root sa database

$dsn = "mysql:host={$host};port={$port};dbname={$dbname};charset=utf8mb4";

$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
    PDO::ATTR_STRINGIFY_FETCHES  => false,
];

try {
    $pdo = new PDO($dsn, $username, $password, $options);
} catch (PDOException $exception) {
    // Do not display connection details or credentials to the browser.
    error_log(
        '[' . date('Y-m-d H:i:s') . '] Circlo database connection failed: ' .
        $exception->getMessage() . PHP_EOL,
        3,
        dirname(__DIR__) . '/logs/error.log'
    );

    http_response_code(500);
    exit('The system is temporarily unavailable. Please try again later.');
}
