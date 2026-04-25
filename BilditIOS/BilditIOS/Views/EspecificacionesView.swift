//
//  EspecificacionesView.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 22/4/26.
//

import SwiftUI

struct EspecificacionesView: View {
    
    var usuario: Usuario
    var proyecto: Proyecto
    var partida: Partida
    
    @Environment(\.presentationMode) var present_mode
    
    @State private var descripciones: [Descripcion] = []
    @State private var totalPartida: Double = 0
    @State private var mostrar_msj = false
    @State private var mensaje = ""
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 0) {
                    backButtonView
                    encabezadoView
                    listaDescripcionesView
                    botonCerrarView
                    mensajeView
                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            DatabaseManager.shared.asegurarDescripciones(proyectoId: proyecto.id, partidaId: partida.id)
            cargarDescripciones()
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
            
            Spacer().frame(height: 18)
            
            HStack {
                Text(partida.nombre)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("$\(formatearDinero(totalPartida))")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                    .underline()
            }
            
            Spacer().frame(height: 18)
        }
    }
    
    var listaDescripcionesView: some View {
        VStack(spacing: 14) {
            ForEach(descripciones) { descripcion in
                NavigationLink(
                    destination: DetalleDescripcionView(
                        usuario: usuario,
                        proyecto: proyecto,
                        partida: partida,
                        descripcion: descripcion
                    )
                ) {
                    HStack {
                        Text(descripcion.nombre)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("$\(formatearDinero(descripcion.subtotal))")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 14)
                    .frame(width: 320, height: 54)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    var botonCerrarView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 28)
            
            Button(action: {
                cerrarPartidaActual()
            }) {
                Text("Cerrar partida")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 220, height: 48)
                    .background(Color(red: 0.05, green: 0.62, blue: 0.67))
                    .cornerRadius(14)
            }
        }
    }
    
    var mensajeView: some View {
        VStack(spacing: 0) {
            if mostrar_msj {
                Text(mensaje)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(mensaje == "Partida cerrada correctamente" ? .green : .red)
                    .padding(.top, 12)
            }
        }
    }
    
    
    /*
     * Entradas: proyecto.id, partida.id
     * Salida: carga las descripciones de la partida y el total correspondiente
     * Valor de retorno: ninguno
     * Función: consultar descripciones y total monetario de una partida
     * Variables: descripciones, totalPartida
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: asegurarDescripciones(), obtenerDescripcionesDePartida(), obtenerTotalPartida()
     */
    func cargarDescripciones() {
        descripciones = DatabaseManager.shared.obtenerDescripcionesDePartida(
            proyectoId: proyecto.id,
            partidaId: partida.id
        )
        
        totalPartida = DatabaseManager.shared.obtenerTotalPartida(
            proyectoId: proyecto.id,
            partidaId: partida.id
        )
    }
    
    /*
     * Entradas: proyecto.id, partida.id
     * Salida: cierra la partida actual si cumple las condiciones definidas
     * Valor de retorno: ninguno
     * Función: marcar una partida como terminada
     * Variables: resultado, mensaje, mostrar_msj
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: cerrarPartida()
     */
    func cerrarPartidaActual() {
        let resultado = DatabaseManager.shared.cerrarPartida(
            proyectoId: proyecto.id,
            partidaId: partida.id
        )
        
        if resultado {
            mensaje = "Partida cerrada correctamente"
            mostrar_msj = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                present_mode.wrappedValue.dismiss()
            }
        } else {
            mensaje = "No se pudo cerrar la partida"
            mostrar_msj = true
        }
    }
    
    func formatearDinero(_ valor: Double) -> String {
        String(format: "%.0f", valor)
    }
}

struct EspecificacionesView_Previews: PreviewProvider {
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
        
        let proy_prueba = Proyecto(
            id: 1,
            nombre: "Grupo Roble",
            ubicacion: "Urbanizacion El Trebol, Pasaje Maquilishuat, #31",
            estado: "ABIERTO",
            usuarioId: 1,
            fecha_cierre: ""
        )
        
        let partida_prueba = Partida(
            id: 5,
            nombre: "Acabados",
            estado: "EN PROCESO"
        )
        
        NavigationView {
            EspecificacionesView(
                usuario: usr_prueba,
                proyecto: proy_prueba,
                partida: partida_prueba
            )
        }
    }
}
