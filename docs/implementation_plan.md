# Plan de Arquitectura — UniRent

## Descripción General

UniRent es una plataforma de alojamiento estudiantil para la UFRO. La arquitectura combina:
- **Flutter** como cliente móvil/web
- **Spring Boot** como backend con lógica de negocio y API REST
- **Firebase (plan gratuito)** para autenticación y base de datos
- **Cloudinary (plan gratuito)** para almacenamiento de imágenes

> [!IMPORTANT]
> Firebase Storage **SÍ es de pago** desde el inicio. Por eso lo reemplazamos con **Cloudinary**, que ofrece **25 GB gratis** más que suficiente para el proyecto.

---

## Stack Tecnológico Final

| Capa | Tecnología | Plan | Para qué se usa |
|---|---|---|---|
| 📱 **Frontend** | Flutter + Riverpod | — | App móvil/web |
| ⚙️ **Backend** | Spring Boot (Java 17) | Gratuito (local/Railway) | Lógica de negocio, API REST |
| 🔐 **Autenticación** | Firebase Auth | **Gratuito** | Login con Google / Email |
| 🗄️ **Base de Datos** | Firebase Firestore | **Gratuito** (50k reads/día) | Datos de usuarios, propiedades, reservas |
| 🖼️ **Imágenes** | Cloudinary | **Gratuito** (25 GB) | Fotos de propiedades y perfiles |
| 🗺️ **Mapas** | Google Maps Flutter | Gratuito con límites | Ubicación de propiedades |
| ☁️ **Deploy Backend** | Railway / Render | **Gratuito** | Hosting del servidor Spring Boot |

---

## Diagrama de Arquitectura General

```
┌─────────────────────────────────────────────────────────┐
│                   FLUTTER APP                            │
│  (Riverpod + go_router + Clean Architecture)            │
└────────────────────┬────────────────────────────────────┘
                     │ HTTP (REST API)
                     ▼
┌─────────────────────────────────────────────────────────┐
│              SPRING BOOT BACKEND                        │
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Controller  │→ │   Service    │→ │  Repository  │  │
│  │  (REST API)  │  │ (Lógica de   │  │  (Acceso a   │  │
│  │              │  │  Negocio)    │  │   Datos)     │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│         │                                    │          │
│         │ Verifica Token                     │ CRUD     │
│         ▼                                    ▼          │
│  ┌─────────────┐                   ┌──────────────────┐ │
│  │ Firebase    │                   │ Firebase         │ │
│  │   Auth      │                   │   Firestore      │ │
│  │(Validación) │                   │  (Base de Datos) │ │
│  └─────────────┘                   └──────────────────┘ │
│                                                         │
│         │ Subir/Obtener imágenes                        │
│         ▼                                               │
│  ┌─────────────┐                                        │
│  │  Cloudinary │                                        │
│  │  (Imágenes) │                                        │
│  └─────────────┘                                        │
└─────────────────────────────────────────────────────────┘
```

---

## Estructura del Backend (Spring Boot)

```
📦 unirent-backend
 ┣ 📂 src/main/java/com/unirent/
 ┃  ┣ 📂 controller/
 ┃  ┃  ┣ AuthController.java          ← POST /api/auth/verify
 ┃  ┃  ┣ PropertyController.java      ← CRUD propiedades
 ┃  ┃  ┣ RentalController.java        ← Solicitudes de arriendo
 ┃  ┃  ┣ ReviewController.java        ← Calificaciones y reseñas
 ┃  ┃  ┗ UserController.java          ← Gestión de usuarios/roles
 ┃  ┣ 📂 service/
 ┃  ┃  ┣ AuthService.java             ← Verifica tokens Firebase
 ┃  ┃  ┣ PropertyService.java         ← Lógica de propiedades
 ┃  ┃  ┣ RentalService.java           ← Reglas de arriendo
 ┃  ┃  ┣ ReviewService.java           ← Cálculo de promedios
 ┃  ┃  ┣ CloudinaryService.java       ← Upload de imágenes
 ┃  ┃  ┗ UserService.java             ← Asignación de roles
 ┃  ┣ 📂 repository/
 ┃  ┃  ┣ PropertyRepository.java      ← Acceso a Firestore
 ┃  ┃  ┣ RentalRepository.java
 ┃  ┃  ┣ ReviewRepository.java
 ┃  ┃  ┗ UserRepository.java
 ┃  ┣ 📂 model/
 ┃  ┃  ┣ Property.java
 ┃  ┃  ┣ RentalRequest.java
 ┃  ┃  ┣ Review.java
 ┃  ┃  ┗ AppUser.java
 ┃  ┣ 📂 dto/                         ← Objetos de Transferencia de Datos
 ┃  ┃  ┣ PropertyDTO.java
 ┃  ┃  ┗ RentalRequestDTO.java
 ┃  ┣ 📂 config/
 ┃  ┃  ┣ FirebaseConfig.java          ← Inicializa Firebase Admin SDK
 ┃  ┃  ┣ CloudinaryConfig.java        ← Configuración de Cloudinary
 ┃  ┃  ┗ SecurityConfig.java          ← Intercepta tokens en cada request
 ┃  ┗ UnirentApplication.java
 ┗ 📂 src/main/resources/
    ┣ application.properties           ← Variables de entorno
    ┗ firebase-service-account.json    ← Credenciales Firebase Admin
```

