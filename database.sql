-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 15, 2026 at 05:03 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `carrent_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `fleet`
--

CREATE TABLE `fleet` (
  `id` int(11) NOT NULL,
  `brand` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  `cubic` int(11) DEFAULT NULL,
  `fuel` varchar(50) DEFAULT NULL,
  `transmission` varchar(50) DEFAULT NULL,
  `year` int(4) DEFAULT NULL,
  `available` tinyint(1) NOT NULL DEFAULT 1,
  `price_per_day` double NOT NULL DEFAULT 0,
  `type` enum('rental','taxi','both') NOT NULL DEFAULT 'rental',
  `image_path` varchar(255) DEFAULT NULL,
  `gps_device_id` varchar(100) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fleet`
--

INSERT INTO `fleet` (`id`, `brand`, `model`, `cubic`, `fuel`, `transmission`, `year`, `available`, `price_per_day`, `type`, `image_path`, `gps_device_id`, `created_at`) VALUES
(14, 'Toyota', 'Corolla', 1600, 'Petrol', 'Manual', 2020, 1, 35, 'rental', 'images/corolla.jpg', 'DEMO001', '2026-10-15 10:06:52'),
(15, 'Honda', 'Civic', 1800, 'Petrol', 'Automatic', 2021, 1, 40, 'rental', 'images/civic.jpg', 'DEMO002', '2026-10-15 10:06:52'),
(16, 'Ford', 'Focus', 1500, 'Diesel', 'Manual', 2019, 1, 30, 'rental', 'images/focus.jpg', 'DEMO003', '2026-10-15 10:06:52'),
(17, 'BMW', '320i', 2000, 'Petrol', 'Automatic', 2022, 1, 65, 'rental', 'images/bmw320.jpg', 'DEMO004', '2026-10-15 10:06:52'),
(18, 'Mercedes', 'C200', 2000, 'Diesel', 'Automatic', 2021, 1, 70, 'taxi', 'images/c200.jpg', 'DEMO005', '2026-10-15 10:06:52'),
(19, 'Skoda', 'Octavia', 1600, 'Diesel', 'Manual', 2020, 1, 32, 'taxi', 'images/octavia.jpg', 'DEMO006', '2026-10-15 10:06:52'),
(20, 'Volkswagen', 'Golf', 1600, 'Petrol', 'Manual', 2019, 1, 28, 'rental', 'images/golf.jpg', 'DEMO007', '2026-10-15 10:06:52'),
(21, 'Audi', 'A4', 2000, 'Diesel', 'Automatic', 2022, 1, 75, 'rental', 'images/a4.jpg', 'DEMO008', '2026-10-15 10:06:52');

-- --------------------------------------------------------

--
-- Table structure for table `location_logs`
--

