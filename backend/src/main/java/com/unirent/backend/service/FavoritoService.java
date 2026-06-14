package com.unirent.backend.service;

import com.unirent.backend.model.Usuario;
import com.unirent.backend.repository.UsuarioRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ExecutionException;

@Service
public class FavoritoService {

    private final UsuarioRepository usuarioRepository;

    public FavoritoService(UsuarioRepository usuarioRepository) {
        this.usuarioRepository = usuarioRepository;
    }

    public List<Integer> getFavoritos(String uid) throws ExecutionException, InterruptedException {
        Optional<Usuario> usuarioOpt = usuarioRepository.buscarPorId(uid);
        if (usuarioOpt.isPresent() && usuarioOpt.get().getFavoritos() != null) {
            return usuarioOpt.get().getFavoritos();
        }
        return new ArrayList<>();
    }

    public void addFavorito(String uid, int listingId) throws ExecutionException, InterruptedException {
        Optional<Usuario> usuarioOpt = usuarioRepository.buscarPorId(uid);
        if (usuarioOpt.isPresent()) {
            Usuario usuario = usuarioOpt.get();
            List<Integer> favoritos = usuario.getFavoritos();
            if (favoritos == null) {
                favoritos = new ArrayList<>();
            }
            if (!favoritos.contains(listingId)) {
                favoritos.add(listingId);
                usuario.setFavoritos(favoritos);
                usuarioRepository.guardar(usuario);
            }
        } else {
            throw new IllegalArgumentException("Usuario no encontrado");
        }
    }

    public void removeFavorito(String uid, int listingId) throws ExecutionException, InterruptedException {
        Optional<Usuario> usuarioOpt = usuarioRepository.buscarPorId(uid);
        if (usuarioOpt.isPresent()) {
            Usuario usuario = usuarioOpt.get();
            List<Integer> favoritos = usuario.getFavoritos();
            if (favoritos != null && favoritos.contains(listingId)) {
                favoritos.remove(Integer.valueOf(listingId));
                usuario.setFavoritos(favoritos);
                usuarioRepository.guardar(usuario);
            }
        } else {
            throw new IllegalArgumentException("Usuario no encontrado");
        }
    }
}
