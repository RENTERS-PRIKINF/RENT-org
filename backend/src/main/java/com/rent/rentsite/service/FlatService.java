package com.rent.rentsite.service;

public class FlatService {
    
    public boolean canBeRented(Flat flat) {
    return flat != null
            && flat.isActive()
            && flat.getPrice() > 0;
}
}
