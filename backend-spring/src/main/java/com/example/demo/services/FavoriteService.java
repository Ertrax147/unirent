package com.example.demo.services;

import com.example.demo.models.Favorite;
import com.example.demo.repositories.FavoriteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class FavoriteService {

    private final FavoriteRepository favoriteRepository;

    @Autowired
    public FavoriteService(FavoriteRepository favoriteRepository) {
        this.favoriteRepository = favoriteRepository;
    }

    public List<Favorite> getUserFavorites(String userId) {
        return favoriteRepository.findByUserId(userId);
    }

    @Transactional
    public Favorite addFavorite(String userId, Long listingId) {
        // Prevent duplicates
        if (favoriteRepository.findByUserIdAndListingId(userId, listingId).isPresent()) {
            return favoriteRepository.findByUserIdAndListingId(userId, listingId).get();
        }
        Favorite favorite = new Favorite(userId, listingId);
        return favoriteRepository.save(favorite);
    }

    @Transactional
    public void removeFavorite(String userId, Long listingId) {
        favoriteRepository.deleteByUserIdAndListingId(userId, listingId);
    }
}
