package com.example.demo.repositories;

import com.example.demo.models.ChatRoom;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ChatRoomRepository extends JpaRepository<ChatRoom, Long> {
    List<ChatRoom> findByStudentIdOrLandlordIdOrderByLastMessageTimeDesc(String studentId, String landlordId);
    Optional<ChatRoom> findByStudentIdAndListingId(String studentId, Long listingId);
}
