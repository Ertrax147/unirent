package com.unirent.backend.repository;

import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.unirent.backend.model.AvisoArriendo;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ExecutionException;

@Repository
public class AvisoArriendoRepository {

    private final Firestore firestore;
    private static final String COLLECTION_NAME = "avisos";

    public AvisoArriendoRepository(Firestore firestore) {
        this.firestore = firestore;
    }

    public List<AvisoArriendo> findAll() throws ExecutionException, InterruptedException {
        ApiFuture<QuerySnapshot> future = firestore.collection(COLLECTION_NAME).get();
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        List<AvisoArriendo> avisos = new ArrayList<>();
        for (DocumentSnapshot document : documents) {
            AvisoArriendo aviso = document.toObject(AvisoArriendo.class);
            if(aviso != null) {
                aviso.setId(document.getId());
                avisos.add(aviso);
            }
        }
        return avisos;
    }

    public String save(AvisoArriendo aviso) throws ExecutionException, InterruptedException {
        if (aviso.getId() == null || aviso.getId().isEmpty()) {
            DocumentReference docRef = firestore.collection(COLLECTION_NAME).document();
            aviso.setId(docRef.getId());
        }
        ApiFuture<WriteResult> collectionsApiFuture = firestore.collection(COLLECTION_NAME)
                .document(aviso.getId())
                .set(aviso);
        
        return aviso.getId();
    }

    public Optional<AvisoArriendo> findById(String id) throws ExecutionException, InterruptedException {
        ApiFuture<DocumentSnapshot> future = firestore.collection(COLLECTION_NAME).document(id).get();
        DocumentSnapshot document = future.get();
        if (document.exists()) {
            AvisoArriendo aviso = document.toObject(AvisoArriendo.class);
            if(aviso != null) aviso.setId(document.getId());
            return Optional.of(aviso);
        }
        return Optional.empty();
    }
}
