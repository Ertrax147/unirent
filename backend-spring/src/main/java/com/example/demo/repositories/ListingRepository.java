package com.example.demo.repositories;

import com.example.demo.models.Listing;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ListingRepository extends JpaRepository<Listing, Long> {
    // Hereda los métodos mágicos de JPA como findAll(), save(), etc.
}
