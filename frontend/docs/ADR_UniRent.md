# Registros de Decisiones de Arquitectura (ADR) — UniRent

> **UniRent** es una plataforma de alojamiento estudiantil para la Universidad de la Frontera (UFRO), que conecta estudiantes buscando arriendo con arrendadores que ofrecen habitaciones y departamentos cercanos al campus.

---

# ADR-1. Flutter como Plataforma de Desarrollo Frontend

## Situación
Aceptado

## Contexto
El equipo necesita desarrollar una aplicación cliente que funcione en dispositivos móviles Android, considerando que la mayoría de los estudiantes de la UFRO acceden a servicios digitales desde sus teléfonos. Se requiere una solución que permita un desarrollo ágil con un único código base, soporte para mapas, cámara y almacenamiento local, y que sea viable de implementar durante el semestre académico por un equipo pequeño.

## Decisión
Se decide utilizar **Flutter (Dart)** como framework de desarrollo frontend por las siguientes razones:

- **Un solo código base** compila para Android, iOS y Web, reduciendo el tiempo de desarrollo.
- **Rendimiento nativo**: Flutter renderiza con su propio motor gráfico (Skia/Impeller), sin depender de un WebView, entregando una experiencia fluida.
- **Ecosistema maduro**: Paquetes disponibles para todas las necesidades del proyecto: `google_maps_flutter`, `image_picker`, `flutter_rating_bar`, `firebase_auth`.
- **Integración directa con Firebase**: Los SDKs de Firebase para Flutter están oficialmente mantenidos por Google, garantizando compatibilidad y estabilidad.
- **Adopción académica y laboral creciente**: Permite al equipo desarrollar una habilidad con alta demanda en el mercado.

## Consecuencias

| Trade-off | Impacto |
|---|---|
| ✅ Un solo código base para múltiples plataformas | Reduce el tiempo de desarrollo a la mitad vs. desarrollo nativo separado |
| ✅ Rendimiento cercano al nativo | Mejor experiencia de usuario que soluciones híbridas (React Native, Ionic) |
| ✅ Hot reload acelera el desarrollo | Iteraciones de UI rápidas sin reiniciar la app |
| ⚠️ Tamaño del APK mayor (~15-20 MB) | El motor gráfico propio de Flutter incrementa el tamaño del ejecutable |
| ⚠️ Dart es un lenguaje menos conocido que JS/Python | Curva de aprendizaje inicial para el equipo |
| ❌ Acceso limitado a APIs del sistema operativo | Algunas funciones nativas requieren escribir código Kotlin/Swift adicional |

## Cumplimiento
- La app debe compilar exitosamente con `flutter build apk --release` sin errores.
- Debe ejecutarse correctamente en un dispositivo Android físico o emulador con API 21+.
- Las pantallas principales deben renderizarse en menos de 300ms en un dispositivo de gama media.

## Notas
Autor: [NOMBRE] [CORREO]. <br />
Día de publicación: 12-05-2026 <br />
Última actualización: 12-05-2026

---

# ADR-2. Spring Boot como Backend y API REST

## Situación
Aceptado

## Contexto
El proyecto UniRent requiere un componente de backend que centralice la lógica de negocio, valide las reglas del sistema (Ej: un estudiante no puede tener más de un arriendo activo) y exponga una API que la aplicación Flutter pueda consumir. Sin un backend propio, estas reglas vivirían en el cliente (Flutter), lo que representa un riesgo de seguridad ya que pueden ser manipuladas por el usuario. Además, el contexto académico del ramo **Arquitectura de Software** exige demostrar patrones arquitectónicos concretos.

## Decisión
Se decide utilizar **Spring Boot (Java 17)** como framework para el servidor backend, exponiendo una **API REST** con los siguientes fundamentos:

- **Arquitectura en capas explícita**: Spring Boot fuerza la separación entre Controller, Service y Repository, que es exactamente el patrón que el ramo de Arquitectura de Software requiere demostrar.
- **Madurez y estabilidad empresarial**: Es el framework Java más utilizado en la industria para microservicios y APIs REST.
- **Spring Security**: Permite interceptar cada request HTTP y validar el token JWT de Firebase Auth antes de ejecutar cualquier lógica de negocio.
- **Integración con Firebase Admin SDK**: Permite verificar tokens de Firebase desde el backend de forma segura sin exponer credenciales en el cliente.
- **Inyección de dependencias nativa**: El contenedor IoC de Spring facilita la aplicación del principio de inversión de dependencias (SOLID).