CREATE TABLE `location_logs` (
  `id` int(11) NOT NULL,
  `fleet_id` int(11) NOT NULL,
  `latitude` decimal(10,7) NOT NULL,
  `longitude` decimal(10,7) NOT NULL,
  `speed` float DEFAULT 0,
  `odometer_km` int(11) DEFAULT 0,
  `heading` float DEFAULT NULL,
  `recorded_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `location_logs`
--

INSERT INTO `location_logs` (`id`, `fleet_id`, `latitude`, `longitude`, `speed`, `odometer_km`, `heading`, `recorded_at`) VALUES
(2823, 14, 41.3275000, 19.8187000, 45, 1200, NULL, '2026-10-15 10:07:22'),
(2824, 15, 41.3301000, 19.8224000, 0, 850, NULL, '2026-10-15 10:07:22'),
(2825, 16, 41.3250000, 19.8150000, 30, 2100, NULL, '2026-10-15 10:07:22'),
(2826, 17, 41.3289000, 19.8201000, 0, 1500, NULL, '2026-10-15 10:07:22'),
(2827, 18, 41.3240000, 19.8130000, 60, 980, NULL, '2026-10-15 10:07:22'),
(2828, 19, 41.3320000, 19.8290000, 0, 650, NULL, '2026-10-15 10:07:22'),
(2829, 20, 41.3262000, 19.8170000, 25, 1100, NULL, '2026-10-15 10:07:22'),
(2830, 21, 41.3288000, 19.8235000, 0, 700, NULL, '2026-10-15 10:07:22');

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` int(11) NOT NULL,
  `rental_id` int(11) DEFAULT NULL,
  `paypal_payment_id` varchar(255) DEFAULT NULL,
  `paypal_payer_id` varchar(255) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `amount` double DEFAULT NULL,
  `currency` varchar(10) DEFAULT 'USD',
  `payment_time` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rental_bookings`
--

CREATE TABLE `rental_bookings` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `customer_name` varchar(150) NOT NULL,
  `customer_email` varchar(150) NOT NULL,
  `fleet_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `pickup_location` varchar(255) DEFAULT NULL,
  `dropoff_location` varchar(255) DEFAULT NULL,
  `total_price` double NOT NULL DEFAULT 0,
  `status` enum('Pending','Approved','Rejected','Completed') NOT NULL DEFAULT 'Pending',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `taxi_bookings`
--

CREATE TABLE `taxi_bookings` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `customer_name` varchar(150) NOT NULL,
  `customer_phone` varchar(50) NOT NULL,
  `fleet_id` int(11) DEFAULT NULL,
  `booking_type` enum('immediate','scheduled') NOT NULL DEFAULT 'immediate',
  `pickup_address` varchar(255) NOT NULL,
  `dropoff_address` varchar(255) NOT NULL,
  `pickup_lat` decimal(10,7) DEFAULT NULL,
  `pickup_lng` decimal(10,7) DEFAULT NULL,
  `dropoff_lat` decimal(10,7) DEFAULT NULL,
  `dropoff_lng` decimal(10,7) DEFAULT NULL,
  `scheduled_time` datetime DEFAULT NULL,
  `estimated_price` double DEFAULT NULL,
  `status` enum('Pending','Assigned','InProgress','Completed','Cancelled') NOT NULL DEFAULT 'Pending',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `taxi_bookings`
--

INSERT INTO `taxi_bookings` (`id`, `user_id`, `customer_name`, `customer_phone`, `fleet_id`, `booking_type`, `pickup_address`, `dropoff_address`, `pickup_lat`, `pickup_lng`, `dropoff_lat`, `dropoff_lng`, `scheduled_time`, `estimated_price`, `status`, `created_at`) VALUES
(3, 2, 'John Doe', '+355 69 000 0000', NULL, 'immediate', 'Rruga Myslym Shyri, Tirana', 'Tirana International Airport', 41.3275000, 19.8187000, 41.4147000, 19.7205000, '2026-10-15 16:59:02', 25, 'Pending', '2026-10-15 16:59:02');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `username` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `contact` varchar(50) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `role` enum('customer','admin') NOT NULL DEFAULT 'customer',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `first_name`, `last_name`, `username`, `email`, `password_hash`, `contact`, `address`, `role`, `created_at`) VALUES
(1, 'user', '', 'user1', 'User1@gmail.com', '123456', '+355 69 000 0000', 'Tirana, Albania', 'customer', '2026-04-17 07:51:48'),
(2, 'John', 'Doe', 'johnd', 'john@example.com', '12485', '+44 7000 000000', 'London, UK', 'customer', '2026-04-17 07:51:48'),
(3, 'Admin', 'User', 'admin', 'admin@carrent.com', 'admin123', NULL, NULL, 'admin', '2026-04-17 07:51:48');

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_latest_positions`
-- (See below for the actual view)
--
CREATE TABLE `view_latest_positions` (
`fleet_id` int(11)
,`brand` varchar(100)
,`model` varchar(100)
,`gps_device_id` varchar(100)
,`vehicle_type` enum('rental','taxi','both')
,`latitude` decimal(10,7)
,`longitude` decimal(10,7)
,`speed` float
,`recorded_at` datetime
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_rental_details`
-- (See below for the actual view)
--
CREATE TABLE `view_rental_details` (
`id` int(11)
,`customer_name` varchar(150)
,`customer_email` varchar(150)
,`start_date` date
,`end_date` date
,`pickup_location` varchar(255)
,`dropoff_location` varchar(255)
,`total_price` double
,`status` enum('Pending','Approved','Rejected','Completed')
,`created_at` datetime
,`brand` varchar(100)
,`model` varchar(100)
,`fuel` varchar(50)
,`transmission` varchar(50)
,`price_per_day` double
,`gps_device_id` varchar(100)
,`image_path` varchar(255)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_taxi_details`
-- (See below for the actual view)
--
CREATE TABLE `view_taxi_details` (
`id` int(11)
,`customer_name` varchar(150)
,`customer_phone` varchar(50)
,`booking_type` enum('immediate','scheduled')
,`pickup_address` varchar(255)
,`dropoff_address` varchar(255)
,`scheduled_time` datetime
,`estimated_price` double
,`status` enum('Pending','Assigned','InProgress','Completed','Cancelled')
,`created_at` datetime
,`brand` varchar(100)
,`model` varchar(100)
,`gps_device_id` varchar(100)
);

-- --------------------------------------------------------

--
-- Structure for view `view_latest_positions`
--
DROP TABLE IF EXISTS `view_latest_positions`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_latest_positions`  AS SELECT `f`.`id` AS `fleet_id`, `f`.`brand` AS `brand`, `f`.`model` AS `model`, `f`.`gps_device_id` AS `gps_device_id`, `f`.`type` AS `vehicle_type`, `ll`.`latitude` AS `latitude`, `ll`.`longitude` AS `longitude`, `ll`.`speed` AS `speed`, `ll`.`recorded_at` AS `recorded_at` FROM (`fleet` `f` left join `location_logs` `ll` on(`ll`.`id` = (select `location_logs`.`id` from `location_logs` where `location_logs`.`fleet_id` = `f`.`id` order by `location_logs`.`recorded_at` desc limit 1))) ;

-- --------------------------------------------------------

--
-- Structure for view `view_rental_details`
--
DROP TABLE IF EXISTS `view_rental_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_rental_details`  AS SELECT `rb`.`id` AS `id`, `rb`.`customer_name` AS `customer_name`, `rb`.`customer_email` AS `customer_email`, `rb`.`start_date` AS `start_date`, `rb`.`end_date` AS `end_date`, `rb`.`pickup_location` AS `pickup_location`, `rb`.`dropoff_location` AS `dropoff_location`, `rb`.`total_price` AS `total_price`, `rb`.`status` AS `status`, `rb`.`created_at` AS `created_at`, `f`.`brand` AS `brand`, `f`.`model` AS `model`, `f`.`fuel` AS `fuel`, `f`.`transmission` AS `transmission`, `f`.`price_per_day` AS `price_per_day`, `f`.`gps_device_id` AS `gps_device_id`, `f`.`image_path` AS `image_path` FROM (`rental_bookings` `rb` join `fleet` `f` on(`rb`.`fleet_id` = `f`.`id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `view_taxi_details`
--
DROP TABLE IF EXISTS `view_taxi_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_taxi_details`  AS SELECT `tb`.`id` AS `id`, `tb`.`customer_name` AS `customer_name`, `tb`.`customer_phone` AS `customer_phone`, `tb`.`booking_type` AS `booking_type`, `tb`.`pickup_address` AS `pickup_address`, `tb`.`dropoff_address` AS `dropoff_address`, `tb`.`scheduled_time` AS `scheduled_time`, `tb`.`estimated_price` AS `estimated_price`, `tb`.`status` AS `status`, `tb`.`created_at` AS `created_at`, `f`.`brand` AS `brand`, `f`.`model` AS `model`, `f`.`gps_device_id` AS `gps_device_id` FROM (`taxi_bookings` `tb` left join `fleet` `f` on(`tb`.`fleet_id` = `f`.`id`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `fleet`
--
ALTER TABLE `fleet`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `gps_device_id` (`gps_device_id`);

--
-- Indexes for table `location_logs`
--
ALTER TABLE `location_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_ll_fleet` (`fleet_id`),
  ADD KEY `idx_fleet_time` (`fleet_id`,`recorded_at`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_pay_rental` (`rental_id`);

--
-- Indexes for table `rental_bookings`
--
ALTER TABLE `rental_bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_rb_user` (`user_id`),
  ADD KEY `fk_rb_fleet` (`fleet_id`);

--
-- Indexes for table `taxi_bookings`
--
ALTER TABLE `taxi_bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_tb_user` (`user_id`),
  ADD KEY `fk_tb_fleet` (`fleet_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `fleet`
--
ALTER TABLE `fleet`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `location_logs`
--
ALTER TABLE `location_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2838;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rental_bookings`
--
ALTER TABLE `rental_bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `taxi_bookings`
--
ALTER TABLE `taxi_bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `location_logs`
--
ALTER TABLE `location_logs`
  ADD CONSTRAINT `fk_ll_fleet` FOREIGN KEY (`fleet_id`) REFERENCES `fleet` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `fk_pay_rental` FOREIGN KEY (`rental_id`) REFERENCES `rental_bookings` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `rental_bookings`
--
ALTER TABLE `rental_bookings`
  ADD CONSTRAINT `fk_rb_fleet` FOREIGN KEY (`fleet_id`) REFERENCES `fleet` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_rb_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `taxi_bookings`
--
ALTER TABLE `taxi_bookings`
  ADD CONSTRAINT `fk_tb_fleet` FOREIGN KEY (`fleet_id`) REFERENCES `fleet` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tb_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
