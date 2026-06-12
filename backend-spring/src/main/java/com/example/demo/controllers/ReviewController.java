package com.example.demo.controllers;

import com.example.demo.models.ChatRoom;
import com.example.demo.models.Review;
import com.example.demo.repositories.ChatRoomRepository;
import com.example.demo.repositories.ReviewRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reviews")
public class ReviewController {

    private final ReviewRepository reviewRepository;
    private final ChatRoomRepository chatRoomRepository;

    @Autowired
    public ReviewController(ReviewRepository reviewRepository, ChatRoomRepository chatRoomRepository) {
        this.reviewRepository = reviewRepository;
        this.chatRoomRepository = chatRoomRepository;
    }

    // Dejar una calificación
    @PostMapping
    public ResponseEntity<?> createReview(@AuthenticationPrincipal Jwt jwt, @RequestBody Map<String, Object> payload) {
        String reviewerId = jwt.getSubject();
        Long chatRoomId = Long.parseLong(payload.get("chatRoomId").toString());
        int stars = Integer.parseInt(payload.get("stars").toString());
        String comment = payload.getOrDefault("comment", "").toString();

        // Verificar que el chat esté cerrado (arriendo concretado)
        ChatRoom room = chatRoomRepository.findById(chatRoomId)
            .orElseThrow(() -> new RuntimeException("Chat no encontrado"));

        if (!room.isClosed()) {
            return ResponseEntity.badRequest().body("Solo puedes calificar luego de concretar el arriendo");
        }

        // Verificar que el reviewer sea parte del chat
        if (!reviewerId.equals(room.getStudentId()) && !reviewerId.equals(room.getLandlordId())) {
            return ResponseEntity.badRequest().body("No perteneces a este chat");
        }

        // Verificar que no haya calificado ya
        if (reviewRepository.existsByChatRoomIdAndReviewerId(chatRoomId, reviewerId)) {
            return ResponseEntity.badRequest().body("Ya has calificado en este arriendo");
        }

        // Determinar quién es el calificado
        String reviewedId = reviewerId.equals(room.getStudentId()) ? room.getLandlordId() : room.getStudentId();

        Review review = new Review(chatRoomId, reviewerId, reviewedId, room.getListingId(), stars, comment);
        Review saved = reviewRepository.save(review);
        return ResponseEntity.ok(saved);
    }

    // Ver calificaciones de un usuario
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Review>> getUserReviews(@PathVariable String userId) {
        return ResponseEntity.ok(reviewRepository.findByReviewedId(userId));
    }

    // Verificar si ya calificaste en un chat
    @GetMapping("/can-review/{chatRoomId}")
    public ResponseEntity<Map<String, Object>> canReview(@AuthenticationPrincipal Jwt jwt, @PathVariable Long chatRoomId) {
        String userId = jwt.getSubject();
        boolean alreadyReviewed = reviewRepository.existsByChatRoomIdAndReviewerId(chatRoomId, userId);
        return ResponseEntity.ok(Map.of("alreadyReviewed", alreadyReviewed));
    }
}
