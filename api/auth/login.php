<?php
require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../users/classes.php';

try {
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Validate input
    if (empty($data['email']) || empty($data['password'])) {
        throw new Exception('All fields are required', 400);
    }

    $email = filter_var($data['email'], FILTER_SANITIZE_EMAIL);
    $password = $data['password'];

    // Get user securely
    $user = User::login($email, $password);

    if (!$user) {
        throw new Exception('Invalid credentials', 401);
    }

    if ($user->ban) {
        throw new Exception('Account suspended', 403);
    }

    // Generate JWT
    $payload = [
        'iss' => $_SERVER['HTTP_HOST'],
        'iat' => time(),
        'exp' => time() + 3600,
        'sub' => $user->id,
        'role' => $user->role
    ];

    $jwt = JWT::encode($payload, JWT_SECRET, JWT_ALGO);

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'token' => $jwt,
        'user' => [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role
        ]
    ]);

} catch (Exception $e) {
    http_response_code($e->getCode() ?: 500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}