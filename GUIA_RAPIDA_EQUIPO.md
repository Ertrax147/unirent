# Guía Rápida para el Equipo de Desarrollo 🚀

Sigue estos pasos en orden para descargar el proyecto desde GitLab y ponerlo a correr en tu computador.

### 1. Clonar el repositorio
Abre una terminal en la carpeta donde quieras guardar el proyecto y ejecuta:
```bash
git clone https://gitlab.com/USUARIO_AQUI/unirent.git
cd unirent
```

### 2. Levantar el Backend (Base de Datos y API)
Abre otra terminal y entra a la carpeta del backend. Ejecuta el servidor:
```bash
cd backend

# En Windows:
.\mvnw.cmd clean spring-boot:run

# En Mac/Linux:
./mvnw clean spring-boot:run
```
*Deja esta terminal abierta para que el servidor siga corriendo.*

### 3. Configurar tu IP Local en la App
La aplicación móvil (Frontend) necesita saber cuál es la IP de tu computador para conectarse al backend que acabas de encender.

1. Abre una nueva terminal para saber tu IP local:
   - **Windows:** Escribe `ipconfig` y busca la "Dirección IPv4" (ejemplo: `192.168.0.15`).
   - **Mac/Linux:** Escribe `ifconfig` o `ip a`.
   - *Nota: Si vas a usar el emulador de Android Studio en tu propia PC, no busques tu IP. Usa siempre `10.0.2.2`.*
2. En tu editor de código (VS Code/Android Studio), abre el archivo:
   `frontend/lib/core/network/api_client.dart`
3. Cambia la variable `baseUrl` por tu IP local obtenida en el paso 1:
   ```dart
   final String baseUrl = 'http://TU_NUEVA_IP_AQUI:8080/api'; 
   ```

### 4. Configurar tu "Huella Digital" en Firebase (Obligatorio)
Para que te funcione el inicio de sesión con Google y SMS localmente, Firebase debe conocer tu computador.
1. Abre una terminal y dirígete a `frontend/android`.
2. Genera tu huella digital (SHA-1):
   - **Windows:** `.\gradlew signingReport`
   - **Mac/Linux:** `./gradlew signingReport`
3. Copia el código `SHA1` que aparece en la sección `debug`.
4. Pídele al dueño del proyecto de Firebase que te agregue en la consola web de Firebase -> "Configuración del Proyecto" -> "Tus apps" -> "Agregar Huella Digital" y pega tu SHA-1.

### 5. Instalar y Correr el Frontend (App Móvil)
Ahora que todo está conectado, instala las librerías de Flutter y ejecuta la app.

Asegúrate de tener tu celular conectado por USB (o un emulador abierto), entra a la carpeta `frontend` y ejecuta:
```bash
cd frontend
flutter pub get
flutter run
```

¡Listo! Ya tienes UniRent corriendo y configurado perfectamente en tu ambiente de desarrollo.
