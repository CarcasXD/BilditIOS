//
//  RegistroView.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 19/4/26.
//

import SwiftUI

struct RegistroView: View {
    
    @Environment(\.presentationMode) var present_mode
    @State var usuario = ""
    @State var contrasena = ""
    @State var nombre = ""
    @State var apellido = ""
    @State var correo = ""
    @State var telefono = ""
    @State var ocupacion = "Ingeniero"
    @State var mostrar_msj = false
    @State var mensaje = ""
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 0) {
                    bloqueEncabezado
                    bloqueUsuario
                    bloqueContrasena
                    bloqueNombre
                    bloqueApellido
                    bloqueCorreo
                    bloqueTelefono
                    bloqueOcupacion
                    bloqueBoton
                }
                .frame(maxWidth: .infinity)
                .navigationTitle("")
            }
        }
    }
    
    var bloqueEncabezado: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 30)
            
            Image("logo_bildit")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
                .cornerRadius(20)
            
            Spacer().frame(height: 10)
            
            Text("Bienvenido a Bildit")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            Text("Llena tus datos")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.black)
            
            Spacer().frame(height: 20)
        }
    }
    
    var bloqueUsuario: some View {
        bloqueTexto(titulo: "Usuario", placeholder: "Usuario", texto: $usuario)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
    
    var bloqueContrasena: some View {
        bloqueSeguro(titulo: "Contrasena", placeholder: "Contrasena", texto: $contrasena)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
    
    var bloqueNombre: some View {
        bloqueTexto(titulo: "Nombre", placeholder: "Nombre", texto: $nombre)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
    
    var bloqueApellido: some View {
        bloqueTexto(titulo: "Apellido", placeholder: "Apellido", texto: $apellido)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
    
    var bloqueCorreo: some View {
        bloqueTexto(titulo: "Correo", placeholder: "Correo", texto: $correo)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
    
    var bloqueTelefono: some View {
        bloqueTexto(titulo: "Telefono", placeholder: "Telefono", texto: $telefono)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .keyboardType(.numberPad)
    }
    
    var bloqueOcupacion: some View {
        VStack(spacing: 0) {
            Text("Ocupacion")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
            
            Spacer().frame(height: 12)
            
            Menu(ocupacion) {
                Button("Ingeniero") {
                    ocupacion = "Ingeniero"
                }
                Button("Contratista") {
                    ocupacion = "Contratista"
                }
                Button("Maestro de obra") {
                    ocupacion = "Maestro de obra"
                }
            }
            .frame(width: 220, height: 40)
            
            Spacer().frame(height: 20)
        }
    }
    
    var bloqueBoton: some View {
        VStack(spacing: 0) {
            Button(action: {
                guardarUsuario()
            }) {
                Text("Guardar")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 180, height: 44)
                    .background(Color(red: 0.05, green: 0.62, blue: 0.67))
                    .cornerRadius(14)
            }
            if mostrar_msj {
                Text(mensaje)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(mensaje == "Usuario guardado correctamente" ? .green : .red)
                    .padding(.top, 10)
            }
            Spacer().frame(height: 30)
        }
    }
    
    func bloqueTexto(titulo: String, placeholder: String, texto: Binding<String>) -> some View {
        VStack(spacing: 0) {
            Text(titulo)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
            
            Spacer().frame(height: 10)
            
            TextField(placeholder, text: texto)
                .frame(width: 240, height: 35)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 240, height: 1)
            
            Spacer().frame(height: 18)
        }
    }
    
    func bloqueSeguro(titulo: String, placeholder: String, texto: Binding<String>) -> some View {
        VStack(spacing: 0) {
            Text(titulo)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
            
            Spacer().frame(height: 10)
            
            SecureField(placeholder, text: texto)
                .frame(width: 240, height: 35)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 240, height: 1)
            
            Spacer().frame(height: 18)
        }
    }
    
    
    /*
     * Entradas: usuario, contrasena, nombre, apellido, correo, telefono, ocupacion
     * Salida: registra un nuevo usuario en la base de datos y muestra mensajes de éxito o error
     * Valor de retorno: ninguno
     * Función: guardar un nuevo usuario desde la pantalla de registro
     * Variables: resultado, mensaje, mostrar_msj
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: soloLetras(), correoValido(), telefonoValido(), insertarUsuario()
     */
    func guardarUsuario() {
        if usuario.isEmpty || contrasena.isEmpty || nombre.isEmpty || apellido.isEmpty {
            mensaje = "Completa los campos obligatorios"
            mostrar_msj = true
            return
        }
        
        if !soloLetras(nombre) {
            mensaje = "El nombre solo debe contener letras"
            mostrar_msj = true
            return
        }
        
        if !soloLetras(apellido) {
            mensaje = "El apellido solo debe contener letras"
            mostrar_msj = true
            return
        }
        
        if !correo.isEmpty && !correoValido(correo) {
            mensaje = "Correo invalido"
            mostrar_msj = true
            return
        }
        
        if !telefono.isEmpty && !telefonoValido(telefono) {
            mensaje = "Telefono invalido. Usa 0000-0000"
            mostrar_msj = true
            return
        }
        
        let resultado = DatabaseManager.shared.insertarUsuario(
            usuario: usuario,
            contrasena: contrasena,
            nombre: nombre,
            apellido: apellido,
            correo: correo,
            telefono: telefono,
            ocupacion: ocupacion
        )
        
        if resultado {
            mensaje = "Usuario guardado correctamente"
            mostrar_msj = true
            
            usuario = ""
            contrasena = ""
            nombre = ""
            apellido = ""
            correo = ""
            telefono = ""
            ocupacion = "Ingeniero"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                present_mode.wrappedValue.dismiss()
            }
        } else {
            mensaje = "No se pudo guardar el usuario"
            mostrar_msj = true
        }
    }
    
    /*
     * Entradas: texto
     * Salida: indica si el contenido contiene únicamente letras y espacios
     * Valor de retorno: Bool
     * Función: validar campos de nombre y apellido
     * Variables: patron, predicado
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: NSPredicate()
     */
    func soloLetras(_ texto: String) -> Bool {
        let patron = "^[A-Za-zÁÉÍÓÚáéíóúÑñ ]+$"
        let predicado = NSPredicate(format: "SELF MATCHES %@", patron)
        return predicado.evaluate(with: texto)
    }

    /*
     * Entradas: texto
     * Salida: verifica si el correo cumple con una estructura válida
     * Valor de retorno: Bool
     * Función: validar correo electrónico del usuario
     * Variables: patron, predicado
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: NSPredicate()
     */
    func correoValido(_ texto: String) -> Bool {
        let patron = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let predicado = NSPredicate(format: "SELF MATCHES %@", patron)
        return predicado.evaluate(with: texto)
    }

    /*
     * Entradas: texto
     * Salida: verifica si el teléfono cumple el formato 0000-0000
     * Valor de retorno: Bool
     * Función: validar número telefónico ingresado en el registro
     * Variables: patron, predicado
     * Fecha: 24-04-2026
     * Autor: Carlos Arístides Rivas Calderón
     * Rutinas anexas: NSPredicate()
     */
    func telefonoValido(_ texto: String) -> Bool {
        let patron = "^[0-9]{4}-[0-9]{4}$"
        let predicado = NSPredicate(format: "SELF MATCHES %@", patron)
        return predicado.evaluate(with: texto)
    }
    func formatearTelefono(_ texto: String) -> String {
        let numeros = texto.filter { $0.isNumber }
        let limitado = String(numeros.prefix(8))
        
        if limitado.count > 4 {
            let inicio = limitado.prefix(4)
            let fin = limitado.suffix(limitado.count - 4)
            return "\(inicio)-\(fin)"
        } else {
            return limitado
        }
    }
}

struct RegistroView_Previews: PreviewProvider {
    static var previews: some View {
        RegistroView()
    }
}
