package com.unirent.backend.controller;

import com.unirent.backend.dto.UsuarioPublicoDTO;
import com.unirent.backend.model.Usuario;
import com.unirent.backend.repository.UsuarioRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/users")
public class UsuarioController {

    private final UsuarioRepository usuarioRepository;

    public UsuarioController(UsuarioRepository usuarioRepository) {
        this.usuarioRepository = usuarioRepository;
    }

    @GetMapping("/{uid}/public")
    public ResponseEntity<UsuarioPublicoDTO> getPublicProfile(@PathVariable String uid) {
        try {
            Optional<Usuario> usuarioOpt = usuarioRepository.buscarPorId(uid);
            if (usuarioOpt.isPresent()) {
                Usuario usuario = usuarioOpt.get();
                String displayName = (usuario.getNombre() != null ? usuario.getNombre() : "") + " " + 
                                     (usuario.getApellido() != null ? usuario.getApellido() : "");
                if (displayName.trim().isEmpty()) {
                    displayName = "Usuario";
                }
                
                UsuarioPublicoDTO dto = UsuarioPublicoDTO.builder()
                        .id(uid)
                        .displayName(displayName.trim())
                        .photoUrl("") // No manejamos fotos aún, retornamos vacío
                        .build();
                return ResponseEntity.ok(dto);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}
