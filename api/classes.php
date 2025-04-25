<?php
require_once __DIR__ . '/config.php';

abstract class User {
    // ... properties ...

    public static function login($email, $password) {
        $cn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
        
        $stmt = $cn->prepare("SELECT * FROM users WHERE email = ?");
        $stmt->bind_param("s", $email);
        $stmt->execute();
        
        $result = $stmt->get_result();
        $user = $result->fetch_assoc();
        
        if (!$user || !password_verify($password, $user['password'])) {
            return false;
        }

        switch ($user['role']) {
            case 'admin':
                return new Admin($user['id'], $user['name'], $user['email']);
            case 'employer':
                return new Employer($user['id'], $user['name'], $user['email']);
            default:
                throw new Exception('Invalid user role');
        }
    }
}

class Employer extends User {
    public static function register($name, $email, $password, $role) {
        $hashedPassword = password_hash($password, PASSWORD_BCRYPT);
        
        $cn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
        $stmt = $cn->prepare("INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("ssss", $name, $email, $hashedPassword, $role);
        
        return $stmt->execute();
    }

    public function store_job($title, $description, $num_workers, $salary, $type, $location, $picture, $user_id) {
        $cn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
        $stmt = $cn->prepare("INSERT INTO jobs (...) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("ssiisssi", $title, $description, $num_workers, $salary, $type, $location, $picture, $user_id);
        
        return $stmt->execute();
    }
}