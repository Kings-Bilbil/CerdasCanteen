-- Database CerdasCanteen (Kelompok 1 - Tugas 11 Autentikasi MySQL)
CREATE DATABASE IF NOT EXISTS cerdascanteen_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE cerdascanteen_db;

-- Tabel pengguna mahasiswa dengan password ter-hash (bcrypt)
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nim VARCHAR(20) NOT NULL UNIQUE,
  nama VARCHAR(100) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabel pesanan (untuk relasi ERD bersama Anggota 2)
CREATE TABLE IF NOT EXISTS orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  kode_pesanan VARCHAR(30) NOT NULL UNIQUE,
  metode_bayar VARCHAR(40) NOT NULL,
  total_item INT NOT NULL,
  total_harga INT NOT NULL,
  status VARCHAR(30) DEFAULT 'Diproses',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_orders_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
);