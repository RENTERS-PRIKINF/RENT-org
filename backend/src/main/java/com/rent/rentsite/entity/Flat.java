package com.rent.rentsite.entity;

import java.time.Clock;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class Flat {

    private Long flatId;
    private Long landlordId;
    private String address;
    private Double area;
    private Integer rooms;
    private Integer floor;
    private String cadastralNumber;
    private FlatStatus status;
    private String description;
    private LocalDateTime createdAt = LocalDateTime.now(Clock.systemUTC());
    private List<String> listingUrls = new ArrayList<>();
    private List<FlatMedia> media = new ArrayList<>();

    protected Flat() {
    }

    public Flat(
            Long flatId,                //TODO: Добавить автогенерацию
            Long landlordId,
            String address,
            Double area,
            Integer rooms,
            Integer floor,
            String cadastralNumber,
            FlatStatus status,
            String description
    ) {
        this.flatId = flatId;           //TODO: Добавить автогенерацию
        this.landlordId = landlordId;
        this.address = address;
        this.area = area;
        this.rooms = rooms;
        this.floor = floor;
        this.cadastralNumber = cadastralNumber;
        this.status = status;
        this.description = description;
    }

    public Long getFlatId() {
        return flatId;
    }

    public Long getLandlordId() {
        return landlordId;
    }

    public void setLandlordId(Long landlordId) {
        this.landlordId = landlordId;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public Double getArea() {
        return area;
    }

    public void setArea(Double area) {
        this.area = area;
    }

    public Integer getRooms() {
        return rooms;
    }

    public void setRooms(Integer rooms) {
        this.rooms = rooms;
    }

    public Integer getFloor() {
        return floor;
    }

    public void setFloor(Integer floor) {
        this.floor = floor;
    }

    public String getCadastralNumber() {
        return cadastralNumber;
    }

    public void setCadastralNumber(String cadastralNumber) {
        this.cadastralNumber = cadastralNumber;
    }

    public FlatStatus getStatus() {
        return status;
    }

    public void setStatus(FlatStatus status) {
        this.status = status;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public List<String> getListingUrls() {
        return List.copyOf(listingUrls);
    }

    public void addListingUrl(String url) {
        if (url == null || url.isBlank()) {
            throw new IllegalArgumentException(
                    "Ссылка на объявление не должна быть пустой."
            );
        }

        String normalizedUrl = url.trim();

        if (!listingUrls.contains(normalizedUrl)) {
            listingUrls.add(normalizedUrl);
        }
    }

    public void removeListingUrl(String url) {
         if (url != null) {
            listingUrls.remove(url.trim());
        }
    }

    public List<FlatMedia> getMedia() {
        return List.copyOf(media);
    }

    public void addMedia(FlatMedia flatMedia) {
        if (flatMedia == null) {
            throw new IllegalArgumentException(
                    "Медиафайл не должен быть null."
            );
        }

        if (flatMedia.getFlatId() != null && !flatMedia.getFlatId().equals(this.flatId)) {
            throw new IllegalArgumentException(
                    "Медиафайл уже привязан к другой квартире."
            );
        }

        if (media.contains(flatMedia)) {
            return;
        }

        media.add(flatMedia);
        flatMedia.setFlatId(this.flatId);
    }

    public void removeMedia(FlatMedia flatMedia) {
        if (media.remove(flatMedia)) {
            flatMedia.setFlatId(null);
        }
    }
}