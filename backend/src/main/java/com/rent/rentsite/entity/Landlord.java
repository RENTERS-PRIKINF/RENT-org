package com.rent.rentsite.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "landlords")
@Getter
@Setter
@NoArgsConstructor
public class Landlord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "landlord_id")
    private Long landlordId;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "user_id", 
            nullable = false, 
            unique = true,
            foreignKey = @ForeignKey(name = "landlords_user_id_fkey")
    )
    private User user;

    @Column(name = "company_name", length = 255)
    private String companyName;

    @Column(name = "notes", columnDefinition = "text")
    private String notes;

    public Landlord(User user, String companyName, String notes) {
        this.user = user;
        this.companyName = companyName;
        this.notes = notes;
    }
}