//
//  NuevoProyectoView.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 20/4/26.
//

import SwiftUI

struct NuevoProyectoView: View {
    
    var usuario: Usuario
    var proyectoEditar: Proyecto? = nil
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var mostrarMensaje = false
    @State private var mensaje = ""
    
    @State private var tipoProyecto = ""
    @State private var fechaInicio = ""
    @State private var fechaFinal = ""
    
    @State private var clienteNombre = ""
    @State private var clienteTelefono = ""
    @State private var clienteCorreo = ""
    @State private var clienteContacto = ""
    @State private var clienteNIT = ""
    
    @State private var presupuestoTotal = ""
    @State private var anticipo = ""
    @State private var costoMateriales = ""
    @State private var costoManoObra = ""
    
    @State private var coordenadas = ""
    @State private var direccion = ""
    @State private var areaTerreno = ""
    @State private var tipoTerreno = ""
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
            if let proyecto = proyectoEditar {
                tipoProyecto = proyecto.nombre
                direccion = proyecto.ubicacion
            }
        }
    }
    
    var fondoView: some View {
        Color(.systemGray6)
            .edgesIgnoringSafeArea(.all)
    }
    
    var encabezadoView: some View {
        VStack(spacing: 8) {
            Spacer().frame(height: 20)
            
            Text(proyectoEditar == nil ? "Nuevo Proyecto" : "Editar Proyecto")
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
                campoFormulario("Tipo de proyecto:", text: $tipoProyecto)
                campoFormulario("Fecha de inicio prevista:", text: $fechaInicio)
                campoFormulario("Fecha estimada de finalización:", text: $fechaFinal)
            }
        }
        .padding(.top, 12)
    }
    
    var infoClienteView: some View {
        VStack(spacing: 10) {
            seccionTitulo("Información del Cliente")
            
            cajaSeccion {
                campoFormulario("Nombre del cliente o empresa:", text: $clienteNombre)
                campoFormulario("Teléfono de contacto:", text: $clienteTelefono)
                campoFormulario("Correo electrónico:", text: $clienteCorreo)
                campoFormulario("Persona de contacto:", text: $clienteContacto)
                campoFormulario("NIT:", text: $clienteNIT)
            }
        }
        .padding(.top, 16)
    }
    
    var infoEconomicaView: some View {
        VStack(spacing: 10) {
            seccionTitulo("Información Económica")
            
            cajaSeccion {
                campoFormulario("Presupuesto estimado total:", text: $presupuestoTotal)
                campoFormulario("Anticipo recibido (%):", text: $anticipo)
                campoFormulario("Costo de materiales estimado:", text: $costoMateriales)
                campoFormulario("Costo de mano de obra estimado:", text: $costoManoObra)
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
                campoFormulario("Área del terreno (m²):", text: $areaTerreno)
                campoFormulario("Tipo de terreno o suelo:", text: $tipoTerreno)
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
                Text(proyectoEditar == nil ? "Guardar" : "Actualizar")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 210, height: 48)
                    .background(Color(red: 0.05, green: 0.62, blue: 0.67))
                    .cornerRadius(14)
            }
            
            if mostrarMensaje {
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
    
    func guardarProyecto() {
        if tipoProyecto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            mensaje = "Ingresa el tipo de proyecto"
            mostrarMensaje = true
            return
        }
        
        if direccion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            mensaje = "Ingresa la dirección"
            mostrarMensaje = true
            return
        }
        
        var resultado = false
        
        if let proyecto = proyectoEditar {
            resultado = DatabaseManager.shared.actualizarProyecto(
                id: proyecto.id,
                nombre: tipoProyecto,
                ubicacion: direccion
            )
            
            if resultado {
                mensaje = "Proyecto actualizado correctamente"
            } else {
                mensaje = "No se pudo actualizar el proyecto"
            }
        } else {
            resultado = DatabaseManager.shared.insertarProyecto(
                nombre: tipoProyecto,
                ubicacion: direccion,
                usuarioId: usuario.id
            )
            
            if resultado {
                mensaje = "Proyecto guardado correctamente"
            } else {
                mensaje = "No se pudo guardar el proyecto"
            }
        }
        
        mostrarMensaje = true
        
        if resultado {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                presentationMode.wrappedValue.dismiss()
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
        let usuarioPrueba = Usuario(
            id: 1,
            usuario: "carcas",
            nombre: "Carlos",
            apellido: "Rivas",
            correo: "carlos@bildit.com",
            telefono: "77886754",
            ocupacion: "Ingeniero"
        )
        
        NavigationView {
            NuevoProyectoView(usuario: usuarioPrueba, proyectoEditar: nil)
        }
    }
}
