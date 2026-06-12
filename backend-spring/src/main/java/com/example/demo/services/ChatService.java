package com.example.demo.services;

import com.example.demo.models.ChatMessage;
import com.example.demo.models.ChatRoom;
import com.example.demo.models.Listing;
import com.example.demo.repositories.ChatMessageRepository;
import com.example.demo.repositories.ChatRoomRepository;
import com.example.demo.repositories.ListingRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ChatService {

    private final ChatRoomRepository chatRoomRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final ListingRepository listingRepository;

    @Autowired
    public ChatService(ChatRoomRepository chatRoomRepository, 
                       ChatMessageRepository chatMessageRepository,
                       ListingRepository listingRepository) {
        this.chatRoomRepository = chatRoomRepository;
        this.chatMessageRepository = chatMessageRepository;
        this.listingRepository = listingRepository;
    }

    @Transactional
    public ChatRoom getOrCreateChatRoom(String studentId, Long listingId) {
        return chatRoomRepository.findByStudentIdAndListingId(studentId, listingId)
            .orElseGet(() -> {
                Listing listing = listingRepository.findById(listingId)
                    .orElseThrow(() -> new RuntimeException("Listing not found"));
                
                ChatRoom newRoom = new ChatRoom(studentId, listing.getOwnerId(), listingId);
                return chatRoomRepository.save(newRoom);
            });
    }

    public List<ChatRoom> getUserChats(String userId) {
        return chatRoomRepository.findByStudentIdOrLandlordIdOrderByLastMessageTimeDesc(userId, userId);
    }

    @Transactional
    public ChatMessage sendMessage(Long chatRoomId, String senderId, String content) {
        ChatRoom room = chatRoomRepository.findById(chatRoomId)
            .orElseThrow(() -> new RuntimeException("ChatRoom not found"));

        ChatMessage message = new ChatMessage(chatRoomId, senderId, content);
        ChatMessage savedMessage = chatMessageRepository.save(message);

        // Actualizar último mensaje del chat room
        room.setLastMessageTime(LocalDateTime.now());
        chatRoomRepository.save(room);

        return savedMessage;
    }

    public List<ChatMessage> getMessages(Long chatRoomId) {
        return chatMessageRepository.findByChatRoomIdOrderByTimestampAsc(chatRoomId);
    }

    @Transactional
    public ChatRoom agreeToRent(Long chatRoomId, String userId) {
        ChatRoom room = chatRoomRepository.findById(chatRoomId)
            .orElseThrow(() -> new RuntimeException("ChatRoom not found"));

        if (room.isClosed()) {
            return room; // Ya cerrado
        }

        if (userId.equals(room.getStudentId())) {
            room.setStudentAgreed(true);
        } else if (userId.equals(room.getLandlordId())) {
            room.setLandlordAgreed(true);
        } else {
            throw new RuntimeException("User not part of this chat");
        }

        if (room.isStudentAgreed() && room.isLandlordAgreed()) {
            room.setClosed(true);
            
            // Cambiar estado de la casa a RENTED
            listingRepository.findById(room.getListingId()).ifPresent(listing -> {
                listing.setStatus("RENTED");
                listingRepository.save(listing);
            });
        }

        return chatRoomRepository.save(room);
    }
}
