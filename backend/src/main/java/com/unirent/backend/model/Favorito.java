package com.unirent.backend.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Favorito {
    private String id;
    private String usuarioId;
    private String avisoArriendoId;
}
