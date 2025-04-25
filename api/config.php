<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

define('DB_HOST', 'localhost');
define('DB_USER', 'secure_user');
define('DB_PASS', 'Strong@Password123');
define('DB_NAME', 'shaghalny');
define('JWT_SECRET', 'your_256_bit_secret');
define('JWT_ALGO', 'HS256');
