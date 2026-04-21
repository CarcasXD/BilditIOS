//
//  PantallaInicioView.swift
//  BilditIOS
//
//  Created by Carlos Arìstides Rivas Calderòn on 20/4/26.
//

import SwiftUI

struct PantallaInicioView: View {
    
    let proyectos = [
        "Grupo Roble - Santa Ana",
        "Constructora Sinai - Quezaltepeque",
        "Grupo Siman - Ahuachapan"
    ]
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .center, spacing: 0) {
                    
                    Spacer()
                        .frame(height: 30)
                    
                    Text("Hola Jose!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .underline()
                    
                    Spacer()
                        .frame(height: 18)
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            print("Nuevo proyecto")
                        }) {
                            Text("Nuevo proyecto")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 130, height: 42)
                                .background(Color(red: 0.05, green: 0.62, blue: 0.67))
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            print("Proyectos cerrados")
                        }) {
                            Text("Proyectos cerrados")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 150, height: 42)
                                .background(Color(red: 0.05, green: 0.62, blue: 0.67))
                                .cornerRadius(12)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 30)
                    
                    VStack(spacing: 18) {
                        ForEach(proyectos, id: \.self) { proyecto in
                            ProyectoCardView(nombreProyecto: proyecto)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 30)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
    }
}

struct ProyectoCardView: View {
    let nombreProyecto: String
    
    var body: some View {
        Button(action: {
            print("Abrir proyecto: \(nombreProyecto)")
        }) {
            HStack {
                Text(nombreProyecto)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding()
            .frame(width: 320, height: 72)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PantallaInicioView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PantallaInicioView()
        }
    }
}
