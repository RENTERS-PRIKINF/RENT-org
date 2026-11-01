package com.rent.rentsite.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Flat {

    private Long flatId;
    private Long landlordId;
    private String address;
    private BigDecimal area;
    private Integer rooms;
    private Integer floor;
    private String cadastralNumber;
    private FlatStatus status;
    private String description;
    private LocalDateTime createdAt;

    protected Flat() {
    }

    public Flat(
            Long flatId,
            Long landlordId,
            String address,
            BigDecimal area,
            Integer rooms,
            Integer floor,
            String cadastralNumber,
            FlatStatus status,
            String description,
            LocalDateTime createdAt
    ) {
        this.flatId = flatId;
        this.landlordId = landlordId;
        this.address = address;
        this.area = area;
        this.rooms = rooms;
        this.floor = floor;
        this.cadastralNumber = cadastralNumber;
        this.status = status;
        this.description = description;
        this.createdAt = createdAt;
    }

    public Long getFlatId() {
        return flatId;
    }

    public void setFlatId(Long flatId) {
        this.flatId = flatId;
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

    public BigDecimal getArea() {
        return area;
    }

    public void setArea(BigDecimal area) {
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

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}