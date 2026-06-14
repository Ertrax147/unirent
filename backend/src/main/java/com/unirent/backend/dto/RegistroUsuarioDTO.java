package com.unirent.backend.dto;

import com.unirent.backend.model.RolEnum;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class RegistroUsuarioDTO {

    @NotNull(message = "El rol es obligatorio (ESTUDIANTE o ARRENDADOR)")
    private RolEnum rol;

    private String telefono;
}