<?php
header("Access-Control-Allow-Origin: " . (ENVIRONMENT === 'production' ? 'https://yourdomain.com' : '*'));
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Max-Age: 3600");

// Database configuration
define('DB_HOST', 'localhost');
define('DB_USER', 'secure_user');
define('DB_PASS', 'Strong@Password123');
define('DB_NAME', 'shaghalny');

// JWT Configuration
define('JWT_SECRET', 'your_256_bit_secret_here');
define('JWT_ALGO', 'HS256');

// Environment settings
define('ENVIRONMENT', 'development'); // Change to 'production' when deploying