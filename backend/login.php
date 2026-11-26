<?php
require_once __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Metode harus POST']);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);
$email = strtolower(trim($input['email'] ?? ''));
$password = $input['password'] ?? '';

if ($email === '' || $password === '') {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Email dan password wajib diisi.',
    ]);
    exit();
}

$stmt = $pdo->prepare(
    'SELECT id, nim, nama, email, password_hash FROM users WHERE email = :email LIMIT 1'
);
$stmt->execute([':email' => $email]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password_hash'])) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Email atau password salah.',
    ]);
    exit();
}

$token = bin2hex(random_bytes(16));

echo json_encode([
    'success' => true,
    'message' => 'Login berhasil.',
    'user' => [
        'id' => (int) $user['id'],
        'nim' => $user['nim'],
        'nama' => $user['nama'],
        'email' => $user['email'],
        'token' => $token,
    ],
]);