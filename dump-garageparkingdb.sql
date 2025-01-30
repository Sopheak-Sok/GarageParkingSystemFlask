-- MySQL dump 10.13  Distrib 8.0.31, for Win64 (x86_64)
--
-- Host: localhost    Database: garageparkingdb
-- ------------------------------------------------------
-- Server version	8.0.31

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cars`
--

DROP TABLE IF EXISTS `cars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cars` (
  `CarID` int NOT NULL AUTO_INCREMENT,
  `OwnerID` int DEFAULT NULL,
  `Make` varchar(50) DEFAULT NULL,
  `Model` varchar(50) DEFAULT NULL,
  `Year` int DEFAULT NULL,
  `Color` varchar(20) DEFAULT NULL,
  `LicensePlate` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`CarID`),
  KEY `OwnerID` (`OwnerID`),
  CONSTRAINT `cars_ibfk_1` FOREIGN KEY (`OwnerID`) REFERENCES `owners` (`OwnerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cars`
--

LOCK TABLES `cars` WRITE;
/*!40000 ALTER TABLE `cars` DISABLE KEYS */;
/*!40000 ALTER TABLE `cars` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `owners`
--

DROP TABLE IF EXISTS `owners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `owners` (
  `OwnerID` int NOT NULL AUTO_INCREMENT,
  `FirstName` varchar(50) DEFAULT NULL,
  `LastName` varchar(50) DEFAULT NULL,
  `PhoneNumber` varchar(15) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`OwnerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `owners`
--

LOCK TABLES `owners` WRITE;
/*!40000 ALTER TABLE `owners` DISABLE KEYS */;
/*!40000 ALTER TABLE `owners` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `parkingslots`
--

DROP TABLE IF EXISTS `parkingslots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parkingslots` (
  `SlotID` int NOT NULL AUTO_INCREMENT,
  `SlotNumber` varchar(10) DEFAULT NULL,
  `IsOccupied` tinyint(1) DEFAULT NULL,
  `CarID` int DEFAULT NULL,
  PRIMARY KEY (`SlotID`),
  KEY `CarID` (`CarID`),
  CONSTRAINT `parkingslots_ibfk_1` FOREIGN KEY (`CarID`) REFERENCES `cars` (`CarID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parkingslots`
--

LOCK TABLES `parkingslots` WRITE;
/*!40000 ALTER TABLE `parkingslots` DISABLE KEYS */;
/*!40000 ALTER TABLE `parkingslots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `TransactionID` int NOT NULL AUTO_INCREMENT,
  `CarID` int DEFAULT NULL,
  `SlotID` int DEFAULT NULL,
  `EntryTime` datetime DEFAULT NULL,
  `ExitTime` datetime DEFAULT NULL,
  `AmountPaid` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`TransactionID`),
  KEY `CarID` (`CarID`),
  KEY `SlotID` (`SlotID`),
  CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`CarID`) REFERENCES `cars` (`CarID`),
  CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`SlotID`) REFERENCES `parkingslots` (`SlotID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'garageparkingdb'
--
/*!50003 DROP PROCEDURE IF EXISTS `AddCarAndAssignSlot` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddCarAndAssignSlot`(
    IN p_OwnerID INT,
    IN p_Make VARCHAR(50),
    IN p_Model VARCHAR(50),
    IN p_Year INT,
    IN p_Color VARCHAR(20),
    IN p_LicensePlate VARCHAR(20)
)
BEGIN
    DECLARE v_CarID INT;
    DECLARE v_SlotID INT;
   	
	START TRANSACTION;

    -- Insert the new car
    INSERT INTO Cars (OwnerID, Make, Model, Year, Color, LicensePlate)
    VALUES (p_OwnerID, p_Make, p_Model, p_Year, p_Color, p_LicensePlate);

    -- Get the last inserted CarID
    SET v_CarID = LAST_INSERT_ID();

    -- Find an available slot
    SELECT SlotID INTO v_SlotID
    FROM ParkingSlots
    WHERE IsOccupied = FALSE
    LIMIT 1;

    -- Update the slot to be occupied by the new car
    UPDATE ParkingSlots
    SET IsOccupied = TRUE, CarID = v_CarID
    WHERE SlotID = v_SlotID;
	
    -- Transaction Record EntryTime
   	INSERT INTO Transactions (CarID, SlotID, EntryTime, ExitTime, AmountPaid)
    VALUES (v_CarID, v_SlotID, CURRENT_TIMESTAMP, NULL, NULL);
   	
   	commit;
   
    -- Return the SlotID
    SELECT v_SlotID AS AssignedSlotID;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `RecordParkingTransaction` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `RecordParkingTransaction`(
    IN p_SlotID INT,
    IN p_AmountPaid DECIMAL(10, 2)
)
begin
	declare EnT Datetime;
	declare p_CarID int;

	SELECT EntryTime into EnT FROM Transactions WHERE CarID = p_CarID ORDER BY EntryTime DESC LIMIT 1;
	
	SELECT CarID INTO p_CarID
    FROM ParkingSlots
    WHERE SlotID = p_SlotID
    LIMIT 1;	

    -- Insert the transaction
    UPDATE Transactions 
   	set ExitTime = current_timestamp, AmountPaid = p_AmountPaid 
   	where CarID = p_CarID;
    
    -- Update the parking slot to be unoccupied
    UPDATE ParkingSlots
    SET IsOccupied = FALSE, CarID = NULL
    WHERE SlotID = p_SlotID;
    
    -- Return the TransactionID
    SELECT LAST_INSERT_ID() AS TransactionID;
end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-06-01  6:53:33
