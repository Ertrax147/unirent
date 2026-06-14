package com.unirent.backend.service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.unirent.backend.dto.RegistroUsuarioDTO;
import com.unirent.backend.dto.UsuarioPerfilDTO;
import com.unirent.backend.model.Usuario;
import com.unirent.backend.repository.UsuarioRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@Service
public class EstudianteAuthService {

    private final UsuarioRepository usuarioRepository;
    private final UniversidadDomainCache domainCache;

    public EstudianteAuthService(UsuarioRepository usuarioRepository, UniversidadDomainCache domainCache) {
        this.usuarioRepository = usuarioRepository;
        this.domainCache = domainCache;
    }

    public UsuarioPerfilDTO registrarEstudianteDesdeGoogle(String uid, String email, String nombreCompleto, RegistroUsuarioDTO dto) 
            throws ExecutionException, InterruptedException, FirebaseAuthException {
        
        if (!domainCache.esDominioValido(email)) {
            throw new IllegalArgumentException("Acceso denegado: El correo " + email + " no pertenece a una universidad chilena registrada.");
        }

        String nombre = nombreCompleto;
        String apellido = "";
        if (nombreCompleto != null && nombreCompleto.contains(" ")) {
            nombre = nombreCompleto.substring(0, nombreCompleto.indexOf(" "));
            apellido = nombreCompleto.substring(nombreCompleto.indexOf(" ") + 1);
        }

        Usuario nuevoEstudiante = Usuario.builder()
                .id(uid)
                .nombre(nombre)
                .apellido(apellido)
                .correo(email)
                .rol(com.unirent.backend.model.RolEnum.ESTUDIANTE) 
                .telefono(dto.getTelefono())
                .favoritos(new ArrayList<>())
                .build();

        usuarioRepository.guardar(nuevoEstudiante);

        Map<String, Object> claims = new HashMap<>();
        claims.put("rol", nuevoEstudiante.getRol().name()); 
        
        FirebaseAuth.getInstance().setCustomUserClaims(uid, claims);

        return UsuarioPerfilDTO.builder()
                .id(nuevoEstudiante.getId())
                .nombre(nuevoEstudiante.getNombre())
                .apellido(nuevoEstudiante.getApellido())
                .correo(nuevoEstudiante.getCorreo())
                .rol(nuevoEstudiante.getRol())
                .telefono(nuevoEstudiante.getTelefono())
                .favoritos(nuevoEstudiante.getFavoritos())
                .build();
    }
}