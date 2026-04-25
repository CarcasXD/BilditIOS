//
//  ProyectosCerradosView.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 23/4/26.
//

import SwiftUI

struct ProyectosCerradosView: View {
    
    var usuario: Usuario
    @Environment(\.presentationMode) var present_mode
    
    @State private var proyectos: [ProyectoCerrado] = []
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 0) {
                    backButtonView
                    encabezadoView
                    listaProyectosView
                    botonCerrarView
                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            cargarProyectos()
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
            
            HStack {
                Text("Historial de Proyectos")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .underline()
                Spacer()
            }
            
            Spacer().frame(height: 18)
            
            HStack {
                Text("Proyectos")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            Spacer().frame(height: 14)
        }
    }
    
    var listaProyectosView: some View {
        VStack(spacing: 14) {
            ForEach(proyectos) { proyecto in
                NavigationLink(
                    destination: DetalleProyectoCerradoView(usuario: usuario, proyecto: proyecto)
                ) {
                    ProyectoCerradoCardView(proyecto: proyecto)
                }
                .buttonStyle(PlainButtonStyle())
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
     * Entradas: usuario.id
     * Salida: carga la lista de proyectos cerrados del usuario
     * Valor de retorno: ninguno
     * Función: consultar el historial de proyectos cerrados
     * Variables: proyectos
     * Fecha: 25-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: obtenerCerradosRes()
     */
    func cargarProyectos() {
        proyectos = DatabaseManager.shared.obtenerCerradosRes(usuarioId: usuario.id)
    }
}

struct ProyectoCerradoCardView: View {
    let proyecto: ProyectoCerrado
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(proyecto.nombre) - \(proyecto.ubicacion)")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)
            
            HStack {
                Text("Fecha de finalización: \(proyecto.fecha_cierre)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("Total: $\(formatearDinero(proyecto.total))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
            }
        }
        .padding()
        .frame(width: 320, alignment: .leading)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.yellow, lineWidth: 2)
        )
        .cornerRadius(14)
    }
    
    func formatearDinero(_ valor: Double) -> String {
        String(format: "%.2f", valor)
    }
}

struct ProyectosCerradosView_Previews: PreviewProvider {
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
        
        NavigationView {
            ProyectosCerradosView(usuario: usr_prueba)
        }
    }
}
