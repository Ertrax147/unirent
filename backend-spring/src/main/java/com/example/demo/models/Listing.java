package com.example.demo.models;

import jakarta.persistence.*;

@Entity
@Table(name = "listings")
public class Listing {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String price; // ej. "$280.000/mes" - para el MVP lo guardaremos como texto para no complicar la UI
    private String location;
    private String type; // Individual, Compartida, Estudio
    private String rating;
    private String imageUrl; // Ruta del asset (ej. "assets/images/prop_0.png")
    
    @Column(name = "owner_id")
    private String ownerId; // ID del Arrendador que publicó la propiedad

    // Constructor vacío requerido por JPA
    public Listing() {}

    public Listing(String title, String price, String location, String type, String rating, String imageUrl, String ownerId) {
        this.title = title;
        this.price = price;
        this.location = location;
        this.type = type;
        this.rating = rating;
        this.imageUrl = imageUrl;
        this.ownerId = ownerId;
    }

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getPrice() { return price; }
    public void setPrice(String price) { this.price = price; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getRating() { return rating; }
    public void setRating(String rating) { this.rating = rating; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    
    public String getOwnerId() { return ownerId; }
    public void setOwnerId(String ownerId) { this.ownerId = ownerId; }
}
