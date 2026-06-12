package com.example.demo.repositories;

import com.example.demo.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, String> {
    // Spring Data JPA provee automáticamente métodos como save(), findById(), etc.
    // ¡Esta interfaz vacía es suficiente para conectar el modelo User a PostgreSQL!
}
