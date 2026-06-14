package com.unirent.backend.service;

import com.unirent.backend.model.Reseña;
import com.unirent.backend.repository.ReseñaRepository;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@Service
public class ReseñaService {

    private final ReseñaRepository reseñaRepository;

    public ReseñaService(ReseñaRepository reseñaRepository) {
        this.reseñaRepository = reseñaRepository;
    }

    public List<Reseña> obtenerReseñasPorUsuario(String targetUserId) throws ExecutionException, InterruptedException {
        return reseñaRepository.findByTargetUserId(targetUserId);
    }

    public Reseña guardarReseña(Reseña reseña) throws ExecutionException, InterruptedException {
        if (reseña.getTimestamp() == null) {
            reseña.setTimestamp(new Date());
        }
        reseñaRepository.save(reseña);
        return reseña;
    }

    public Map<String, Object> obtenerEstadisticas(String targetUserId) throws ExecutionException, InterruptedException {
        List<Reseña> reseñas = reseñaRepository.findByTargetUserId(targetUserId);
        
        int total = reseñas.size();
        double average = 0.0;
        
        if (total > 0) {
            double sum = 0;
            for (Reseña r : reseñas) {
                sum += r.getRating();
            }
            average = sum / total;
        }

        Map<String, Object> stats = new HashMap<>();
        stats.put("average", average);
        stats.put("totalReviews", total);
        return stats;
    }
}
