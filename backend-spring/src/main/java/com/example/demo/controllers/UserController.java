package com.example.demo.controllers;

import com.example.demo.models.User;
import com.example.demo.services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    @Autowired
    public UserController(UserService userService) {
        this.userService = userService;
    }

    // Endpoint llamado después de un inicio de sesión exitoso en Firebase
    @PostMapping("/sync")
    public ResponseEntity<User> syncUser(@AuthenticationPrincipal Jwt jwt, @RequestBody Map<String, String> payload) {
        String uid = jwt.getSubject(); // Extraído matemáticamente del token, imposible de falsificar
        String phoneNumber = payload.get("phoneNumber");
        String email = payload.get("email");
        String displayName = payload.get("displayName");
        String photoUrl = payload.get("photoUrl");
        
        if (uid == null) {
            return ResponseEntity.badRequest().build();
        }
        
        User user = userService.syncUser(uid, phoneNumber, email, displayName, photoUrl);
        return ResponseEntity.ok(user);
    }
    
    // Endpoint para obtener el perfil del usuario
    @GetMapping("/{uid}")
    public ResponseEntity<User> getUser(@AuthenticationPrincipal Jwt jwt, @PathVariable String uid) {
        // Validación de seguridad: un usuario solo puede ver su propio perfil
        if (!uid.equals(jwt.getSubject())) {
            return ResponseEntity.status(403).build(); // Forbidden
        }
        
        User user = userService.getUser(uid);
        if (user != null) {
            return ResponseEntity.ok(user);
        }
        return ResponseEntity.notFound().build();
    }

    // Endpoint público para obtener info básica de otro usuario (ej: el dueño de una propiedad)
    @GetMapping("/{uid}/public")
    public ResponseEntity<Map<String, String>> getPublicUser(@PathVariable String uid) {
        User user = userService.getUser(uid);
        if (user != null) {
            Map<String, String> publicInfo = Map.of(
                "id", user.getId(),
                "displayName", user.getDisplayName() != null ? user.getDisplayName() : "Usuario",
                "photoUrl", user.getPhotoUrl() != null ? user.getPhotoUrl() : ""
            );
            return ResponseEntity.ok(publicInfo);
        }
        return ResponseEntity.notFound().build();
    }
    
    // Endpoint para actualizar el rol del usuario
    @PutMapping("/{uid}/role")
    public ResponseEntity<User> updateRole(@AuthenticationPrincipal Jwt jwt, @PathVariable String uid, @RequestBody Map<String, String> payload) {
        // Validación de seguridad: un usuario solo puede actualizar su propio rol
        if (!uid.equals(jwt.getSubject())) {
            return ResponseEntity.status(403).build(); // Forbidden
        }
        
        String role = payload.get("role");
        if (role == null) {
            return ResponseEntity.badRequest().build();
        }
        
        User updatedUser = userService.updateRole(uid, role);
        if (updatedUser != null) {
            return ResponseEntity.ok(updatedUser);
        }
        return ResponseEntity.notFound().build();
    }
}
