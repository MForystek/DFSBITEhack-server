package com.dfs.repository;

import com.dfs.model.Tag;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface TagsRepository extends JpaRepository<Tag, Long> {
    Optional<Tag> findByName(String name);

}
