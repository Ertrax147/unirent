package com.unirent.backend.controller;

import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import com.unirent.backend.dto.RegistroUsuarioDTO;
import com.unirent.backend.dto.UsuarioPerfilDTO;
import com.unirent.backend.service.ArrendadorAuthService;
import com.unirent.backend.service.EstudianteAuthService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/auth") 
public class AuthController {

    private final EstudianteAuthService estudianteAuthService;
    private final ArrendadorAuthService arrendadorAuthService;

    public AuthController(EstudianteAuthService estudianteAuthService, ArrendadorAuthService arrendadorAuthService) {
        this.estudianteAuthService = estudianteAuthService;
        this.arrendadorAuthService = arrendadorAuthService;
    }

    /**
     * Endpoint: POST /api/auth/estudiante/registro
     */
    @PostMapping("/estudiante/registro")
    public ResponseEntity<?> registrarEstudiante(
            @Valid @RequestBody RegistroUsuarioDTO dto,
            Authentication authentication) {

        try {
            FirebaseToken decodedToken = (FirebaseToken) authentication.getCredentials();

            String uid = decodedToken.getUid();
            String email = decodedToken.getEmail();
            String nombreCompleto = decodedToken.getName();

            UsuarioPerfilDTO perfil = estudianteAuthService.registrarEstudianteDesdeGoogle(uid, email, nombreCompleto, dto);

            return ResponseEntity.status(HttpStatus.CREATED).body(perfil);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());

        } catch (ExecutionException | InterruptedException | FirebaseAuthException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error interno del servidor: " + e.getMessage());
        }
    }

    /**
     * Endpoint: POST /api/auth/arrendador/registro
     */
    @PostMapping("/arrendador/registro")
    public ResponseEntity<?> registrarArrendador(
            @Valid @RequestBody RegistroUsuarioDTO dto,
            Authentication authentication) {

        try {
            FirebaseToken decodedToken = (FirebaseToken) authentication.getCredentials();

            String uid = decodedToken.getUid();
            String email = decodedToken.getEmail();
            String nombreCompleto = decodedToken.getName();

            UsuarioPerfilDTO perfil = arrendadorAuthService.registrarArrendadorDesdeGoogle(uid, email, nombreCompleto, dto);

            return ResponseEntity.status(HttpStatus.CREATED).body(perfil);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());

        } catch (ExecutionException | InterruptedException | FirebaseAuthException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error interno del servidor: " + e.getMessage());
        }
    }
}