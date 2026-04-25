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
            
            insertusr_prueba()
            insertarProyectosPrueba()
            insertarPartidasCatalogo()
            insertarDescripcionesCatalogo()
            
            asegurarPartidas(proyectoId: 1)
            asegurarPartidas(proyectoId: 2)
            asegurarPartidas(proyectoId: 3)
            asegurarPartidas(proyectoId: 4)

            poblarProyectoListoParaCerrar(proyectoId: 3)
            poblarProyectoConExtrasPendientes(proyectoId: 4)
    }
    
    
    /*
     * Entradas: ninguna
     * Salida: devuelve la ruta donde se almacenará el archivo SQLite de la aplicación
     * Valor de retorno: String
     * Función: construir la ruta local de la base de datos en Documents
     * Variables: file_mgr, urls, docs_url, dbURL
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: file_mgr.default
     */
    func getDatabasePath() -> String {
        let file_mgr = FileManager.default
        let urls = file_mgr.urls(for: .documentDirectory, in: .userDomainMask)
        let docs_url = urls[0]
        let dbURL = docs_url.appendingPathComponent("bildit_v4.sqlite")
        print("Ruta BD: \(dbURL.path)")
        return dbURL.path
        
    }
    
    
    /*
     * Entradas: path de la base de datos generado por getDatabasePath()
     * Salida: abre la conexión con el archivo SQLite local
     * Valor de retorno: ninguno
     * Función: establecer la conexión principal con la base de datos de la aplicación
     * Variables: path, db
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: getDatabasePath()
     */
    func openDatabase() {
            let path = getDatabasePath()
        
            if sqlite3_open(path, &db) == SQLITE_OK {
                    print("Base de datos abierta correctamente")
            } else {
                    print("Error al abrir la base de datos")
            }
    }
    
    
    /*
     * Entradas: ninguna
     * Salida: crea la tabla usuarios si aún no existe
     * Valor de retorno: ninguno
     * Función: definir la estructura de almacenamiento de usuarios del sistema
     * Variables: sql_crear, stmt
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_prepare_v2(), sqlite3_step(), sqlite3_finalize()
     */
    func createUsuariosTable() {
                let sql_crear = """
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
        
            var stmt: OpaquePointer?
        
            if sqlite3_prepare_v2(db, sql_crear, -1, &stmt, nil) == SQLITE_OK {
                    if sqlite3_step(stmt) == SQLITE_DONE {
                            print("Tabla usuarios creada correctamente")
                    } else {
                            print("No se pudo crear la tabla usuarios")
                    }
                    } else {
                            print("Error al preparar createUsuariosTable")
                    }
        
            sqlite3_finalize(stmt)
    }
    
    /*
     * Entradas: ninguna
     * Salida: crea la tabla proyectos si no existe
     * Valor de retorno: ninguno
     * Función: definir la estructura de almacenamiento de proyectos
     * Variables: sql_crear, stmt
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_prepare_v2(), sqlite3_step(), sqlite3_finalize()
     */
    func createProyectosTable() {
        let sql_crear = """
        CREATE TABLE IF NOT EXISTS proyectos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            ubicacion TEXT,
            estado TEXT DEFAULT 'ABIERTO',
            usuario_id INTEGER NOT NULL,
            fecha_cierre TEXT DEFAULT ''
        );
        """
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql_crear, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Tabla proyectos creada correctamente")
            } else {
                print("No se pudo crear la tabla proyectos")
            }
        } else {
            print("Error al preparar createProyectosTable")
        }
        
        sqlite3_finalize(stmt)
    }
    
    /*
     * Entradas: ninguna
     * Salida: crea la tabla catálogo de partidas
     * Valor de retorno: ninguno
     * Función: almacenar el catálogo base de partidas del sistema
     * Variables: sql_crear, stmt
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_prepare_v2(), sqlite3_step(), sqlite3_finalize()
     */
    func createPartidasCatalogoTable() {
        let sql_crear = """
        CREATE TABLE IF NOT EXISTS partidas_catalogo (
            id INTEGER PRIMARY KEY,
            nombre TEXT NOT NULL UNIQUE
        );
        """
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql_crear, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Tabla partidas_catalogo creada correctamente")
            } else {
                print("No se pudo crear la tabla partidas_catalogo")
            }
        } else {
            print("Error al preparar createPartidasCatalogoTable")
        }
        
        sqlite3_finalize(stmt)
    }
    
    
    /*
     * Entradas: ninguna
     * Salida: crea la tabla relacional entre proyectos y partidas
     * Valor de retorno: ninguno
     * Función: guardar el estado de cada partida dentro de cada proyecto
     * Variables: sql_crear, stmt
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_prepare_v2(), sqlite3_step(), sqlite3_finalize()
     */
    func createProyectoPartidaTable() {
        let sql_crear = """
        CREATE TABLE IF NOT EXISTS proyecto_partida (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            proyecto_id INTEGER NOT NULL,
            partida_id INTEGER NOT NULL,
            estado TEXT NOT NULL DEFAULT 'NO INICIADA',
            UNIQUE(proyecto_id, partida_id)
        );
        """
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql_crear, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Tabla proyecto_partida creada correctamente")
            } else {
                print("No se pudo crear la tabla proyecto_partida")
            }
        } else {
            print("Error al preparar createProyectoPartidaTable")
        }
        
        sqlite3_finalize(stmt)
    }
    
    /*
     * Entradas: ninguna
     * Salida: inserta un usuario inicial de prueba
     * Valor de retorno: ninguno
     * Función: crear un usuario base para pruebas de autenticación
     * Variables: sql_insert, stmt
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_prepare_v2(), sqlite3_step(), sqlite3_finalize()
     */
    func insertusr_prueba() {
        let sql_insert = """
        INSERT OR IGNORE INTO usuarios
        (usuario, contrasena, nombre, apellido, correo, telefono, ocupacion)
        VALUES
        ('carcas', 'prueba123', 'Carlos', 'Rivas', 'carlos@bildit.com', '77886754', 'Ingeniero');
        """
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql_insert, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Usuario de prueba insertado o ya existente")
            } else {
                print("No se pudo insertar el usuario de prueba")
            }
        } else {
            print("Error al preparar insertusr_prueba")
        }
        
        sqlite3_finalize(stmt)
    }
    
    /*
     * Entradas: ninguna
     * Salida: inserta proyectos de ejemplo abiertos y cerrados
     * Valor de retorno: ninguno
     * Función: poblar la base de datos con proyectos de prueba
     * Variables: sql_insert, stmt
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_prepare_v2(), sqlite3_step(), sqlite3_finalize()
     */
    func insertarProyectosPrueba() {
        let sql_insert = """
        INSERT OR IGNORE INTO proyectos (id, nombre, ubicacion, estado, usuario_id, fecha_cierre)
        VALUES
        (1, 'Grupo Roble', 'Urbanizacion El Trebol, Pasaje Maquilishuat, #31', 'ABIERTO', 1, ''),
        (2, 'Constructora Sinai', 'Quezaltepeque', 'CERRADO', 1, '26/04/2024'),
        (3, 'Residencial Las Flores', 'Santa Ana', 'ABIERTO', 1, ''),
        (4, 'Torre Empresarial Nova', 'San Salvador', 'ABIERTO', 1, '');
        """
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql_insert, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Proyectos de prueba insertados o ya existentes")
            } else {
                print("No se pudieron insertar los proyectos de prueba")
            }
        } else {
            print("Error al preparar insertarProyectosPrueba")
        }
        
        sqlite3_finalize(stmt)
    }
    
    
    /*
     * Entradas: ninguna
     * Salida: inserta las partidas base del sistema
     * Valor de retorno: ninguno
     * Función: poblar el catálogo de partidas estándar de BILDIT
     * Variables: sql_insert, stmt
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_prepare_v2(), sqlite3_step(), sqlite3_finalize()
     */
    func insertarPartidasCatalogo() {
        let sql_insert = """
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
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql_insert, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Partidas catalogo insertadas")
            } else {
                print("No se pudieron insertar partidas catalogo")
            }
        } else {
            print("Error al preparar insertarPartidasCatalogo")
        }
        
        sqlite3_finalize(stmt)
    }
    
    /*
     * Entradas: usuario, contrasena, nombre, apellido, correo, telefono, ocupacion
     * Salida: inserta un nuevo usuario en la tabla usuarios
     * Valor de retorno: Bool
     * Función: registrar usuarios en la base de datos
     * Variables: sql_insert, stmt, resultado
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_bind_text(), sqlite3_step(), sqlite3_finalize()
     */
    
    func insertarUsuario(
        usuario: String,
        contrasena: String,
        nombre: String,
        apellido: String,
        correo: String,
        telefono: String,
        ocupacion: String
    ) -> Bool {
        
        let sql_insert = """
        INSERT INTO usuarios
        (usuario, contrasena, nombre, apellido, correo, telefono, ocupacion)
        VALUES (?, ?, ?, ?, ?, ?, ?);
        """
        
        var stmt: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, sql_insert, -1, &stmt, nil) == SQLITE_OK {
            
            sqlite3_bind_text(stmt, 1, (usuario as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (contrasena as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (nombre as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (apellido as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (correo as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (telefono as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 7, (ocupacion as NSString).utf8String, -1, nil)
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Usuario insertado correctamente")
                resultado = true
            } else {
                print("No se pudo insertar el usuario")
            }
            
        } else {
            print("Error al preparar insertarUsuario")
        }
        
        sqlite3_finalize(stmt)
        return resultado
    }
    
    
    /*
     * Entradas: usuario, contrasena
     * Salida: consulta si las credenciales existen en la base de datos
     * Valor de retorno: Usuario?
     * Función: autenticar a un usuario y devolver sus datos si son correctos
     * Variables: query, stmt, usr_encontrado
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_bind_text(), sqlite3_step(), sqlite3_finalize()
     */
    func validarLogin(usuario: String, contrasena: String) -> Usuario? {
            let query = """
            SELECT id, usuario, nombre, apellido, correo, telefono, ocupacion
            FROM usuarios
            WHERE usuario = ? AND contrasena = ?;
            """
        
            var stmt: OpaquePointer?
            var usr_encontrado: Usuario? = nil
        
            if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            
                    sqlite3_bind_text(stmt, 1, (usuario as NSString).utf8String, -1, nil)
                    sqlite3_bind_text(stmt, 2, (contrasena as NSString).utf8String, -1, nil)
            
                if sqlite3_step(stmt) == SQLITE_ROW {
                        let id = Int(sqlite3_column_int(stmt, 0))
                
                        let usuarioDB = String(cString: sqlite3_column_text(stmt, 1))
                        let nombreDB = String(cString: sqlite3_column_text(stmt, 2))
                        let apellidoDB = String(cString: sqlite3_column_text(stmt, 3))
                
                        let correoDB = sqlite3_column_text(stmt, 4) != nil ? String(cString: sqlite3_column_text(stmt, 4)) : ""
                        let telefonoDB = sqlite3_column_text(stmt, 5) != nil ? String(cString: sqlite3_column_text(stmt, 5)) : ""
                        let ocupacionDB = sqlite3_column_text(stmt, 6) != nil ? String(cString: sqlite3_column_text(stmt, 6)) : ""
                
                usr_encontrado = Usuario(
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
        
        sqlite3_finalize(stmt)
        return usr_encontrado
    }
    
    
    /*
     * Entradas: nombre, ubicacion, usuarioId
     * Salida: inserta un nuevo proyecto abierto en la base de datos y genera sus partidas
     * Valor de retorno: Bool
     * Función: registrar un proyecto nuevo asociado a un usuario
     * Variables: sql_insert, stmt, resultado, nuevoId
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: asegurarPartidasDeProyecto()
     */
    func insertarProyecto(nombre: String, ubicacion: String, usuarioId: Int) -> Bool {
        let sql_insert = """
        INSERT INTO proyectos (nombre, ubicacion, estado, usuario_id, fecha_cierre)
        VALUES (?, ?, 'ABIERTO', ?, '');
        """
        
        var stmt: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, sql_insert, -1, &stmt, nil) == SQLITE_OK {
            
            sqlite3_bind_text(stmt, 1, (nombre as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (ubicacion as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 3, Int32(usuarioId))
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                let nuevoId = Int(sqlite3_last_insert_rowid(db))
                asegurarPartidas(proyectoId: nuevoId)
                print("Proyecto insertado correctamente")
                resultado = true
            } else {
                print("No se pudo insertar el proyecto")
            }
            
        } else {
            print("Error al preparar insertarProyecto")
        }
        
        sqlite3_finalize(stmt)
        return resultado
    }
    
    /*
     * Entradas: id, nombre, ubicacion
     * Salida: modifica la información principal de un proyecto
     * Valor de retorno: Bool
     * Función: actualizar los datos básicos de un proyecto
     * Variables: sql_update, stmt, resultado
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_bind_text(), sqlite3_step(), sqlite3_finalize()
     */
    func actualizarProyecto(id: Int, nombre: String, ubicacion: String) -> Bool {
        let sql_update = """
        UPDATE proyectos
        SET nombre = ?, ubicacion = ?
        WHERE id = ?;
        """
        
        var stmt: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, sql_update, -1, &stmt, nil) == SQLITE_OK {
            
            sqlite3_bind_text(stmt, 1, (nombre as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (ubicacion as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 3, Int32(id))
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Proyecto actualizado correctamente")
                resultado = true
            } else {
                print("No se pudo actualizar el proyecto")
            }
            
        } else {
            print("Error al preparar actualizarProyecto")
        }
        
        sqlite3_finalize(stmt)
        return resultado
    }
    
    /*
     * Entradas: id
     * Salida: elimina un proyecto del sistema
     * Valor de retorno: Bool
     * Función: borrar un proyecto por identificador
     * Variables: sql_delete, stmt, resultado
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_bind_int(), sqlite3_step(), sqlite3_finalize()
     */
    func eliminarProyecto(id: Int) -> Bool {
        let sql_delete = "DELETE FROM proyectos WHERE id = ?;"
        
        var stmt: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, sql_delete, -1, &stmt, nil) == SQLITE_OK {
            
            sqlite3_bind_int(stmt, 1, Int32(id))
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Proyecto eliminado correctamente")
                resultado = true
            } else {
                print("No se pudo eliminar el proyecto")
            }
            
        } else {
            print("Error al preparar eliminarProyecto")
        }
        
        sqlite3_finalize(stmt)
        return resultado
    }
    
    /*
     * Entradas: usuarioId
     * Salida: obtiene la lista de proyectos abiertos del usuario
     * Valor de retorno: [Proyecto]
     * Función: consultar proyectos en estado ABIERTO
     * Variables: query, stmt, proyectos
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_prepare_v2(), sqlite3_step(), sqlite3_finalize()
     */
    func obtener_abiertos(usuarioId: Int) -> [Proyecto] {
        let query = """
        SELECT id, nombre, ubicacion, estado, usuario_id, fecha_cierre
        FROM proyectos
        WHERE usuario_id = ? AND estado = 'ABIERTO';
        """
        
        var stmt: OpaquePointer?
        var proyectos: [Proyecto] = []
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(usuarioId))
            
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let nombre = String(cString: sqlite3_column_text(stmt, 1))
                let ubicacion = sqlite3_column_text(stmt, 2) != nil ? String(cString: sqlite3_column_text(stmt, 2)) : ""
                let estado = String(cString: sqlite3_column_text(stmt, 3))
                let usuarioIdDB = Int(sqlite3_column_int(stmt, 4))
                let fecha_cierre = sqlite3_column_text(stmt, 5) != nil ? String(cString: sqlite3_column_text(stmt, 5)) : ""
                
                let proyecto = Proyecto(
                    id: id,
                    nombre: nombre,
                    ubicacion: ubicacion,
                    estado: estado,
                    usuarioId: usuarioIdDB,
                    fecha_cierre: fecha_cierre
                )
                
                proyectos.append(proyecto)
            }
        } else {
            print("Error al preparar obtener_abiertos")
        }
        
        sqlite3_finalize(stmt)
        return proyectos
    }
    
    /*
     * Entradas: usuarioId
     * Salida: devuelve la lista de proyectos cerrados del usuario
     * Valor de retorno: [Proyecto]
     * Función: consultar proyectos en estado CERRADO
     * Variables: query, stmt, proyectos
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_bind_int(), sqlite3_step(), sqlite3_finalize()
     */
    func obtenerProyectosCerrados(usuarioId: Int) -> [Proyecto] {
        let query = """
        SELECT id, nombre, ubicacion, estado, usuario_id, fecha_cierre
        FROM proyectos
        WHERE usuario_id = ? AND estado = 'CERRADO';
        """
        
        var stmt: OpaquePointer?
        var proyectos: [Proyecto] = []
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(usuarioId))
            
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let nombre = String(cString: sqlite3_column_text(stmt, 1))
                let ubicacion = sqlite3_column_text(stmt, 2) != nil ? String(cString: sqlite3_column_text(stmt, 2)) : ""
                let estado = String(cString: sqlite3_column_text(stmt, 3))
                let usuarioIdDB = Int(sqlite3_column_int(stmt, 4))
                let fecha_cierre = sqlite3_column_text(stmt, 5) != nil ? String(cString: sqlite3_column_text(stmt, 5)) : ""
                
                let proyecto = Proyecto(
                    id: id,
                    nombre: nombre,
                    ubicacion: ubicacion,
                    estado: estado,
                    usuarioId: usuarioIdDB,
                    fecha_cierre: fecha_cierre
                )
                
                proyectos.append(proyecto)
            }
        } else {
            print("Error al preparar obtenerProyectosCerrados")
        }
        
        sqlite3_finalize(stmt)
        return proyectos
    }
    

    /*
     * Entradas: proyectoId
     * Salida: garantiza que un proyecto tenga todas sus partidas asociadas
     * Valor de retorno: ninguno
     * Función: insertar automáticamente las partidas base de un proyecto
     * Variables: sql_insert, stmt
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_bind_int(), sqlite3_step(), sqlite3_finalize()
     */
    func asegurarPartidas(proyectoId: Int) {
        let sql_insert = """
        INSERT OR IGNORE INTO proyecto_partida (proyecto_id, partida_id, estado)
        SELECT ?, id, 'NO INICIADA'
        FROM partidas_catalogo;
        """
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql_insert, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(proyectoId))
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Partidas aseguradas para proyecto \(proyectoId)")
            } else {
                print("No se pudieron asegurar partidas del proyecto")
            }
        } else {
            print("Error al preparar asegurarPartidasDeProyecto")
        }
        
        sqlite3_finalize(stmt)
    }
    
    
    /*
     * Entradas: proyectoId
     * Salida: devuelve todas las partidas asociadas al proyecto
     * Valor de retorno: [Partida]
     * Función: consultar el listado de partidas de un proyecto
     * Variables: query, stmt, partidas
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_bind_int(), sqlite3_step(), sqlite3_finalize()
     */
    func obtenerPartidas(proyectoId: Int) -> [Partida] {
        let query = """
        SELECT pp.partida_id, pc.nombre, pp.estado
        FROM proyecto_partida pp
        INNER JOIN partidas_catalogo pc ON pc.id = pp.partida_id
        WHERE pp.proyecto_id = ?
        ORDER BY pp.partida_id;
        """
        
        var stmt: OpaquePointer?
        var partidas: [Partida] = []
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(proyectoId))
            
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let nombre = String(cString: sqlite3_column_text(stmt, 1))
                let estado = String(cString: sqlite3_column_text(stmt, 2))
                
                let partida = Partida(id: id, nombre: nombre, estado: estado)
                partidas.append(partida)
            }
        } else {
            print("Error al preparar obtenerPartidasDeProyecto")
        }
        
        sqlite3_finalize(stmt)
        return partidas
    }
    
    /*
     * Entradas: proyectoId, partidaId, estado
     * Salida: actualiza el estado manual de una partida
     * Valor de retorno: Bool
     * Función: cambiar el estado de una partida específica
     * Variables: sql_update, stmt, resultado
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_bind_text(), sqlite3_step(), sqlite3_finalize()
     */
    func actEstadoPartida(proyectoId: Int, partidaId: Int, estado: String) -> Bool {
        let sql_update = """
        UPDATE proyecto_partida
        SET estado = ?
        WHERE proyecto_id = ? AND partida_id = ?;
        """
        
        var stmt: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, sql_update, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (estado as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 2, Int32(proyectoId))
            sqlite3_bind_int(stmt, 3, Int32(partidaId))
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                resultado = true
            }
        }
        
        sqlite3_finalize(stmt)
        return resultado
    }
    
    /*
     * Entradas: proyectoId
     * Salida: indica si todas las partidas del proyecto están terminadas
     * Valor de retorno: Bool
     * Función: validar si un proyecto puede cerrarse
     * Variables: query, stmt, todas_ok
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_bind_int(), sqlite3_step(), sqlite3_finalize()
     */
    func partidasTerminadas(proyectoId: Int) -> Bool {
        let query = """
        SELECT COUNT(*)
        FROM proyecto_partida
        WHERE proyecto_id = ? AND estado != 'TERMINADA';
        """
        
        var stmt: OpaquePointer?
        var todasTerminadas = false
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(proyectoId))
            
            if sqlite3_step(stmt) == SQLITE_ROW {
                let pendientes = Int(sqlite3_column_int(stmt, 0))
                todasTerminadas = (pendientes == 0)
            }
        } else {
            print("Error al preparar todasLasPartidasTerminadas")
        }
        
        sqlite3_finalize(stmt)
        return todasTerminadas
    }
    
    /*
     * Entradas: proyectoId
     * Salida: cambia el estado del proyecto a CERRADO y registra la fecha de cierre
     * Valor de retorno: Bool
     * Función: finalizar formalmente un proyecto en la base de datos
     * Variables: fechaActual, sql_update, stmt, resultado
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: fechaActualTexto()
     */
    func cerrarProyecto(proyectoId: Int) -> Bool {
        let fechaActual = fechaActualTexto()
        
        let sql_update = """
        UPDATE proyectos
        SET estado = 'CERRADO', fecha_cierre = ?
        WHERE id = ?;
        """
        
        var stmt: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, sql_update, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (fechaActual as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 2, Int32(proyectoId))
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Proyecto cerrado correctamente")
                resultado = true
            } else {
                print("No se pudo cerrar el proyecto")
            }
        } else {
            print("Error al preparar cerrarProyecto")
        }
        
        sqlite3_finalize(stmt)
        return resultado
    }
    
    /*
     * Entradas: ninguna
     * Salida: devuelve la fecha actual formateada como texto
     * Valor de retorno: String
     * Función: generar la fecha de cierre de un proyecto
     * Variables: formatter
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: DateFormatter()
     */
    func fechaActualTexto() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date())
    }

    /*
     * Entradas: proyectoId
     * Salida: calcula el total monetario acumulado del proyecto
     * Valor de retorno: Double
     * Función: sumar todos los subtotales del proyecto
     * Variables: query, stmt, total
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_bind_int(), sqlite3_step(), sqlite3_finalize()
     */
    func obtenerTotalProyecto(proyectoId: Int) -> Double {
        let query = """
        SELECT IFNULL(SUM(subtotal), 0)
        FROM proyecto_descripcion
        WHERE proyecto_id = ?;
        """
        
        var stmt: OpaquePointer?
        var total: Double = 0
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(proyectoId))
            
            if sqlite3_step(stmt) == SQLITE_ROW {
                total = sqlite3_column_double(stmt, 0)
            }
        }
        
        sqlite3_finalize(stmt)
        return total
    }

    /*
     * Entradas: usuarioId
     * Salida: devuelve el resumen de proyectos cerrados con total incluido
     * Valor de retorno: [ProyectoCerrado]
     * Función: construir la lista resumida de proyectos cerrados para historial
     * Variables: proyectos, lista, total
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: obtenerProyectosCerrados(), obtenerTotalProyecto()
     */
    func obtenerCerradosRes(usuarioId: Int) -> [ProyectoCerrado] {
        let proyectos = obtenerProyectosCerrados(usuarioId: usuarioId)
        var lista: [ProyectoCerrado] = []
        
        for proyecto in proyectos {
            let total = obtenerTotalProyecto(proyectoId: proyecto.id)
            
            lista.append(
                ProyectoCerrado(
                    id: proyecto.id,
                    nombre: proyecto.nombre,
                    ubicacion: proyecto.ubicacion,
                    fecha_cierre: proyecto.fecha_cierre,
                    total: total
                )
            )
        }
        
        return lista
    }

    /*
     * Entradas: proyectoId
     * Salida: devuelve partidas cerradas con sus descripciones y totales
     * Valor de retorno: [PartidaCerradaDetalle]
     * Función: construir el detalle de un proyecto cerrado
     * Variables: partidas, resultado, descripciones, total
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: obtenerPartidas(), obtenerDescripcionesDePartida()
     */
    func obtenerPartidasCerr(proyectoId: Int) -> [PartidaCerradaDetalle] {
        let partidas = obtenerPartidas(proyectoId: proyectoId)
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
    
    /*
     * Entradas: ninguna
     * Salida: crea la tabla catálogo de descripciones
     * Valor de retorno: ninguno
     * Función: almacenar las descripciones base de cada partida
     * Variables: sql_crear, stmt
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_prepare_v2(), sqlite3_step(), sqlite3_finalize()
     */
    func createDescripcionesCatalogoTable() {
        let sql_crear = """
        CREATE TABLE IF NOT EXISTS descripciones_catalogo (
            id INTEGER PRIMARY KEY,
            partida_id INTEGER NOT NULL,
            nombre TEXT NOT NULL
        );
        """
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql_crear, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Tabla descripciones_catalogo creada correctamente")
            } else {
                print("No se pudo crear la tabla descripciones_catalogo")
            }
        } else {
            print("Error al preparar createDescripcionesCatalogoTable")
        }
        
        sqlite3_finalize(stmt)
    }

    
    /*
     * Entradas: ninguna
     * Salida: crea la tabla de descripciones asociadas a cada proyecto y partida
     * Valor de retorno: ninguno
     * Función: almacenar subtotales y cantidades de las descripciones del proyecto
     * Variables: sql_crear, stmt
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_prepare_v2(), sqlite3_step(), sqlite3_finalize()
     */
    func createProyectoDescripcionTable() {
        let sql_crear = """
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
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql_crear, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Tabla proyecto_descripcion creada correctamente")
            } else {
                print("No se pudo crear la tabla proyecto_descripcion")
            }
        } else {
            print("Error al preparar createProyectoDescripcionTable")
        }
        
        sqlite3_finalize(stmt)
    }
    
    
    /*
     * Entradas: ninguna
     * Salida: inserta las descripciones base de cada partida
     * Valor de retorno: ninguno
     * Función: poblar el catálogo general de descripciones técnicas
     * Variables: sql_insert, stmt
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_prepare_v2(), sqlite3_step(), sqlite3_finalize()
     */
    func insertarDescripcionesCatalogo() {
        let sql_insert = """
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
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql_insert, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Descripciones catalogo insertadas")
            } else {
                print("No se pudieron insertar descripciones catalogo")
            }
        } else {
            print("Error al preparar insertarDescripcionesCatalogo")
        }
        
        sqlite3_finalize(stmt)
    }
    
    /*
     * Entradas: proyectoId, partidaId
     * Salida: crea las descripciones base de una partida si no existen
     * Valor de retorno: ninguno
     * Función: asociar descripciones técnicas a una partida de un proyecto
     * Variables: sql_insert, stmt
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_bind_int(), sqlite3_step(), sqlite3_finalize()
     */
    func asegurarDescripciones(proyectoId: Int, partidaId: Int) {
        let sql_insert = """
        INSERT OR IGNORE INTO proyecto_descripcion (proyecto_id, partida_id, descripcion_id, subtotal)
        SELECT ?, ?, id, 0
        FROM descripciones_catalogo
        WHERE partida_id = ?;
        """
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql_insert, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(proyectoId))
            sqlite3_bind_int(stmt, 2, Int32(partidaId))
            sqlite3_bind_int(stmt, 3, Int32(partidaId))
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Descripciones aseguradas para proyecto \(proyectoId), partida \(partidaId)")
            } else {
                print("No se pudieron asegurar descripciones")
            }
        } else {
            print("Error al preparar asegurarDescripciones")
        }
        
        sqlite3_finalize(stmt)
    }
    
    /*
     * Entradas: proyectoId, partidaId
     * Salida: devuelve descripciones y subtotales de una partida
     * Valor de retorno: [Descripcion]
     * Función: consultar descripciones registradas en una partida
     * Variables: query, stmt, descripciones
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_bind_int(), sqlite3_step(), sqlite3_finalize()
     */
    func obtenerDescripcionesDePartida(proyectoId: Int, partidaId: Int) -> [Descripcion] {
        let query = """
        SELECT dc.id, dc.nombre, pd.subtotal
        FROM proyecto_descripcion pd
        INNER JOIN descripciones_catalogo dc ON dc.id = pd.descripcion_id
        WHERE pd.proyecto_id = ? AND pd.partida_id = ?
        ORDER BY dc.id;
        """
        
        var stmt: OpaquePointer?
        var descripciones: [Descripcion] = []
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(proyectoId))
            sqlite3_bind_int(stmt, 2, Int32(partidaId))
            
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let nombre = String(cString: sqlite3_column_text(stmt, 1))
                let subtotal = sqlite3_column_double(stmt, 2)
                
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
        
        sqlite3_finalize(stmt)
        return descripciones
    }
    
    
    /*
     * Entradas: proyectoId, partidaId
     * Salida: calcula el total acumulado de una partida
     * Valor de retorno: Double
     * Función: sumar los subtotales de las descripciones de una partida
     * Variables: query, stmt, total
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_bind_int(), sqlite3_step(), sqlite3_finalize()
     */
    func obtenerTotalPartida(proyectoId: Int, partidaId: Int) -> Double {
        let query = """
        SELECT IFNULL(SUM(subtotal), 0)
        FROM proyecto_descripcion
        WHERE proyecto_id = ? AND partida_id = ?;
        """
        
        var stmt: OpaquePointer?
        var total: Double = 0
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(proyectoId))
            sqlite3_bind_int(stmt, 2, Int32(partidaId))
            
            if sqlite3_step(stmt) == SQLITE_ROW {
                total = sqlite3_column_double(stmt, 0)
            }
        } else {
            print("Error al preparar obtenerTotalPartida")
        }
        
        sqlite3_finalize(stmt)
        return total
    }
    
    func partidaCompleta(proyectoId: Int, partidaId: Int) -> Bool {
        let query = """
        SELECT COUNT(*)
        FROM proyecto_descripcion
        WHERE proyecto_id = ? AND partida_id = ?
        AND NOT (cantidad_total > 0 AND subtotal > 0);
        """
        
        var stmt: OpaquePointer?
        var completa = false
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(proyectoId))
            sqlite3_bind_int(stmt, 2, Int32(partidaId))
            
            if sqlite3_step(stmt) == SQLITE_ROW {
                let pendientes = Int(sqlite3_column_int(stmt, 0))
                completa = (pendientes == 0)
            }
        }
        
        sqlite3_finalize(stmt)
        return completa
    }

    /*
     * Entradas: proyectoId, partidaId
     * Salida: marca una partida como terminada si está completa
     * Valor de retorno: Bool
     * Función: cerrar una partida finalizada
     * Variables: sql_update, stmt, resultado
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: partidaCompleta()
     */
    func cerrarPartida(proyectoId: Int, partidaId: Int) -> Bool {
        if !partidaCompleta(proyectoId: proyectoId, partidaId: partidaId) {
            return false
        }
        
        let sql_update = """
        UPDATE proyecto_partida
        SET estado = 'TERMINADA'
        WHERE proyecto_id = ? AND partida_id = ?;
        """
        
        var stmt: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, sql_update, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(proyectoId))
            sqlite3_bind_int(stmt, 2, Int32(partidaId))
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                resultado = true
            }
        }
        
        sqlite3_finalize(stmt)
        return resultado
    }
    
    /*
     * Entradas: ninguna
     * Salida: crea la tabla de recursos por descripción
     * Valor de retorno: ninguno
     * Función: almacenar los recursos materiales y costos unitarios de cada descripción
     * Variables: sql_crear, stmt
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_prepare_v2(), sqlite3_step(), sqlite3_finalize()
     */
    func createDescripcionRecursoTable() {
        let sql_crear = """
        CREATE TABLE IF NOT EXISTS descripcion_recurso (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            proyecto_descripcion_id INTEGER NOT NULL,
            nombre_recurso TEXT NOT NULL,
            unidad TEXT NOT NULL,
            cant_por_unidad REAL NOT NULL,
            pu REAL NOT NULL
        );
        """
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql_crear, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("Tabla descripcion_recurso creada correctamente")
            } else {
                print("No se pudo crear la tabla descripcion_recurso")
            }
        } else {
            print("Error al preparar createDescripcionRecursoTable")
        }
        
        sqlite3_finalize(stmt)
    }
    
    /*
     * Entradas: proyectoId, partidaId, descripcionId
     * Salida: obtiene el id interno de la relación proyecto_descripcion
     * Valor de retorno: Int?
     * Función: localizar el identificador relacional de una descripción dentro del proyecto
     * Variables: query, stmt, resultado
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_bind_int(), sqlite3_step(), sqlite3_finalize()
     */
    func obtenerproy_desc_id(proyectoId: Int, partidaId: Int, descripcionId: Int) -> Int? {
        let query = """
        SELECT id
        FROM proyecto_descripcion
        WHERE proyecto_id = ? AND partida_id = ? AND descripcion_id = ?;
        """
        
        var stmt: OpaquePointer?
        var resultado: Int? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(proyectoId))
            sqlite3_bind_int(stmt, 2, Int32(partidaId))
            sqlite3_bind_int(stmt, 3, Int32(descripcionId))
            
            if sqlite3_step(stmt) == SQLITE_ROW {
                resultado = Int(sqlite3_column_int(stmt, 0))
            }
        }
        
        sqlite3_finalize(stmt)
        return resultado
    }
    
    /*
     * Entradas: proyectoId, partidaId, descripcionId, nom_recurso, unidad, cant_unidad, precio_unit
     * Salida: inserta un recurso y recalcula subtotal y estado de la partida
     * Valor de retorno: Bool
     * Función: registrar un recurso dentro de una descripción específica
     * Variables: proy_desc_id, sql_insert, stmt, resultado
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: obtenerproy_desc_id(), recalcularSubtotalDescripcion(), recalcularEstadoPartida()
     */
    func insertarRecurso(
        proyectoId: Int,
        partidaId: Int,
        descripcionId: Int,
        nom_recurso: String,
        unidad: String,
        cant_unidad: Double,
        precio_unit: Double
    ) -> Bool {
        
        guard let proy_desc_id = obtenerproy_desc_id(
            proyectoId: proyectoId,
            partidaId: partidaId,
            descripcionId: descripcionId
        ) else {
            print("No se encontró proyecto_descripcion_id")
            return false
        }
        
        let sql_insert = """
        INSERT INTO descripcion_recurso
        (proyecto_descripcion_id, nombre_recurso, unidad, cant_por_unidad, pu)
        VALUES (?, ?, ?, ?, ?);
        """
        
        var stmt: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, sql_insert, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(proy_desc_id))
            sqlite3_bind_text(stmt, 2, (nom_recurso as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (unidad as NSString).utf8String, -1, nil)
            sqlite3_bind_double(stmt, 4, cant_unidad)
            sqlite3_bind_double(stmt, 5, precio_unit)
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                resultado = true
            }
        }
        
        sqlite3_finalize(stmt)
        
        if resultado {
            recalcSubtotalDesc(proyectoId: proyectoId, partidaId: partidaId, descripcionId: descripcionId)
            recalcEstadoPartida(proyectoId: proyectoId, partidaId: partidaId)
        }
        
        return resultado
    }
    
    
    /*
     * Entradas: proyectoId, partidaId, descripcionId
     * Salida: devuelve los recursos asociados a una descripción
     * Valor de retorno: [Recurso]
     * Función: consultar los recursos registrados en una descripción del proyecto
     * Variables: query, stmt, recursos
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_bind_int(), sqlite3_step(), sqlite3_finalize()
     */
    func obtenerRecursos(proyectoId: Int, partidaId: Int, descripcionId: Int) -> [Recurso] {
        let query = """
        SELECT dr.id, dr.nombre_recurso, dr.unidad, dr.cant_por_unidad, dr.pu
        FROM descripcion_recurso dr
        INNER JOIN proyecto_descripcion pd ON pd.id = dr.proyecto_descripcion_id
        WHERE pd.proyecto_id = ? AND pd.partida_id = ? AND pd.descripcion_id = ?
        ORDER BY dr.id;
        """
        
        var stmt: OpaquePointer?
        var recursos: [Recurso] = []
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(proyectoId))
            sqlite3_bind_int(stmt, 2, Int32(partidaId))
            sqlite3_bind_int(stmt, 3, Int32(descripcionId))
            
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let nombre = String(cString: sqlite3_column_text(stmt, 1))
                let unidad = String(cString: sqlite3_column_text(stmt, 2))
                let cantidad = sqlite3_column_double(stmt, 3)
                let precio = sqlite3_column_double(stmt, 4)
                
                recursos.append(
                    Recurso(
                        id: id,
                        nom_recurso: nombre,
                        unidad: unidad,
                        cant_unidad: cantidad,
                        precio_unit: precio
                    )
                )
            }
        }
        
        sqlite3_finalize(stmt)
        return recursos
    }
    
    
    /*
     * Entradas: proyectoId, partidaId, descripcionId, cantidadTotal
     * Salida: actualiza la cantidad total de una descripción y recalcula valores dependientes
     * Valor de retorno: Bool
     * Función: guardar la cantidad total de medidas de una descripción
     * Variables: sql_update, stmt, resultado
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: recalcSubtotalDesc(), recalcEstadoPartida()
     */
    func actCantDesc(
        proyectoId: Int,
        partidaId: Int,
        descripcionId: Int,
        cantidadTotal: Double
    ) -> Bool {
        
        let sql_update = """
        UPDATE proyecto_descripcion
        SET cantidad_total = ?
        WHERE proyecto_id = ? AND partida_id = ? AND descripcion_id = ?;
        """
        
        var stmt: OpaquePointer?
        var resultado = false
        
        if sqlite3_prepare_v2(db, sql_update, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_double(stmt, 1, cantidadTotal)
            sqlite3_bind_int(stmt, 2, Int32(proyectoId))
            sqlite3_bind_int(stmt, 3, Int32(partidaId))
            sqlite3_bind_int(stmt, 4, Int32(descripcionId))
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                resultado = true
            }
        }
        
        sqlite3_finalize(stmt)
        
        if resultado {
            recalcSubtotalDesc(proyectoId: proyectoId, partidaId: partidaId, descripcionId: descripcionId)
            recalcEstadoPartida(proyectoId: proyectoId, partidaId: partidaId)
        }
        
        return resultado
    }
    
    
    /*
     * Entradas: proyectoId, partidaId, descripcionId
     * Salida: obtiene la cantidad total guardada para una descripción
     * Valor de retorno: Double
     * Función: consultar la cantidad total de medidas de una descripción
     * Variables: query, stmt, cantidad
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_bind_int(), sqlite3_step(), sqlite3_finalize()
     */
    func obtenerCantDesc(proyectoId: Int, partidaId: Int, descripcionId: Int) -> Double {
        let query = """
        SELECT cantidad_total
        FROM proyecto_descripcion
        WHERE proyecto_id = ? AND partida_id = ? AND descripcion_id = ?;
        """
        
        var stmt: OpaquePointer?
        var cantidad: Double = 0
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(proyectoId))
            sqlite3_bind_int(stmt, 2, Int32(partidaId))
            sqlite3_bind_int(stmt, 3, Int32(descripcionId))
            
            if sqlite3_step(stmt) == SQLITE_ROW {
                cantidad = sqlite3_column_double(stmt, 0)
            }
        }
        
        sqlite3_finalize(stmt)
        return cantidad
    }
    
    /*
     * Entradas: proyectoId, partidaId, descripcionId
     * Salida: calcula el costo total por unidad de una descripción
     * Valor de retorno: Double
     * Función: sumar el costo unitario de los recursos de una descripción
     * Variables: query, stmt, total
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_bind_int(), sqlite3_step(), sqlite3_finalize()
     */
    func obtenerTotalUnidadDesc(proyectoId: Int, partidaId: Int, descripcionId: Int) -> Double {
        let query = """
        SELECT IFNULL(SUM(dr.cant_por_unidad * dr.pu), 0)
        FROM descripcion_recurso dr
        INNER JOIN proyecto_descripcion pd ON pd.id = dr.proyecto_descripcion_id
        WHERE pd.proyecto_id = ? AND pd.partida_id = ? AND pd.descripcion_id = ?;
        """
        
        var stmt: OpaquePointer?
        var total: Double = 0
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(proyectoId))
            sqlite3_bind_int(stmt, 2, Int32(partidaId))
            sqlite3_bind_int(stmt, 3, Int32(descripcionId))
            
            if sqlite3_step(stmt) == SQLITE_ROW {
                total = sqlite3_column_double(stmt, 0)
            }
        }
        
        sqlite3_finalize(stmt)
        return total
    }

    /*
     * Entradas: proyectoId, partidaId, descripcionId
     * Salida: actualiza el subtotal total de una descripción
     * Valor de retorno: ninguno
     * Función: recalcular el subtotal de una descripción en base a cantidad total y total unitario
     * Variables: cantidadTotal, totalPorUnidad, subtotal, sql_update, stmt
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: obtenerCantDesc(), obtenerTotalUnidadDesc()
     */
    func recalcSubtotalDesc(proyectoId: Int, partidaId: Int, descripcionId: Int) {
        let cantidadTotal = obtenerCantDesc(
            proyectoId: proyectoId,
            partidaId: partidaId,
            descripcionId: descripcionId
        )
        
        let total_unidad = obtenerTotalUnidadDesc(
            proyectoId: proyectoId,
            partidaId: partidaId,
            descripcionId: descripcionId
        )
        
        let subtotal = cantidadTotal * total_unidad
        
        let sql_update = """
        UPDATE proyecto_descripcion
        SET subtotal = ?
        WHERE proyecto_id = ? AND partida_id = ? AND descripcion_id = ?;
        """
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql_update, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_double(stmt, 1, subtotal)
            sqlite3_bind_int(stmt, 2, Int32(proyectoId))
            sqlite3_bind_int(stmt, 3, Int32(partidaId))
            sqlite3_bind_int(stmt, 4, Int32(descripcionId))
            
            _ = sqlite3_step(stmt)
        }
        
        sqlite3_finalize(stmt)
    }
    
    
    /*
     * Entradas: proyectoId, partidaId
     * Salida: actualiza el estado de la partida según el avance real de sus descripciones
     * Valor de retorno: ninguno
     * Función: recalcular si una partida está no iniciada, en proceso o terminada
     * Variables: total, iniciadas, completas, nuevoEstado, stmt
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: ejecutarCount()
     */
    func recalcEstadoPartida(proyectoId: Int, partidaId: Int) {
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
        
        let sql_update = """
        UPDATE proyecto_partida
        SET estado = ?
        WHERE proyecto_id = ? AND partida_id = ?;
        """
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql_update, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (nuevoEstado as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 2, Int32(proyectoId))
            sqlite3_bind_int(stmt, 3, Int32(partidaId))
            
            _ = sqlite3_step(stmt)
        }
        
        sqlite3_finalize(stmt)
    }
    
    /*
     * Entradas: query, proyectoId, partidaId
     * Salida: ejecuta una consulta COUNT sobre la base de datos
     * Valor de retorno: Int
     * Función: reutilizar conteos SQL para cálculos de estado
     * Variables: stmt, valor
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: sqlite3_bind_int(), sqlite3_step(), sqlite3_finalize()
     */
    func ejecutarCount(query: String, proyectoId: Int, partidaId: Int) -> Int {
        var stmt: OpaquePointer?
        var valor = 0
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(proyectoId))
            sqlite3_bind_int(stmt, 2, Int32(partidaId))
            
            if sqlite3_step(stmt) == SQLITE_ROW {
                valor = Int(sqlite3_column_int(stmt, 0))
            }
        }
        
        sqlite3_finalize(stmt)
        return valor
    }
    
    func proyectoYaTieneRecursos(proyectoId: Int) -> Bool {
        let query = """
        SELECT COUNT(*)
        FROM descripcion_recurso dr
        INNER JOIN proyecto_descripcion pd ON pd.id = dr.proyecto_descripcion_id
        WHERE pd.proyecto_id = ?;
        """
        
        var stmt: OpaquePointer?
        var cantidad = 0
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(proyectoId))
            
            if sqlite3_step(stmt) == SQLITE_ROW {
                cantidad = Int(sqlite3_column_int(stmt, 0))
            }
        }
        
        sqlite3_finalize(stmt)
        return cantidad > 0
    }
    
    func asegurarTodasLasDescripcionesDeProyecto(proyectoId: Int) {
        let partidas = obtenerPartidas(proyectoId: proyectoId)
        
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
        cant_unidad: Double,
        precio_unit: Double
    ) {
        let _ = insertarRecurso(
            proyectoId: proyectoId,
            partidaId: partidaId,
            descripcionId: descripcionId,
            nom_recurso: recurso,
            unidad: unidad,
            cant_unidad: cant_unidad,
            precio_unit: precio_unit
        )
        
        let _ = actCantDesc(
            proyectoId: proyectoId,
            partidaId: partidaId,
            descripcionId: descripcionId,
            cantidadTotal: cantidadTotal
        )
    }
    
    func poblarProyectoListoParaCerrar(proyectoId: Int) {
        if proyectoYaTieneRecursos(proyectoId: proyectoId) { return }
        
        asegurarPartidas(proyectoId: proyectoId)
        asegurarTodasLasDescripcionesDeProyecto(proyectoId: proyectoId)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 1, descripcionId: 101, cantidadTotal: 10, recurso: "Mano de obra", unidad: "jornal", cant_unidad: 1, precio_unit: 12)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 1, descripcionId: 102, cantidadTotal: 8, recurso: "Cal", unidad: "bolsa", cant_unidad: 1, precio_unit: 6)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 1, descripcionId: 103, cantidadTotal: 12, recurso: "Excavadora", unidad: "hora", cant_unidad: 1, precio_unit: 20)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 1, descripcionId: 104, cantidadTotal: 9, recurso: "Material selecto", unidad: "m3", cant_unidad: 1, precio_unit: 8)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 1, descripcionId: 199, cantidadTotal: 2, recurso: "Extras tierras", unidad: "unid", cant_unidad: 1, precio_unit: 15)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 2, descripcionId: 201, cantidadTotal: 5, recurso: "Concreto", unidad: "m3", cant_unidad: 1, precio_unit: 90)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 2, descripcionId: 202, cantidadTotal: 4, recurso: "Hierro", unidad: "qq", cant_unidad: 1, precio_unit: 35)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 2, descripcionId: 203, cantidadTotal: 3, recurso: "Anclajes", unidad: "set", cant_unidad: 1, precio_unit: 22)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 2, descripcionId: 204, cantidadTotal: 6, recurso: "Losa base", unidad: "m2", cant_unidad: 1, precio_unit: 40)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 2, descripcionId: 299, cantidadTotal: 1, recurso: "Extras cimentacion", unidad: "unid", cant_unidad: 1, precio_unit: 18)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 3, descripcionId: 301, cantidadTotal: 7, recurso: "Columnas", unidad: "unid", cant_unidad: 1, precio_unit: 55)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 3, descripcionId: 302, cantidadTotal: 7, recurso: "Vigas", unidad: "unid", cant_unidad: 1, precio_unit: 45)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 3, descripcionId: 303, cantidadTotal: 7, recurso: "Losas", unidad: "m2", cant_unidad: 1, precio_unit: 35)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 3, descripcionId: 304, cantidadTotal: 2, recurso: "Escaleras", unidad: "tramo", cant_unidad: 1, precio_unit: 80)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 3, descripcionId: 399, cantidadTotal: 1, recurso: "Extras estructura", unidad: "unid", cant_unidad: 1, precio_unit: 25)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 4, descripcionId: 401, cantidadTotal: 10, recurso: "Bloques", unidad: "ciento", cant_unidad: 1, precio_unit: 30)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 4, descripcionId: 402, cantidadTotal: 8, recurso: "Tabiques", unidad: "ciento", cant_unidad: 1, precio_unit: 28)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 4, descripcionId: 403, cantidadTotal: 6, recurso: "Mortero", unidad: "m3", cant_unidad: 1, precio_unit: 20)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 4, descripcionId: 404, cantidadTotal: 5, recurso: "Repello", unidad: "m2", cant_unidad: 1, precio_unit: 10)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 4, descripcionId: 499, cantidadTotal: 1, recurso: "Extras albanileria", unidad: "unid", cant_unidad: 1, precio_unit: 12)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 5, descripcionId: 501, cantidadTotal: 3, recurso: "Ceramica", unidad: "caja", cant_unidad: 1, precio_unit: 15)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 5, descripcionId: 502, cantidadTotal: 2, recurso: "Pintura", unidad: "galon", cant_unidad: 1, precio_unit: 20)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 5, descripcionId: 503, cantidadTotal: 2, recurso: "Puertas", unidad: "unid", cant_unidad: 1, precio_unit: 80)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 5, descripcionId: 504, cantidadTotal: 2, recurso: "Ventanas", unidad: "unid", cant_unidad: 1, precio_unit: 60)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 5, descripcionId: 599, cantidadTotal: 1, recurso: "Extras acabados", unidad: "unid", cant_unidad: 1, precio_unit: 25)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 6, descripcionId: 601, cantidadTotal: 10, recurso: "Tuberia EMT", unidad: "barra", cant_unidad: 1, precio_unit: 7)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 6, descripcionId: 602, cantidadTotal: 8, recurso: "Cable", unidad: "rollo", cant_unidad: 1, precio_unit: 18)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 6, descripcionId: 603, cantidadTotal: 2, recurso: "Tableros", unidad: "unid", cant_unidad: 1, precio_unit: 120)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 6, descripcionId: 604, cantidadTotal: 10, recurso: "Luminarias", unidad: "unid", cant_unidad: 1, precio_unit: 14)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 6, descripcionId: 699, cantidadTotal: 1, recurso: "Extras electricas", unidad: "unid", cant_unidad: 1, precio_unit: 18)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 7, descripcionId: 701, cantidadTotal: 10, recurso: "PVC", unidad: "barra", cant_unidad: 1, precio_unit: 8)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 7, descripcionId: 702, cantidadTotal: 4, recurso: "Lavabos", unidad: "unid", cant_unidad: 1, precio_unit: 45)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 7, descripcionId: 703, cantidadTotal: 4, recurso: "WC", unidad: "unid", cant_unidad: 1, precio_unit: 65)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 7, descripcionId: 704, cantidadTotal: 2, recurso: "Pruebas", unidad: "serv", cant_unidad: 1, precio_unit: 30)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 7, descripcionId: 799, cantidadTotal: 1, recurso: "Extras sanitarias", unidad: "unid", cant_unidad: 1, precio_unit: 16)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 8, descripcionId: 801, cantidadTotal: 6, recurso: "Adoquin", unidad: "m2", cant_unidad: 1, precio_unit: 18)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 8, descripcionId: 802, cantidadTotal: 5, recurso: "Jardineria", unidad: "m2", cant_unidad: 1, precio_unit: 12)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 8, descripcionId: 803, cantidadTotal: 3, recurso: "Muros", unidad: "m2", cant_unidad: 1, precio_unit: 25)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 8, descripcionId: 899, cantidadTotal: 1, recurso: "Extras urbanizacion", unidad: "unid", cant_unidad: 1, precio_unit: 20)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 9, descripcionId: 901, cantidadTotal: 1, recurso: "Extras generales", unidad: "unid", cant_unidad: 1, precio_unit: 50)
    }
    
    func poblarProyectoConExtrasPendientes(proyectoId: Int) {
        if proyectoYaTieneRecursos(proyectoId: proyectoId) { return }
        
        asegurarPartidas(proyectoId: proyectoId)
        asegurarTodasLasDescripcionesDeProyecto(proyectoId: proyectoId)
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 1, descripcionId: 101, cantidadTotal: 10, recurso: "Mano de obra", unidad: "jornal", cant_unidad: 1, precio_unit: 12)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 1, descripcionId: 102, cantidadTotal: 8, recurso: "Cal", unidad: "bolsa", cant_unidad: 1, precio_unit: 6)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 1, descripcionId: 103, cantidadTotal: 12, recurso: "Excavadora", unidad: "hora", cant_unidad: 1, precio_unit: 20)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 1, descripcionId: 104, cantidadTotal: 9, recurso: "Material selecto", unidad: "m3", cant_unidad: 1, precio_unit: 8)
        
       
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 2, descripcionId: 201, cantidadTotal: 5, recurso: "Concreto", unidad: "m3", cant_unidad: 1, precio_unit: 90)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 2, descripcionId: 202, cantidadTotal: 4, recurso: "Hierro", unidad: "qq", cant_unidad: 1, precio_unit: 35)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 2, descripcionId: 203, cantidadTotal: 3, recurso: "Anclajes", unidad: "set", cant_unidad: 1, precio_unit: 22)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 2, descripcionId: 204, cantidadTotal: 6, recurso: "Losa base", unidad: "m2", cant_unidad: 1, precio_unit: 40)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 3, descripcionId: 301, cantidadTotal: 7, recurso: "Columnas", unidad: "unid", cant_unidad: 1, precio_unit: 55)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 3, descripcionId: 302, cantidadTotal: 7, recurso: "Vigas", unidad: "unid", cant_unidad: 1, precio_unit: 45)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 3, descripcionId: 303, cantidadTotal: 7, recurso: "Losas", unidad: "m2", cant_unidad: 1, precio_unit: 35)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 3, descripcionId: 304, cantidadTotal: 2, recurso: "Escaleras", unidad: "tramo", cant_unidad: 1, precio_unit: 80)
        
       
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 4, descripcionId: 401, cantidadTotal: 10, recurso: "Bloques", unidad: "ciento", cant_unidad: 1, precio_unit: 30)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 4, descripcionId: 402, cantidadTotal: 8, recurso: "Tabiques", unidad: "ciento", cant_unidad: 1, precio_unit: 28)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 4, descripcionId: 403, cantidadTotal: 6, recurso: "Mortero", unidad: "m3", cant_unidad: 1, precio_unit: 20)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 4, descripcionId: 404, cantidadTotal: 5, recurso: "Repello", unidad: "m2", cant_unidad: 1, precio_unit: 10)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 5, descripcionId: 501, cantidadTotal: 3, recurso: "Ceramica", unidad: "caja", cant_unidad: 1, precio_unit: 15)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 5, descripcionId: 502, cantidadTotal: 2, recurso: "Pintura", unidad: "galon", cant_unidad: 1, precio_unit: 20)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 5, descripcionId: 503, cantidadTotal: 2, recurso: "Puertas", unidad: "unid", cant_unidad: 1, precio_unit: 80)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 5, descripcionId: 504, cantidadTotal: 2, recurso: "Ventanas", unidad: "unid", cant_unidad: 1, precio_unit: 60)
        
       
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 6, descripcionId: 601, cantidadTotal: 10, recurso: "Tuberia EMT", unidad: "barra", cant_unidad: 1, precio_unit: 7)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 6, descripcionId: 602, cantidadTotal: 8, recurso: "Cable", unidad: "rollo", cant_unidad: 1, precio_unit: 18)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 6, descripcionId: 603, cantidadTotal: 2, recurso: "Tableros", unidad: "unid", cant_unidad: 1, precio_unit: 120)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 6, descripcionId: 604, cantidadTotal: 10, recurso: "Luminarias", unidad: "unid", cant_unidad: 1, precio_unit: 14)
        
        
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 7, descripcionId: 701, cantidadTotal: 10, recurso: "PVC", unidad: "barra", cant_unidad: 1, precio_unit: 8)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 7, descripcionId: 702, cantidadTotal: 4, recurso: "Lavabos", unidad: "unid", cant_unidad: 1, precio_unit: 45)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 7, descripcionId: 703, cantidadTotal: 4, recurso: "WC", unidad: "unid", cant_unidad: 1, precio_unit: 65)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 7, descripcionId: 704, cantidadTotal: 2, recurso: "Pruebas", unidad: "serv", cant_unidad: 1, precio_unit: 30)
        
       
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 8, descripcionId: 801, cantidadTotal: 6, recurso: "Adoquin", unidad: "m2", cant_unidad: 1, precio_unit: 18)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 8, descripcionId: 802, cantidadTotal: 5, recurso: "Jardineria", unidad: "m2", cant_unidad: 1, precio_unit: 12)
        llenarDescripcionDemo(proyectoId: proyectoId, partidaId: 8, descripcionId: 803, cantidadTotal: 3, recurso: "Muros", unidad: "m2", cant_unidad: 1, precio_unit: 25)
        
    }
    
    func obtenerCerradoId(proyectoId: Int) -> ProyectoCerrado? {
        let query = """
        SELECT id, nombre, ubicacion, fecha_cierre
        FROM proyectos
        WHERE id = ? AND estado = 'CERRADO';
        """
        
        var stmt: OpaquePointer?
        var proyecto: ProyectoCerrado? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(proyectoId))
            
            if sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let nombre = String(cString: sqlite3_column_text(stmt, 1))
                let ubicacion = sqlite3_column_text(stmt, 2) != nil ? String(cString: sqlite3_column_text(stmt, 2)) : ""
                let fecha_cierre = sqlite3_column_text(stmt, 3) != nil ? String(cString: sqlite3_column_text(stmt, 3)) : ""
                let total = obtenerTotalProyecto(proyectoId: id)
                
                proyecto = ProyectoCerrado(
                    id: id,
                    nombre: nombre,
                    ubicacion: ubicacion,
                    fecha_cierre: fecha_cierre,
                    total: total
                )
            }
        } else {
            print("Error al preparar obtenerCerradoId")
        }
        
        sqlite3_finalize(stmt)
        return proyecto
    }
}
