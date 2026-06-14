package com.unirent.backend.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Usuario {
    private String id; 
    private String nombre;
    private String apellido;
    private String correo; 
    private RolEnum rol;    
    private String telefono;
    private List<Integer> favoritos; 
}