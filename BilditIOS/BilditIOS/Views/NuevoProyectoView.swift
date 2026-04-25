//
//  NuevoProyectoView.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 20/4/26.
//

import SwiftUI

struct NuevoProyectoView: View {
    
    var usuario: Usuario
    var proy_editar: Proyecto? = nil
    
    @Environment(\.presentationMode) var present_mode
    
    @State private var mostrar_msj = false
    @State private var mensaje = ""
    
    @State private var tipo_proy = ""
    @State private var fecha_ini = ""
    @State private var fecha_fin = ""
    
    @State private var cliente_nom = ""
    @State private var cliente_tel = ""
    @State private var cliente_correo = ""
    @State private var cliente_contacto = ""
    @State private var cliente_nit = ""
    
    @State private var pres_total = ""
    @State private var anticipo = ""
    @State private var costo_mat = ""
    @State private var costo_mano = ""
    
    @State private var coordenadas = ""
    @State private var direccion = ""
    @State private var area_terreno = ""
    @State private var tipo_terreno = ""
    @State private var accesos = ""
    
    @State private var supervisor = ""
    @State private var arquitecto = ""
    @State private var contratistas = ""
    @State private var trabajadores = ""
    
    var body: some View {
        ZStack {
            fondoView
            
            ScrollView {
                VStack(spacing: 0) {
                    backButtonView
                    encabezadoView
                    infoProyectoView
                    infoClienteView
                    infoEconomicaView
                    ubicacionView
                    equipoView
                    botonGuardarView
                    espacioFinalView
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if let proyecto = proy_editar {
                tipo_proy = proyecto.nombre
                direccion = proyecto.ubicacion
            }
        }
    }
    
    var fondoView: some View {
        Color(.systemGray6)
            .edgesIgnoringSafeArea(.all)
    }
    
    var backButtonView:some View{
        HStack{
            Button(action:{
                present_mode.wrappedValue.dismiss()
            }){
                HStack(spacing: 4){
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
        VStack(spacing: 8) {
            Spacer().frame(height: 20)
            
            Text(proy_editar == nil ? "Nuevo Proyecto" : "Editar Proyecto")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.black)
            
            Rectangle()
                .fill(Color.black)
                .frame(width: 280, height: 2)
        }
    }
    
    var infoProyectoView: some View {
        VStack(spacing: 10) {
            seccionTitulo("Información del Proyecto")
            
            cajaSeccion {
                campoFormulario("Tipo de proyecto:", text: $tipo_proy)
                campoFormulario("Fecha de inicio prevista:", text: $fecha_ini)
                campoFormulario("Fecha estimada de finalización:", text: $fecha_fin)
            }
        }
        .padding(.top, 12)
    }
    
    var infoClienteView: some View {
        VStack(spacing: 10) {
            seccionTitulo("Información del Cliente")
            
            cajaSeccion {
                campoFormulario("Nombre del cliente o empresa:", text: $cliente_nom)
                campoFormulario("Teléfono de contacto:", text: $cliente_tel)
                campoFormulario("Correo electrónico:", text: $cliente_correo)
                campoFormulario("Persona de contacto:", text: $cliente_contacto)
                campoFormulario("NIT:", text: $cliente_nit)
            }
        }
        .padding(.top, 16)
    }
    
    var infoEconomicaView: some View {
        VStack(spacing: 10) {
            seccionTitulo("Información Económica")
            
            cajaSeccion {
                campoFormulario("Presupuesto estimado total:", text: $pres_total)
                campoFormulario("Anticipo recibido (%):", text: $anticipo)
                campoFormulario("Costo de materiales estimado:", text: $costo_mat)
                campoFormulario("Costo de mano de obra estimado:", text: $costo_mano)
            }
        }
        .padding(.top, 16)
    }
    
    var ubicacionView: some View {
        VStack(spacing: 10) {
            seccionTitulo("Ubicación y logística")
            
            cajaSeccion {
                campoFormulario("Coordenadas GPS:", text: $coordenadas)
                campoFormulario("Dirección completa:", text: $direccion)
                campoFormulario("Área del terreno (m²):", text: $area_terreno)
                campoFormulario("Tipo de terreno o suelo:", text: $tipo_terreno)
                campoFormulario("Accesos importantes:", text: $accesos)
            }
        }
        .padding(.top, 16)
    }
    
    var equipoView: some View {
        VStack(spacing: 10) {
            seccionTitulo("Equipo y responsables")
            
            cajaSeccion {
                campoFormulario("Supervisor o ingeniero responsable:", text: $supervisor)
                campoFormulario("Arquitecto o diseñador:", text: $arquitecto)
                campoFormulario("Contratistas / subcontratistas:", text: $contratistas)
                campoFormulario("Número de trabajadores:", text: $trabajadores)
            }
        }
        .padding(.top, 16)
    }
    
    var botonGuardarView: some View {
        VStack(spacing: 0) {
            Button(action: {
                guardarProyecto()
            }) {
                Text(proy_editar == nil ? "Guardar" : "Actualizar")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 210, height: 48)
                    .background(Color(red: 0.05, green: 0.62, blue: 0.67))
                    .cornerRadius(14)
            }
            
            if mostrar_msj {
                Text(mensaje)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(mensaje == "Proyecto guardado correctamente" || mensaje == "Proyecto actualizado correctamente" ? .green : .red)
                    .padding(.top, 10)
            }
        }
        .padding(.top, 24)
    }
    
    var espacioFinalView: some View {
        Spacer().frame(height: 30)
    }
    
    
    /*
     * Entradas: tipo_proy, direccion, usuario.id, proy_editar
     * Salida: crea o actualiza un proyecto y muestra mensajes al usuario
     * Valor de retorno: ninguno
     * Función: guardar un nuevo proyecto o actualizar uno existente
     * Variables: resultado, mensaje, mostrar_msj
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: insertarProyecto(), actualizarProyecto()
     */
    func guardarProyecto() {
        if tipo_proy.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            mensaje = "Ingresa el tipo de proyecto"
            mostrar_msj = true
            return
        }
        
        if direccion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            mensaje = "Ingresa la dirección"
            mostrar_msj = true
            return
        }
        
        var resultado = false
        
        if let proyecto = proy_editar {
            resultado = DatabaseManager.shared.actualizarProyecto(
                id: proyecto.id,
                nombre: tipo_proy,
                ubicacion: direccion
            )
            
            if resultado {
                mensaje = "Proyecto actualizado correctamente"
            } else {
                mensaje = "No se pudo actualizar el proyecto"
            }
        } else {
            resultado = DatabaseManager.shared.insertarProyecto(
                nombre: tipo_proy,
                ubicacion: direccion,
                usuarioId: usuario.id
            )
            
            if resultado {
                mensaje = "Proyecto guardado correctamente"
            } else {
                mensaje = "No se pudo guardar el proyecto"
            }
        }
        
        mostrar_msj = true
        
        if resultado {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                present_mode.wrappedValue.dismiss()
            }
        }
    }
    
    func seccionTitulo(_ texto: String) -> some View {
        Text(texto)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.black)
    }
    
    func cajaSeccion<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.yellow, lineWidth: 2)
        )
        .cornerRadius(18)
    }
    
    func campoFormulario(_ titulo: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titulo)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.black)
            
            TextField("", text: text)
                .textFieldStyle(PlainTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
        }
    }
}

struct NuevoProyectoView_Previews: PreviewProvider {
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
            NuevoProyectoView(usuario: usr_prueba, proy_editar: nil)
        }
    }
}
