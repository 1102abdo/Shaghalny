<?php
require_once __DIR__ . '/../../config.php';
require_once __DIR__ . '/../users/classes.php';

try {
    // Verify JWT
    $token = str_replace('Bearer ', '', $_SERVER['HTTP_AUTHORIZATION'] ?? '');
    $payload = JWT::decode($token, JWT_SECRET, [JWT_ALGO]);

    // Only admin/employer can delete
    if (!in_array($payload->role, ['admin', 'employer'])) {
        throw new Exception('Unauthorized', 403);
    }

    $data = json_decode(file_get_contents('php://input'), true);
    $job_id = (int)($data['job_id'] ?? 0);

    if ($job_id < 1) {
        throw new Exception('Invalid job ID', 400);
    }

    // Admin can delete any job, employers only their own
    if ($payload->role === 'employer') {
        $admin = new Admin();
        $job = $admin->get_job_by_id($job_id);
        if ($job['user_id'] !== $payload->sub) {
            throw new Exception('Not your job', 403);
        }
    }

    $result = Admin::delete_jobs($job_id);

    if ($result) {
        http_response_code(200);
        echo json_encode(['success' => true]);
    }

} catch (Exception $e) {
    http_response_code($e->getCode() ?: 500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}