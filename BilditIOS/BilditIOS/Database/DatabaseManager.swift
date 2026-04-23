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
        createProyectosTable()
        createPartidasCatalogoTable()
        createProyectoPartidaTable()
        
        insertUsuarioPrueba()
        insertarProyectosPrueba()
        insertarPartidasCatalogo()
        
        asegurarPartidasDeProyecto(proyectoId: 1)
        asegurarPartidasDeProyecto(proyectoId: 2)
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
    
    // MARK: - TABLAS
    
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
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Tabla usuarios creada correctamente")
            } else {
                print("No se pudo crear la tabla usuarios")
            }
        } else {
            print("Error al preparar createUsuariosTable")
        }
        
        sqlite3_finalize(statement)
    }
    
    func createProyectosTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS proyectos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            ubicacion TEXT,
            estado TEXT DEFAULT 'ABIERTO',
            usuario_id INTEGER NOT NULL
        );
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Tabla proyectos creada correctamente")
            } else {
                print("No se pudo crear la tabla proyectos")
            }
        } else {
            print("Error al preparar createProyectosTable")
        }
        
        sqlite3_finalize(statement)
    }
    
    func createPartidasCatalogoTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS partidas_catalogo (
            id INTEGER PRIMARY KEY,
            nombre TEXT NOT NULL UNIQUE
        );
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Tabla partidas_catalogo creada correctamente")
            } else {
                print("No se pudo crear la tabla partidas_catalogo")
            }
        } else {
            print("Error al preparar createPartidasCatalogoTable")
        }
        
        sqlite3_finalize(statement)
    }
    
    func createProyectoPartidaTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS proyecto_partida (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            proyecto_id INTEGER NOT NULL,
            partida_id INTEGER NOT NULL,
            estado TEXT NOT NULL DEFAULT 'NO INICIADA',
            UNIQUE(proyecto_id, partida_id)
        );
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Tabla proyecto_partida creada correctamente")
            } else {
                print("No se pudo crear la tabla proyecto_partida")
            }
        } else {
            print("Error al preparar createProyectoPartidaTable")
        }
        
        sqlite3_finalize(statement)
    }
    
    // MARK: - INSERTS BASE
    
    func insertUsuarioPrueba() {
        let insertSQL = """
        INSERT OR IGNORE INTO usuarios
        (usuario, contrasena, nombre, apellido, correo, telefono, ocupacion)
        VALUES
        ('carcas', 'prueba123', 'Carlos', 'Rivas', 'carlos@bildit.com', '77886754', 'Ingeniero');
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Usuario de prueba insertado o ya existente")
            } else {
                print("No se pudo insertar el usuario de prueba")
            }
        } else {
            print("Error al preparar insertUsuarioPrueba")
        }
        
        sqlite3_finalize(statement)
    }
    
    func insertarProyectosPrueba() {
        let insertSQL = """
        INSERT OR IGNORE INTO proyectos (id, nombre, ubicacion, estado, usuario_id)
        VALUES
        (1, 'Grupo Roble', 'Urbanizacion El Trebol, Pasaje Maquilishuat, #31', 'ABIERTO', 1),
        (2, 'Grupo Carretera', 'Sonsonate', 'CERRADO', 1);
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Proyectos de prueba insertados o ya existentes")
            } else {
                print("No se pudieron insertar los proyectos de prueba")
            }
        } else {
            print("Error al preparar insertarProyectosPrueba")
        }
        
        sqlite3_finalize(statement)
    }
    
    func insertarPartidasCatalogo() {
        let insertSQL = """
        INSERT OR IGNORE INTO partidas_catalogo (id, nombre)
        VALUES
        (1, 'Movimiento de tierras'),
        (2, 'Cimentacion'),
        (3, 'Estructura'),
        (4, 'Albanileria'),
        (5, 'Acabados'),
        (6, 'Instalacion electrica'),
        (7, 'Instalacion sanitaria'),
        (8, 'Urbanizacion'),
        (9, 'Extras');
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Partidas catalogo insertadas")
            } else {
                print("No se pudieron insertar partidas catalogo")
            }
        } else {
            print("Error al preparar insertarPartidasCatalogo")
        }
        
        sqlite3_finalize(statement)
    }
    
    // MARK: - USUARIOS
    
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
    
    func validarLogin(usuario: String, contrasena: String) -> Usuario? {
        let query = """
        SELECT id, usuario, nombre, apellido, correo, telefono, ocupacion
        FROM usuarios
        WHERE usuario = ? AND contrasena = ?;
        """
        
        var statement: OpaquePointer?
        var usuarioEncontrado: Usuario? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(statement, 1, (usuario as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (contrasena as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                
                let usuarioDB = String(cString: sqlite3_column_text(statement, 1))
                let nombreDB = String(cString: sqlite3_column_text(statement, 2))
                let apellidoDB = String(cString: sqlite3_column_text(statement, 3))
                
                let correoDB = sqlite3_column_text(statement, 4) != nil ? String(cString: sqlite3_column_text(statement, 4)) : ""
                let telefonoDB = sqlite3_column_text(statement, 5) != nil ? String(cString: sqlite3_column_text(statement, 5)) : ""
                let ocupacionDB = sqlite3_column_text(statement, 6) != nil ? String(cString: sqlite3_column_text(statement, 6)) : ""
                
                usuarioEncontrado = Usuario(
                    id: id,
                    usuario: usuarioDB,
                    nombre: nombreDB,
                    apellido: apellidoDB,
                    correo: correoDB,
                    telefono: telefonoDB,
                    ocupacion: ocupacionDB
                )
            }
            
        } else {
            print("Error al preparar validarLogin")
        }
        
        sqlite3_finalize(statement)
        return usuarioEncontrado
    }
    
    // MARK: - PROYECTOS
    
    func insertarProyecto(nombre: String, ubicacion: String, usuarioId: Int) -> Bool {
        let insertSQL = """
        INSERT INTO proyectos (nombre, ubicacion, estado, usuario_id)
        VALUES (?, ?, 'ABIERTO', ?);
        """
        
        var statement: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(statement, 1, (nombre as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (ubicacion as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 3, Int32(usuarioId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                let nuevoId = Int(sqlite3_last_insert_rowid(db))
                asegurarPartidasDeProyecto(proyectoId: nuevoId)
                print("Proyecto insertado correctamente")
                resultado = true
            } else {
                print("No se pudo insertar el proyecto")
            }
            
        } else {
            print("Error al preparar insertarProyecto")
        }
        
        sqlite3_finalize(statement)
        return resultado
    }
    
    func actualizarProyecto(id: Int, nombre: String, ubicacion: String) -> Bool {
        let updateSQL = """
        UPDATE proyectos
        SET nombre = ?, ubicacion = ?
        WHERE id = ?;
        """
        
        var statement: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(statement, 1, (nombre as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (ubicacion as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 3, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Proyecto actualizado correctamente")
                resultado = true
            } else {
                print("No se pudo actualizar el proyecto")
            }
            
        } else {
            print("Error al preparar actualizarProyecto")
        }
        
        sqlite3_finalize(statement)
        return resultado
    }
    
    func eliminarProyecto(id: Int) -> Bool {
        let deleteSQL = "DELETE FROM proyectos WHERE id = ?;"
        
        var statement: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, deleteSQL, -1, &statement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(statement, 1, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Proyecto eliminado correctamente")
                resultado = true
            } else {
                print("No se pudo eliminar el proyecto")
            }
            
        } else {
            print("Error al preparar eliminarProyecto")
        }
        
        sqlite3_finalize(statement)
        return resultado
    }
    
    func obtenerProyectosAbiertos(usuarioId: Int) -> [Proyecto] {
        let query = """
        SELECT id, nombre, ubicacion, estado, usuario_id
        FROM proyectos
        WHERE usuario_id = ? AND estado = 'ABIERTO';
        """
        
        var statement: OpaquePointer?
        var proyectos: [Proyecto] = []
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(usuarioId))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let nombre = String(cString: sqlite3_column_text(statement, 1))
                let ubicacion = sqlite3_column_text(statement, 2) != nil ? String(cString: sqlite3_column_text(statement, 2)) : ""
                let estado = String(cString: sqlite3_column_text(statement, 3))
                let usuarioIdDB = Int(sqlite3_column_int(statement, 4))
                
                let proyecto = Proyecto(
                    id: id,
                    nombre: nombre,
                    ubicacion: ubicacion,
                    estado: estado,
                    usuarioId: usuarioIdDB
                )
                
                proyectos.append(proyecto)
            }
        } else {
            print("Error al preparar obtenerProyectosAbiertos")
        }
        
        sqlite3_finalize(statement)
        return proyectos
    }
    
    func obtenerProyectosCerrados(usuarioId: Int) -> [Proyecto] {
        let query = """
        SELECT id, nombre, ubicacion, estado, usuario_id
        FROM proyectos
        WHERE usuario_id = ? AND estado = 'CERRADO';
        """
        
        var statement: OpaquePointer?
        var proyectos: [Proyecto] = []
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(usuarioId))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let nombre = String(cString: sqlite3_column_text(statement, 1))
                let ubicacion = sqlite3_column_text(statement, 2) != nil ? String(cString: sqlite3_column_text(statement, 2)) : ""
                let estado = String(cString: sqlite3_column_text(statement, 3))
                let usuarioIdDB = Int(sqlite3_column_int(statement, 4))
                
                let proyecto = Proyecto(
                    id: id,
                    nombre: nombre,
                    ubicacion: ubicacion,
                    estado: estado,
                    usuarioId: usuarioIdDB
                )
                
                proyectos.append(proyecto)
            }
        } else {
            print("Error al preparar obtenerProyectosCerrados")
        }
        
        sqlite3_finalize(statement)
        return proyectos
    }
    

    
    func asegurarPartidasDeProyecto(proyectoId: Int) {
        let insertSQL = """
        INSERT OR IGNORE INTO proyecto_partida (proyecto_id, partida_id, estado)
        SELECT ?, id, 'NO INICIADA'
        FROM partidas_catalogo;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(proyectoId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Partidas aseguradas para proyecto \(proyectoId)")
            } else {
                print("No se pudieron asegurar partidas del proyecto")
            }
        } else {
            print("Error al preparar asegurarPartidasDeProyecto")
        }
        
        sqlite3_finalize(statement)
    }
    
    func obtenerPartidasDeProyecto(proyectoId: Int) -> [Partida] {
        let query = """
        SELECT pp.partida_id, pc.nombre, pp.estado
        FROM proyecto_partida pp
        INNER JOIN partidas_catalogo pc ON pc.id = pp.partida_id
        WHERE pp.proyecto_id = ?
        ORDER BY pp.partida_id;
        """
        
        var statement: OpaquePointer?
        var partidas: [Partida] = []
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(proyectoId))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let nombre = String(cString: sqlite3_column_text(statement, 1))
                let estado = String(cString: sqlite3_column_text(statement, 2))
                
                let partida = Partida(id: id, nombre: nombre, estado: estado)
                partidas.append(partida)
            }
        } else {
            print("Error al preparar obtenerPartidasDeProyecto")
        }
        
        sqlite3_finalize(statement)
        return partidas
    }
    
    func actualizarEstadoPartida(proyectoId: Int, partidaId: Int, estado: String) -> Bool {
        let updateSQL = """
        UPDATE proyecto_partida
        SET estado = ?
        WHERE proyecto_id = ? AND partida_id = ?;
        """
        
        var statement: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (estado as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(proyectoId))
            sqlite3_bind_int(statement, 3, Int32(partidaId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                resultado = true
            }
        }
        
        sqlite3_finalize(statement)
        return resultado
    }
    
    func todasLasPartidasTerminadas(proyectoId: Int) -> Bool {
        let query = """
        SELECT COUNT(*)
        FROM proyecto_partida
        WHERE proyecto_id = ? AND estado != 'TERMINADA';
        """
        
        var statement: OpaquePointer?
        var todasTerminadas = false
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(proyectoId))
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let pendientes = Int(sqlite3_column_int(statement, 0))
                todasTerminadas = (pendientes == 0)
            }
        } else {
            print("Error al preparar todasLasPartidasTerminadas")
        }
        
        sqlite3_finalize(statement)
        return todasTerminadas
    }
    
    func cerrarProyecto(proyectoId: Int) -> Bool {
        let updateSQL = """
        UPDATE proyectos
        SET estado = 'CERRADO'
        WHERE id = ?;
        """
        
        var statement: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(proyectoId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Proyecto cerrado correctamente")
                resultado = true
            } else {
                print("No se pudo cerrar el proyecto")
            }
        } else {
            print("Error al preparar cerrarProyecto")
        }
        
        sqlite3_finalize(statement)
        return resultado
    }
}
