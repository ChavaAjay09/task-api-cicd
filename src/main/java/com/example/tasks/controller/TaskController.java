package com.example.tasks.controller;

import com.example.tasks.model.Task;
import com.example.tasks.model.TaskExecution;
import com.example.tasks.service.TaskService;

import jakarta.validation.Valid;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
public class TaskController {

    private final TaskService service;

    public TaskController(TaskService service) {
        this.service = service;
    }

    @GetMapping("/tasks")
    public ResponseEntity<?> getTasks(@RequestParam(value = "id", required = false) String id) {
        if (id == null || id.isBlank()) {
            List<Task> tasks = service.getAllTasks();
            return ResponseEntity.ok(tasks);
        } else {
            Task task = service.getTaskById(id);
            return ResponseEntity.ok(task);
        }
    }

    @PutMapping("/tasks")
    public ResponseEntity<Task> putTask(@Valid @RequestBody Task task) {
        Task saved = service.saveTask(task);
        return ResponseEntity.ok(saved);
    }

    @DeleteMapping("/tasks/{id}")
    public ResponseEntity<Void> delete(@PathVariable String id) {
        service.deleteTask(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/tasks/search")
    public ResponseEntity<List<Task>> search(@RequestParam("name") String name) {
        List<Task> found = service.findByNameContains(name);
        return ResponseEntity.ok(found);
    }

    @PutMapping("/tasks/{id}/execute")
    public ResponseEntity<TaskExecution> execute(@PathVariable String id) {
        TaskExecution exec = service.executeTask(id);
        return ResponseEntity.ok(exec);
    }
}
