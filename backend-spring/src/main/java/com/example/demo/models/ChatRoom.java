package com.example.demo.models;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "chat_rooms")
public class ChatRoom {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "student_id", nullable = false)
    private String studentId;

    @Column(name = "landlord_id", nullable = false)
    private String landlordId;

    @Column(name = "listing_id", nullable = false)
    private Long listingId;

    @Column(name = "last_message_time")
    private LocalDateTime lastMessageTime;

    @Column(name = "student_agreed")
    private Boolean studentAgreed = false;

    @Column(name = "landlord_agreed")
    private Boolean landlordAgreed = false;

    @Column(name = "is_closed")
    private Boolean isClosed = false;

    public ChatRoom() {}

    public ChatRoom(String studentId, String landlordId, Long listingId) {
        this.studentId = studentId;
        this.landlordId = landlordId;
        this.listingId = listingId;
        this.lastMessageTime = LocalDateTime.now();
        this.studentAgreed = false;
        this.landlordAgreed = false;
        this.isClosed = false;
    }

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getLandlordId() { return landlordId; }
    public void setLandlordId(String landlordId) { this.landlordId = landlordId; }

    public Long getListingId() { return listingId; }
    public void setListingId(Long listingId) { this.listingId = listingId; }

    public LocalDateTime getLastMessageTime() { return lastMessageTime; }
    public void setLastMessageTime(LocalDateTime lastMessageTime) { this.lastMessageTime = lastMessageTime; }
    
    public boolean isStudentAgreed() { return studentAgreed != null ? studentAgreed : false; }
    public void setStudentAgreed(Boolean studentAgreed) { this.studentAgreed = studentAgreed; }
    
    public boolean isLandlordAgreed() { return landlordAgreed != null ? landlordAgreed : false; }
    public void setLandlordAgreed(Boolean landlordAgreed) { this.landlordAgreed = landlordAgreed; }
    
    public boolean isClosed() { return isClosed != null ? isClosed : false; }
    public void setClosed(Boolean closed) { isClosed = closed; }
}
