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
    
    @Environment(\.presentationMode) var present_mode
    
    @State private var recursos: [Recurso] = []
    @State private var cant_total_txt = ""
    @State private var total_unidad: Double = 0
    @State private var total_final: Double = 0
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
            
            Spacer().frame(height: 16)
        }
    }
    
    var resumenView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Total de medidas consideradas en el proyecto:")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
            
            TextField("0", text: $cant_total_txt)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("Total por unidad: $\(formatearDinero(total_unidad))")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            Text("Total: $\(formatearDinero(total_final))")
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
                    Text(recurso.nom_recurso)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    HStack {
                        Text(recurso.unidad)
                        Spacer()
                        Text("\(formatearNumero(recurso.cant_unidad))")
                        Spacer()
                        Text("$\(formatearDinero(recurso.precio_unit))")
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
            if mostrar_msj {
                Text(mensaje)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(mensaje == "Guardado correctamente" ? .green : .red)
                    .padding(.top, 10)
            }
        }
    }
    
    
    /*
     * Entradas: proyecto.id, partida.id, descripcion.id
     * Salida: carga recursos, cantidad total, total por unidad y total final
     * Valor de retorno: ninguno
     * Función: mostrar el detalle económico de una descripción
     * Variables: recursos, cant_total_txt, total_unidad, total_final
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: obtenerRecursos(), obtenerCantDesc(), obtenertotal_unidadDescripcion()
     */
    func cargarDatos() {
        recursos = DatabaseManager.shared.obtenerRecursos(
            proyectoId: proyecto.id,
            partidaId: partida.id,
            descripcionId: descripcion.id
        )
        
        let cantidad = DatabaseManager.shared.obtenerCantDesc(
            proyectoId: proyecto.id,
            partidaId: partida.id,
            descripcionId: descripcion.id
        )
        
        cant_total_txt = cantidad == 0 ? "" : formatearNumero(cantidad)
        
        total_unidad = DatabaseManager.shared.obtenerTotalUnidadDesc(
            proyectoId: proyecto.id,
            partidaId: partida.id,
            descripcionId: descripcion.id
        )
        
        total_final = cantidad * total_unidad
    }
    
    
    /*
     * Entradas: cant_total_txt, proyecto.id, partida.id, descripcion.id
     * Salida: guarda la cantidad total y recalcula la información mostrada
     * Valor de retorno: ninguno
     * Función: registrar la cantidad total considerada en el proyecto para una descripción
     * Variables: texto, cantidad, resultado, mensaje, mostrar_msj
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: actCantDesc(), cargarDatos()
     */
    func guardarCantidadTotal() {
        let texto = cant_total_txt.replacingOccurrences(of: ",", with: ".")
        let cantidad = Double(texto) ?? 0
        
        let resultado = DatabaseManager.shared.actCantDesc(
            proyectoId: proyecto.id,
            partidaId: partida.id,
            descripcionId: descripcion.id,
            cantidadTotal: cantidad
        )
        
        if resultado {
            mensaje = "Guardado correctamente"
            mostrar_msj = true
            cargarDatos()
        } else {
            mensaje = "No se pudo guardar"
            mostrar_msj = true
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
            DetalleDescripcionView(
                usuario: usr_prueba,
                proyecto: proy_prueba,
                partida: partida_prueba,
                descripcion: desc_prueba
            )
        }
    }
}
