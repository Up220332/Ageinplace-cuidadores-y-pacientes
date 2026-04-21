# AgeInPlace - Administrador

## 📋 Requisitos Previos

- **Flutter** (última versión estable)
- **Windows 10/11**
- **Visual Studio**  para ejecutar APP en Windows
- **Android Studio** para ejecutar APP en Android
- **Red UAH** Cuando pruebe la APP asegurese de estar conectado a la red interna de la UAH
- **Git** (opcional, para clonar)

Ejecuta ``` flutter doctor ``` paracomprobar que se ha instalado todo correctamente

## 🚀 Instalación

### 1. Clonar o descargar el proyecto

git clone https://github.com/Up220332/Ageinplace-cuidadores-y-pacientes (en terminal)
O descarga el ZIP y extrae los archivos. \
Debe clonarse en un carpeta no muy larga por ejemplo C://FlutterProyects

2. Abrir terminal en la carpeta del proyecto: \
``` cd ageinplace-cuidadores-y-pacientes```

3. Instalar dependencias: \
```flutter pub get```

4. Ejecutar la aplicación en Windows: \
```flutter build windows```
```flutter run -d windows```

El fichero main se encuentra en lib/main.dart

#### Solución de problemas
**Error de CMake (path mismatch)**
Si aparece error de CMake, ejecuta: \
```flutter clean rmdir /s build``` \
```flutter pub get``` \
```flutter build windows```
```flutter run -d windows```

**Error de dependencias** \
Si hay errores con los paquetes: \
```flutter pub upgrade``` \
```flutter clean``` \
```flutter pub get```

####  📦 Compilar para producción 
```flutter build windows --release ``` \
El ejecutable estará en: build/windows/runner/Release/

####  📝 Notas 
La primera ejecución puede tardar varios minutos
Asegúrate de tener conexión a internet para descargar dependencias
PostgreSQL debe estar instalado y configurado (si la app lo requiere)

# AUTORES
- Anahí Varela, Paulina Álvarez, Carlos Castillo y Albert Fazakas. 
- Supervisores: María del Carmen Pérez Rubio; Alejandro García Requejo; Álvaro Hernández
- Geintra Research Group, Universidad de Alcalá (UAH) 

# TRABAJOS FUTUROS
1. Añadir datos NILM en pantalla de visualización. \
Para ello en Influx.dart se deben cambiar las funciones GetLTSM, GetLTSMAlarms, GetADLs, GetEvADLs y GetConsumo; todas ellas llamadas en screen_Consumo.dart. Se debe enazar con la información guardada en postgres.

