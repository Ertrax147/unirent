package com.unirent.backend.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.google.cloud.firestore.annotation.PropertyName;
import java.util.Date;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Reseña {
    private String id;

    @JsonProperty("targetUserId")
    @PropertyName("targetUserId")
    private String targetUserId;

    @JsonProperty("authorUserId")
    @PropertyName("authorUserId")
    private String authorUserId;

    @JsonProperty("chatRoomId")
    @PropertyName("chatRoomId")
    private String chatRoomId;

    @JsonProperty("isStudent")
    @PropertyName("isStudent")
    private Boolean isStudent;

    private int rating; 
    private String comment;
    private Date timestamp;
}