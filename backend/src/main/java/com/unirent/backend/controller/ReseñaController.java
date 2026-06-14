package com.unirent.backend.controller;

import com.unirent.backend.model.Reseña;
import com.unirent.backend.service.ReseñaService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reviews")
public class ReseñaController {

    private final ReseñaService reseñaService;

    public ReseñaController(ReseñaService reseñaService) {
        this.reseñaService = reseñaService;
    }

    @GetMapping("/{userId}")
    public ResponseEntity<List<Reseña>> obtenerReseñas(@PathVariable String userId) {
        try {
            List<Reseña> list = reseñaService.obtenerReseñasPorUsuario(userId);
            System.out.println("GET /api/reviews/" + userId + " -> Returning " + list.size() + " reviews.");
            return ResponseEntity.ok(list);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/debug")
    public ResponseEntity<List<Reseña>> debugAll() {
        try {
            List<com.google.cloud.firestore.QueryDocumentSnapshot> docs = com.google.firebase.cloud.FirestoreClient.getFirestore()
                    .collection("reviews").get().get().getDocuments();
            List<Reseña> list = new java.util.ArrayList<>();
            for (com.google.cloud.firestore.DocumentSnapshot doc : docs) {
                Reseña r = doc.toObject(Reseña.class);
                if (r != null) { r.setId(doc.getId()); list.add(r); }
            }
            return ResponseEntity.ok(list);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/{userId}/stats")
    public ResponseEntity<Map<String, Object>> obtenerEstadisticas(@PathVariable String userId) {
        try {
            return ResponseEntity.ok(reseñaService.obtenerEstadisticas(userId));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @PostMapping
    public ResponseEntity<Reseña> guardarReseña(Authentication authentication, @RequestBody Reseña reseña) {
        try {
            System.out.println("POST /api/reviews -> Received payload: " + reseña);
            String uid = (String) authentication.getPrincipal();
            reseña.setAuthorUserId(uid);
            return ResponseEntity.ok(reseñaService.guardarReseña(reseña));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }
}
