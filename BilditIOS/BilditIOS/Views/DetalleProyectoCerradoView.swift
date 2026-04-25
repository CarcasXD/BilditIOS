//
//  DetalleProyectoCerradoView.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 23/4/26.
//

import SwiftUI

struct DetalleProyectoCerradoView: View {
    
    var usuario: Usuario
    var proyecto: ProyectoCerrado
    
    @State private var pdf_url: URL? = nil
    @State private var ver_pdf = false
    @State private var mostrar_msj = false
    @State private var mensaje = ""
    @Environment(\.presentationMode) var present_mode
    @State private var partidas: [PartidaCerradaDetalle] = []
    @State private var expandida_id: Int? = nil
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 0) {
                    backButtonView
                    encabezadoView
                    listaPartidasView
                    botonPDFView
                    mensajeView
                    botonCerrarView
                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            cargarPartidas()
        }
        .sheet(isPresented: $ver_pdf) {
            if let url = pdf_url {
                PDFPreviewView(url: url)
            }
        }
    }
    
    var backButtonView: some View {
        HStack {
            Button(action: {
                present_mode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
            }
            Spacer()
        }
        .padding(.top, 20)
    }
    
    var encabezadoView: some View {
        VStack(spacing: 6) {
            Spacer().frame(height: 10)
            
            Text(proyecto.nombre)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            Rectangle()
                .fill(Color.black)
                .frame(width: 250, height: 2)
            
            Text(proyecto.ubicacion)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            Spacer().frame(height: 12)
            
            Text("Total: $\(formatearDinero(proyecto.total))")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
            
            Spacer().frame(height: 18)
            
            HStack {
                Text("Partidas")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            Spacer().frame(height: 14)
        }
    }
    
    var listaPartidasView: some View {
        VStack(spacing: 12) {
            ForEach(partidas) { partida in
                VStack(spacing: 0) {
                    Button(action: {
                        toggleExpand(partida.id)
                    }) {
                        HStack {
                            Text(partida.nombre)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image(systemName: expandida_id == partida.id ? "chevron.down" : "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 14)
                        .frame(width: 320, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if expandida_id == partida.id {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(partida.descripciones) { descripcion in
                                if descripcion.subtotal > 0 {
                                    Text("\(descripcion.nombre): $\(formatearDinero(descripcion.subtotal))")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding()
                        .frame(width: 320, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    var botonPDFView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 24)
            
            Button(action: {
                generarPDF()
            }) {
                Text("Generar PDF")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 180, height: 44)
                    .background(Color.red)
                    .cornerRadius(14)
            }
        }
    }
    
    /*
     * Entradas: proyecto.id, proyecto
     * Salida: genera el PDF del proyecto cerrado, lo guarda localmente y abre su vista previa
     * Valor de retorno: ninguno
     * Función: exportar un proyecto cerrado en formato PDF
     * Variables: detalle, url, pdf_url, mensaje, mostrar_msj, ver_pdf
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: obtenerPartidasCerr(), generarPDFProyectoCerrado()
     */
    func generarPDF() {
        let detalle = DatabaseManager.shared.obtenerPartidasCerr(proyectoId: proyecto.id)
        
        if let url = PDFGenerator.shared.generarPDFProyectoCerrado(
            proyecto: proyecto,
            partidas: detalle
        ) {
            print("Ruta PDF: \(url.path)")
            pdf_url = url
            mensaje = "PDF generado correctamente"
            mostrar_msj = true
            ver_pdf = true
        } else {
            mensaje = "No se pudo generar el PDF"
            mostrar_msj = true
        }
    }
    var mensajeView: some View {
        VStack(spacing: 0) {
            if mostrar_msj {
                Text(mensaje)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(mensaje == "PDF generado correctamente" ? .green : .red)
                    .padding(.top, 10)
            }
        }
    }
    
    var botonCerrarView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 24)
            
            Button(action: {
                present_mode.wrappedValue.dismiss()
            }) {
                Text("Cerrar")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 180, height: 44)
                    .background(Color(red: 0.05, green: 0.62, blue: 0.67))
                    .cornerRadius(14)
            }
        }
    }
    
    
    /*
     * Entradas: proyecto.id
     * Salida: carga las partidas cerradas con sus descripciones y totales
     * Valor de retorno: ninguno
     * Función: mostrar el detalle interno de un proyecto cerrado
     * Variables: partidas
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: obtenerPartidasCerr()
     */
    func cargarPartidas() {
        partidas = DatabaseManager.shared.obtenerPartidasCerr(proyectoId: proyecto.id)
    }
    
    /*
     * Entradas: id
     * Salida: expande o contrae la visualización de los detalles de una partida
     * Valor de retorno: ninguno
     * Función: controlar el comportamiento del acordeón de partidas
     * Variables: expandida_id
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: ninguna
     */
    func toggleExpand(_ id: Int) {
        if expandida_id == id {
            expandida_id = nil
        } else {
            expandida_id = id
        }
    }
    
    func formatearDinero(_ valor: Double) -> String {
        String(format: "%.2f", valor)
    }
}

struct DetalleProyectoCerradoView_Previews: PreviewProvider {
    static var previews: some View {
        let usr_prueba = Usuario(
            id: 1,
            usuario: "carcas",
            nombre: "Carlos",
            apellido: "Rivas",
            correo: "carlos@bildit.com",
            telefono: "77886754",
            ocupacion: "Ingeniero"
        )
        
        let proy_prueba = ProyectoCerrado(
            id: 2,
            nombre: "Constructora Sinai",
            ubicacion: "Quezaltepeque",
            fecha_cierre: "26/04/2024",
            total: 7550.00
        )
        
        NavigationView {
            DetalleProyectoCerradoView(usuario: usr_prueba, proyecto: proy_prueba)
        }
    }
}
