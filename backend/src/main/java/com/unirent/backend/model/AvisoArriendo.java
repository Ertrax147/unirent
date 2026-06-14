package com.unirent.backend.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AvisoArriendo {
    private String id;
    private String arrendadorId; 
    private String titulo;
    private String descripcion;  
    private Double precio;
    private String ciudad;
    private String direccion;
    private Map<String, Double> ubicacion; 
    private boolean disponible;       
    private Integer cuposDisponibles; 
}