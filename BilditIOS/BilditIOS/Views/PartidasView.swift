//
//  PartidasView.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 21/4/26.
//

import SwiftUI

struct PartidasView: View {
    
    var usuario: Usuario
    var proyecto: Proyecto
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var partidas: [Partida] = []
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
                    tituloPartidasView
                    listaPartidasView
                    botonCerrarView
                    mensajeView
                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            DatabaseManager.shared.asegurarPartidasDeProyecto(proyectoId: proyecto.id)
            cargarPartidas()
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
            
            Spacer().frame(height: 20)
        }
    }
    
    var tituloPartidasView: some View {
        HStack {
            Text("Partidas")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.bottom, 14)
    }
    
    var listaPartidasView: some View {
        VStack(spacing: 12) {
            ForEach(partidas) { partida in
                NavigationLink(
                    destination: EspecificacionesView(
                        usuario: usuario,
                        proyecto: proyecto,
                        partida: partida
                    )
                ) {
                    PartidaCardView(partida: partida)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    var botonCerrarView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 28)
            
            Button(action: {
                intentarCerrarProyecto()
            }) {
                Text("Cerrar proyecto")
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
                    .foregroundColor(mensaje == "Proyecto cerrado correctamente" ? .green : .red)
                    .padding(.top, 12)
            }
        }
    }
    
    func cargarPartidas() {
        partidas = DatabaseManager.shared.obtenerPartidasDeProyecto(proyectoId: proyecto.id)
        print("Cantidad de partidas: \(partidas.count)")
    }
    
    func intentarCerrarProyecto() {
        let sePuedeCerrar = DatabaseManager.shared.todasLasPartidasTerminadas(proyectoId: proyecto.id)
        
        if sePuedeCerrar {
            let resultado = DatabaseManager.shared.cerrarProyecto(proyectoId: proyecto.id)
            
            if resultado {
                mensaje = "Proyecto cerrado correctamente"
                mostrarMensaje = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                mensaje = "No se pudo cerrar el proyecto"
                mostrarMensaje = true
            }
        } else {
            mensaje = "Todas las partidas deben estar terminadas"
            mostrarMensaje = true
        }
    }
}

struct PartidaCardView: View {
    let partida: Partida
    
    var body: some View {
        HStack {
            Text(partida.nombre)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)
            
            Spacer()
            
            estadoIcono
        }
        .padding(.horizontal, 14)
        .frame(width: 320, height: 54)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    var estadoIcono: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(colorEstado)
                .frame(width: 24, height: 24)
            
            Image(systemName: iconoEstado)
                .foregroundColor(.black)
                .font(.system(size: 13, weight: .bold))
        }
    }
    
    var colorEstado: Color {
        if partida.estado == "TERMINADA" {
            return .green
        } else if partida.estado == "EN PROCESO" {
            return .yellow
        } else {
            return .red
        }
    }
    
    var iconoEstado: String {
        if partida.estado == "TERMINADA" {
            return "checkmark"
        } else if partida.estado == "EN PROCESO" {
            return "arrow.triangle.2.circlepath"
        } else {
            return "xmark"
        }
    }
}

struct PartidasView_Previews: PreviewProvider {
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
            usuarioId: 1,
            fechaCierre: ""
        )
        
        NavigationView {
            PartidasView(usuario: usuarioPrueba, proyecto: proyectoPrueba)
        }
    }
}
