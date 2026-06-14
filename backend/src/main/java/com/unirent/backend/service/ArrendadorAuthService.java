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
public class ArrendadorAuthService {

    private final UsuarioRepository usuarioRepository;

    public ArrendadorAuthService(UsuarioRepository usuarioRepository) {
        this.usuarioRepository = usuarioRepository;
    }

    public UsuarioPerfilDTO registrarArrendadorDesdeGoogle(String uid, String email, String nombreCompleto, RegistroUsuarioDTO dto) 
            throws ExecutionException, InterruptedException, FirebaseAuthException {
        
        String nombre = nombreCompleto;
        String apellido = "";
        if (nombreCompleto != null && nombreCompleto.contains(" ")) {
            nombre = nombreCompleto.substring(0, nombreCompleto.indexOf(" "));
            apellido = nombreCompleto.substring(nombreCompleto.indexOf(" ") + 1);
        }

        Usuario nuevoArrendador = Usuario.builder()
                .id(uid)
                .nombre(nombre)
                .apellido(apellido)
                .correo(email)
                .rol(com.unirent.backend.model.RolEnum.ARRENDADOR) 
                .telefono(dto.getTelefono())
                .favoritos(new ArrayList<>())
                .build();

        usuarioRepository.guardar(nuevoArrendador);

        Map<String, Object> claims = new HashMap<>();
        claims.put("rol", nuevoArrendador.getRol().name()); 
        
        FirebaseAuth.getInstance().setCustomUserClaims(uid, claims);

        return UsuarioPerfilDTO.builder()
                .id(nuevoArrendador.getId())
                .nombre(nuevoArrendador.getNombre())
                .apellido(nuevoArrendador.getApellido())
                .correo(nuevoArrendador.getCorreo())
                .rol(nuevoArrendador.getRol())
                .telefono(nuevoArrendador.getTelefono())
                .favoritos(nuevoArrendador.getFavoritos())
                .build();
    }
}