---

## Flujo de Autenticación

```
1. Usuario abre Flutter App
        │
        ▼
2. Flutter: Google Sign-In → Firebase Auth → obtiene ID Token (JWT)
        │
        ▼
3. Flutter: Envía ID Token en cada request al backend
   Header: Authorization: Bearer <firebase_id_token>
        │
        ▼
4. Spring Boot: SecurityConfig intercepta el token
        │
        ▼
5. Spring Boot: AuthService.verifyToken() llama a Firebase Admin SDK
        │
        ├── ✅ Token válido → Extrae UID → Continúa con la lógica
        └── ❌ Token inválido → Retorna 401 Unauthorized
```

---

## Flujo de Subida de Imágenes (Cloudinary)

```
1. Usuario selecciona foto en Flutter (image_picker)
        │
        ▼
2. Flutter: POST /api/properties/upload-image
   Body: multipart/form-data (la imagen)
   Header: Authorization: Bearer <token>
        │
        ▼
3. Spring Boot: CloudinaryService.uploadImage(file)
        │
        ▼
4. Cloudinary: Almacena la imagen, retorna una URL pública
   Ej: https://res.cloudinary.com/unirent/image/upload/prop_123.jpg
        │
        ▼
5. Spring Boot: Guarda la URL en Firestore (no la imagen)
        │
        ▼
6. Flutter: Muestra la imagen usando la URL pública
```

---

## Modelo de Datos (Firestore Collections)

### `users/{uid}`
```json
{
  "id": "firebase_uid",
  "email": "estudiante@ufro.cl",
  "name": "María González",
  "photoUrl": "https://cloudinary.com/...",
  "role": "student | landlord | unassigned",
  "phone": "+56912345678",
  "isPhoneVerified": false,
  "createdAt": "timestamp"
}
```

### `properties/{propertyId}`
```json
{
  "id": "prop_001",
  "landlordId": "firebase_uid",
  "title": "Habitación cerca de UFRO",
  "description": "...",
  "price": 180000,
  "type": "room | apartment | house",
  "address": "Av. Francisco Salva 01145",
  "location": { "lat": -38.739, "lng": -72.590 },
  "imageUrls": ["https://cloudinary.com/..."],
  "amenities": ["wifi", "washing_machine"],
  "isAvailable": true,
  "averageRating": 4.5,
  "reviewCount": 12
}
```

### `rentals/{rentalId}`
```json
{
  "id": "rental_001",
  "propertyId": "prop_001",
  "studentId": "firebase_uid",
  "landlordId": "firebase_uid",
  "status": "pending | approved | rejected | active | completed",
  "startDate": "timestamp",
  "endDate": "timestamp",
  "createdAt": "timestamp"
}
```

### `reviews/{reviewId}`
```json
{
  "id": "review_001",
  "propertyId": "prop_001",
  "studentId": "firebase_uid",
  "rating": 4,
  "comment": "Excelente ubicación",
  "createdAt": "timestamp"
}
```

---

## Endpoints de la API REST (Spring Boot)

### Autenticación
| Método | Endpoint | Descripción |
|---|---|---|
| `POST` | `/api/auth/verify` | Verifica token Firebase y retorna datos del usuario |
| `PATCH` | `/api/auth/role` | Asigna rol (student/landlord) al usuario |

