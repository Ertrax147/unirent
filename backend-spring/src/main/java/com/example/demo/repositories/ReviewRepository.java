package com.example.demo.repositories;

import com.example.demo.models.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ReviewRepository extends JpaRepository<Review, Long> {
    List<Review> findByReviewedId(String reviewedId);
    List<Review> findByChatRoomIdAndReviewerId(Long chatRoomId, String reviewerId);
    boolean existsByChatRoomIdAndReviewerId(Long chatRoomId, String reviewerId);
}
