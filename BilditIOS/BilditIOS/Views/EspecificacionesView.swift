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
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var descripciones: [Descripcion] = []
    @State private var totalPartida: Double = 0
    @State private var mostrarMensaje = false
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
                presentationMode.wrappedValue.dismiss()
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
            if mostrarMensaje {
                Text(mensaje)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(mensaje == "Partida cerrada correctamente" ? .green : .red)
                    .padding(.top, 12)
            }
        }
    }
    
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
    
    func cerrarPartidaActual() {
        let resultado = DatabaseManager.shared.cerrarPartida(
            proyectoId: proyecto.id,
            partidaId: partida.id
        )
        
        if resultado {
            mensaje = "Partida cerrada correctamente"
            mostrarMensaje = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                presentationMode.wrappedValue.dismiss()
            }
        } else {
            mensaje = "No se pudo cerrar la partida"
            mostrarMensaje = true
        }
    }
    
    func formatearDinero(_ valor: Double) -> String {
        String(format: "%.0f", valor)
    }
}

struct EspecificacionesView_Previews: PreviewProvider {
    static var previews: some View {
        let usuarioPrueba = Usuario(
            id: 1,
            usuario: "carcas",
            nombre: "Carlos",
            apellido: "Rivas",
            correo: "carlos@bildit.com",
            telefono: "77886754",
            ocupacion: "Ingeniero"
        )
        
        let proyectoPrueba = Proyecto(
            id: 1,
            nombre: "Grupo Roble",
            ubicacion: "Urbanizacion El Trebol, Pasaje Maquilishuat, #31",
            estado: "ABIERTO",
            usuarioId: 1
        )
        
        let partidaPrueba = Partida(
            id: 5,
            nombre: "Acabados",
            estado: "EN PROCESO"
        )
        
        NavigationView {
            EspecificacionesView(
                usuario: usuarioPrueba,
                proyecto: proyectoPrueba,
                partida: partidaPrueba
            )
        }
    }
}
