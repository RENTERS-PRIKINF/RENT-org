package com.rent.rentsite.entity;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter(autoApply = true)
public class FlatStatusConverter implements AttributeConverter<FlatStatus, String> {

    @Override
    public String convertToDatabaseColumn(FlatStatus attribute) {
        if (attribute == null) {
            return null;
        }
        return attribute.name().toLowerCase(); // RENTED -> "rented"
    }

    @Override
    public FlatStatus convertToEntityAttribute(String dbData) {
        if (dbData == null) {
            return null;
        }
        return FlatStatus.valueOf(dbData.toUpperCase()); // "rented" -> RENTED
    }
}