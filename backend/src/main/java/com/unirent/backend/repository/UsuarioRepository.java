package com.unirent.backend.repository;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.WriteResult;
import com.unirent.backend.model.Usuario;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.concurrent.ExecutionException;

@Repository
public class UsuarioRepository {

    private final Firestore firestore;
    private static final String COLLECTION_NAME = "usuarios";

    public UsuarioRepository(Firestore firestore) {
        this.firestore = firestore;
    }

    /**
     * Guarda o actualiza un usuario en la colección "usuarios".
     * Se fuerza a que el ID del documento sea exactamente el UID de Firebase Auth.
     */
    public String guardar(Usuario usuario) throws ExecutionException, InterruptedException {
        ApiFuture<WriteResult> collectionsApiFuture = firestore.collection(COLLECTION_NAME)
                .document(usuario.getId())
                .set(usuario);
        
        return collectionsApiFuture.get().getUpdateTime().toString();
    }

    /**
     * Busca un usuario en Firestore utilizando su UID único.
     */
    public Optional<Usuario> buscarPorId(String id) throws ExecutionException, InterruptedException {
        ApiFuture<DocumentSnapshot> future = firestore.collection(COLLECTION_NAME).document(id).get();
        DocumentSnapshot document = future.get();

        if (document.exists()) {
            Usuario usuario = document.toObject(Usuario.class);
            return Optional.ofNullable(usuario);
        }
        
        return Optional.empty();
    }
}