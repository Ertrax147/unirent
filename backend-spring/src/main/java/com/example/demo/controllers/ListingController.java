package com.example.demo.controllers;

import com.example.demo.models.Listing;
import com.example.demo.services.ListingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/listings")
public class ListingController {

    private final ListingService listingService;

    @Autowired
    public ListingController(ListingService listingService) {
        this.listingService = listingService;
    }

    // Endpoint para obtener todas las propiedades
    @GetMapping
    public ResponseEntity<List<Listing>> getAllListings() {
        List<Listing> listings = listingService.getAllListings();
        return ResponseEntity.ok(listings);
    }

    // Endpoint para publicar una nueva propiedad
    @PostMapping
    public ResponseEntity<Listing> createListing(@AuthenticationPrincipal Jwt jwt, @RequestBody Listing listing) {
        // Extraemos la identidad de forma segura desde el token
        String ownerId = jwt.getSubject();
        listing.setOwnerId(ownerId);
        
        // Asignamos imagen por defecto si no viene
        if (listing.getImageUrl() == null || listing.getImageUrl().isEmpty()) {
            listing.setImageUrl("assets/images/prop_0.png");
        }
        
        // Guardamos la propiedad
        Listing savedListing = listingService.saveListing(listing);
        return ResponseEntity.ok(savedListing);
    }
}