## Consecuencias

| Trade-off | Impacto |
|---|---|
| ✅ Lógica de negocio protegida en el servidor | Las reglas no pueden ser evadidas desde el cliente |
| ✅ Arquitectura en capas demostrable | Cumple el objetivo académico del ramo |
| ✅ Escalabilidad futura | Puede migrarse a microservicios sin reescribir la app Flutter |
| ✅ Documentación y comunidad amplia | Facilita la resolución de problemas durante el desarrollo |
| ⚠️ Tiempo de desarrollo adicional | Requiere programar el backend además del frontend Flutter |
| ⚠️ Arranque lento (cold start) | En el plan gratuito de Railway, el servidor puede tardar ~30s en despertar |
| ❌ Mayor complejidad operacional | Se debe mantener y desplegar un servicio adicional |

## Cumplimiento
- Todos los endpoints de la API deben retornar los códigos HTTP correctos: `200`, `201`, `400`, `401`, `403`, `404`.
- Cada request a `/api/**` (excepto auth pública) debe fallar con `401 Unauthorized` si no incluye un token Firebase válido.
- El backend debe estar desplegado y accesible en una URL pública (Railway/Render).

## Notas
Autor: [NOMBRE] [CORREO]. <br />
Día de publicación: 12-05-2026 <br />
Última actualización: 12-05-2026

---

# ADR-3. Arquitectura en Capas para el Backend (Layered Architecture)

## Situación
Aceptado

## Contexto
Al decidir usar Spring Boot, es necesario definir cómo se organizará internamente el código del backend. Sin una estructura definida, el código tiende a volverse un monolito desorganizado donde la lógica de negocio, el acceso a datos y la presentación HTTP se mezclan en los mismos archivos, dificultando el mantenimiento, las pruebas y la escalabilidad.

## Decisión
Se adopta el patrón de **Arquitectura en Capas (Layered Architecture)** con las siguientes capas bien definidas:

```
Controller Layer  →  Service Layer  →  Repository Layer  →  Data Source (Firestore)
```

- **Controller**: Solo recibe y responde peticiones HTTP. No contiene lógica de negocio.
- **Service**: Contiene todas las reglas de negocio de UniRent. Es la capa más importante.
- **Repository**: Abstrae el acceso a Firebase Firestore. El Service no sabe si los datos vienen de Firestore, PostgreSQL u otra fuente.
- **Model/DTO**: Objetos que representan los datos del dominio (`Property`, `RentalRequest`, `AppUser`) y los objetos de transferencia entre capas.

## Consecuencias

| Trade-off | Impacto |
|---|---|
| ✅ Separación de responsabilidades clara (SRP) | Cada clase tiene una única razón para cambiar |
| ✅ Testabilidad | Los Services pueden ser probados con mocks de los Repositories |
| ✅ Mantenibilidad | Un cambio en la base de datos solo afecta el Repository, no el Service |
| ✅ Legibilidad y onboarding | Un desarrollador nuevo entiende la estructura en minutos |
| ⚠️ Más clases y archivos | Para funciones simples, puede sentirse como sobre-ingeniería |
| ⚠️ Latencia adicional | Las llamadas pasan por más capas vs. acceso directo a la BD |

## Cumplimiento
- Ningún `@RestController` debe contener lógica de negocio. Solo debe llamar métodos del `@Service`.
- Ningún `@Service` debe importar clases HTTP de Spring (como `HttpServletRequest`).
- Ningún `@Repository` debe contener reglas de negocio, solo operaciones CRUD.
- Se verificará mediante revisión de código que no existan dependencias entre capas del mismo nivel ni dependencias invertidas.

## Notas
Autor: [NOMBRE] [CORREO]. <br />
Día de publicación: 12-05-2026 <br />
Última actualización: 12-05-2026

---

# ADR-4. Firebase Auth + Firestore como Sistema de Autenticación y Base de Datos

## Situación
Aceptado

