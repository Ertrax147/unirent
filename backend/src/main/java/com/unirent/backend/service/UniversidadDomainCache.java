package com.unirent.backend.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PostConstruct;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import java.io.InputStream;
import java.util.HashSet;
import java.util.Set;

@Component
public class UniversidadDomainCache {

    private final Set<String> dominiosValidos = new HashSet<>();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public UniversidadDomainCache() {
    }

    @PostConstruct
    public void inicializarCache() {
        try {
            InputStream inputStream = new ClassPathResource("universidades-chile.json").getInputStream();
            JsonNode rootNode = objectMapper.readTree(inputStream);

            for (JsonNode nodoUniversidad : rootNode) {
                JsonNode dominiosArray = nodoUniversidad.get("domains");
                if (dominiosArray != null) {
                    for (JsonNode dominio : dominiosArray) {
                        dominiosValidos.add(dominio.asText().toLowerCase());
                    }
                }
            }
            System.out.println("Caché Universitario activado: " + dominiosValidos.size() + " dominios listos en RAM.");
        } catch (Exception e) {
            System.err.println("Error crítico: No se pudo cargar el archivo de universidades. " + e.getMessage());
        }
    }

    public boolean esDominioValido(String correo) {
        if (correo == null || !correo.contains("@")) {
            return false;
        }
        String dominio = correo.substring(correo.indexOf("@") + 1).toLowerCase();
        return dominiosValidos.contains(dominio);
    }
}