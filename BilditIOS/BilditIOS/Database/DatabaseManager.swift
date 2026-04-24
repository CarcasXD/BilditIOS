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
            createDescripcionesCatalogoTable()
            createProyectoDescripcionTable()
            createDescripcionRecursoTable()
            
            insertUsuarioPrueba()
            insertarProyectosPrueba()
            insertarPartidasCatalogo()
            insertarDescripcionesCatalogo()
            
            asegurarPartidasDeProyecto(proyectoId: 1)
            asegurarPartidasDeProyecto(proyectoId: 2)
            asegurarPartidasDeProyecto(proyectoId: 3)
            asegurarPartidasDeProyecto(proyectoId: 4)

            poblarProyectoListoParaCerrar(proyectoId: 3)
            poblarProyectoConExtrasPendientes(proyectoId: 4)
    }
    
    func getDatabasePath() -> String {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsURL = urls[0]
        let dbURL = documentsURL.appendingPathComponent("bildit_v4.sqlite")
        print("Ruta BD: \(dbURL.path)")
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
            usuario_id INTEGER NOT NULL,
            fecha_cierre TEXT DEFAULT ''
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
        INSERT OR IGNORE INTO proyectos (id, nombre, ubicacion, estado, usuario_id, fecha_cierre)
        VALUES
        (1, 'Grupo Roble', 'Urbanizacion El Trebol, Pasaje Maquilishuat, #31', 'ABIERTO', 1, ''),
        (2, 'Constructora Sinai', 'Quezaltepeque', 'CERRADO', 1, '26/04/2024'),
        (3, 'Residencial Las Flores', 'Santa Ana', 'ABIERTO', 1, ''),
        (4, 'Torre Empresarial Nova', 'San Salvador', 'ABIERTO', 1, '');
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
        INSERT INTO proyectos (nombre, ubicacion, estado, usuario_id, fecha_cierre)
        VALUES (?, ?, 'ABIERTO', ?, '');
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
        SELECT id, nombre, ubicacion, estado, usuario_id, fecha_cierre
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
                let fechaCierre = sqlite3_column_text(statement, 5) != nil ? String(cString: sqlite3_column_text(statement, 5)) : ""
                
                let proyecto = Proyecto(
                    id: id,
                    nombre: nombre,
                    ubicacion: ubicacion,
                    estado: estado,
                    usuarioId: usuarioIdDB,
                    fechaCierre: fechaCierre
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
        SELECT id, nombre, ubicacion, estado, usuario_id, fecha_cierre
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
                let fechaCierre = sqlite3_column_text(statement, 5) != nil ? String(cString: sqlite3_column_text(statement, 5)) : ""
                
                let proyecto = Proyecto(
                    id: id,
                    nombre: nombre,
                    ubicacion: ubicacion,
                    estado: estado,
                    usuarioId: usuarioIdDB,
                    fechaCierre: fechaCierre
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
        let fechaActual = fechaActualTexto()
        
        let updateSQL = """
        UPDATE proyectos
        SET estado = 'CERRADO', fecha_cierre = ?
        WHERE id = ?;
        """
        
        var statement: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (fechaActual as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(proyectoId))
            
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
    
    func fechaActualTexto() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date())
    }

    func obtenerTotalProyecto(proyectoId: Int) -> Double {
        let query = """
        SELECT IFNULL(SUM(subtotal), 0)
        FROM proyecto_descripcion
        WHERE proyecto_id = ?;
        """
        
        var statement: OpaquePointer?
        var total: Double = 0
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(proyectoId))
            
            if sqlite3_step(statement) == SQLITE_ROW {
                total = sqlite3_column_double(statement, 0)
            }
        }
        
        sqlite3_finalize(statement)
        return total
    }

    func obtenerProyectosCerradosResumen(usuarioId: Int) -> [ProyectoCerrado] {
        let proyectos = obtenerProyectosCerrados(usuarioId: usuarioId)
        var lista: [ProyectoCerrado] = []
        
        for proyecto in proyectos {
            let total = obtenerTotalProyecto(proyectoId: proyecto.id)
            
            lista.append(
                ProyectoCerrado(
                    id: proyecto.id,
                    nombre: proyecto.nombre,
                    ubicacion: proyecto.ubicacion,
                    fechaCierre: proyecto.fechaCierre,
                    total: total
                )
            )
        }
        
        return lista
    }

    func obtenerPartidasCerradasDetalle(proyectoId: Int) -> [PartidaCerradaDetalle] {
        let partidas = obtenerPartidasDeProyecto(proyectoId: proyectoId)
        var resultado: [PartidaCerradaDetalle] = []
        
        for partida in partidas {
            let descripciones = obtenerDescripcionesDePartida(proyectoId: proyectoId, partidaId: partida.id)
            let total = descripciones.reduce(0) { $0 + $1.subtotal }
            
            resultado.append(
                PartidaCerradaDetalle(
                    id: partida.id,
                    nombre: partida.nombre,
                    total: total,
                    descripciones: descripciones
                )
            )
        }
        
        return resultado
    }
    
    func createDescripcionesCatalogoTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS descripciones_catalogo (
            id INTEGER PRIMARY KEY,
            partida_id INTEGER NOT NULL,
            nombre TEXT NOT NULL
        );
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Tabla descripciones_catalogo creada correctamente")
            } else {
                print("No se pudo crear la tabla descripciones_catalogo")
            }
        } else {
            print("Error al preparar createDescripcionesCatalogoTable")
        }
        
        sqlite3_finalize(statement)
    }

    func createProyectoDescripcionTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS proyecto_descripcion (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            proyecto_id INTEGER NOT NULL,
            partida_id INTEGER NOT NULL,
            descripcion_id INTEGER NOT NULL,
            subtotal REAL NOT NULL DEFAULT 0,
            cantidad_total REAL NOT NULL DEFAULT 0,
            UNIQUE(proyecto_id, partida_id, descripcion_id)
        );
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Tabla proyecto_descripcion creada correctamente")
            } else {
                print("No se pudo crear la tabla proyecto_descripcion")
            }
        } else {
            print("Error al preparar createProyectoDescripcionTable")
        }
        
        sqlite3_finalize(statement)
    }
    
    func insertarDescripcionesCatalogo() {
        let insertSQL = """
        INSERT OR IGNORE INTO descripciones_catalogo (id, partida_id, nombre)
        VALUES
        (101, 1, 'Limpieza del terreno'),
        (102, 1, 'Trazos y niveles'),
        (103, 1, 'Excavaciones'),
        (104, 1, 'Rellenos'),
        (199, 1, 'Extras'),

        (201, 2, 'Zapata aislada'),
        (202, 2, 'Vigas de fundacion'),
        (203, 2, 'Dados y anclajes'),
        (204, 2, 'Losa de cimentacion'),
        (299, 2, 'Extras'),

        (301, 3, 'Columnas'),
        (302, 3, 'Vigas'),
        (303, 3, 'Losas'),
        (304, 3, 'Escaleras'),
        (399, 3, 'Extras'),

        (401, 4, 'Muros'),
        (402, 4, 'Tabiques'),
        (403, 4, 'Mamposteria'),
        (404, 4, 'Repellos'),
        (499, 4, 'Extras'),

        (501, 5, 'Pisos'),
        (502, 5, 'Pintura'),
        (503, 5, 'Puertas'),
        (504, 5, 'Ventanas'),
        (599, 5, 'Extras'),

        (601, 6, 'Canalizacion'),
        (602, 6, 'Cableado'),
        (603, 6, 'Tableros'),
        (604, 6, 'Luminarias'),
        (699, 6, 'Extras'),

        (701, 7, 'Tuberias'),
        (702, 7, 'Lavabos'),
        (703, 7, 'WC'),
        (704, 7, 'Pruebas'),
        (799, 7, 'Extras'),

        (801, 8, 'Aceras'),
        (802, 8, 'Jardineria'),
        (803, 8, 'Muros'),
        (899, 8, 'Extras'),

        (901, 9, 'Extras');
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Descripciones catalogo insertadas")
            } else {
                print("No se pudieron insertar descripciones catalogo")
            }
        } else {
            print("Error al preparar insertarDescripcionesCatalogo")
        }
        
        sqlite3_finalize(statement)
    }
    
    func asegurarDescripciones(proyectoId: Int, partidaId: Int) {
        let insertSQL = """
        INSERT OR IGNORE INTO proyecto_descripcion (proyecto_id, partida_id, descripcion_id, subtotal)
        SELECT ?, ?, id, 0
        FROM descripciones_catalogo
        WHERE partida_id = ?;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(proyectoId))
            sqlite3_bind_int(statement, 2, Int32(partidaId))
            sqlite3_bind_int(statement, 3, Int32(partidaId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Descripciones aseguradas para proyecto \(proyectoId), partida \(partidaId)")
            } else {
                print("No se pudieron asegurar descripciones")
            }
        } else {
            print("Error al preparar asegurarDescripciones")
        }
        
        sqlite3_finalize(statement)
    }
    
    func obtenerDescripcionesDePartida(proyectoId: Int, partidaId: Int) -> [Descripcion] {
        let query = """
        SELECT dc.id, dc.nombre, pd.subtotal
        FROM proyecto_descripcion pd
        INNER JOIN descripciones_catalogo dc ON dc.id = pd.descripcion_id
        WHERE pd.proyecto_id = ? AND pd.partida_id = ?
        ORDER BY dc.id;
        """
        
        var statement: OpaquePointer?
        var descripciones: [Descripcion] = []
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(proyectoId))
            sqlite3_bind_int(statement, 2, Int32(partidaId))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let nombre = String(cString: sqlite3_column_text(statement, 1))
                let subtotal = sqlite3_column_double(statement, 2)
                
                let descripcion = Descripcion(
                    id: id,
                    nombre: nombre,
                    subtotal: subtotal
                )
                
                descripciones.append(descripcion)
            }
        } else {
            print("Error al preparar obtenerDescripcionesDePartida")
        }
        
        sqlite3_finalize(statement)
        return descripciones
    }
    
    func obtenerTotalPartida(proyectoId: Int, partidaId: Int) -> Double {
        let query = """
        SELECT IFNULL(SUM(subtotal), 0)
        FROM proyecto_descripcion
        WHERE proyecto_id = ? AND partida_id = ?;
        """
        
        var statement: OpaquePointer?
        var total: Double = 0
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(proyectoId))
            sqlite3_bind_int(statement, 2, Int32(partidaId))
            
            if sqlite3_step(statement) == SQLITE_ROW {
                total = sqlite3_column_double(statement, 0)
            }
        } else {
            print("Error al preparar obtenerTotalPartida")
        }
        
        sqlite3_finalize(statement)
        return total
    }
    
    func partidaCompleta(proyectoId: Int, partidaId: Int) -> Bool {
        let query = """
        SELECT COUNT(*)
        FROM proyecto_descripcion
        WHERE proyecto_id = ? AND partida_id = ?
        AND NOT (cantidad_total > 0 AND subtotal > 0);
        """
        
        var statement: OpaquePointer?
        var completa = false
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(proyectoId))
            sqlite3_bind_int(statement, 2, Int32(partidaId))
            
            if sqlite3_step(statement) == SQLITE_ROW {
                let pendientes = Int(sqlite3_column_int(statement, 0))
                completa = (pendientes == 0)
            }
        }
        
        sqlite3_finalize(statement)
        return completa
    }

    func cerrarPartida(proyectoId: Int, partidaId: Int) -> Bool {
        if !partidaCompleta(proyectoId: proyectoId, partidaId: partidaId) {
            return false
        }
        
        let updateSQL = """
        UPDATE proyecto_partida
        SET estado = 'TERMINADA'
        WHERE proyecto_id = ? AND partida_id = ?;
        """
        
        var statement: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(proyectoId))
            sqlite3_bind_int(statement, 2, Int32(partidaId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                resultado = true
            }
        }
        
        sqlite3_finalize(statement)
        return resultado
    }
    
    func createDescripcionRecursoTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS descripcion_recurso (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            proyecto_descripcion_id INTEGER NOT NULL,
            nombre_recurso TEXT NOT NULL,
            unidad TEXT NOT NULL,
            cant_por_unidad REAL NOT NULL,
            pu REAL NOT NULL
        );
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Tabla descripcion_recurso creada correctamente")
            } else {
                print("No se pudo crear la tabla descripcion_recurso")
            }
        } else {
            print("Error al preparar createDescripcionRecursoTable")
        }
        
        sqlite3_finalize(statement)
    }
    
    func obtenerProyectoDescripcionId(proyectoId: Int, partidaId: Int, descripcionId: Int) -> Int? {
        let query = """
        SELECT id
        FROM proyecto_descripcion
        WHERE proyecto_id = ? AND partida_id = ? AND descripcion_id = ?;
        """
        
        var statement: OpaquePointer?
        var resultado: Int? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(proyectoId))
            sqlite3_bind_int(statement, 2, Int32(partidaId))
            sqlite3_bind_int(statement, 3, Int32(descripcionId))
            
            if sqlite3_step(statement) == SQLITE_ROW {
                resultado = Int(sqlite3_column_int(statement, 0))
            }
        }
        
        sqlite3_finalize(statement)
        return resultado
    }
    
    func insertarRecurso(
        proyectoId: Int,
        partidaId: Int,
        descripcionId: Int,
        nombreRecurso: String,
        unidad: String,
        cantidadPorUnidad: Double,
        precioUnitario: Double
    ) -> Bool {
        
        guard let proyectoDescripcionId = obtenerProyectoDescripcionId(
            proyectoId: proyectoId,
            partidaId: partidaId,
            descripcionId: descripcionId
        ) else {
            print("No se encontró proyecto_descripcion_id")
            return false
        }
        
        let insertSQL = """
        INSERT INTO descripcion_recurso
        (proyecto_descripcion_id, nombre_recurso, unidad, cant_por_unidad, pu)
        VALUES (?, ?, ?, ?, ?);
        """
        
        var statement: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(proyectoDescripcionId))
            sqlite3_bind_text(statement, 2, (nombreRecurso as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (unidad as NSString).utf8String, -1, nil)
            sqlite3_bind_double(statement, 4, cantidadPorUnidad)
            sqlite3_bind_double(statement, 5, precioUnitario)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                resultado = true
            }
        }
        
        sqlite3_finalize(statement)
        
        if resultado {
            recalcularSubtotalDescripcion(proyectoId: proyectoId, partidaId: partidaId, descripcionId: descripcionId)
            recalcularEstadoPartida(proyectoId: proyectoId, partidaId: partidaId)
        }
        
        return resultado
    }
    
    func obtenerRecursos(proyectoId: Int, partidaId: Int, descripcionId: Int) -> [Recurso] {
        let query = """
        SELECT dr.id, dr.nombre_recurso, dr.unidad, dr.cant_por_unidad, dr.pu
        FROM descripcion_recurso dr
        INNER JOIN proyecto_descripcion pd ON pd.id = dr.proyecto_descripcion_id
        WHERE pd.proyecto_id = ? AND pd.partida_id = ? AND pd.descripcion_id = ?
        ORDER BY dr.id;
        """
        
        var statement: OpaquePointer?
        var recursos: [Recurso] = []
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(proyectoId))
            sqlite3_bind_int(statement, 2, Int32(partidaId))
            sqlite3_bind_int(statement, 3, Int32(descripcionId))
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let nombre = String(cString: sqlite3_column_text(statement, 1))
                let unidad = String(cString: sqlite3_column_text(statement, 2))
                let cantidad = sqlite3_column_double(statement, 3)
                let precio = sqlite3_column_double(statement, 4)
                
                recursos.append(
                    Recurso(
                        id: id,
                        nombreRecurso: nombre,
                        unidad: unidad,
                        cantidadPorUnidad: cantidad,
                        precioUnitario: precio
                    )
                )
            }
        }
        
        sqlite3_finalize(statement)
        return recursos
    }
    
    func actualizarCantidadTotalDescripcion(
        proyectoId: Int,
        partidaId: Int,
        descripcionId: Int,
        cantidadTotal: Double
    ) -> Bool {
        
        let updateSQL = """
        UPDATE proyecto_descripcion
        SET cantidad_total = ?
        WHERE proyecto_id = ? AND partida_id = ? AND descripcion_id = ?;
        """
        
        var statement: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_double(statement, 1, cantidadTotal)
            sqlite3_bind_int(statement, 2, Int32(proyectoId))
            sqlite3_bind_int(statement, 3, Int32(partidaId))
            sqlite3_bind_int(statement, 4, Int32(descripcionId))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                resultado = true
            }
        }
        
        sqlite3_finalize(statement)
        
        if resultado {
            recalcularSubtotalDescripcion(proyectoId: proyectoId, partidaId: partidaId, descripcionId: descripcionId)
            recalcularEstadoPartida(proyectoId: proyectoId, partidaId: partidaId)
        }
        
        return resultado
    }
    
    func obtenerCantidadTotalDescripcion(proyectoId: Int, partidaId: Int, descripcionId: Int) -> Double {
        let query = """
        SELECT cantidad_total
        FROM proyecto_descripcion
        WHERE proyecto_id = ? AND partida_id = ? AND descripcion_id = ?;
        """
        
        var statement: OpaquePointer?
        var cantidad: Double = 0
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(proyectoId))
            sqlite3_bind_int(statement, 2, Int32(partidaId))
            sqlite3_bind_int(statement, 3, Int32(descripcionId))
            
            if sqlite3_step(statement) == SQLITE_ROW {
                cantidad = sqlite3_column_double(statement, 0)
            }
        }
        
        sqlite3_finalize(statement)
        return cantidad
    }

    func obtenerTotalPorUnidadDescripcion(proyectoId: Int, partidaId: Int, descripcionId: Int) -> Double {
        let query = """
        SELECT IFNULL(SUM(dr.cant_por_unidad * dr.pu), 0)
        FROM descripcion_recurso dr
        INNER JOIN proyecto_descripcion pd ON pd.id = dr.proyecto_descripcion_id
        WHERE pd.proyecto_id = ? AND pd.partida_id = ? AND pd.descripcion_id = ?;
        """
        
        var statement: OpaquePointer?
        var total: Double = 0
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(proyectoId))
            sqlite3_bind_int(statement, 2, Int32(partidaId))
            sqlite3_bind_int(statement, 3, Int32(descripcionId))
            
            if sqlite3_step(statement) == SQLITE_ROW {
                total = sqlite3_column_double(statement, 0)
            }
        }
        
        sqlite3_finalize(statement)
        return total
    }

    func recalcularSubtotalDescripcion(proyectoId: Int, partidaId: Int, descripcionId: Int) {
        let cantidadTotal = obtenerCantidadTotalDescripcion(
            proyectoId: proyectoId,
            partidaId: partidaId,
            descripcionId: descripcionId
        )
        
        let totalPorUnidad = obtenerTotalPorUnidadDescripcion(
            proyectoId: proyectoId,
            partidaId: partidaId,
            descripcionId: descripcionId
        )
        
        let subtotal = cantidadTotal * totalPorUnidad
        
        let updateSQL = """
        UPDATE proyecto_descripcion
        SET subtotal = ?
        WHERE proyecto_id = ? AND partida_id = ? AND descripcion_id = ?;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_double(statement, 1, subtotal)
            sqlite3_bind_int(statement, 2, Int32(proyectoId))
            sqlite3_bind_int(statement, 3, Int32(partidaId))
            sqlite3_bind_int(statement, 4, Int32(descripcionId))
            
            _ = sqlite3_step(statement)
        }
        
        sqlite3_finalize(statement)
    }
    
    func recalcularEstadoPartida(proyectoId: Int, partidaId: Int) {
        let totalQuery = """
        SELECT COUNT(*)
        FROM proyecto_descripcion
        WHERE proyecto_id = ? AND partida_id = ?;
        """
        
        let iniciadasQuery = """
        SELECT COUNT(*)
        FROM proyecto_descripcion pd
        WHERE pd.proyecto_id = ? AND pd.partida_id = ?
        AND (
            pd.cantidad_total > 0
            OR EXISTS (
                SELECT 1
                FROM descripcion_recurso dr
                WHERE dr.proyecto_descripcion_id = pd.id
            )
        );
        """
        
        let completasQuery = """
        SELECT COUNT(*)
        FROM proyecto_descripcion
        WHERE proyecto_id = ? AND partida_id = ?
        AND cantidad_total > 0
        AND subtotal > 0;
        """
        
        var total = 0
        var iniciadas = 0
        var completas = 0
        
        total = ejecutarCount(query: totalQuery, proyectoId: proyectoId, partidaId: partidaId)
        iniciadas = ejecutarCount(query: iniciadasQuery, proyectoId: proyectoId, partidaId: partidaId)
        completas = ejecutarCount(query: completasQuery, proyectoId: proyectoId, partidaId: partidaId)
        
        var nuevoEstado = "NO INICIADA"
        
        if iniciadas == 0 {
            nuevoEstado = "NO INICIADA"
        } else if completas == total && total > 0 {
            nuevoEstado = "TERMINADA"
        } else {
            nuevoEstado = "EN PROCESO"
        }
        
        let updateSQL = """
        UPDATE proyecto_partida
        SET estado = ?
        WHERE proyecto_id = ? AND partida_id = ?;
        """
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (nuevoEstado as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(proyectoId))
            sqlite3_bind_int(statement, 3, Int32(partidaId))
            
            _ = sqlite3_step(statement)
        }
        
        sqlite3_finalize(statement)
    }
    
    func ejecutarCount(query: String, proyectoId: Int, partidaId: Int) -> Int {
        var statement: OpaquePointer?
        var valor = 0
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(proyectoId))
            sqlite3_bind_int(statement, 2, Int32(partidaId))
            
            if sqlite3_step(statement) == SQLITE_ROW {
                valor = Int(sqlite3_column_int(statement, 0))
            }
        }
        
        sqlite3_finalize(statement)
        return valor
    }
    
    func proyectoYaTieneRecursos(proyectoId: Int) -> Bool {
        let query = """
        SELECT COUNT(*)
        FROM descripcion_recurso dr
        INNER JOIN proyecto_descripcion pd ON pd.id = dr.proyecto_descripcion_id
        WHERE pd.proyecto_id = ?;
        """
        
        var statement: OpaquePointer?
        var cantidad = 0
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(proyectoId))
            
            if sqlite3_step(statement) == SQLITE_ROW {
                cantidad = Int(sqlite3_column_int(statement, 0))
            }
        }
        
        sqlite3_finalize(statement)
        return cantidad > 0
    }
    
    func asegurarTodasLasDescripcionesDeProyecto(proyectoId: Int) {
        let partidas = obtenerPartidasDeProyecto(proyectoId: proyectoId)
        
        for partida in partidas {
            asegurarDescripciones(proyectoId: proyectoId, partidaId: partida.id)
        }
    }
    
    func llenarDescripcionDemo(
        proyectoId: Int,
        partidaId: Int,
        descripcionId: Int,
        cantidadTotal: Double,
        recurso: String,
        unidad: String,
        cantidadPorUnidad: Double,
        precioUnitario: Double
    ) {
        let _ = insertarRecurso(
            proyectoId: proyectoId,
            partidaId: partidaId,
            descripcionId: descripcionId,
            nombreRecurso: recurso,
            unidad: unidad,
            cantidadPorUnidad: cantidadPorUnidad,
            precioUnitario: precioUnitario
        )
        
        let _ = actualizarCantidadTotalDescripcion(
            proyectoId: proyectoId,
            partidaId: partidaId,
            descripcionId: descripcionId,
            cantidadTotal: cantidadTotal
        )
    }
    
    func poblarProyectoListoParaCerrar(proyectoId: Int) {
        if proyectoYaTieneRecursos(proyectoId: proyectoId) { return }
        
        asegurarPartidasDeProyecto(proyectoId: proyectoId)
        asegurarTodasLasDescripcionesDeProyecto(proyectoId: proyectoId)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 1, descripcionId: 101, cantidadTotal: 10, recurso: "Mano de obra", unidad: "jornal", cantidadPorUnidad: 1, precioUnitario: 12)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 1, descripcionId: 102, cantidadTotal: 8, recurso: "Cal", unidad: "bolsa", cantidadPorUnidad: 1, precioUnitario: 6)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 1, descripcionId: 103, cantidadTotal: 12, recurso: "Excavadora", unidad: "hora", cantidadPorUnidad: 1, precioUnitario: 20)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 1, descripcionId: 104, cantidadTotal: 9, recurso: "Material selecto", unidad: "m3", cantidadPorUnidad: 1, precioUnitario: 8)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 1, descripcionId: 199, cantidadTotal: 2, recurso: "Extras tierras", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 15)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 2, descripcionId: 201, cantidadTotal: 5, recurso: "Concreto", unidad: "m3", cantidadPorUnidad: 1, precioUnitario: 90)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 2, descripcionId: 202, cantidadTotal: 4, recurso: "Hierro", unidad: "qq", cantidadPorUnidad: 1, precioUnitario: 35)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 2, descripcionId: 203, cantidadTotal: 3, recurso: "Anclajes", unidad: "set", cantidadPorUnidad: 1, precioUnitario: 22)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 2, descripcionId: 204, cantidadTotal: 6, recurso: "Losa base", unidad: "m2", cantidadPorUnidad: 1, precioUnitario: 40)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 2, descripcionId: 299, cantidadTotal: 1, recurso: "Extras cimentacion", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 18)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 3, descripcionId: 301, cantidadTotal: 7, recurso: "Columnas", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 55)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 3, descripcionId: 302, cantidadTotal: 7, recurso: "Vigas", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 45)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 3, descripcionId: 303, cantidadTotal: 7, recurso: "Losas", unidad: "m2", cantidadPorUnidad: 1, precioUnitario: 35)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 3, descripcionId: 304, cantidadTotal: 2, recurso: "Escaleras", unidad: "tramo", cantidadPorUnidad: 1, precioUnitario: 80)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 3, descripcionId: 399, cantidadTotal: 1, recurso: "Extras estructura", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 25)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 4, descripcionId: 401, cantidadTotal: 10, recurso: "Bloques", unidad: "ciento", cantidadPorUnidad: 1, precioUnitario: 30)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 4, descripcionId: 402, cantidadTotal: 8, recurso: "Tabiques", unidad: "ciento", cantidadPorUnidad: 1, precioUnitario: 28)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 4, descripcionId: 403, cantidadTotal: 6, recurso: "Mortero", unidad: "m3", cantidadPorUnidad: 1, precioUnitario: 20)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 4, descripcionId: 404, cantidadTotal: 5, recurso: "Repello", unidad: "m2", cantidadPorUnidad: 1, precioUnitario: 10)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 4, descripcionId: 499, cantidadTotal: 1, recurso: "Extras albanileria", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 12)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 5, descripcionId: 501, cantidadTotal: 3, recurso: "Ceramica", unidad: "caja", cantidadPorUnidad: 1, precioUnitario: 15)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 5, descripcionId: 502, cantidadTotal: 2, recurso: "Pintura", unidad: "galon", cantidadPorUnidad: 1, precioUnitario: 20)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 5, descripcionId: 503, cantidadTotal: 2, recurso: "Puertas", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 80)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 5, descripcionId: 504, cantidadTotal: 2, recurso: "Ventanas", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 60)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 5, descripcionId: 599, cantidadTotal: 1, recurso: "Extras acabados", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 25)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 6, descripcionId: 601, cantidadTotal: 10, recurso: "Tuberia EMT", unidad: "barra", cantidadPorUnidad: 1, precioUnitario: 7)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 6, descripcionId: 602, cantidadTotal: 8, recurso: "Cable", unidad: "rollo", cantidadPorUnidad: 1, precioUnitario: 18)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 6, descripcionId: 603, cantidadTotal: 2, recurso: "Tableros", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 120)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 6, descripcionId: 604, cantidadTotal: 10, recurso: "Luminarias", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 14)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 6, descripcionId: 699, cantidadTotal: 1, recurso: "Extras electricas", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 18)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 7, descripcionId: 701, cantidadTotal: 10, recurso: "PVC", unidad: "barra", cantidadPorUnidad: 1, precioUnitario: 8)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 7, descripcionId: 702, cantidadTotal: 4, recurso: "Lavabos", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 45)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 7, descripcionId: 703, cantidadTotal: 4, recurso: "WC", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 65)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 7, descripcionId: 704, cantidadTotal: 2, recurso: "Pruebas", unidad: "serv", cantidadPorUnidad: 1, precioUnitario: 30)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 7, descripcionId: 799, cantidadTotal: 1, recurso: "Extras sanitarias", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 16)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 8, descripcionId: 801, cantidadTotal: 6, recurso: "Adoquin", unidad: "m2", cantidadPorUnidad: 1, precioUnitario: 18)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 8, descripcionId: 802, cantidadTotal: 5, recurso: "Jardineria", unidad: "m2", cantidadPorUnidad: 1, precioUnitario: 12)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 8, descripcionId: 803, cantidadTotal: 3, recurso: "Muros", unidad: "m2", cantidadPorUnidad: 1, precioUnitario: 25)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 8, descripcionId: 899, cantidadTotal: 1, recurso: "Extras urbanizacion", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 20)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 9, descripcionId: 901, cantidadTotal: 1, recurso: "Extras generales", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 50)
    }
    
    func poblarProyectoConExtrasPendientes(proyectoId: Int) {
        if proyectoYaTieneRecursos(proyectoId: proyectoId) { return }
        
        asegurarPartidasDeProyecto(proyectoId: proyectoId)
        asegurarTodasLasDescripcionesDeProyecto(proyectoId: proyectoId)
        
        // Se llenan TODAS menos las de Extras
        
        // Partida 1
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 1, descripcionId: 101, cantidadTotal: 10, recurso: "Mano de obra", unidad: "jornal", cantidadPorUnidad: 1, precioUnitario: 12)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 1, descripcionId: 102, cantidadTotal: 8, recurso: "Cal", unidad: "bolsa", cantidadPorUnidad: 1, precioUnitario: 6)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 1, descripcionId: 103, cantidadTotal: 12, recurso: "Excavadora", unidad: "hora", cantidadPorUnidad: 1, precioUnitario: 20)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 1, descripcionId: 104, cantidadTotal: 9, recurso: "Material selecto", unidad: "m3", cantidadPorUnidad: 1, precioUnitario: 8)
        
        // Partida 2
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 2, descripcionId: 201, cantidadTotal: 5, recurso: "Concreto", unidad: "m3", cantidadPorUnidad: 1, precioUnitario: 90)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 2, descripcionId: 202, cantidadTotal: 4, recurso: "Hierro", unidad: "qq", cantidadPorUnidad: 1, precioUnitario: 35)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 2, descripcionId: 203, cantidadTotal: 3, recurso: "Anclajes", unidad: "set", cantidadPorUnidad: 1, precioUnitario: 22)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 2, descripcionId: 204, cantidadTotal: 6, recurso: "Losa base", unidad: "m2", cantidadPorUnidad: 1, precioUnitario: 40)
        
        // Partida 3
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 3, descripcionId: 301, cantidadTotal: 7, recurso: "Columnas", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 55)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 3, descripcionId: 302, cantidadTotal: 7, recurso: "Vigas", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 45)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 3, descripcionId: 303, cantidadTotal: 7, recurso: "Losas", unidad: "m2", cantidadPorUnidad: 1, precioUnitario: 35)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 3, descripcionId: 304, cantidadTotal: 2, recurso: "Escaleras", unidad: "tramo", cantidadPorUnidad: 1, precioUnitario: 80)
        
        // Partida 4
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 4, descripcionId: 401, cantidadTotal: 10, recurso: "Bloques", unidad: "ciento", cantidadPorUnidad: 1, precioUnitario: 30)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 4, descripcionId: 402, cantidadTotal: 8, recurso: "Tabiques", unidad: "ciento", cantidadPorUnidad: 1, precioUnitario: 28)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 4, descripcionId: 403, cantidadTotal: 6, recurso: "Mortero", unidad: "m3", cantidadPorUnidad: 1, precioUnitario: 20)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 4, descripcionId: 404, cantidadTotal: 5, recurso: "Repello", unidad: "m2", cantidadPorUnidad: 1, precioUnitario: 10)
        
        // Partida 5
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 5, descripcionId: 501, cantidadTotal: 3, recurso: "Ceramica", unidad: "caja", cantidadPorUnidad: 1, precioUnitario: 15)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 5, descripcionId: 502, cantidadTotal: 2, recurso: "Pintura", unidad: "galon", cantidadPorUnidad: 1, precioUnitario: 20)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 5, descripcionId: 503, cantidadTotal: 2, recurso: "Puertas", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 80)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 5, descripcionId: 504, cantidadTotal: 2, recurso: "Ventanas", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 60)
        
        // Partida 6
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 6, descripcionId: 601, cantidadTotal: 10, recurso: "Tuberia EMT", unidad: "barra", cantidadPorUnidad: 1, precioUnitario: 7)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 6, descripcionId: 602, cantidadTotal: 8, recurso: "Cable", unidad: "rollo", cantidadPorUnidad: 1, precioUnitario: 18)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 6, descripcionId: 603, cantidadTotal: 2, recurso: "Tableros", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 120)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 6, descripcionId: 604, cantidadTotal: 10, recurso: "Luminarias", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 14)
        
        // Partida 7
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 7, descripcionId: 701, cantidadTotal: 10, recurso: "PVC", unidad: "barra", cantidadPorUnidad: 1, precioUnitario: 8)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 7, descripcionId: 702, cantidadTotal: 4, recurso: "Lavabos", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 45)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 7, descripcionId: 703, cantidadTotal: 4, recurso: "WC", unidad: "unid", cantidadPorUnidad: 1, precioUnitario: 65)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 7, descripcionId: 704, cantidadTotal: 2, recurso: "Pruebas", unidad: "serv", cantidadPorUnidad: 1, precioUnitario: 30)
        
        // Partida 8
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 8, descripcionId: 801, cantidadTotal: 6, recurso: "Adoquin", unidad: "m2", cantidadPorUnidad: 1, precioUnitario: 18)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 8, descripcionId: 802, cantidadTotal: 5, recurso: "Jardineria", unidad: "m2", cantidadPorUnidad: 1, precioUnitario: 12)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 8, descripcionId: 803, cantidadTotal: 3, recurso: "Muros", unidad: "m2", cantidadPorUnidad: 1, precioUnitario: 25)
        
        // Nota:
        // NO llenamos:
        // 199, 299, 399, 499, 599, 699, 799, 899 y 901
        // para que tú completes Extras
    }
}
