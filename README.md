# 💰 Cuentamela

**Una aplicación de gestión de finanzas personales desarrollada con Flutter y Dart.**

Cuentamela ayuda a los usuarios a administrar sus finanzas personales mediante el registro de ingresos, gastos y objetivos de ahorro, ofreciendo una experiencia móvil sencilla e intuitiva.

## ✨ Características

* 💵 **Registro de ingresos:** Registra y administra tus ingresos personales.
* 💸 **Registro de gastos:** Lleva un control de tus gastos diarios.
* 🎯 **Objetivos de ahorro:** Crea hasta tres objetivos de compra y supervisa el progreso hacia cada meta.
* 👤 **Configuración del usuario:** Guarda el nombre del usuario y sus ingresos iniciales durante la configuración inicial.
* 💾 **Almacenamiento local de datos:** Guarda la información financiera directamente en el dispositivo mediante Hive.
* 🌓 **Temas claro y oscuro:** Elige la apariencia que mejor se adapte a tus preferencias.
* ⚡ **Gestión reactiva del estado:** Mantiene la interfaz sincronizada con los datos de la aplicación mediante Riverpod.

## 🛠️ Tecnologías utilizadas

* **Flutter** — Desarrollo de aplicaciones multiplataforma.
* **Dart** — Lenguaje de programación de la aplicación.
* **Hive** — Base de datos NoSQL local y ligera.
* **Material Design** — Componentes de interfaz y diseño visual.
* **Flutter Services** — Acceso a funcionalidades de la plataforma y del dispositivo.
* **Riverpod** — Gestión del estado y lógica reactiva de la aplicación.

## 🏗️ Descripción de la arquitectura

La aplicación combina una interfaz de usuario desarrollada con Flutter, Riverpod para la gestión del estado y Hive para el almacenamiento persistente de datos de forma local.

```text
Interfaz de usuario
        ↓
     Riverpod
        ↓
  Lógica de la aplicación
        ↓
  Base de datos local Hive
        ↓
 Almacenamiento del dispositivo
```

## 🔒 Privacidad

La información financiera se almacena localmente en el dispositivo. La aplicación está diseñada para gestionar datos financieros personales sin necesidad de una base de datos remota.

*Nota: La persistencia de los datos, el comportamiento de las copias de seguridad y la seguridad del dispositivo dependen de la implementación de la aplicación.*

## 🚀 Primeros pasos

### Requisitos previos

* Flutter SDK.
* Dart SDK.
* Android Studio o Visual Studio Code.

### Instalación

```bash
git clone https://github.com/SergioRaul11/Cuentamela_app_personal_de_gastos_ingresos.git
cd Cuentamela_app_personal_de_gastos_ingresos
flutter pub get
flutter run
```

## 📸 Capturas de pantalla



## 👨‍💻 Autor

**Sergio Orozco**

Desarrollador de software | Flutter y Dart

---

*Desarrollado para explorar el desarrollo de aplicaciones móviles, el almacenamiento local de datos, la gestión reactiva del estado y las herramientas para administrar las finanzas personales.*
