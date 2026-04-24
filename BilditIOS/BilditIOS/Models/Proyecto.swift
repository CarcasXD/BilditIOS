//
//  Proyecto.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 20/4/26.
//

import Foundation

struct Proyecto: Identifiable {
    var id: Int
    var nombre: String
    var ubicacion: String
    var estado: String
    var usuarioId: Int
    var fechaCierre: String = ""
}