## Contexto
UniRent necesita un sistema de autenticación seguro (con soporte para Google Sign-In) y una base de datos para almacenar usuarios, propiedades, arriendos y reseñas. Configurar y mantener un servidor de autenticación propio y una base de datos relacional desde cero requeriría un tiempo que excede el alcance del proyecto académico. Se debe priorizar una solución robusta, gratuita y de rápida implementación.

## Decisión
Se decide utilizar **Firebase Authentication** para la gestión de identidades y **Cloud Firestore** como base de datos NoSQL, ambos dentro del **plan Spark (gratuito)** de Firebase:

- **Firebase Auth**: Gestiona el registro, login con Google y la generación de tokens JWT que el backend Spring Boot valida mediante el Admin SDK. El plan gratuito no tiene límite de usuarios activos mensuales.
- **Cloud Firestore**: Base de datos NoSQL en tiempo real con **50.000 lecturas y 20.000 escrituras diarias gratuitas**, suficiente para un proyecto universitario. La estructura de documentos y colecciones se adapta bien al modelo de datos de UniRent (usuarios, propiedades, arriendos).

**Nota:** Firebase Storage **no se utilizará** por ser de pago desde el primer byte. Las imágenes se gestionarán con Cloudinary (ver ADR-5).

## Consecuencias

| Trade-off | Impacto |
|---|---|
| ✅ Autenticación robusta sin configurar servidor propio | Ahorra semanas de trabajo en infraestructura de seguridad |
| ✅ Plan gratuito generoso | 50k lecturas/día y 20k escrituras/día, suficiente para el MVP |
| ✅ Actualizaciones en tiempo real | Firestore puede notificar cambios en tiempo real a la app |
| ✅ Tokens JWT estándar | Verificables desde Spring Boot con el Admin SDK |
| ⚠️ Base de datos NoSQL | Las relaciones complejas entre colecciones requieren cuidado en el modelado para evitar lecturas innecesarias |
| ⚠️ Dependencia de Google | Si Firebase cambia sus precios o política, el sistema se ve afectado |
| ❌ Sin soporte para transacciones complejas SQL | No es posible hacer JOINs entre colecciones como en SQL |

## Cumplimiento
- El uso diario de lecturas/escrituras debe monitorearse desde Firebase Console y no superar el 80% del límite gratuito durante las pruebas.
- Toda comunicación con Firestore debe realizarse desde el backend (Spring Boot), no directamente desde Flutter, para garantizar que las reglas de negocio se apliquen antes de acceder a los datos.
- Los tokens de Firebase deben verificarse en cada request al backend mediante `FirebaseAuth.getInstance().verifyIdToken()`.

## Notas
Autor: [NOMBRE] [CORREO]. <br />
Día de publicación: 12-05-2026 <br />
Última actualización: 12-05-2026

---

# ADR-5. Cloudinary como Servicio de Almacenamiento de Imágenes

## Situación
Aceptado

## Contexto
La plataforma UniRent requiere que los arrendadores suban fotos de sus propiedades y que los usuarios tengan foto de perfil. Firebase Storage, que sería la solución natural junto a Firebase, **no tiene plan gratuito**: cobra desde el primer GB almacenado. Se necesita una alternativa gratuita, confiable y con buena integración para Spring Boot.

## Decisión
Se decide utilizar **Cloudinary** como servicio de almacenamiento y transformación de imágenes por los siguientes motivos:

- **Plan gratuito generoso**: 25 GB de almacenamiento y 25 GB de ancho de banda mensual, suficiente para el proyecto.
- **SDK oficial para Java/Spring Boot**: Se integra fácilmente como un `@Service` en el backend.
- **URLs públicas optimizadas**: Cloudinary genera URLs directas para las imágenes que se almacenan en Firestore y se consumen desde Flutter con el widget `Image.network()`.
- **Transformación de imágenes**: Permite redimensionar, comprimir y optimizar imágenes automáticamente mediante parámetros en la URL, sin código adicional.
- **Flujo seguro**: El cliente (Flutter) no se comunica directamente con Cloudinary. Las imágenes se envían al backend Spring Boot, que las sube a Cloudinary y devuelve la URL resultante.

## Consecuencias

