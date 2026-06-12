package com.example.demo.controllers;

import com.example.demo.models.Favorite;
import com.example.demo.services.FavoriteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/favorites")
public class FavoriteController {

    private final FavoriteService favoriteService;

    @Autowired
    public FavoriteController(FavoriteService favoriteService) {
        this.favoriteService = favoriteService;
    }

    @GetMapping
    public ResponseEntity<List<Favorite>> getUserFavorites(@AuthenticationPrincipal Jwt jwt) {
        String userId = jwt.getSubject();
        List<Favorite> favorites = favoriteService.getUserFavorites(userId);
        return ResponseEntity.ok(favorites);
    }

    @PostMapping("/{listingId}")
    public ResponseEntity<Favorite> addFavorite(@AuthenticationPrincipal Jwt jwt, @PathVariable Long listingId) {
        String userId = jwt.getSubject();
        Favorite favorite = favoriteService.addFavorite(userId, listingId);
        return ResponseEntity.ok(favorite);
    }

    @DeleteMapping("/{listingId}")
    public ResponseEntity<Void> removeFavorite(@AuthenticationPrincipal Jwt jwt, @PathVariable Long listingId) {
        String userId = jwt.getSubject();
        favoriteService.removeFavorite(userId, listingId);
        return ResponseEntity.ok().build();
    }
}
