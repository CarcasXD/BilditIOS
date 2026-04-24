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
    
    @Environment(\.presentationMode) var presentationMode
    @State private var partidas: [PartidaCerradaDetalle] = []
    @State private var expandidaId: Int? = nil
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 0) {
                    backButtonView
                    encabezadoView
                    listaPartidasView
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
                            
                            Image(systemName: expandidaId == partida.id ? "chevron.down" : "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 14)
                        .frame(width: 320, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if expandidaId == partida.id {
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
    
    var botonCerrarView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 24)
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
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
    
    func cargarPartidas() {
        partidas = DatabaseManager.shared.obtenerPartidasCerradasDetalle(proyectoId: proyecto.id)
    }
    
    func toggleExpand(_ id: Int) {
        if expandidaId == id {
            expandidaId = nil
        } else {
            expandidaId = id
        }
    }
    
    func formatearDinero(_ valor: Double) -> String {
        String(format: "%.2f", valor)
    }
}

struct DetalleProyectoCerradoView_Previews: PreviewProvider {
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
        
        let proyectoPrueba = ProyectoCerrado(
            id: 2,
            nombre: "Constructora Sinai",
            ubicacion: "Quezaltepeque",
            fechaCierre: "26/04/2024",
            total: 7550.00
        )
        
        NavigationView {
            DetalleProyectoCerradoView(usuario: usuarioPrueba, proyecto: proyectoPrueba)
        }
    }
}
