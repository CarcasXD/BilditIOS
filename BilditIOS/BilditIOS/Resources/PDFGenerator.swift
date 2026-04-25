//
//  PDFGenerator.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 24/4/26.
//

import Foundation
import UIKit

class PDFGenerator {
    
    static let shared = PDFGenerator()
    
    private init() { }
    
    
    /*
     * Entradas: proyecto, partidas
     * Salida: genera y guarda un archivo PDF en la carpeta Documents del dispositivo
     * Valor de retorno: URL?
     * Función: construir el reporte PDF de un proyecto cerrado con sus partidas y descripciones
     * Variables: fileName, docs_url, pdfURL, renderer, y, pageWidth, pageHeight, margin
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: formatearDinero(), UIGraphicsPDFRenderer
     */
    func generarPDFProyectoCerrado(proyecto: ProyectoCerrado, partidas: [PartidaCerradaDetalle]) -> URL? {
        
        let fileName = "Proyecto_\(proyecto.nombre.replacingOccurrences(of: " ", with: "_")).pdf"
        
        let docs_url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdf_url = docs_url.appendingPathComponent(fileName)
        
        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let margin: CGFloat = 30
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
        
        do {
            try renderer.writePDF(to: pdf_url) { context in
                context.beginPage()
                
                var y: CGFloat = margin
                
                func dibujarTexto(_ texto: String, x: CGFloat, y: CGFloat, font: UIFont) -> CGFloat {
                    let atributos: [NSAttributedString.Key: Any] = [
                        .font: font
                    ]
                    
                    let textoRect = CGRect(x: x, y: y, width: pageWidth - 2 * margin, height: 1000)
                    let textoNSString = texto as NSString
                    let bounding = textoNSString.boundingRect(
                        with: CGSize(width: textoRect.width, height: 1000),
                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                        attributes: atributos,
                        context: nil
                    )
                    
                    textoNSString.draw(in: CGRect(x: x, y: y, width: textoRect.width, height: bounding.height), withAttributes: atributos)
                    return bounding.height
                }
                
                y += dibujarTexto("Reporte de Proyecto Cerrado", x: margin, y: y, font: UIFont.boldSystemFont(ofSize: 24))
                y += 12
                y += dibujarTexto("Proyecto: \(proyecto.nombre)", x: margin, y: y, font: UIFont.boldSystemFont(ofSize: 18))
                y += 6
                y += dibujarTexto("Ubicación: \(proyecto.ubicacion)", x: margin, y: y, font: UIFont.systemFont(ofSize: 16))
                y += 6
                y += dibujarTexto("Fecha de cierre: \(proyecto.fecha_cierre)", x: margin, y: y, font: UIFont.systemFont(ofSize: 16))
                y += 6
                y += dibujarTexto("Total del proyecto: $\(formatearDinero(proyecto.total))", x: margin, y: y, font: UIFont.boldSystemFont(ofSize: 16))
                y += 20
                
                y += dibujarTexto("Detalle de partidas", x: margin, y: y, font: UIFont.boldSystemFont(ofSize: 20))
                y += 12
                
                for partida in partidas {
                    
                    if y > pageHeight - 140 {
                        context.beginPage()
                        y = margin
                    }
                    
                    y += dibujarTexto("Partida: \(partida.nombre)", x: margin, y: y, font: UIFont.boldSystemFont(ofSize: 17))
                    y += 4
                    y += dibujarTexto("Total partida: $\(formatearDinero(partida.total))", x: margin, y: y, font: UIFont.systemFont(ofSize: 15))
                    y += 8
                    
                    for descripcion in partida.descripciones {
                        if descripcion.subtotal > 0 {
                            
                            if y > pageHeight - 100 {
                                context.beginPage()
                                y = margin
                            }
                            
                            y += dibujarTexto("• \(descripcion.nombre): $\(formatearDinero(descripcion.subtotal))", x: margin + 14, y: y, font: UIFont.systemFont(ofSize: 14))
                            y += 4
                        }
                    }
                    
                    y += 10
                }
            }
            
            print("PDF generado en: \(pdf_url.path)")
            return pdf_url
            
        } catch {
            print("Error al generar PDF: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func formatearDinero(_ valor: Double) -> String {
        String(format: "%.2f", valor)
    }
}
