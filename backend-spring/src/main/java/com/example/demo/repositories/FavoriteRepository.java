package com.example.demo.repositories;

import com.example.demo.models.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FavoriteRepository extends JpaRepository<Favorite, Long> {
    List<Favorite> findByUserId(String userId);
    Optional<Favorite> findByUserIdAndListingId(String userId, Long listingId);
    void deleteByUserIdAndListingId(String userId, Long listingId);
}
