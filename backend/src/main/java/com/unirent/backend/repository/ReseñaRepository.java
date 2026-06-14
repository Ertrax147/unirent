package com.unirent.backend.repository;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.unirent.backend.model.Reseña;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

@Repository
public class ReseñaRepository {

    private final Firestore firestore;
    private static final String COLLECTION_NAME = "reviews";

    public ReseñaRepository(Firestore firestore) {
        this.firestore = firestore;
    }

    public List<Reseña> findByTargetUserId(String targetUserId) throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> future = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("targetUserId", targetUserId)
                .get();

        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        List<Reseña> reseñas = new ArrayList<>();
        for (DocumentSnapshot document : documents) {
            Reseña reseña = document.toObject(Reseña.class);
            if (reseña != null) {
                reseña.setId(document.getId());
                reseñas.add(reseña);
            }
        }
        
        // Ordenar en memoria por fecha descendente para evitar el error de índice compuesto en Firebase
        reseñas.sort((r1, r2) -> {
            if (r1.getTimestamp() == null && r2.getTimestamp() == null) return 0;
            if (r1.getTimestamp() == null) return 1;
            if (r2.getTimestamp() == null) return -1;
            return r2.getTimestamp().compareTo(r1.getTimestamp());
        });
        
        return reseñas;
    }

    public String save(Reseña reseña) throws ExecutionException, InterruptedException {
        if (reseña.getId() == null || reseña.getId().isEmpty()) {
            DocumentReference docRef = firestore.collection(COLLECTION_NAME).document();
            reseña.setId(docRef.getId());
        }
        ApiFuture<WriteResult> writeResultApiFuture = firestore.collection(COLLECTION_NAME)
                .document(reseña.getId())
                .set(reseña);
        writeResultApiFuture.get(); // wait for completion
        return reseña.getId();
    }
}
