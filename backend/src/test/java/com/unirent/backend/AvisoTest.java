package com.unirent.backend;

import com.unirent.backend.model.AvisoArriendo;
import com.unirent.backend.repository.AvisoArriendoRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;

@SpringBootTest(classes = BackendApplication.class)
class AvisoTest {

    @Autowired
    AvisoArriendoRepository repository;

    @Test
    void testAvisos() {
        try {
            System.out.println("\n\n=== TEST AVISOS ===");
            List<AvisoArriendo> avisos = repository.findAll();
            for (AvisoArriendo a : avisos) {
                System.out.println("ID: " + a.getId());
                System.out.println("ArrendadorId: " + a.getArrendadorId());
                System.out.println("Titulo: " + a.getTitulo());
            }
            System.out.println("=== END TEST AVISOS ===\n\n");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
