package com.unirent.backend.controller;

import com.google.firebase.auth.FirebaseToken;
import com.unirent.backend.service.FavoritoService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/favorites")
public class FavoritoController {

    private final FavoritoService favoritoService;

    public FavoritoController(FavoritoService favoritoService) {
        this.favoritoService = favoritoService;
    }

    @GetMapping
    public ResponseEntity<?> getFavorites(Authentication authentication) {
        try {
            FirebaseToken decodedToken = (FirebaseToken) authentication.getCredentials();
            String uid = decodedToken.getUid();
            List<Integer> favoritos = favoritoService.getFavoritos(uid);
            return ResponseEntity.ok(favoritos);
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error al obtener favoritos: " + e.getMessage());
        }
    }

    @PostMapping("/{id}")
    public ResponseEntity<?> addFavorite(@PathVariable int id, Authentication authentication) {
        try {
            FirebaseToken decodedToken = (FirebaseToken) authentication.getCredentials();
            String uid = decodedToken.getUid();
            favoritoService.addFavorito(uid, id);
            return ResponseEntity.status(HttpStatus.CREATED).build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error al agregar favorito: " + e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> removeFavorite(@PathVariable int id, Authentication authentication) {
        try {
            FirebaseToken decodedToken = (FirebaseToken) authentication.getCredentials();
            String uid = decodedToken.getUid();
            favoritoService.removeFavorito(uid, id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error al eliminar favorito: " + e.getMessage());
        }
    }
}
