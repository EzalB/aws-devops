package com.example.todos.service;

import com.example.todos.dto.CreateTodoRequest;
import com.example.todos.dto.TodoDto;
import com.example.todos.entity.Todo;
import com.example.todos.exception.NotFoundException;
import com.example.todos.repository.TodoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TodoService {
    private final TodoRepository repo;

    private final SqsPublisher sqsPublisher;

    public TodoService(SqsPublisher sqsPublisher) {
        this.sqsPublisher = sqsPublisher;
    }

    public TodoDto create(CreateTodoRequest req) {
        Todo t = Todo.builder()
                .title(req.getTitle())
                .description(req.getDescription())
                .completed(false)
                .build();
        Todo saved = repo.save(t);
        return toDto(saved);
    }

    public TodoDto getById(UUID id) {
        return repo.findById(id).map(this::toDto)
                .orElseThrow(() -> new NotFoundException("Todo not found: " + id));
    }

    public List<TodoDto> listAll() {
        return repo.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    public TodoDto update(UUID id, CreateTodoRequest req) {
        Todo t = repo.findById(id).orElseThrow(() -> new NotFoundException("Todo not found: " + id));
        t.setTitle(req.getTitle());
        t.setDescription(req.getDescription());
        Todo saved = repo.save(t);
        return toDto(saved);
    }

    public void delete(UUID id) {
        if (!repo.existsById(id)) throw new NotFoundException("Todo not found: " + id);
        repo.deleteById(id);
    }

    public TodoDto markCompleted(UUID id, boolean completed) {
        Todo t = repo.findById(id).orElseThrow(() -> new NotFoundException("Todo not found: " + id));
        t.setCompleted(completed);

        String message = "Todo " + todoId + " completed!";
        sqsPublisher.publishNotification(userId, message);

        return toDto(repo.save(t));
    }

    private TodoDto toDto(Todo t) {
        return TodoDto.builder()
                .id(t.getId())
                .title(t.getTitle())
                .description(t.getDescription())
                .completed(t.isCompleted())
                .createdAt(t.getCreatedAt())
                .updatedAt(t.getUpdatedAt())
                .build();
    }
}