| Trade-off | Impacto |
|---|---|
| ✅ Completamente gratuito para el proyecto | Elimina el costo de Firebase Storage |
| ✅ Optimización automática de imágenes | Reduce el consumo de datos móviles de los usuarios |
| ✅ CDN global incluido | Las imágenes cargan rápido desde cualquier ubicación |
| ✅ Flujo de subida centralizado en el backend | Las credenciales de Cloudinary nunca se exponen en el cliente |
| ⚠️ Dependencia de un servicio externo adicional | Si Cloudinary tiene una caída, las imágenes no se pueden subir |
| ⚠️ Las URLs son públicas | Cualquier persona con la URL puede ver la imagen (aceptable para fotos de propiedades) |
| ❌ Límite de 25 GB en plan gratuito | Si el proyecto crece significativamente, se requerirá plan de pago |

## Cumplimiento
- Las URLs de imágenes almacenadas en Firestore deben comenzar con `https://res.cloudinary.com/`.
- El endpoint de subida de imágenes (`POST /api/properties/upload-image`) debe retornar la URL pública de Cloudinary en menos de 5 segundos.
- Las credenciales de Cloudinary (`cloud_name`, `api_key`, `api_secret`) deben vivir únicamente en las variables de entorno del servidor Spring Boot, nunca en el cliente Flutter.

## Notas
Autor: [NOMBRE] [CORREO]. <br />
Día de publicación: 12-05-2026 <br />
Última actualización: 12-05-2026

---

# ADR-6. Riverpod como Sistema de Gestión de Estado en Flutter

## Situación
Aceptado

## Contexto
Una aplicación Flutter con múltiples pantallas necesita compartir estado entre ellas: saber si el usuario está autenticado, qué propiedades están cargadas, cuáles son sus arriendos activos, etc. Sin un sistema de gestión de estado, este dato debe pasarse como parámetro de widget en widget, lo que se conoce como "prop drilling" y genera código frágil, difícil de mantener y de probar. Se evaluaron las alternativas: `Provider`, `Bloc/Cubit`, `GetX` y `Riverpod`.

## Decisión
Se decide utilizar **Flutter Riverpod 2.x** como sistema de gestión de estado por las siguientes razones:

- **Seguridad en tiempo de compilación**: A diferencia de `Provider`, Riverpod detecta errores de configuración en tiempo de compilación, no en tiempo de ejecución.
- **Sin `BuildContext` para acceder al estado**: Los providers se pueden leer desde cualquier lugar, incluidos los repositorios y servicios, sin necesidad de un widget.
- **Soporte nativo para operaciones asíncronas**: `FutureProvider` y `AsyncNotifier` gestionan automáticamente los estados de carga, error y datos sin código adicional.
- **Compatibilidad con el patrón MVVM**: Cada feature tiene su propio `Notifier` (ViewModel) que encapsula la lógica de la UI separada de las pantallas (Views).
- **Integración con `go_router`**: Permite proteger rutas leyendo el estado de autenticación desde los providers de Riverpod.

## Consecuencias

| Trade-off | Impacto |
|---|---|
| ✅ Estado global reactivo | Cualquier pantalla se actualiza automáticamente cuando cambian los datos |
| ✅ Testabilidad | Los providers se pueden sobreescribir en pruebas sin afectar el código de producción |
| ✅ Sin memory leaks | Riverpod destruye automáticamente los providers cuando ya no se usan |
| ✅ Código más limpio y declarativo | Reduce el boilerplate comparado con Bloc |
| ⚠️ Curva de aprendizaje | Riverpod tiene conceptos propios (`ref`, `watch`, `read`, `listen`) que requieren estudio inicial |
| ⚠️ Menos estructurado que Bloc | Bloc impone más convenciones, lo que puede ser mejor en equipos grandes |

## Cumplimiento
- Ningún widget de tipo `StatefulWidget` debe manejar estado de negocio. El estado debe vivir en un `Notifier` o `Provider` de Riverpod.
- El estado de autenticación del usuario (`userProvider`) debe ser la única fuente de verdad para saber si el usuario está logueado, tanto para la UI como para `go_router`.
- Todos los `Provider` deben estar declarados en archivos separados de las pantallas, siguiendo la estructura `features/{feature}/presentation/providers/`.

## Notas
Autor: [NOMBRE] [CORREO]. <br />
Día de publicación: 12-05-2026 <br />
Última actualización: 12-05-2026
