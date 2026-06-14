package com.unirent.backend.dto;

import lombok.Builder;
import lombok.Data;
import java.util.List;

import com.unirent.backend.model.RolEnum;

@Data
@Builder
public class UsuarioPerfilDTO {
    
    private String id;
    private String nombre;
    private String apellido;
    private String correo;
    private RolEnum rol;
    private String telefono;
    private List<Integer> favoritos;
}