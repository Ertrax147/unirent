package com.example.demo.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "reviews")
public class Review {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "chat_room_id", nullable = false)
    private Long chatRoomId;

    @Column(name = "reviewer_id", nullable = false)
    private String reviewerId; // quien califica

    @Column(name = "reviewed_id", nullable = false)
    private String reviewedId; // quien es calificado

    @Column(name = "listing_id")
    private Long listingId;

    @Column(nullable = false)
    private int stars; // 1-5

    private String comment;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    public Review() {}

    public Review(Long chatRoomId, String reviewerId, String reviewedId, Long listingId, int stars, String comment) {
        this.chatRoomId = chatRoomId;
        this.reviewerId = reviewerId;
        this.reviewedId = reviewedId;
        this.listingId = listingId;
        this.stars = stars;
        this.comment = comment;
        this.createdAt = LocalDateTime.now();
    }

    // Getters y Setters
    public Long getId() { return id; }
    public Long getChatRoomId() { return chatRoomId; }
    public void setChatRoomId(Long chatRoomId) { this.chatRoomId = chatRoomId; }
    public String getReviewerId() { return reviewerId; }
    public void setReviewerId(String reviewerId) { this.reviewerId = reviewerId; }
    public String getReviewedId() { return reviewedId; }
    public void setReviewedId(String reviewedId) { this.reviewedId = reviewedId; }
    public Long getListingId() { return listingId; }
    public void setListingId(Long listingId) { this.listingId = listingId; }
    public int getStars() { return stars; }
    public void setStars(int stars) { this.stars = stars; }
    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
