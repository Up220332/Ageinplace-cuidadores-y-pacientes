# AgeInPlace - Administrador

## 📋 Requisitos Previos

- **Flutter** (última versión estable)
- **Windows 10/11**
- **Git** (opcional, para clonar)

## 🚀 Instalación

### 1. Clonar o descargar el proyecto

git clone https://github.com/Up220332/Ageinplace-cuidadores-y-pacientes
O descarga el ZIP y extrae los archivos.

2. Abrir terminal en la carpeta del proyecto
cd ageinplace

3. Instalar dependencias
flutter pub get

4. Ejecutar la aplicación
flutter run -d windows

Solución de problemas
Error de CMake (path mismatch)
Si aparece error de CMake, ejecuta:
flutter clean
rmdir /s build
flutter pub get
flutter run -d windows

Error de dependencias
Si hay errores con los paquetes:
flutter pub upgrade
flutter clean
flutter pub get

📦 Compilar para producción
flutter build windows --release
El ejecutable estará en: build/windows/runner/Release/

📝 Notas
La primera ejecución puede tardar varios minutos
Asegúrate de tener conexión a internet para descargar dependencias
PostgreSQL debe estar instalado y configurado (si la app lo requiere)