package com.rent.rentsite.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "flats")
@Getter
@Setter
@NoArgsConstructor
public class Flat {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "flat_id")
    private Long flatId;

    @Column(name = "landlord_id", nullable = false)
    private Long landlordId;

    @Column(name = "address", nullable = false, length = 250)
    private String address;

    @Column(name = "area", nullable = false)
    private Double area;

    @Column(name = "rooms", nullable = false)
    private Integer rooms;

    @Column(name = "floor")
    private Integer floor;

    @Column(name = "cadastral_number", length = 25)
    private String cadastralNumber;

    @Convert(converter = FlatStatusConverter.class)
    @Column(name = "status", nullable = false)
    private FlatStatus status = FlatStatus.AVAILABLE;

    @Column(name = "description", length = 1000)
    private String description;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "flat", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<FlatMedia> media = new ArrayList<>();

    public Flat(
            Long landlordId,
            String address,
            Double area,
            Integer rooms,
            Integer floor,
            String cadastralNumber,
            FlatStatus status,
            String description
    ) {
        this.landlordId = landlordId;
        this.address = address;
        this.area = area;
        this.rooms = rooms;
        this.floor = floor;
        this.cadastralNumber = cadastralNumber;
        this.status = status != null ? status : FlatStatus.AVAILABLE;
        this.description = description;
    }

    public List<FlatMedia> getMedia() {
        return List.copyOf(media);
    }

    public void addMedia(FlatMedia flatMedia) {
        if (flatMedia == null) {
            throw new IllegalArgumentException("Медиафайл не должен быть null.");
        }
        if (flatMedia.getFlat() != null && !flatMedia.getFlat().equals(this)) {
            throw new IllegalArgumentException("Медиафайл уже привязан к другой квартире.");
        }
        if (media.contains(flatMedia)) {
            return;
        }
        media.add(flatMedia);
        flatMedia.setFlat(this);
    }

    public void removeMedia(FlatMedia flatMedia) {
        if (media.remove(flatMedia)) {
            flatMedia.setFlat(null);
        }
    }
}