<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../users/classes.php';

try {
    // Authentication
    $token = str_replace('Bearer ', '', $_SERVER['HTTP_AUTHORIZATION'] ?? '');
    JWT::decode($token, JWT_SECRET, [JWT_ALGO]);

    $jobs = Admin::get_jobs();

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'jobs' => $jobs
    ]);

} catch (Exception $e) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Unauthorized'
    ]);
}