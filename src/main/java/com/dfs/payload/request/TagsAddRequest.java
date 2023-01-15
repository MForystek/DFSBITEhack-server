package com.dfs.payload.request;

import lombok.Data;

import java.util.List;

@Data
public class TagsAddRequest {
    private List<String> tags_learn;
    private List<String> tags_teach;

}
