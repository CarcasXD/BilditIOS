//
//  AgregarRecursoView.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 23/4/26.
//

import SwiftUI

struct AgregarRecursoView: View {
    
    var usuario: Usuario
    var proyecto: Proyecto
    var partida: Partida
    var descripcion: Descripcion
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var nombreRecurso = ""
    @State private var unidad = ""
    @State private var cantidadXUnidad = ""
    @State private var precioUnitario = ""
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
                    formularioView
                    botonAgregarView
                    mensajeView
                    Spacer().frame(height: 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
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
            
            Text("Agregar recurso")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            Spacer().frame(height: 20)
        }
    }
    
    var formularioView: some View {
        VStack(spacing: 18) {
            campoFormulario("Recurso", text: $nombreRecurso)
            campoFormulario("Unidad", text: $unidad)
            campoFormulario("Cantidad X Unidad", text: $cantidadXUnidad)
            campoFormulario("Precio unitario", text: $precioUnitario)
        }
    }
    
    var botonAgregarView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 24)
            
            Button(action: {
                agregarRecurso()
            }) {
                Text("Agregar")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 180, height: 44)
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
                    .foregroundColor(mensaje == "Recurso agregado correctamente" ? .green : .red)
                    .padding(.top, 12)
            }
        }
    }
    
    func campoFormulario(_ titulo: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titulo)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
            
            TextField(titulo, text: text)
                .textFieldStyle(PlainTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(titulo == "Cantidad X Unidad" || titulo == "Precio unitario" ? .decimalPad : .default)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
        }
    }
    
    func agregarRecurso() {
        if nombreRecurso.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            unidad.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            cantidadXUnidad.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            precioUnitario.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            mensaje = "Completa todos los campos"
            mostrarMensaje = true
            return
        }
        
        let cantidad = Double(cantidadXUnidad.replacingOccurrences(of: ",", with: ".")) ?? 0
        let precio = Double(precioUnitario.replacingOccurrences(of: ",", with: ".")) ?? 0
        
        if cantidad <= 0 || precio <= 0 {
            mensaje = "Cantidad y precio deben ser mayores a 0"
            mostrarMensaje = true
            return
        }
        
        let resultado = DatabaseManager.shared.insertarRecurso(
            proyectoId: proyecto.id,
            partidaId: partida.id,
            descripcionId: descripcion.id,
            nombreRecurso: nombreRecurso,
            unidad: unidad,
            cantidadPorUnidad: cantidad,
            precioUnitario: precio
        )
        
        if resultado {
            mensaje = "Recurso agregado correctamente"
            mostrarMensaje = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                presentationMode.wrappedValue.dismiss()
            }
        } else {
            mensaje = "No se pudo agregar el recurso"
            mostrarMensaje = true
        }
    }
}

struct AgregarRecursoView_Previews: PreviewProvider {
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
        
        let partidaPrueba = Partida(id: 5, nombre: "Acabados", estado: "EN PROCESO")
        let descripcionPrueba = Descripcion(id: 501, nombre: "Pisos", subtotal: 0)
        
        NavigationView {
            AgregarRecursoView(
                usuario: usuarioPrueba,
                proyecto: proyectoPrueba,
                partida: partidaPrueba,
                descripcion: descripcionPrueba
            )
        }
    }
}
