# BilditIOS 🏗️📱
**Sistema Móvil de Control Presupuestario y Auditoría de Obras Civiles**

## 📝 Descripción del Proyecto

**BilditIOS** es una aplicación móvil nativa diseñada bajo el ecosistema Apple para optimizar la gestión de costos, control de presupuestos y auditoría técnica de proyectos de construcción civil. Desarrollada de manera declarativa y reactiva, la aplicación permite a ingenieros y supervisores documentar el progreso real de las obras en campo, inyectar recursos transaccionales y exportar reportes financieros inmutables en formato PDF de alta fidelidad legal sin depender de servicios de red externos.

---

## 🛠️ Características Principales

*   **Autenticación y Registro Seguro:** Control de acceso local parametrizado con enmascaramiento dinámico de datos y validaciones sintácticas estrictas mediante expresiones regulares (`NSPredicate`).
*   **Gestión Presupuestaria de Obra:** Desglose jerárquico de presupuestos estructurado de forma descendente: *Proyectos ➔ Partidas (Rubros) ➔ Descripciones (Conceptos) ➔ Recursos (Insumos)*.
*   **Arquitectura Inmutable de Cierre:** Capa de datos dividida entre el estado dinámico (proyectos abiertos) e histórico (proyectos cerrados), garantizando la inmutabilidad de las auditorías de liquidación financiera.
*   **Reportería Vectorial Nativa:** Generador interno de documentos PDF (`UIGraphicsPDFRenderer`) calibrado para formatos A4 con algoritmos de control de desbordamiento y saltos de página automáticos.
*   **Vista Previa Integrada:** Interoperabilidad con el framework `QuickLook` para desplegar visualizaciones previas con soporte nativo de impresión y compartición de iOS.
*   **Persistencia de Alto Rendimiento:** Motor relacional basado directamente en la API nativa de **SQLite3 en C**, asegurando velocidad, eficiencia en hardware limitado y un consumo nulo de dependencias de red externos (*Offline-First*).

---

## 📐 Arquitectura y Estructura del Código

El proyecto está diseñado bajo las directrices del desarrollo declarativo de **SwiftUI**, controlando el flujo gráfico mediante estados reactivos y aislando las responsabilidades lógicas en capas de abstracción modulares:

```text
BilditIOS/
│
├── BilditIOSApp.swift          # Punto de entrada de la aplicación e inicio de la BD
├── ContentView.swift             # Enrutador raíz y contenedor de navegación inicial
├── Info.plist                    # Manifiesto de configuración y permisos del sistema
│
├── Models/                       # Estructuras de datos inmutables (Identifiable)
│   ├── Usuario.swift
│   ├── Proyecto.swift / ProyectoCerrado.swift
│   ├── Partida.swift / PartidaCerradaDetalle.swift
│   ├── Descripcion.swift
│   └── Recurso.swift
│
├── Views/                        # Interfaces gráficas y subvistas reutilizables
│   ├── LoginView.swift / RegistroView.swift
│   ├── PantallaInicioView.swift / NuevoProyectoView.swift
│   ├── PartidasView.swift / EspecificacionesView.swift
│   ├── DetalleDescripcionView.swift / AgregarRecursoView.swift
│   └── PDFPreviewView.swift
│
└── Resources/                    # Capa de Servicios lógicos y Persistencia
    ├── DatabaseManager.swift     # Manejador transaccional nativo de SQLite3 en C
    └── PDFGenerator.swift        # Motor matemático de renderizado vectorial PDF
