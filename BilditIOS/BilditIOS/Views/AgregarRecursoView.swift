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
    
    @Environment(\.presentationMode) var present_mode
    
    @State private var nom_recurso = ""
    @State private var unidad = ""
    @State private var cant_x_unid = ""
    @State private var precio_unit = ""
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
            campoFormulario("Recurso", text: $nom_recurso)
            campoFormulario("Unidad", text: $unidad)
            campoFormulario("Cantidad X Unidad", text: $cant_x_unid)
            campoFormulario("Precio unitario", text: $precio_unit)
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
            if mostrar_msj {
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
    
    
    /*
     * Entradas: nom_recurso, unidad, cant_x_unid, precio_unit, proyecto.id, partida.id, descripcion.id
     * Salida: inserta un recurso y actualiza subtotales y estados
     * Valor de retorno: ninguno
     * Función: registrar un nuevo recurso dentro del detalle de una descripción
     * Variables: cantidad, precio, resultado, mensaje, mostrar_msj
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: insertarRecurso()
     */
    func agregarRecurso() {
        if nom_recurso.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            unidad.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            cant_x_unid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            precio_unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            mensaje = "Completa todos los campos"
            mostrar_msj = true
            return
        }
        
        let cantidad = Double(cant_x_unid.replacingOccurrences(of: ",", with: ".")) ?? 0
        let precio = Double(precio_unit.replacingOccurrences(of: ",", with: ".")) ?? 0
        
        if cantidad <= 0 || precio <= 0 {
            mensaje = "Cantidad y precio deben ser mayores a 0"
            mostrar_msj = true
            return
        }
        
        let resultado = DatabaseManager.shared.insertarRecurso(
            proyectoId: proyecto.id,
            partidaId: partida.id,
            descripcionId: descripcion.id,
            nom_recurso: nom_recurso,
            unidad: unidad,
            cant_unidad: cantidad,
            precio_unit: precio
        )
        
        if resultado {
            mensaje = "Recurso agregado correctamente"
            mostrar_msj = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                present_mode.wrappedValue.dismiss()
            }
        } else {
            mensaje = "No se pudo agregar el recurso"
            mostrar_msj = true
        }
    }
}

struct AgregarRecursoView_Previews: PreviewProvider {
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
        
        let partida_prueba = Partida(id: 5, nombre: "Acabados", estado: "EN PROCESO")
        let desc_prueba = Descripcion(id: 501, nombre: "Pisos", subtotal: 0)
        
        NavigationView {
            AgregarRecursoView(
                usuario: usr_prueba,
                proyecto: proy_prueba,
                partida: partida_prueba,
                descripcion: desc_prueba
            )
        }
    }
}
