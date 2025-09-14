package com.ezalb.todo.controller;

import com.ezalb.todo.dto.CreateTodoRequest;
import com.ezalb.todo.dto.TodoDto;
import com.ezalb.todo.service.TodoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/todos")
@RequiredArgsConstructor
@Validated
public class TodoController {
    private final TodoService service;

    @PostMapping
    public ResponseEntity<TodoDto> create(@RequestBody @Validated CreateTodoRequest req) {
        TodoDto created = service.create(req);
        return ResponseEntity.status(201).body(created);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TodoDto> get(@PathVariable UUID id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @GetMapping
    public ResponseEntity<List<TodoDto>> list() {
        return ResponseEntity.ok(service.listAll());
    }

    @PutMapping("/{id}")
    public ResponseEntity<TodoDto> update(@PathVariable UUID id, @RequestBody @Validated CreateTodoRequest req) {
        return ResponseEntity.ok(service.update(id, req));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable UUID id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/complete")
    public ResponseEntity<TodoDto> markComplete(@PathVariable UUID id, @RequestParam boolean completed) {
        return ResponseEntity.ok(service.markCompleted(id, completed));
    }
}
