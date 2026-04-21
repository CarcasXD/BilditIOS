//
//  LoginView.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 19/4/26.
//

import SwiftUI

struct LoginView: View {
    
    @State private var usuario: String = ""
    @State private var contrasena: String = ""
    @State private var irAPantallaInicio = false
    @State private var mostrarError = false
    
    var body: some View {
        ZStack {
            fondoView
            
            ScrollView {
                VStack(spacing: 0) {
                    logoView
                    usuarioView
                    contrasenaView
                    botonLoginView
                    errorView
                    registroView
                    navigationLoginView
                    espacioFinalView
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarHidden(true)
    }
    
    var fondoView: some View {
        Color(.systemGray6)
            .edgesIgnoringSafeArea(.all)
    }
    
    var logoView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 40)
            
            Image("logo_bildit")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .cornerRadius(35)
        }
    }
    
    var usuarioView: some View {
        VStack(spacing: 8) {
            Text("Usuario")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            
            VStack(spacing: 4) {
                TextField("Usuario", text: $usuario)
                    .autocapitalization(.none)
                    .disableAutocorrection(/*@START_MENU_TOKEN@*/false/*@END_MENU_TOKEN@*/)
                    .font(.system(size: 20))
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }
            .padding(.horizontal, 35)
        }
        .padding(.top, 20)
    }
    
    var contrasenaView: some View {
        VStack(spacing: 8) {
            Text("Contrasena")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            
            VStack(spacing: 4) {
                SecureField("Contrasena", text: $contrasena)
                    .autocapitalization(.none)
                    .disableAutocorrection(false)
                    .font(.system(size: 20))
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }
            .padding(.horizontal, 35)
        }
        .padding(.top, 20)
    }
    
    var botonLoginView: some View {
        VStack(spacing: 0) {
            Button(action: {
                iniciarSesion()
            }) {
                Text("Iniciar Sesion")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 220, height: 50)
                    .background(Color(red: 0.05, green: 0.62, blue: 0.67))
                    .cornerRadius(15)
            }
        }
        .padding(.top, 25)
    }
    
    var errorView: some View {
        VStack(spacing: 0) {
            if mostrarError {
                Text("Usuario o contrasena incorrectos")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.red)
                    .padding(.top, 12)
            }
        }
    }
    
    var registroView: some View {
        VStack(spacing: 14) {
            Text("No tienes cuenta?")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            NavigationLink(destination: RegistroView()) {
                Text("Registrate aqui")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 150, height: 35)
                    .background(Color(red: 0.05, green: 0.62, blue: 0.67))
                    .cornerRadius(15)
            }
        }
        .padding(.top, 18)
    }
    
    var navigationLoginView: some View {
        NavigationLink(
            destination: PantallaInicioView(),
            isActive: $irAPantallaInicio
        ) {
            EmptyView()
        }
    }
    
    var espacioFinalView: some View {
        Spacer()
            .frame(height: 30)
    }
    
    func iniciarSesion() {
        let loginValido = DatabaseManager.shared.validarLogin(
            usuario: usuario,
            contrasena: contrasena
        )
        
        if loginValido {
            mostrarError = false
            irAPantallaInicio = true
        } else {
            mostrarError = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView()
        }
    }
}
