<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../users/classes.php';

try {
    // Verify JWT
    $token = str_replace('Bearer ', '', $_SERVER['HTTP_AUTHORIZATION'] ?? '');
    $payload = JWT::decode($token, JWT_SECRET, [JWT_ALGO]);
    
    // Only employers can post jobs
    if ($payload->role !== 'employer') {
        throw new Exception('Unauthorized', 403);
    }

    $data = json_decode(file_get_contents('php://input'), true);

    // Validate inputs
    $required = ['title', 'description', 'num_workers', 'salary', 'type', 'location'];
    foreach ($required as $field) {
        if (empty($data[$field])) {
            throw new Exception("Missing $field", 400);
        }
    }

    // Create job
    $employer = new Employers($payload->sub);
    $result = $employer->store_job(
        htmlspecialchars($data['title']),
        htmlspecialchars($data['description']),
        (int)$data['num_workers'],
        (float)$data['salary'],
        htmlspecialchars($data['type']),
        htmlspecialchars($data['location']),
        $data['picture'] ?? null,
        $payload->sub // user_id from JWT
    );

    if ($result) {
        http_response_code(201);
        echo json_encode(['success' => true, 'message' => 'Job posted']);
    }

} catch (Exception $e) {
    http_response_code($e->getCode() ?: 500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}