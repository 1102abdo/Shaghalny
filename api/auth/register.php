<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../users/classes.php';

try {
    $data = json_decode(file_get_contents('php://input'), true);

    // Validation
    $required = ['name', 'email', 'password', 'role'];
    foreach ($required as $field) {
        if (empty($data[$field])) {
            throw new Exception("Missing $field", 400);
        }
    }

    // Sanitize inputs
    $name = htmlspecialchars($data['name']);
    $email = filter_var($data['email'], FILTER_SANITIZE_EMAIL);
    $role = in_array($data['role'], ['worker', 'employer']) ? $data['role'] : 'worker';

    // Register user
    $result = Employers::register(
        $name,
        $email,
        $data['password'], // Password will be hashed in the class
        $role
    );

    if ($result) {
        http_response_code(201);
        echo json_encode(['success' => true, 'message' => 'Registration successful']);
    } else {
        throw new Exception('Registration failed', 500);
    }

} catch (Exception $e) {
    http_response_code($e->getCode() ?: 500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}