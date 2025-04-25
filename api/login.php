<?php
session_start();
$errors = [];

// التحقق من الإيميل والباسورد
if (empty($_REQUEST["email"])) $errors["login"] = "empty field";
if (empty($_REQUEST["password"])) $errors["login"] = "empty field";

// إذا كان في أخطاء في المدخلات
if (!empty($errors)) {
    echo json_encode(['success' => false, 'message' => 'emptyfield']);
    exit;
}

require_once("classes.php");

// محاولة تسجيل الدخول
$user = User::login($_REQUEST["email"], md5($_REQUEST["password"]));

// إذا كانت نتيجة التسجيل فارغة أو المستخدم مش موجود
if (empty($user)) {
    echo json_encode(['success' => false, 'message' => 'no user']);
    exit;
}

// إذا كان المستخدم محظور
if ($user->ban == 1) {
    echo json_encode(['success' => false, 'message' => 'ban']);
    exit;
}

// إذا كان كل شيء تمام، نقوم بإرجاع البيانات للمستخدم
$_SESSION["user"] = serialize($user);

// الرد في حالة نجاح الدخول
echo json_encode([
    'success' => true,
    'message' => 'login successful',
    'user' => [
        'id' => $user->id,
        'name' => $user->name,
        'email' => $user->email,
        'role' => $user->role
    ]
]);

?>
