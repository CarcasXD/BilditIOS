//
//  Recurso.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 23/4/26.
//

import Foundation

struct Recurso: Identifiable {
    var id: Int
    var nom_recurso: String
    var unidad: String
    var cant_unidad: Double
    var precio_unit: Double
    
    var subtotal: Double {
        cant_unidad * precio_unit
    }
}
