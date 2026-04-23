//
//  DetalleDescripcionView.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 23/4/26.
//

import SwiftUI

struct DetalleDescripcionView: View {
    
    var usuario: Usuario
    var proyecto: Proyecto
    var partida: Partida
    var descripcion: Descripcion
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var recursos: [Recurso] = []
    @State private var cantidadTotalTexto = ""
    @State private var totalPorUnidad: Double = 0
    @State private var totalFinal: Double = 0
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
                    resumenView
                    botonesView
                    listaRecursosView
                    mensajeView
                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            cargarDatos()
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
            
            Text("\(partida.nombre) - \(descripcion.nombre)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            Spacer().frame(height: 16)
        }
    }
    
    var resumenView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Total de medidas consideradas en el proyecto:")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
            
            TextField("0", text: $cantidadTotalTexto)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("Total por unidad: $\(formatearDinero(totalPorUnidad))")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            Text("Total: $\(formatearDinero(totalFinal))")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
        }
    }
    
    var botonesView: some View {
        HStack(spacing: 20) {
            NavigationLink(
                destination: AgregarRecursoView(
                    usuario: usuario,
                    proyecto: proyecto,
                    partida: partida,
                    descripcion: descripcion
                )
            ) {
                Text("Agregar recurso")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 140, height: 42)
                    .background(Color(red: 0.05, green: 0.62, blue: 0.67))
                    .cornerRadius(12)
            }
            
            Button(action: {
                guardarCantidadTotal()
            }) {
                Text("Guardar")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 140, height: 42)
                    .background(Color(red: 0.05, green: 0.62, blue: 0.67))
                    .cornerRadius(12)
            }
        }
        .padding(.top, 18)
        .padding(.bottom, 20)
    }
    
    var listaRecursosView: some View {
        VStack(spacing: 14) {
            ForEach(recursos) { recurso in
                VStack(alignment: .leading, spacing: 8) {
                    Text(recurso.nombreRecurso)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    HStack {
                        Text(recurso.unidad)
                        Spacer()
                        Text("\(formatearNumero(recurso.cantidadPorUnidad))")
                        Spacer()
                        Text("$\(formatearDinero(recurso.precioUnitario))")
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    
                    Text("Subtotal: $\(formatearDinero(recurso.subtotal))")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
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
        }
    }
    
    var mensajeView: some View {
        VStack(spacing: 0) {
            if mostrarMensaje {
                Text(mensaje)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(mensaje == "Guardado correctamente" ? .green : .red)
                    .padding(.top, 10)
            }
        }
    }
    
    func cargarDatos() {
        recursos = DatabaseManager.shared.obtenerRecursos(
            proyectoId: proyecto.id,
            partidaId: partida.id,
            descripcionId: descripcion.id
        )
        
        let cantidad = DatabaseManager.shared.obtenerCantidadTotalDescripcion(
            proyectoId: proyecto.id,
            partidaId: partida.id,
            descripcionId: descripcion.id
        )
        
        cantidadTotalTexto = cantidad == 0 ? "" : formatearNumero(cantidad)
        
        totalPorUnidad = DatabaseManager.shared.obtenerTotalPorUnidadDescripcion(
            proyectoId: proyecto.id,
            partidaId: partida.id,
            descripcionId: descripcion.id
        )
        
        totalFinal = cantidad * totalPorUnidad
    }
    
    func guardarCantidadTotal() {
        let texto = cantidadTotalTexto.replacingOccurrences(of: ",", with: ".")
        let cantidad = Double(texto) ?? 0
        
        let resultado = DatabaseManager.shared.actualizarCantidadTotalDescripcion(
            proyectoId: proyecto.id,
            partidaId: partida.id,
            descripcionId: descripcion.id,
            cantidadTotal: cantidad
        )
        
        if resultado {
            mensaje = "Guardado correctamente"
            mostrarMensaje = true
            cargarDatos()
        } else {
            mensaje = "No se pudo guardar"
            mostrarMensaje = true
        }
    }
    
    func formatearDinero(_ valor: Double) -> String {
        String(format: "%.2f", valor)
    }
    
    func formatearNumero(_ valor: Double) -> String {
        String(format: "%.1f", valor)
    }
}

struct DetalleDescripcionView_Previews: PreviewProvider {
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
        
        let partidaPrueba = Partida(id: 5, nombre: "Acabados", estado: "EN PROCESO")
        let descripcionPrueba = Descripcion(id: 501, nombre: "Pisos", subtotal: 0)
        
        NavigationView {
            DetalleDescripcionView(
                usuario: usuarioPrueba,
                proyecto: proyectoPrueba,
                partida: partidaPrueba,
                descripcion: descripcionPrueba
            )
        }
    }
}
