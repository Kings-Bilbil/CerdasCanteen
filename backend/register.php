<?php
require_once __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Metode harus POST']);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);
$nim = strtoupper(trim($input['nim'] ?? ''));
$nama = trim($input['nama'] ?? '');
$email = strtolower(trim($input['email'] ?? ''));
$password = $input['password'] ?? '';

if ($nim === '' || $nama === '' || $email === '' || strlen($password) < 6) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Data tidak lengkap atau password kurang dari 6 karakter.',
    ]);
    exit();
}

// Cek apakah email atau NIM sudah terdaftar
$cek = $pdo->prepare('SELECT id FROM users WHERE email = :email OR nim = :nim LIMIT 1');
$cek->execute([':email' => $email, ':nim' => $nim]);
if ($cek->fetch()) {
    http_response_code(409);
    echo json_encode([
        'success' => false,
        'message' => 'Email atau NIM sudah terdaftar. Silakan login.',
    ]);
    exit();
}

// Hash password menggunakan BCRYPT (aman, tidak menyimpan plaintext)
$passwordHash = password_hash($password, PASSWORD_BCRYPT);

$stmt = $pdo->prepare(
    'INSERT INTO users (nim, nama, email, password_hash) VALUES (:nim, :nama, :email, :hash)'
);
$stmt->execute([
    ':nim' => $nim,
    ':nama' => $nama,
    ':email' => $email,
    ':hash' => $passwordHash,
]);

$userId = (int) $pdo->lastInsertId();
$token = bin2hex(random_bytes(16));

http_response_code(201);
echo json_encode([
    'success' => true,
    'message' => 'Registrasi mahasiswa berhasil.',
    'user' => [
        'id' => $userId,
        'nim' => $nim,
        'nama' => $nama,
        'email' => $email,
        'token' => $token,
    ],
]);