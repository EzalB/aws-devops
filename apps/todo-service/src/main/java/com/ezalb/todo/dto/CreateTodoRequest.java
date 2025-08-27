package com.example.todos.dto;

import lombok.*;
import jakarta.validation.constraints.NotBlank;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateTodoRequest {
    @NotBlank
    private String title;
    private String description;
}
