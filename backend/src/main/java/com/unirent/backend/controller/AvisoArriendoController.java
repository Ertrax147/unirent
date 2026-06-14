package com.unirent.backend.controller;

import com.unirent.backend.model.AvisoArriendo;
import com.unirent.backend.service.AvisoArriendoService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/avisos")
public class AvisoArriendoController {

    private final AvisoArriendoService service;

    public AvisoArriendoController(AvisoArriendoService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<List<AvisoArriendo>> obtenerTodos() {
        try {
            List<AvisoArriendo> avisos = service.obtenerTodos().stream()
                    .filter(a -> a.isDisponible())
                    .toList();
            return ResponseEntity.ok(avisos);
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<AvisoArriendo> obtenerPorId(@PathVariable String id) {
        try {
            var avisoOpt = service.obtenerPorId(id);
            if (avisoOpt.isPresent()) {
                return ResponseEntity.ok(avisoOpt.get());
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @PostMapping
    public ResponseEntity<AvisoArriendo> crearAviso(Authentication authentication, @RequestBody AvisoArriendo aviso) {
        try {
            String uid = (String) authentication.getPrincipal();
            aviso.setArrendadorId(uid);
            
            // Asignar disponible si no viene
            if (aviso.getPrecio() != null && aviso.getCuposDisponibles() == null) {
                aviso.setCuposDisponibles(1);
            }
            aviso.setDisponible(true);
            
            AvisoArriendo guardado = service.guardar(aviso);
            return ResponseEntity.ok(guardado);
        } catch (ExecutionException | InterruptedException e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @PutMapping("/{id}/cerrar")
    public ResponseEntity<Void> cerrarAviso(Authentication authentication, @PathVariable String id) {
        try {
            var avisoOpt = service.obtenerPorId(id);
            if (avisoOpt.isPresent()) {
                AvisoArriendo aviso = avisoOpt.get();
                aviso.setDisponible(false);
                service.guardar(aviso);
                return ResponseEntity.ok().build();
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}
