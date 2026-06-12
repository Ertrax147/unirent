package com.example.demo.services;

import com.example.demo.models.Listing;
import com.example.demo.repositories.ListingRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ListingService {

    private final ListingRepository listingRepository;

    @Autowired
    public ListingService(ListingRepository listingRepository) {
        this.listingRepository = listingRepository;
    }

    public List<Listing> getAllListings() {
        return listingRepository.findAll();
    }

    public Listing saveListing(Listing listing) {
        return listingRepository.save(listing);
    }

    // Este método se ejecuta automáticamente al iniciar la app
    // Sirve para inyectar datos de prueba en la base de datos si está vacía
    @PostConstruct
    public void initDbWithMockData() {
        if (listingRepository.count() == 0) {
            System.out.println("Base de datos vacía. Inyectando datos de prueba...");
            
            String mockOwnerId = "admin_mock_user_id";

            listingRepository.save(new Listing(
                    "Habitación individual cerca UFRO", 
                    "$280.000/mes", 
                    "Centro, Temuco", 
                    "Individual", 
                    "4.8", 
                    "assets/images/prop_0.png",
                    mockOwnerId
            ));
            
            listingRepository.save(new Listing(
                    "Departamento amoblado 2 personas", 
                    "$420.000/mes", 
                    "Pueblo Nuevo, Temuco", 
                    "Compartida", 
                    "4.5", 
                    "assets/images/prop_1.png",
                    mockOwnerId
            ));
            
            listingRepository.save(new Listing(
                    "Pieza con baño privado", 
                    "$320.000/mes", 
                    "Santa Rosa, Temuco", 
                    "Individual", 
                    "4.9", 
                    "assets/images/prop_2.png",
                    mockOwnerId
            ));
            
            listingRepository.save(new Listing(
                    "Departamento estudio UFRO", 
                    "$350.000/mes", 
                    "Av. Alemania, Temuco", 
                    "Estudio", 
                    "4.7", 
                    "assets/images/prop_3.png",
                    mockOwnerId
            ));
            
            System.out.println("¡Datos inyectados correctamente!");
        }
    }
}
