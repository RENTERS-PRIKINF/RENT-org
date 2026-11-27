package com.rent.rentsite.repository;

import com.rent.rentsite.entity.Flat;
import com.rent.rentsite.entity.FlatStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FlatRepository extends JpaRepository<Flat, Long> {
    
    List<Flat> findByStatus(FlatStatus status);
    
    List<Flat> findByLandlordId(Long landlordId);
}