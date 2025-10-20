package com.example.tasks.service;

import com.example.tasks.model.Task;
import com.example.tasks.model.TaskExecution;
import com.example.tasks.repo.TaskRepository;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Date;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Service
public class TaskService {

    private final TaskRepository repository;
    private final CommandValidator validator;

    public TaskService(TaskRepository repository, CommandValidator validator) {
        this.repository = repository;
        this.validator = validator;
    }

    public List<Task> getAllTasks() {
        return repository.findAll();
    }

    public Task getTaskById(String id) {
        return repository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Task not found"));
    }

    public Task saveTask(Task task) {
        if (!validator.isCommandSafe(task.getCommand())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Command rejected as unsafe");
        }
        if (task.getId() == null || task.getId().isBlank()) {
            task.setId(UUID.randomUUID().toString());
        } else {
            Optional<Task> existing = repository.findById(task.getId());
            if (existing.isPresent()) {
                Task existingTask = existing.get();
                existingTask.setName(task.getName());
                existingTask.setOwner(task.getOwner());
                existingTask.setCommand(task.getCommand());
                return repository.save(existingTask);
            }
        }
        return repository.save(task);
    }

    public void deleteTask(String id) {
        if (!repository.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Task not found");
        }
        repository.deleteById(id);
    }

    public List<Task> findByNameContains(String q) {
        List<Task> results = repository.findByNameContainingIgnoreCase(q);
        if (results == null || results.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "No tasks match the query");
        }
        return results;
    }

    public TaskExecution executeTask(String id) {
        Task task = getTaskById(id);
        if (!validator.isCommandSafe(task.getCommand())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Stored command rejected as unsafe");
        }
        Date start = new Date();
        String output = runCommand(task.getCommand(), Duration.ofSeconds(30));
        Date end = new Date();

        TaskExecution exec = new TaskExecution(start, end, output);
        task.getTaskExecutions().add(exec);
        repository.save(task);
        return exec;
    }

    private String runCommand(String command, Duration timeout) {
        boolean isWindows = System.getProperty("os.name").toLowerCase().contains("win");
        ProcessBuilder pb = isWindows
                ? new ProcessBuilder("cmd.exe", "/c", command)
                : new ProcessBuilder("bash", "-lc", command);
        pb.redirectErrorStream(true);

        try {
            Process process = pb.start();
            boolean finished = process.waitFor(timeout.toMillis(), TimeUnit.MILLISECONDS);
            if (!finished) {
                process.destroyForcibly();
                throw new ResponseStatusException(HttpStatus.REQUEST_TIMEOUT, "Command timed out");
            }
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line).append(System.lineSeparator());
                }
            }
            return sb.toString().trim();
        } catch (ResponseStatusException e) {
            throw e;
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Command execution failed");
        }
    }
}
