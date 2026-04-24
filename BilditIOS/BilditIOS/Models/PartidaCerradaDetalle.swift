//
//  PartidaCerradaDetalle.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 23/4/26.
//

import Foundation

struct PartidaCerradaDetalle: Identifiable {
    var id: Int
    var nombre: String
    var total: Double
    var descripciones: [Descripcion]
}
