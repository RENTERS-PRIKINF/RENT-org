package com.rent.rentsite.service;

import com.rent.rentsite.entity.Flat;
import com.rent.rentsite.entity.FlatStatus;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class FlatServiceTest {

    private final FlatService flatService = new FlatService();

    private Flat createValidFlat() {
        return new Flat(
                1L,
                10L,
                "ул. Ленина, 10",
                new BigDecimal("45.5"),
                2,
                3,
                "12345678901234567890",
                FlatStatus.FREE,
                "Описание квартиры",
                LocalDateTime.now()
        );
    }

    @Test
    void validateFlat_shouldReturnEmptyList_whenFlatIsValid() {
        Flat flat = createValidFlat();

        List<String> errors = flatService.validateFlat(flat);

        assertThat(errors).isEmpty();
    }

    @Test
    void validateFlat_shouldReturnError_whenFlatIsNull() {
        List<String> errors = flatService.validateFlat(null);

        assertThat(errors)
                .hasSize(1)
                .contains("Квартира не должна быть null.");
    }

    @Test
    void validateFlat_shouldReturnError_whenLandlordIdIsNull() {
        Flat flat = createValidFlat();
        flat.setLandlordId(null);

        List<String> errors = flatService.validateFlat(flat);

        assertThat(errors).contains(
                "Необходимо указать корректный идентификатор арендодателя."
        );
    }

    @Test
    void validateFlat_shouldReturnError_whenLandlordIdIsNotPositive() {
        Flat flat = createValidFlat();
        flat.setLandlordId(0L);

        List<String> errors = flatService.validateFlat(flat);

        assertThat(errors).contains(
                "Необходимо указать корректный идентификатор арендодателя."
        );
    }

    @Test
    void validateFlat_shouldReturnError_whenAddressIsNull() {
        Flat flat = createValidFlat();
        flat.setAddress(null);

        List<String> errors = flatService.validateFlat(flat);

        assertThat(errors).contains("Необходимо указать адрес квартиры.");
    }

    @Test
    void validateFlat_shouldReturnError_whenAddressIsBlank() {
        Flat flat = createValidFlat();
        flat.setAddress("   ");

        List<String> errors = flatService.validateFlat(flat);

        assertThat(errors).contains("Необходимо указать адрес квартиры.");
    }

    @Test
    void validateFlat_shouldReturnError_whenAreaIsNull() {
        Flat flat = createValidFlat();
        flat.setArea(null);

        List<String> errors = flatService.validateFlat(flat);

        assertThat(errors).contains(
                "Площадь квартиры должна быть положительной."
        );
    }

    @Test
    void validateFlat_shouldReturnError_whenAreaIsZero() {
        Flat flat = createValidFlat();
        flat.setArea(BigDecimal.ZERO);

        List<String> errors = flatService.validateFlat(flat);

        assertThat(errors).contains(
                "Площадь квартиры должна быть положительной."
        );
    }

    @Test
    void validateFlat_shouldReturnError_whenAreaIsNegative() {
        Flat flat = createValidFlat();
        flat.setArea(new BigDecimal("-10"));

        List<String> errors = flatService.validateFlat(flat);

        assertThat(errors).contains(
                "Площадь квартиры должна быть положительной."
        );
    }

    @Test
    void validateFlat_shouldReturnError_whenRoomsIsNull() {
        Flat flat = createValidFlat();
        flat.setRooms(null);

        List<String> errors = flatService.validateFlat(flat);

        assertThat(errors).contains(
                "Количество комнат должно быть положительным."
        );
    }

    @Test
    void validateFlat_shouldReturnError_whenRoomsIsZero() {
        Flat flat = createValidFlat();
        flat.setRooms(0);

        List<String> errors = flatService.validateFlat(flat);

        assertThat(errors).contains(
                "Количество комнат должно быть положительным."
        );
    }

    @Test
    void validateFlat_shouldReturnError_whenRoomsIsNegative() {
        Flat flat = createValidFlat();
        flat.setRooms(-1);

        List<String> errors = flatService.validateFlat(flat);

        assertThat(errors).contains(
                "Количество комнат должно быть положительным."
        );
    }

    @Test
    void validateFlat_shouldReturnError_whenFloorIsNull() {
        Flat flat = createValidFlat();
        flat.setFloor(null);

        List<String> errors = flatService.validateFlat(flat);

        assertThat(errors).contains(
                "Этаж не может быть отрицательным."
        );
    }

    @Test
    void validateFlat_shouldReturnError_whenFloorIsNegative() {
        Flat flat = createValidFlat();
        flat.setFloor(-1);

        List<String> errors = flatService.validateFlat(flat);

        assertThat(errors).contains(
                "Этаж не может быть отрицательным."
        );
    }

    @Test
    void validateFlat_shouldAcceptZeroFloor() {
        Flat flat = createValidFlat();
        flat.setFloor(0);

        List<String> errors = flatService.validateFlat(flat);

        assertThat(errors).isEmpty();
    }

    @Test
    void validateFlat_shouldReturnError_whenStatusIsNull() {
        Flat flat = createValidFlat();
        flat.setStatus(null);

        List<String> errors = flatService.validateFlat(flat);

        assertThat(errors).contains(
                "Необходимо указать статус квартиры."
        );
    }

    @Test
    void validateFlat_shouldReturnAllErrors_whenSeveralFieldsAreInvalid() {
        Flat flat = createValidFlat();
        flat.setLandlordId(null);
        flat.setAddress("");
        flat.setArea(BigDecimal.ZERO);
        flat.setRooms(0);
        flat.setFloor(-1);
        flat.setStatus(null);

        List<String> errors = flatService.validateFlat(flat);

        assertThat(errors).hasSize(6);
    }

    @Test
    void canBeRented_shouldReturnTrue_whenFlatIsValidAndFree() {
        Flat flat = createValidFlat();

        boolean result = flatService.canBeRented(flat);

        assertThat(result).isTrue();
    }

    @ParameterizedTest
    @EnumSource(
            value = FlatStatus.class,
            mode = EnumSource.Mode.EXCLUDE,
            names = {"FREE"}
    )
    void canBeRented_shouldReturnFalse_whenFlatIsNotFree(
            FlatStatus status
    ) {
        Flat flat = createValidFlat();
        flat.setStatus(status);

        boolean result = flatService.canBeRented(flat);

        assertThat(result).isFalse();
    }

    @Test
    void canBeRented_shouldReturnFalse_whenFlatIsInvalid() {
        Flat flat = createValidFlat();
        flat.setArea(BigDecimal.ZERO);

        boolean result = flatService.canBeRented(flat);

        assertThat(result).isFalse();
    }

    @Test
    void canBeRented_shouldReturnFalse_whenFlatIsNull() {
        boolean result = flatService.canBeRented(null);

        assertThat(result).isFalse();
    }

    @Test
    void findAvailableFlats_shouldReturnOnlyValidFreeFlats() {
        Flat availableFlat = createValidFlat();

        Flat rentedFlat = createValidFlat();
        rentedFlat.setStatus(FlatStatus.RENTED);

        Flat invalidFlat = createValidFlat();
        invalidFlat.setArea(BigDecimal.ZERO);

        Flat secondAvailableFlat = createValidFlat();
        secondAvailableFlat.setFlatId(2L);

        List<Flat> flats = Arrays.asList(
                availableFlat,
                rentedFlat,
                invalidFlat,
                null,
                secondAvailableFlat
        );

        List<Flat> result = flatService.findAvailableFlats(flats);

        assertThat(result)
                .hasSize(2)
                .containsExactly(availableFlat, secondAvailableFlat);
    }

    @Test
    void findAvailableFlats_shouldReturnEmptyList_whenNoFlatsAreAvailable() {
        Flat rentedFlat = createValidFlat();
        rentedFlat.setStatus(FlatStatus.RENTED);

        Flat invalidFlat = createValidFlat();
        invalidFlat.setRooms(0);

        List<Flat> result = flatService.findAvailableFlats(
                List.of(rentedFlat, invalidFlat)
        );

        assertThat(result).isEmpty();
    }

    @Test
    void findAvailableFlats_shouldReturnEmptyList_whenInputIsEmpty() {
        List<Flat> result = flatService.findAvailableFlats(List.of());

        assertThat(result).isEmpty();
    }

    @Test
    void findAvailableFlats_shouldThrowException_whenListIsNull() {
        assertThatThrownBy(() -> flatService.findAvailableFlats(null))
                .isInstanceOf(NullPointerException.class)
                .hasMessage("Список квартир не должен быть null.");
    }

    @ParameterizedTest
    @EnumSource(FlatStatus.class)
    void changeStatus_shouldChangeStatus_whenNewStatusIsValid(
            FlatStatus newStatus
    ) {
        Flat flat = createValidFlat();

        flatService.changeStatus(flat, newStatus);

        assertThat(flat.getStatus()).isEqualTo(newStatus);
    }

    @Test
    void changeStatus_shouldThrowException_whenFlatIsNull() {
        assertThatThrownBy(
                () -> flatService.changeStatus(null, FlatStatus.RENTED)
        )
                .isInstanceOf(NullPointerException.class)
                .hasMessage("Квартира не должна быть null.");
    }

    @Test
    void changeStatus_shouldThrowException_whenNewStatusIsNull() {
        Flat flat = createValidFlat();

        assertThatThrownBy(() -> flatService.changeStatus(flat, null))
                .isInstanceOf(NullPointerException.class)
                .hasMessage("Новый статус не должен быть null.");

        assertThat(flat.getStatus()).isEqualTo(FlatStatus.FREE);
    }
}
