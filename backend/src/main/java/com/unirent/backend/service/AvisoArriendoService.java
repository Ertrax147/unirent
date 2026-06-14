package com.unirent.backend.service;

import com.unirent.backend.model.AvisoArriendo;
import com.unirent.backend.repository.AvisoArriendoRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.concurrent.ExecutionException;

@Service
public class AvisoArriendoService {

    private final AvisoArriendoRepository repository;

    public AvisoArriendoService(AvisoArriendoRepository repository) {
        this.repository = repository;
    }

    public List<AvisoArriendo> obtenerTodos() throws ExecutionException, InterruptedException {
        return repository.findAll();
    }

    public AvisoArriendo guardar(AvisoArriendo aviso) throws ExecutionException, InterruptedException {
        String id = repository.save(aviso);
        aviso.setId(id);
        return aviso;
    }

    public Optional<AvisoArriendo> obtenerPorId(String id) throws ExecutionException, InterruptedException {
        return repository.findById(id);
    }
}
