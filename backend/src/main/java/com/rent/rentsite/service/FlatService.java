package com.rent.rentsite.service;

import com.rent.rentsite.entity.Flat;
import com.rent.rentsite.entity.FlatStatus;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import org.springframework.stereotype.Service;

@Service
public class FlatService {

    public List<String> validateFlat(Flat flat) {
        List<String> errors = new ArrayList<>();

        if (flat == null) {
            errors.add("Квартира не должна быть null.");
            return List.copyOf(errors);
        }

        if (flat.getLandlordId() == null || flat.getLandlordId() <= 0) {
            errors.add("Необходимо указать корректный идентификатор арендодателя.");
        }

        if (flat.getAddress() == null || flat.getAddress().isBlank()) {
            errors.add("Необходимо указать адрес квартиры.");
        }

        if (flat.getArea() == null
                || !Double.isFinite(flat.getArea())
                || flat.getArea() <= 0) {
            errors.add("Площадь квартиры должна быть положительной.");
        }

        if (flat.getRooms() == null || flat.getRooms() <= 0) {
            errors.add("Количество комнат должно быть положительным.");
        }

        if (flat.getFloor() == null || flat.getFloor() < 0) {
            errors.add("Этаж не может быть отрицательным.");
        }

        if (flat.getStatus() == null) {
            errors.add("Необходимо указать статус квартиры.");
        }

        return List.copyOf(errors);
    }

    public boolean canBeRented(Flat flat) {
        return validateFlat(flat).isEmpty()
                && flat.getStatus() == FlatStatus.AVAILABLE;
    }

    public List<Flat> findAvailableFlats(List<Flat> flats) {
        Objects.requireNonNull(flats, "Список квартир не должен быть null.");

        return flats.stream()
                .filter(this::canBeRented)
                .toList();
    }

    public void changeStatus(Flat flat, FlatStatus newStatus) {
        Objects.requireNonNull(flat, "Квартира не должна быть null.");
        Objects.requireNonNull(newStatus, "Новый статус не должен быть null.");

        flat.setStatus(newStatus);
    }
}