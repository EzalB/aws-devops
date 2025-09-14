package com.ezalb.todo.service;

import com.ezalb.todo.dto.CreateTodoRequest;
import com.ezalb.todo.dto.TodoDto;
import com.ezalb.todo.entity.Todo;
import com.ezalb.todo.exception.NotFoundException;
import com.ezalb.todo.repository.TodoRepository;
import com.ezalb.todo.sqs.SqsPublisher;
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

        sqsPublisher.publishNotification("system", "Todo updated: " + saved.getId());

        return toDto(saved);
    }

    public void delete(UUID id) {
        if (!repo.existsById(id)) throw new NotFoundException("Todo not found: " + id);
        repo.deleteById(id);

        sqsPublisher.publishNotification("system", "Todo deleted: " + id);
    }

    public TodoDto markCompleted(UUID id, boolean completed) {
        Todo t = repo.findById(id).orElseThrow(() -> new NotFoundException("Todo not found: " + id));
        t.setCompleted(completed);
        Todo saved = repo.save(t);

        String message = "Todo " + saved.getId() + " marked " + (completed ? "completed" : "incomplete");
        sqsPublisher.publishNotification("system", message);

        return toDto(saved);
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
