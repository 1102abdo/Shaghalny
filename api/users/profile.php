<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../users/classes.php';

try {
    $token = str_replace('Bearer ', '', $_SERVER['HTTP_AUTHORIZATION'] ?? '');
    $payload = JWT::decode($token, JWT_SECRET, [JWT_ALGO]);

    $user = new User();
    $profile = $user->get_profile($payload->sub);

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'profile' => $profile
    ]);

} catch (Exception $e) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Unauthorized'
    ]);
}