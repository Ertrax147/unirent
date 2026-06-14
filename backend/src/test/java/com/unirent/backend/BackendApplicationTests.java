package com.unirent.backend;

import com.unirent.backend.model.Usuario;
import com.unirent.backend.repository.UsuarioRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.Optional;

@SpringBootTest(classes = BackendApplication.class)
class BackendApplicationTests {

    @Autowired
    UsuarioRepository repository;

    @Test
    void testFirestore() {
        try {
            System.out.println("\n\n=== EMPEZANDO TEST FIRESTORE ===");
            Optional<Usuario> u = repository.buscarPorId("g2DyRQY24UTiqMfNrcpGzOuf7th2");
            if (u.isPresent()) {
                System.out.println("USER FOUND: " + u.get().getNombre() + " " + u.get().getApellido());
            } else {
                System.out.println("USER NOT FOUND IN FIRESTORE");
            }
            System.out.println("=== TERMINANDO TEST FIRESTORE ===\n\n");
        } catch (Exception e) {
            System.out.println("\n\n=== EXCEPTION FIRESTORE ===");
            e.printStackTrace();
            System.out.println("=== END EXCEPTION ===\n\n");
        }
    }
}