### Propiedades
| Método | Endpoint | Descripción |
|---|---|---|
| `GET` | `/api/properties` | Listar todas las propiedades disponibles |
| `GET` | `/api/properties/{id}` | Obtener detalle de una propiedad |
| `POST` | `/api/properties` | Crear nueva propiedad (requiere rol landlord) |
| `PUT` | `/api/properties/{id}` | Actualizar propiedad (solo el dueño) |
| `DELETE` | `/api/properties/{id}` | Eliminar propiedad |
| `POST` | `/api/properties/upload-image` | Subir imagen a Cloudinary |
| `GET` | `/api/properties/search` | Filtrar por precio, tipo, amenities |

### Arriendos
| Método | Endpoint | Descripción |
|---|---|---|
| `POST` | `/api/rentals` | Estudiante solicita arrendar |
| `GET` | `/api/rentals/my-requests` | Ver mis solicitudes (estudiante) |
| `GET` | `/api/rentals/incoming` | Ver solicitudes recibidas (landlord) |
| `PATCH` | `/api/rentals/{id}/approve` | Landlord aprueba solicitud |
| `PATCH` | `/api/rentals/{id}/reject` | Landlord rechaza solicitud |

### Reseñas
| Método | Endpoint | Descripción |
|---|---|---|
| `POST` | `/api/reviews` | Dejar reseña de una propiedad |
| `GET` | `/api/reviews/property/{id}` | Listar reseñas de una propiedad |

---

## Lógica de Negocio Clave (Spring Boot Services)

Estas son las **reglas** que justifican la existencia del backend y que son el corazón del ramo:

1. **Un estudiante no puede tener más de 1 arriendo activo al mismo tiempo.**
2. **Un landlord no puede aprobar 2 solicitudes para la misma propiedad.**
3. **Solo puedes dejar una reseña si tuviste un arriendo completado en esa propiedad.**
4. **Una propiedad se marca automáticamente como no disponible al aprobarse un arriendo.**
5. **El promedio de calificaciones se recalcula en el servidor cada vez que hay una nueva reseña.**
6. **Solo el dueño de una propiedad puede modificarla o eliminarla.**

---

## Plan de Implementación por Fases

### 🟢 Fase 1 — Setup del Backend (1-2 días)
- [ ] Crear proyecto Spring Boot (Spring Initializr)
- [ ] Configurar Firebase Admin SDK en Spring Boot
- [ ] Crear `SecurityConfig` para validar tokens en cada request
- [ ] Configurar Cloudinary SDK
- [ ] Desplegar en Railway (gratuito) para pruebas remotas

### 🟡 Fase 2 — Auth y Usuarios (1-2 días)
- [ ] `AuthController` + `AuthService` + `UserRepository`
- [ ] Endpoint `POST /api/auth/verify`
- [ ] Endpoint `PATCH /api/auth/role`
- [ ] Adaptar `AuthRepository` en Flutter para consumir el backend

### 🟠 Fase 3 — Propiedades (2-3 días)
- [ ] Modelo `Property` + `PropertyDTO`
- [ ] `PropertyService` con todas las validaciones
- [ ] CRUD completo de propiedades
- [ ] Upload de imágenes con Cloudinary
- [ ] Adaptar Flutter para consumir estos endpoints

### 🔴 Fase 4 — Arriendos y Lógica de Negocio (2-3 días)
- [ ] Modelo `RentalRequest` + flujo de estados
- [ ] `RentalService` con las reglas de negocio críticas
- [ ] Endpoints de solicitud, aprobación y rechazo

### ⚪ Fase 5 — Reseñas y Calificaciones (1 día)
- [ ] `ReviewService` con validación de arriendo completado
- [ ] Recálculo automático del promedio en Firestore
- [ ] Integrar con `flutter_rating_bar` ya instalado

---

## Dependencias de Spring Boot (pom.xml)

```xml
<!-- Firebase Admin SDK -->
<dependency>
  <groupId>com.google.firebase</groupId>
  <artifactId>firebase-admin</artifactId>
  <version>9.2.0</version>
</dependency>

<!-- Cloudinary -->
<dependency>
  <groupId>com.cloudinary</groupId>
  <artifactId>cloudinary-http44</artifactId>
  <version>1.36.0</version>
</dependency>

<!-- Spring Web (REST API) -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<!-- Spring Security (para interceptar tokens) -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-security</artifactId>
</dependency>

<!-- Lombok (evitar getters/setters manuales) -->
<dependency>
  <groupId>org.projectlombok</groupId>
  <artifactId>lombok</artifactId>
  <optional>true</optional>
</dependency>
```
