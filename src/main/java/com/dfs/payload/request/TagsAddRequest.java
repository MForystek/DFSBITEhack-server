package com.dfs.payload.request;

import com.dfs.model.Tag;
import lombok.Data;

import java.util.List;

@Data
public class TagsAddRequest {
    private List<String> tags;
}
