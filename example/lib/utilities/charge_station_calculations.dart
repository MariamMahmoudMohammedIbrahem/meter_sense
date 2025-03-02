import '../commons.dart';

// ---------------------------- Charge Calculation ----------------------------

/// Calculates needed values for the charge center from meter data.
void calculateChargeValues(List<int> data) {
  clientID = convertToInt(data, 1, 4);
  totalReadings = convertToInt(data, 5, 4);
  pulses = convertToInt(data, 9, 2);
  totalReadingsPulses = merge(totalReadings, pulses);
  currentBalance = (convertToInt(data, 11, 4) - convertToInt(data, 27, 4)) / 100;
  // currentTariff = convertToInt(data, 15, 1);
  currentTariffVersion = convertToInt(data, 16, 2);
}