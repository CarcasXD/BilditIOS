//
//  PantallaInicioView.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 20/4/26.
//

import SwiftUI

struct PantallaInicioView: View {
    
    var usuario: Usuario
    @State private var proyectos: [Proyecto] = []
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 0) {
                    encabezadoView
                    botonesView
                    listaProyectosView
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
    
    var encabezadoView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 30)
            
            Text("Hola \(usuario.nombre)!")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
                .underline()
            
            Spacer().frame(height: 18)
        }
    }
    
    var botonesView: some View {
        HStack(spacing: 12) {
            NavigationLink(destination: NuevoProyectoView(usuario: usuario, proy_editar: nil)) {
                Text("Nuevo proyecto")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 130, height: 42)
                    .background(Color(red: 0.05, green: 0.62, blue: 0.67))
                    .cornerRadius(12)
            }
            
            NavigationLink(destination: ProyectosCerradosView(usuario: usuario)) {
                Text("Proyectos cerrados")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 150, height: 42)
                    .background(Color(red: 0.05, green: 0.62, blue: 0.67))
                    .cornerRadius(12)
            }
        }
    }
    
    var listaProyectosView: some View {
        VStack(spacing: 18) {
            Spacer().frame(height: 30)
            
            ForEach(proyectos) { proyecto in
                ProyectoCardView(
                    proyecto: proyecto,
                    usuario: usuario,
                    onDelete: {
                        borrarProyecto(proyecto)
                    }
                )
            }
        }
    }
    
    /*
     * Entradas: usuario.id
     * Salida: carga en pantalla los proyectos abiertos del usuario autenticado
     * Valor de retorno: ninguno
     * Función: consultar y actualizar la lista de proyectos abiertos
     * Variables: proyectos
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: obtener_abiertos()
     */
    func cargarProyectos() {
        proyectos = DatabaseManager.shared.obtener_abiertos(usuarioId: usuario.id)
    }
    
    /*
     * Entradas: proyecto
     * Salida: elimina el proyecto seleccionado y refresca la lista visible
     * Valor de retorno: ninguno
     * Función: borrar un proyecto desde la pantalla de inicio
     * Variables: resultado
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: eliminarProyecto(), cargarProyectos()
     */
    func borrarProyecto(_ proyecto: Proyecto) {
        let resultado = DatabaseManager.shared.eliminarProyecto(id: proyecto.id)
        
        if resultado {
            cargarProyectos()
        }
    }
}

struct ProyectoCardView: View {
    let proyecto: Proyecto
    let usuario: Usuario
    var onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("\(proyecto.nombre) - \(proyecto.ubicacion)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            
            HStack(spacing: 10) {
                NavigationLink(destination: PartidasView(usuario: usuario, proyecto: proyecto)) {
                    Text("Ver")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 36)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: NuevoProyectoView(usuario: usuario, proy_editar: proyecto)) {
                    Text("Editar")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 90, height: 36)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    onDelete()
                }) {
                    Text("Eliminar")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 90, height: 36)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .frame(width: 320)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

struct PantallaInicioView_Previews: PreviewProvider {
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
            PantallaInicioView(usuario: usr_prueba)
        }
    }
}
