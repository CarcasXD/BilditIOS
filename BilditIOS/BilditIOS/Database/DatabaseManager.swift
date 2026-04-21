//
//  DatabaseManager.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 20/4/26.
//

import Foundation
import SQLite3

class DatabaseManager {
    
    static let shared = DatabaseManager()
    var db: OpaquePointer?
    
    private init() {
        openDatabase()
        createUsuariosTable()
        insertUsuarioPrueba()
    }
    
    func getDatabasePath() -> String {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsURL = urls[0]
        let dbURL = documentsURL.appendingPathComponent("bildit.sqlite")
        return dbURL.path
    }
    
    func openDatabase() {
        let path = getDatabasePath()
        
        if sqlite3_open(path, &db) == SQLITE_OK {
            print("Base de datos abierta correctamente")
        } else {
            print("Error al abrir la base de datos")
        }
    }
    
    func createUsuariosTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            usuario TEXT NOT NULL UNIQUE,
            contrasena TEXT NOT NULL,
            nombre TEXT NOT NULL,
            apellido TEXT NOT NULL,
            correo TEXT UNIQUE,
            telefono TEXT,
            ocupacion TEXT,
            creado_en DATETIME DEFAULT CURRENT_TIMESTAMP
        );
        """
        
        var createTableStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Tabla usuarios creada correctamente")
            } else {
                print("No se pudo crear la tabla usuarios")
            }
        } else {
            print("Error al preparar createUsuariosTable")
        }
        
        sqlite3_finalize(createTableStatement)
    }
    
    func insertUsuarioPrueba() {
        let insertSQL = """
        INSERT OR IGNORE INTO usuarios
        (usuario, contrasena, nombre, apellido, correo, telefono, ocupacion)
        VALUES
        ('carcas', 'prueba123', 'Carlos', 'Rivas', 'carlos@bildit.com', '77886754', 'Ingeniero');
        """
        
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &insertStatement, nil) == SQLITE_OK {
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Usuario de prueba insertado o ya existente")
            } else {
                print("No se pudo insertar el usuario de prueba")
            }
        } else {
            print("Error al preparar insertUsuarioPrueba")
        }
        
        sqlite3_finalize(insertStatement)
    }
    
    func validarLogin(usuario: String, contrasena: String) -> Bool {
        let query = "SELECT * FROM usuarios WHERE usuario = ? AND contrasena = ?;"
        
        var statement: OpaquePointer?
        var existe = false
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(statement, 1, (usuario as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (contrasena as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                existe = true
            }
            
        } else {
            print("Error al preparar validarLogin")
        }
        
        sqlite3_finalize(statement)
        return existe
    }
    func insertarUsuario(
        usuario: String,
        contrasena: String,
        nombre: String,
        apellido: String,
        correo: String,
        telefono: String,
        ocupacion: String
    ) -> Bool {
        
        let insertSQL = """
        INSERT INTO usuarios
        (usuario, contrasena, nombre, apellido, correo, telefono, ocupacion)
        VALUES (?, ?, ?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(statement, 1, (usuario as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (contrasena as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (nombre as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (apellido as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 5, (correo as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 6, (telefono as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 7, (ocupacion as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Usuario insertado correctamente")
                resultado = true
            } else {
                print("No se pudo insertar el usuario")
            }
            
        } else {
            print("Error al preparar insertarUsuario")
        }
        
        sqlite3_finalize(statement)
        return resultado
    }
}
