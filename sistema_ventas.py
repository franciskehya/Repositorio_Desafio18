#!/usr/bin/env python3
"""
Sistema de Gestión de Ventas - Obligatorio 2, Desafío 18
Taller de Tecnologías 1 - Universidad ORT Uruguay

Aplicación de consola con tres funcionalidades, alineadas a las ramas
feature/ que pide el desafío:

  - feature/autenticacion   -> registro e inicio de sesión de usuarios
  - feature/alta-productos  -> alta de productos (nombre, descripción, precio, stock)
  - feature/venta-productos -> venta de productos (por nombre y cantidad)

Persistencia: SQLite (archivo ventas.db, se crea solo la primera vez).
No usa librerías externas: corre con Python 3.10+ estándar.
"""

import sqlite3
import hashlib
import os
import getpass

DB = "ventas.db"


# Base de datos
def conectar():
    """Devuelve una conexión a la base SQLite con claves foráneas activas."""
    con = sqlite3.connect(DB)
    con.execute("PRAGMA foreign_keys = ON;")
    return con


def inicializar_bd():
    """Crea las tablas si no existen."""
    with conectar() as con:
        con.executescript(
            """
            CREATE TABLE IF NOT EXISTS usuarios (
                id        INTEGER PRIMARY KEY AUTOINCREMENT,
                usuario   TEXT UNIQUE NOT NULL,
                salt      TEXT NOT NULL,
                hash_pass TEXT NOT NULL
            );

            CREATE TABLE IF NOT EXISTS productos (
                id          INTEGER PRIMARY KEY AUTOINCREMENT,
                nombre      TEXT UNIQUE NOT NULL,
                descripcion TEXT,
                precio      REAL NOT NULL CHECK (precio >= 0),
                stock       INTEGER NOT NULL CHECK (stock >= 0)
            );

            CREATE TABLE IF NOT EXISTS ventas (
                id          INTEGER PRIMARY KEY AUTOINCREMENT,
                producto_id INTEGER NOT NULL,
                usuario_id  INTEGER NOT NULL,
                cantidad    INTEGER NOT NULL CHECK (cantidad > 0),
                total       REAL NOT NULL,
                fecha       TEXT NOT NULL DEFAULT (datetime('now','localtime')),
                FOREIGN KEY (producto_id) REFERENCES productos(id),
                FOREIGN KEY (usuario_id)  REFERENCES usuarios(id)
            );
            """
        )

# feature/autenticacion
def _hash(password: str, salt: str) -> str:
    """Hashea la contraseña con SHA-256 usando un salt aleatorio."""
    return hashlib.sha256((salt + password).encode("utf-8")).hexdigest()


def registrar_usuario():
    usuario = input("Nuevo usuario: ").strip()
    if not usuario:
        print("El usuario no puede estar vacío.\n")
        return
    password = getpass.getpass("Contraseña: ")
    if len(password) < 4:
        print("La contraseña debe tener al menos 4 caracteres.\n")
        return

    salt = os.urandom(16).hex()
    try:
        with conectar() as con:
            con.execute(
                "INSERT INTO usuarios (usuario, salt, hash_pass) VALUES (?, ?, ?)",
                (usuario, salt, _hash(password, salt)),
            )
        print(f"Usuario '{usuario}' registrado con éxito.\n")
    except sqlite3.IntegrityError:
        print("Ese nombre de usuario ya existe.\n")


def iniciar_sesion():
    """Devuelve (id, usuario) si las credenciales son válidas, o None."""
    usuario = input("Usuario: ").strip()
    password = getpass.getpass("Contraseña: ")
    with conectar() as con:
        fila = con.execute(
            "SELECT id, salt, hash_pass FROM usuarios WHERE usuario = ?",
            (usuario,),
        ).fetchone()

    if fila and fila[2] == _hash(password, fila[1]):
        print(f"\nBienvenido/a, {usuario}.\n")
        return (fila[0], usuario)
    print("Usuario o contraseña incorrectos.\n")
    return None

# feature/alta-productos
def alta_producto():
    nombre = input("Nombre del producto: ").strip()
    if not nombre:
        print("El nombre es obligatorio.\n")
        return
    descripcion = input("Descripción: ").strip()
    try:
        precio = float(input("Precio: ").replace(",", "."))
        stock = int(input("Stock: "))
        if precio < 0 or stock < 0:
            raise ValueError
    except ValueError:
        print("Precio o stock inválidos.\n")
        return

    try:
        with conectar() as con:
            con.execute(
                "INSERT INTO productos (nombre, descripcion, precio, stock) "
                "VALUES (?, ?, ?, ?)",
                (nombre, descripcion, precio, stock),
            )
        print(f"Producto '{nombre}' agregado.\n")
    except sqlite3.IntegrityError:
        print("Ya existe un producto con ese nombre.\n")


def listar_productos():
    with conectar() as con:
        filas = con.execute(
            "SELECT nombre, descripcion, precio, stock FROM productos ORDER BY nombre"
        ).fetchall()
    if not filas:
        print("No hay productos cargados.\n")
        return
    print("\n--- Productos ---")
    for nombre, desc, precio, stock in filas:
        print(f"  {nombre:<20} ${precio:<10.2f} stock: {stock:<5} | {desc}")
    print()


# feature/venta-productos
def vender_producto(usuario_id: int):
    nombre = input("Nombre del producto a comprar: ").strip()
    try:
        cantidad = int(input("Cantidad: "))
        if cantidad <= 0:
            raise ValueError
    except ValueError:
        print("Cantidad inválida.\n")
        return

    with conectar() as con:
        prod = con.execute(
            "SELECT id, precio, stock FROM productos WHERE nombre = ?", (nombre,)
        ).fetchone()

        if not prod:
            print("Ese producto no existe.\n")
            return
        prod_id, precio, stock = prod
        if cantidad > stock:
            print(f"Stock insuficiente. Disponible: {stock}.\n")
            return

        total = precio * cantidad
        con.execute("UPDATE productos SET stock = stock - ? WHERE id = ?",
                    (cantidad, prod_id))
        con.execute(
            "INSERT INTO ventas (producto_id, usuario_id, cantidad, total) "
            "VALUES (?, ?, ?, ?)",
            (prod_id, usuario_id, cantidad, total),
        )
    print(f"Compra realizada: {cantidad} x {nombre} = ${total:.2f}\n")


# Menús
def menu_principal():
    print("===== Sistema de Gestión de Ventas =====")
    print("1) Iniciar sesión")
    print("2) Registrarse")
    print("0) Salir")
    return input("Opción: ").strip()


def menu_usuario(sesion):
    usuario_id, usuario = sesion
    while True:
        print(f"===== Menú ({usuario}) =====")
        print("1) Listar productos")
        print("2) Alta de producto")
        print("3) Comprar producto")
        print("9) Cerrar sesión")
        opcion = input("Opción: ").strip()
        if opcion == "1":
            listar_productos()
        elif opcion == "2":
            alta_producto()
        elif opcion == "3":
            vender_producto(usuario_id)
        elif opcion == "9":
            print("Sesión cerrada.\n")
            return
        else:
            print("Opción inválida.\n")


def main():
    inicializar_bd()
    while True:
        opcion = menu_principal()
        if opcion == "1":
            sesion = iniciar_sesion()
            if sesion:
                menu_usuario(sesion)
        elif opcion == "2":
            registrar_usuario()
        elif opcion == "0":
            print("¡Hasta luego!")
            break
        else:
            print("Opción inválida.\n")


if __name__ == "__main__":
    main()
