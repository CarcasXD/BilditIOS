//
//  Recurso.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 23/4/26.
//

import Foundation

struct Recurso: Identifiable {
    var id: Int
    var nombreRecurso: String
    var unidad: String
    var cantidadPorUnidad: Double
    var precioUnitario: Double
    
    var subtotal: Double {
        cantidadPorUnidad * precioUnitario
    }
}
