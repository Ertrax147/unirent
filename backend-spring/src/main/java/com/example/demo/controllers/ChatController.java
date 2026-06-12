package com.example.demo.controllers;

import com.example.demo.models.ChatMessage;
import com.example.demo.models.ChatRoom;
import com.example.demo.services.ChatService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/chats")
public class ChatController {

    private final ChatService chatService;

    @Autowired
    public ChatController(ChatService chatService) {
        this.chatService = chatService;
    }

    // El estudiante inicia o recupera un chat por una propiedad
    @PostMapping
    public ResponseEntity<ChatRoom> getOrCreateChat(@AuthenticationPrincipal Jwt jwt, @RequestBody Map<String, Long> payload) {
        String studentId = jwt.getSubject();
        Long listingId = payload.get("listingId");
        
        ChatRoom room = chatService.getOrCreateChatRoom(studentId, listingId);
        return ResponseEntity.ok(room);
    }

    // Obtener todos los chats del usuario actual
    @GetMapping
    public ResponseEntity<List<ChatRoom>> getUserChats(@AuthenticationPrincipal Jwt jwt) {
        String userId = jwt.getSubject();
        List<ChatRoom> chats = chatService.getUserChats(userId);
        return ResponseEntity.ok(chats);
    }

    // Enviar un mensaje
    @PostMapping("/{chatRoomId}/messages")
    public ResponseEntity<ChatMessage> sendMessage(@AuthenticationPrincipal Jwt jwt, 
                                                   @PathVariable Long chatRoomId, 
                                                   @RequestBody Map<String, String> payload) {
        String senderId = jwt.getSubject();
        String content = payload.get("content");
        
        ChatMessage message = chatService.sendMessage(chatRoomId, senderId, content);
        return ResponseEntity.ok(message);
    }

    // Obtener mensajes de un chat
    @GetMapping("/{chatRoomId}/messages")
    public ResponseEntity<List<ChatMessage>> getMessages(@AuthenticationPrincipal Jwt jwt, @PathVariable Long chatRoomId) {
        // En un sistema real de producción, aquí verificaríamos que jwt.getSubject() pertenece a la sala de chat
        List<ChatMessage> messages = chatService.getMessages(chatRoomId);
        return ResponseEntity.ok(messages);
    }
}
