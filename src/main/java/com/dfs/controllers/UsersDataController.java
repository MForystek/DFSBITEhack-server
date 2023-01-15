package com.dfs.controllers;

import com.dfs.model.Tag;
import com.dfs.model.User;
import com.dfs.payload.request.TagsAddRequest;
import com.dfs.repository.TagsRepository;
import com.dfs.repository.UserRepository;
import com.dfs.security.jwt.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collection;
import java.util.Optional;
import java.util.stream.Collectors;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/user")
public class UsersDataController {
    @Autowired
    AuthenticationManager authenticationManager;
    @Autowired
    UserRepository userRepository;
    @Autowired
    TagsRepository tagsRepository;
    @Autowired
    JwtUtils jwtUtils;


    @PostMapping("add-tags")
    public ResponseEntity<?> addTags(@RequestBody TagsAddRequest tags,
                                     @RequestHeader("Authorization") String token) {

        String username = jwtUtils.getUserNameFromJwtToken(token);
        User user = userRepository.findByUsername(username).orElseThrow();
        Collection<Tag> newTagsLearn = tags
                .getTags_learn()
                .stream()
                .map(t -> tagsRepository.findByName(t))
                .filter(Optional::isPresent)
                .map(Optional::get)
                .collect(Collectors.toSet());
        user.addTagsLearn(newTagsLearn);

        Collection<Tag> newTagsTeach = tags
                .getTags_learn()
                .stream()
                .map(t -> tagsRepository.findByName(t))
                .filter(Optional::isPresent)
                .map(Optional::get)
                .collect(Collectors.toSet());
        user.addTagsTeach(newTagsTeach);

        userRepository.save(user);
        return ResponseEntity.ok(user);
    }

    @PostMapping("delete-tags")
    public ResponseEntity<?> deleteTags(@RequestBody TagsAddRequest tags,
                                     @RequestHeader("Authorization") String token) {

        String username = jwtUtils.getUserNameFromJwtToken(token);
        User user = userRepository.findByUsername(username).orElseThrow();
        Collection<Tag> tagsLearn = tags
                .getTags_learn()
                .stream()
                .map(t -> tagsRepository.findByName(t))
                .filter(Optional::isPresent)
                .map(Optional::get)
                .collect(Collectors.toSet());
        user.deleteTagsLearn(tagsLearn);

        Collection<Tag> tagsTeach = tags
                .getTags_learn()
                .stream()
                .map(t -> tagsRepository.findByName(t))
                .filter(Optional::isPresent)
                .map(Optional::get)
                .collect(Collectors.toSet());
        user.deleteTagsTeach(tagsTeach);

        userRepository.save(user);
        return ResponseEntity.ok(user);
    }

    @GetMapping("user-data")
    public ResponseEntity<?> getUserData(@RequestHeader("Authorization") String token) {
        String username = jwtUtils.getUserNameFromJwtToken(token);
        User user = userRepository.findByUsername(username).orElseThrow();
        return ResponseEntity.ok(user);
    }

    @GetMapping("try-match")
    public ResponseEntity<?> tryMatch(@RequestHeader("Authorization") String token) {
        String username = jwtUtils.getUserNameFromJwtToken(token);
        User user = userRepository.findByUsername(username).orElseThrow();

        return ResponseEntity.ok("");
    }

    @GetMapping("get-matches")
    public ResponseEntity<?> getMatches(@RequestHeader("Authorization") String token) {
        String username = jwtUtils.getUserNameFromJwtToken(token);
        User user = userRepository.findByUsername(username).orElseThrow();

        return ResponseEntity.ok("");
    }

}
