# UniRent - Guía de Configuración para Desarrolladores

¡Bienvenidos al proyecto UniRent! Esta guía les ayudará a clonar el repositorio, configurar sus entornos locales y ejecutar tanto el **Backend en Spring Boot** como el **Frontend en Flutter**.

---

## 🛠️ Requisitos Previos

Antes de empezar, asegúrate de tener instalado:
1. **[Java Development Kit (JDK) 17+](https://adoptium.net/)**: Necesario para correr Spring Boot.
2. **[Flutter SDK](https://docs.flutter.dev/get-started/install)**: Necesario para la aplicación móvil.
3. Un editor de código como **VS Code** o **Android Studio**.

---

## ⚙️ 1. Configurar el Backend (Spring Boot)

El backend maneja la lógica central, base de datos (Firestore vía Admin SDK) y la validación de tokens.

1. Abre una terminal y dirígete a la carpeta del backend:
   ```bash
   cd backend
   ```
2. Ejecuta el servidor usando el wrapper de Maven incluido. Esto descargará las dependencias y levantará el servidor en el puerto `8080`:
   - **En Windows:**
     ```cmd
     .\mvnw.cmd clean spring-boot:run
     ```
   - **En Mac/Linux:**
     ```bash
     ./mvnw clean spring-boot:run
     ```
3. Verás en la consola que el servidor inicia. ¡Listo! El backend ya está funcionando localmente.

---

## 📱 2. Configurar el Frontend (Flutter)

La aplicación móvil se conecta al backend local para operar. 

1. Abre otra terminal y dirígete a la carpeta del frontend:
   ```bash
   cd frontend
   ```
2. Descarga todas las dependencias de Flutter:
   ```bash
   flutter pub get
   ```

### 🔌 Paso Clave A: Conectar la App a tu propio Backend
Para que tu celular o emulador pueda comunicarse con el Spring Boot que acabas de encender, necesitas decirle cuál es la IP de tu computador.

1. Abre el archivo: `frontend/lib/core/network/api_client.dart`
2. Busca la variable `baseUrl`.
3. Cambia la IP `192.168.100.30` por la IP local de tu propio computador en tu red WiFi. 
   - *Nota: Si estás usando el emulador oficial de Android en tu PC, puedes usar la IP especial `10.0.2.2`*.
   ```dart
   // Cambia esto por tu propia IP local
   final String baseUrl = 'http://TU_IP_AQUI:8080/api'; 
   ```

### 🔐 Paso Clave B: Configurar Firebase (SHA-1)
Nuestra app usa Google Sign-In y Autenticación por SMS a través de Firebase. Por razones de seguridad de Google, **cada computador de desarrollo necesita registrar su propia "huella digital" (SHA-1) en el proyecto de Firebase.** Si omites este paso, el inicio de sesión fallará.

1. **Obtén el SHA-1 de tu computador:**
   - Abre una terminal en la carpeta `frontend/android` y ejecuta:
     - **Windows:** `.\gradlew signingReport`
     - **Mac/Linux:** `./gradlew signingReport`
   - En el texto resultante, busca la clave `SHA1` bajo la variante `debug`.
2. **Regístralo en Firebase:**
   - Pide al administrador del proyecto (quien creó el Firebase de UniRent) que te invite al proyecto en la consola web de Firebase.
   - Ve a "Configuración del proyecto" (la rueda de engranaje).
   - En la sección "Tus apps", selecciona la app de Android.
   - Haz clic en **Agregar huella digital** y pega el SHA-1 que obtuviste.
   - ¡Listo! (Los cambios en Firebase pueden tardar 2-3 minutos en reflejarse).

---

## ▶️ 3. Ejecutar la Aplicación

Con el backend corriendo y las configuraciones listas, ¡es hora de correr la app!

1. Asegúrate de tener un emulador abierto o tu teléfono conectado por USB (con depuración USB activada).
2. En la carpeta `frontend`, ejecuta:
   ```bash
   flutter run
   ```
3. ¡Disfruta programando en UniRent! 🚀
