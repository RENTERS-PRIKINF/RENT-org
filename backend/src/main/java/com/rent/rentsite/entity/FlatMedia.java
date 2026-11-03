package com.rent.rentsite.entity;

public class FlatMedia {

    private Long mediaId;
    private Long flatId; 
    private String fileUrl;
    private MediaType mediaType;

    protected FlatMedia() {
    }

    public FlatMedia(String fileUrl, MediaType mediaType) {
        this.fileUrl = fileUrl;
        this.mediaType = mediaType;
    }

    public Long getMediaId() {
        return mediaId;
    }

    public String getFileUrl() {
        return fileUrl;
    }

    public MediaType getMediaType() {
        return mediaType;
    }

    public Long getFlatId() {
        return flatId;
    }

    void setFlatId(Long flatId) {
        this.flatId = flatId;
    }
}
