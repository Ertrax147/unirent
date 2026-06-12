package com.example.demo.services;

import com.example.demo.models.User;
import com.example.demo.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserService {

    private final UserRepository userRepository;

    @Autowired
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User syncUser(String uid, String phoneNumber, String email, String displayName, String photoUrl) {
        Optional<User> existingUser = userRepository.findById(uid);
        
        if (existingUser.isPresent()) {
            User user = existingUser.get();
            boolean updated = false;
            
            if (phoneNumber != null && !phoneNumber.isEmpty() && 
               (user.getPhoneNumber() == null || user.getPhoneNumber().isEmpty())) {
                user.setPhoneNumber(phoneNumber);
                updated = true;
            }
            if (email != null && !email.isEmpty() && (user.getEmail() == null || user.getEmail().isEmpty())) {
                user.setEmail(email);
                updated = true;
            }
            if (displayName != null && !displayName.isEmpty() && (user.getDisplayName() == null || user.getDisplayName().isEmpty())) {
                user.setDisplayName(displayName);
                updated = true;
            }
            if (photoUrl != null && !photoUrl.isEmpty() && (user.getPhotoUrl() == null || user.getPhotoUrl().isEmpty())) {
                user.setPhotoUrl(photoUrl);
                updated = true;
            }
            
            if (updated) {
                return userRepository.save(user);
            }
            return user;
        } else {
            User newUser = new User();
            newUser.setId(uid);
            newUser.setPhoneNumber(phoneNumber);
            newUser.setEmail(email);
            newUser.setDisplayName(displayName);
            newUser.setPhotoUrl(photoUrl);
            newUser.setRole("unassigned");
            return userRepository.save(newUser);
        }
    }
    
    public User getUser(String uid) {
        return userRepository.findById(uid).orElse(null);
    }
    
    public User updateRole(String uid, String role) {
        Optional<User> userOpt = userRepository.findById(uid);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            user.setRole(role);
            return userRepository.save(user);
        }
        return null;
    }
}
