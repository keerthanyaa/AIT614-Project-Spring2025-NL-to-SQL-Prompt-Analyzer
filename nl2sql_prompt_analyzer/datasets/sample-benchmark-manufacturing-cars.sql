-- ============================================================================
-- Final Consolidated SQL Script - Schema Creation and Data Population
-- Generated: Saturday, May 3, 2025
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Schema Definition (CREATE TABLE Statements)
-- ----------------------------------------------------------------------------

-- 1. Addresses Table
CREATE TABLE Addresses (
    AddressID INTEGER PRIMARY KEY,
    StreetAddress TEXT NOT NULL,
    City TEXT NOT NULL,
    State TEXT NOT NULL,
    ZipCode TEXT NOT NULL,
    Country TEXT DEFAULT 'USA',
    AddressType TEXT -- ('Primary', 'Shipping', 'Billing', 'Home', 'Work', 'Site')
);

-- 2. Products Table - FIXED: Added INTEGER data type to ProductID
CREATE TABLE Products (
    ProductID INTEGER PRIMARY KEY,
    ModelName TEXT NOT NULL,
    BodyStyle TEXT NOT NULL,
    BasePrice DECIMAL(10, 2) NOT NULL,
    LaunchYear INTEGER NOT NULL,
    IsActive BOOLEAN NOT NULL
);

-- 3. Features Table
CREATE TABLE Features (
    FeatureID INTEGER PRIMARY KEY,
    FeatureName TEXT NOT NULL,
    FeatureType TEXT NOT NULL,
    AdditionalCost DECIMAL(10, 2) NOT NULL
);

-- 4. Locations Table
CREATE TABLE Locations (
    LocationID INTEGER PRIMARY KEY,
    LocationName TEXT NOT NULL,
    LocationType TEXT NOT NULL, -- ('Factory', 'Dealership', 'Office', 'Warehouse', 'Service Center')
    PrimaryAddressID INTEGER
    -- FK added after Addresses created
);

-- 5. Suppliers Table
CREATE TABLE Suppliers (
    SupplierID INTEGER PRIMARY KEY,
    SupplierName TEXT NOT NULL,
    ContactPerson TEXT,
    ContactEmail TEXT,
    PrimaryAddressID INTEGER
    -- FK added after Addresses created
);

-- 6. Components Table
CREATE TABLE Components (
    ComponentID INTEGER PRIMARY KEY,
    ComponentName TEXT NOT NULL,
    Description TEXT,
    Category TEXT NOT NULL,
    UnitCost DECIMAL(10, 2) NOT NULL,
    Material TEXT,
    SupplierID INTEGER
    -- FK added after Suppliers created
);

-- 7. Customers Table
CREATE TABLE Customers (
    CustomerID INTEGER PRIMARY KEY,
    FirstName TEXT,
    LastName TEXT,
    CompanyName TEXT,
    Email TEXT,
    Phone TEXT,
    PrimaryAddressID INTEGER,
    RegistrationDate DATE NOT NULL,
    LoyaltyPointsBalance INTEGER DEFAULT 0
    -- FK added after Addresses created
);

-- 8. Departments Table
CREATE TABLE Departments (
    DepartmentID INTEGER PRIMARY KEY,
    DepartmentName TEXT NOT NULL,
    ManagerID INTEGER -- FK added after Employees created
);

-- 9. Employees Table
CREATE TABLE Employees (
    EmployeeID INTEGER PRIMARY KEY,
    FirstName TEXT NOT NULL,
    LastName TEXT NOT NULL,
    JobTitle TEXT NOT NULL,
    DepartmentID INTEGER,
    HireDate DATE NOT NULL,
    TerminationDate DATE,
    Status TEXT NOT NULL, -- ('Active', 'Terminated', 'On Leave')
    SalaryOrRate DECIMAL(10, 2) NOT NULL,
    PayType TEXT NOT NULL, -- ('Salary', 'Hourly')
    Email TEXT,
    WorkPhone TEXT,
    LocationID INTEGER,
    HomeAddressID INTEGER,
    SupervisorID INTEGER
    -- FKs added after relevant tables created
);

-- 10. WorkOrders Table
CREATE TABLE WorkOrders (
    WorkOrderID INTEGER PRIMARY KEY,
    ProductID INTEGER NOT NULL,
    Quantity INTEGER NOT NULL,
    DateCreated DATE NOT NULL,
    DueDate DATE,
    Status TEXT NOT NULL -- ('Pending', 'In Progress', 'Completed', 'Cancelled')
    -- FK added after Products created
);

-- 11. Vehicles Table
CREATE TABLE Vehicles (
    VehicleID INTEGER PRIMARY KEY,
    VIN TEXT UNIQUE NOT NULL,
    ProductID INTEGER NOT NULL,
    ManufactureDate DATE NOT NULL,
    Color TEXT,
    WorkOrderID INTEGER,
    CurrentMileage INTEGER,
    LastServiceDate DATE,
    CurrentStatus TEXT NOT NULL, -- ('Inventory', 'Sold', 'Leased', 'Rented', 'In Service', 'Decommissioned')
    CurrentHolderCustomerID INTEGER
    -- FKs added after relevant tables created
);

-- 12. SalesOrders Table
CREATE TABLE SalesOrders (
    SalesOrderID INTEGER PRIMARY KEY,
    CustomerID INTEGER NOT NULL,
    OrderTimestamp TIMESTAMP NOT NULL,
    ShippingAddressID INTEGER,
    Status TEXT NOT NULL, -- ('Placed', 'Processing', 'Shipped', 'Delivered', 'Cancelled')
    TotalAmount DECIMAL(10, 2)
    -- FKs added after relevant tables created
);

-- 13. LeaseRentalAgreements Table
CREATE TABLE LeaseRentalAgreements (
    AgreementID INTEGER PRIMARY KEY,
    CustomerID INTEGER NOT NULL,
    VehicleID INTEGER NOT NULL,
    AgreementType TEXT NOT NULL, -- ('Lease', 'Rental')
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    MonthlyPayment DECIMAL(10, 2),
    RentalRatePerDay DECIMAL(10, 2),
    Status TEXT NOT NULL, -- ('Active', 'Completed', 'Terminated Early', 'Pending')
    Notes TEXT
    -- FKs added after relevant tables created
);

-- 14. ServiceRecords Table
CREATE TABLE ServiceRecords (
    ServiceID INTEGER PRIMARY KEY,
    VehicleID INTEGER NOT NULL,
    CustomerID INTEGER NOT NULL,
    LocationID INTEGER NOT NULL,
    TechnicianID INTEGER,
    ServiceDate DATE NOT NULL,
    ServiceType TEXT NOT NULL,
    IsWarrantyClaim BOOLEAN NOT NULL,
    Notes TEXT,
    LaborHours DECIMAL(5, 2),
    PartsCost DECIMAL(10, 2),
    LaborCost DECIMAL(10, 2),
    TotalCost DECIMAL(10, 2),
    PointsEarned INTEGER
    -- FKs added after relevant tables created
);

-- 15. LoyaltyTransactions Table
CREATE TABLE LoyaltyTransactions (
    TransactionID INTEGER PRIMARY KEY,
    CustomerID INTEGER NOT NULL,
    TransactionType TEXT NOT NULL, -- ('Earned', 'Redeemed', 'Adjustment', 'Expired')
    PointsChanged INTEGER NOT NULL,
    TransactionDate TIMESTAMP NOT NULL,
    RelatedServiceID INTEGER,
    RelatedAgreementID INTEGER,
    Notes TEXT
    -- FKs added after relevant tables created
);

-- 16. InventoryLevels Table
CREATE TABLE InventoryLevels (
    InventoryID INTEGER PRIMARY KEY,
    LocationID INTEGER NOT NULL,
    ProductID INTEGER,
    ComponentID INTEGER,
    QuantityOnHand INTEGER NOT NULL,
    LastUpdated TIMESTAMP NOT NULL
    -- FKs added after relevant tables created
    -- CHECK constraint added below
);

-- 17. ProductFeatures Table (Linking Table)
CREATE TABLE ProductFeatures (
    ProductID INTEGER,
    FeatureID INTEGER,
    PRIMARY KEY (ProductID, FeatureID)
    -- FKs added after relevant tables created
);

-- 18. ProductComponents Table (Linking Table)
CREATE TABLE ProductComponents (
    ProductID INTEGER,
    ComponentID INTEGER,
    QuantityRequired INTEGER NOT NULL,
    PRIMARY KEY (ProductID, ComponentID)
    -- FKs added after relevant tables created
);

-- 19. VehicleFeatures Table (Linking Table)
CREATE TABLE VehicleFeatures (
    VehicleID INTEGER,
    FeatureID INTEGER,
    PRIMARY KEY (VehicleID, FeatureID)
    -- FKs added after relevant tables created
);

-- 20. SalesOrderItems Table
CREATE TABLE SalesOrderItems (
    OrderItemID INTEGER PRIMARY KEY,
    SalesOrderID INTEGER NOT NULL,
    VehicleID INTEGER,
    Quantity INTEGER NOT NULL,
    AgreedPrice DECIMAL(10, 2) NOT NULL
    -- FKs added after relevant tables created
);

-- 21. ServicePartsUsed Table (Linking Table)
CREATE TABLE ServicePartsUsed (
    ServiceID INTEGER,
    ComponentID INTEGER,
    QuantityUsed INTEGER NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (ServiceID, ComponentID)
    -- FKs added after relevant tables created
);

-- ----------------------------------------------------------------------------
-- Adding Foreign Key Constraints (Post-Table Creation)
-- ----------------------------------------------------------------------------

-- Add FKs for Locations
ALTER TABLE Locations
ADD CONSTRAINT fk_locations_address
FOREIGN KEY (PrimaryAddressID) REFERENCES Addresses(AddressID) ON DELETE SET NULL;

-- Add FKs for Suppliers
ALTER TABLE Suppliers
ADD CONSTRAINT fk_suppliers_address
FOREIGN KEY (PrimaryAddressID) REFERENCES Addresses(AddressID) ON DELETE SET NULL;

-- Add FKs for Components
ALTER TABLE Components
ADD CONSTRAINT fk_components_supplier
FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID) ON DELETE SET NULL;

-- Add FKs for Customers
ALTER TABLE Customers
ADD CONSTRAINT fk_customers_address
FOREIGN KEY (PrimaryAddressID) REFERENCES Addresses(AddressID) ON DELETE SET NULL;

-- Add FKs for Employees (except ManagerID and SupervisorID)
ALTER TABLE Employees
ADD CONSTRAINT fk_employees_department
FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID) ON DELETE SET NULL;

ALTER TABLE Employees
ADD CONSTRAINT fk_employees_location
FOREIGN KEY (LocationID) REFERENCES Locations(LocationID) ON DELETE SET NULL;

ALTER TABLE Employees
ADD CONSTRAINT fk_employees_address
FOREIGN KEY (HomeAddressID) REFERENCES Addresses(AddressID) ON DELETE SET NULL;

-- Add FKs for WorkOrders
ALTER TABLE WorkOrders
ADD CONSTRAINT fk_workorders_product
FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE RESTRICT;

-- Add FKs for Vehicles
ALTER TABLE Vehicles
ADD CONSTRAINT fk_vehicles_product
FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE RESTRICT;

ALTER TABLE Vehicles
ADD CONSTRAINT fk_vehicles_workorder
FOREIGN KEY (WorkOrderID) REFERENCES WorkOrders(WorkOrderID) ON DELETE SET NULL;

ALTER TABLE Vehicles
ADD CONSTRAINT fk_vehicles_customer
FOREIGN KEY (CurrentHolderCustomerID) REFERENCES Customers(CustomerID) ON DELETE SET NULL;

-- Add FKs for SalesOrders
ALTER TABLE SalesOrders
ADD CONSTRAINT fk_salesorders_customer
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE RESTRICT;

ALTER TABLE SalesOrders
ADD CONSTRAINT fk_salesorders_address
FOREIGN KEY (ShippingAddressID) REFERENCES Addresses(AddressID) ON DELETE SET NULL;

-- Add FKs for LeaseRentalAgreements
ALTER TABLE LeaseRentalAgreements
ADD CONSTRAINT fk_leaserentals_customer
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE RESTRICT;

ALTER TABLE LeaseRentalAgreements
ADD CONSTRAINT fk_leaserentals_vehicle
FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID) ON DELETE RESTRICT;

-- Add FKs for ServiceRecords
ALTER TABLE ServiceRecords
ADD CONSTRAINT fk_servicerecords_vehicle
FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID) ON DELETE RESTRICT;

ALTER TABLE ServiceRecords
ADD CONSTRAINT fk_servicerecords_customer
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE RESTRICT;

ALTER TABLE ServiceRecords
ADD CONSTRAINT fk_servicerecords_location
FOREIGN KEY (LocationID) REFERENCES Locations(LocationID) ON DELETE RESTRICT;
-- TechnicianID FK added after Employees ALTER

-- Add FKs for LoyaltyTransactions
ALTER TABLE LoyaltyTransactions
ADD CONSTRAINT fk_loyalty_customer
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE;

ALTER TABLE LoyaltyTransactions
ADD CONSTRAINT fk_loyalty_service
FOREIGN KEY (RelatedServiceID) REFERENCES ServiceRecords(ServiceID) ON DELETE SET NULL;

ALTER TABLE LoyaltyTransactions
ADD CONSTRAINT fk_loyalty_agreement
FOREIGN KEY (RelatedAgreementID) REFERENCES LeaseRentalAgreements(AgreementID) ON DELETE SET NULL;

-- Add FKs and CHECK for InventoryLevels
ALTER TABLE InventoryLevels
ADD CONSTRAINT fk_inventory_location
FOREIGN KEY (LocationID) REFERENCES Locations(LocationID) ON DELETE RESTRICT;

ALTER TABLE InventoryLevels
ADD CONSTRAINT fk_inventory_product
FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE;

ALTER TABLE InventoryLevels
ADD CONSTRAINT fk_inventory_component
FOREIGN KEY (ComponentID) REFERENCES Components(ComponentID) ON DELETE CASCADE;

ALTER TABLE InventoryLevels
ADD CONSTRAINT check_product_or_component CHECK (
        (ProductID IS NULL AND ComponentID IS NOT NULL) OR
        (ProductID IS NOT NULL AND ComponentID IS NULL)
    );

-- Add FKs for ProductFeatures
ALTER TABLE ProductFeatures
ADD CONSTRAINT fk_productfeatures_product
FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE;

ALTER TABLE ProductFeatures
ADD CONSTRAINT fk_productfeatures_feature
FOREIGN KEY (FeatureID) REFERENCES Features(FeatureID) ON DELETE CASCADE;

-- Add FKs for ProductComponents
ALTER TABLE ProductComponents
ADD CONSTRAINT fk_productcomponents_product
FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE;

ALTER TABLE ProductComponents
ADD CONSTRAINT fk_productcomponents_component
FOREIGN KEY (ComponentID) REFERENCES Components(ComponentID) ON DELETE CASCADE;

-- Add FKs for VehicleFeatures
ALTER TABLE VehicleFeatures
ADD CONSTRAINT fk_vehiclefeatures_vehicle
FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID) ON DELETE CASCADE;

ALTER TABLE VehicleFeatures
ADD CONSTRAINT fk_vehiclefeatures_feature
FOREIGN KEY (FeatureID) REFERENCES Features(FeatureID) ON DELETE CASCADE;

-- Add FKs for SalesOrderItems
ALTER TABLE SalesOrderItems
ADD CONSTRAINT fk_salesorderitems_order
FOREIGN KEY (SalesOrderID) REFERENCES SalesOrders(SalesOrderID) ON DELETE CASCADE;

ALTER TABLE SalesOrderItems
ADD CONSTRAINT fk_salesorderitems_vehicle
FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID) ON DELETE SET NULL;

-- Add FKs for ServicePartsUsed
ALTER TABLE ServicePartsUsed
ADD CONSTRAINT fk_serviceparts_service
FOREIGN KEY (ServiceID) REFERENCES ServiceRecords(ServiceID) ON DELETE CASCADE;

ALTER TABLE ServicePartsUsed
ADD CONSTRAINT fk_serviceparts_component
FOREIGN KEY (ComponentID) REFERENCES Components(ComponentID) ON DELETE RESTRICT;

-- Add circular/dependent FKs for Departments and Employees
ALTER TABLE Departments
ADD CONSTRAINT fk_departments_manager
FOREIGN KEY (ManagerID) REFERENCES Employees(EmployeeID) ON DELETE SET NULL;

ALTER TABLE Employees
ADD CONSTRAINT fk_employees_supervisor
FOREIGN KEY (SupervisorID) REFERENCES Employees(EmployeeID) ON DELETE SET NULL;

-- Add remaining FK for ServiceRecords
ALTER TABLE ServiceRecords
ADD CONSTRAINT fk_servicerecords_technician
FOREIGN KEY (TechnicianID) REFERENCES Employees(EmployeeID) ON DELETE SET NULL;


-- ----------------------------------------------------------------------------
-- Data Population (INSERT Statements - Order based on Dependencies)
-- ----------------------------------------------------------------------------

-- Addresses Table (IDs 1-53)
INSERT INTO Addresses (AddressID, StreetAddress, City, State, ZipCode, Country, AddressType) VALUES
(1, '1000 Manufacturing Way', 'Detroit', 'MI', '48201', 'USA', 'Site'),(2, '2500 Assembly Drive', 'Toledo', 'OH', '43604', 'USA', 'Site'),
(3, '800 Industrial Parkway', 'Arlington', 'TX', '76010', 'USA', 'Site'),(4, '159 Industrial Circle', 'Indianapolis', 'IN', '46201', 'USA', 'Site'),
(5, '951 Repair Road', 'Cincinnati', 'OH', '45201', 'USA', 'Site'),(6, '357 Maintenance Drive', 'Milwaukee', 'WI', '53201', 'USA', 'Site'),
(7, '159 Service Street', 'Oklahoma City', 'OK', '73101', 'USA', 'Site'),(8, '159 Storage Drive', 'Memphis', 'TN', '38101', 'USA', 'Site'),
(9, '753 Warehouse Road', 'Louisville', 'KY', '40201', 'USA', 'Site'),(10, '951 Inventory Lane', 'Jacksonville', 'FL', '32201', 'USA', 'Site'),
(11, '159 Hybrid Location', 'Baltimore', 'MD', '21201', 'USA', 'Site'),(12, '555 Headquarters Plaza', 'Chicago', 'IL', '60601', 'USA', 'Work'),
(13, '100 Corporate Drive', 'Atlanta', 'GA', '30301', 'USA', 'Work'),(14, '2100 Business Center Blvd', 'Boston', 'MA', '02110', 'USA', 'Work'),
(15, '357 Business Park', 'Raleigh', 'NC', '27601', 'USA', 'Work'),(16, '753 Executive Drive', 'Hartford', 'CT', '06101', 'USA', 'Work'),
(17, '951 Manager Lane', 'Richmond', 'VA', '23218', 'USA', 'Work'),(18, '357 Admin Road', 'Providence', 'RI', '02901', 'USA', 'Work'),
(19, '357 Flexible Space', 'Anchorage', 'AK', '99501', 'USA', 'Work'),(20, '789 Auto Mall Road', 'Los Angeles', 'CA', '90001', 'USA', 'Site'),
(21, '456 Dealership Drive', 'Miami', 'FL', '33101', 'USA', 'Site'),(22, '234 Service Center Ave', 'Phoenix', 'AZ', '85001', 'USA', 'Site'),
(23, '123 Oak Street', 'Seattle', 'WA', '98101', 'USA', 'Home'),(24, '456 Maple Avenue', 'Portland', 'OR', '97201', 'USA', 'Home'),
(25, '789 Pine Road', 'Denver', 'CO', '80201', 'USA', 'Home'),(26, '321 Cedar Lane', 'Austin', 'TX', '78701', 'USA', 'Home'),
(27, '654 Birch Street', 'San Diego', 'CA', '92101', 'USA', 'Home'),(28, '753 Suburban Lane', 'Charlotte', 'NC', '28201', 'USA', 'Home'),
(29, '951 Country Road', 'St. Louis', 'MO', '63101', 'USA', 'Home'),(30, '357 City Avenue', 'Pittsburgh', 'PA', '15201', 'USA', 'Home'),
(31, '987 Residential Blvd', 'Nashville', 'TN', '37201', 'USA', 'Primary'),(32, '654 Highland Drive', 'Houston', 'TX', '77001', 'USA', 'Primary'),
(33, '321 Valley View Road', 'Las Vegas', 'NV', '89101', 'USA', 'Primary'),(34, '147 Mountain Way', 'Salt Lake City', 'UT', '84101', 'USA', 'Primary'),
(35, '258 Lake Drive', 'Minneapolis', 'MN', '55401', 'USA', 'Primary'),(36, '951 Multipurpose Drive', 'Sacramento', 'CA', '95814', 'USA', 'Primary'),
(37, '486 Residential Street', 'Orlando', 'FL', '32801', 'USA', 'Primary'),(38, '159 Neighborhood Lane', 'Dallas', 'TX', '75201', 'USA', 'Primary'),
(39, '753 Community Road', 'San Antonio', 'TX', '78201', 'USA', 'Primary'),(40, '842 Queen Street', 'Toronto', 'ON', 'M5H 2N2', 'Canada', 'Primary'),
(41, '15 Mexico City Blvd', 'Mexico City', 'CDMX', '11529', 'Mexico', 'Primary'),(42, '951 Multi-Use Center', 'Honolulu', 'HI', '96801', 'USA', 'Primary'),
(43, '753 Dual Purpose', 'Columbus', 'OH', '43215', 'USA', 'Primary'),(44, '156 Business Ave', 'Atlanta', 'GA', '30303', 'USA', 'Primary'),
(45, '369 Commerce Park', 'Philadelphia', 'PA', '19101', 'USA', 'Shipping'),(46, '741 Distribution Center', 'Cleveland', 'OH', '44101', 'USA', 'Shipping'),
(47, '852 Logistics Way', 'Kansas City', 'MO', '64101', 'USA', 'Shipping'),(48, '357 Delivery Way', 'Albuquerque', 'NM', '87101', 'USA', 'Shipping'),
(49, '159 Reception Road', 'Tucson', 'AZ', '85701', 'USA', 'Shipping'),(50, '753 Shipment Street', 'Fresno', 'CA', '93721', 'USA', 'Shipping'),
(51, '963 Financial Plaza', 'New York', 'NY', '10001', 'USA', 'Billing'),(52, '159 Accounting Lane', 'San Francisco', 'CA', '94101', 'USA', 'Billing'),
(53, '753 Invoice Road', 'Washington', 'DC', '20001', 'USA', 'Billing');

-- Features Table (IDs 1-50)
INSERT INTO Features (FeatureID, FeatureName, FeatureType, AdditionalCost) VALUES
(1, 'Advanced Driver Assistance System', 'Safety', 2500.00),(2, '360-Degree Camera System', 'Safety', 1800.00),(3, 'Lane Departure Warning', 'Safety', 895.00),
(4, 'Blind Spot Detection', 'Safety', 795.00),(5, 'Automatic Emergency Braking', 'Safety', 1200.00),(6, 'Adaptive Cruise Control', 'Safety', 1500.00),
(7, 'Night Vision Assistant', 'Safety', 2200.00),(8, 'Parking Sensors', 'Safety', 600.00),(9, 'Cross Traffic Alert', 'Safety', 750.00),
(10, 'Driver Drowsiness Detection', 'Safety', 850.00),(11, 'Premium Leather Seats', 'Interior', 3500.00),(12, 'Heated Front Seats', 'Interior', 850.00),
(13, 'Ventilated Seats', 'Interior', 1200.00),(14, 'Massage Seats', 'Interior', 2000.00),(15, 'Panoramic Sunroof', 'Interior', 1500.00),
(16, 'Ambient Lighting Package', 'Interior', 500.00),(17, 'Four-Zone Climate Control', 'Interior', 1200.00),(18, 'Premium Sound System', 'Interior', 2500.00),
(19, 'Wireless Phone Charging', 'Interior', 300.00),(20, 'Head-Up Display', 'Interior', 1000.00),(21, '20-inch Alloy Wheels', 'Exterior', 1200.00),
(22, 'LED Matrix Headlights', 'Exterior', 1800.00),(23, 'Power Folding Mirrors', 'Exterior', 450.00),(24, 'Roof Rails', 'Exterior', 400.00),
(25, 'Metallic Paint', 'Exterior', 695.00),(26, 'Panoramic Glass Roof', 'Exterior', 1600.00),(27, 'Adaptive Headlights', 'Exterior', 1200.00),
(28, 'Running Boards', 'Exterior', 850.00),(29, 'Sport Body Kit', 'Exterior', 2500.00),(30, 'Chrome Package', 'Exterior', 800.00),
(31, 'Sport Suspension', 'Performance', 1800.00),(32, 'Performance Brakes', 'Performance', 2500.00),(33, 'Sport Exhaust System', 'Performance', 1500.00),
(34, 'All-Wheel Drive', 'Performance', 2000.00),(35, 'Adaptive Air Suspension', 'Performance', 2800.00),(36, 'Sport Differential', 'Performance', 1850.00),
(37, 'Performance Tires', 'Performance', 1200.00),(38, 'Engine Power Upgrade', 'Performance', 3500.00),(39, 'Sport Steering', 'Performance', 950.00),
(40, 'Launch Control', 'Performance', 1500.00),(41, 'Navigation System Plus', 'Technology', 1500.00),(42, 'Premium Infotainment System', 'Technology', 2000.00),
(43, 'Digital Instrument Cluster', 'Technology', 1200.00),(44, 'Rear Entertainment System', 'Technology', 2500.00),(45, 'Voice Control System', 'Technology', 500.00),
(46, 'Smartphone Integration Package', 'Technology', 450.00),(47, 'WiFi Hotspot', 'Technology', 300.00),(48, 'Remote Start System', 'Technology', 650.00),
(49, 'Digital Key', 'Technology', 400.00),(50, 'Advanced Parking Assistant', 'Technology', 1200.00);

-- Locations Table (IDs 1-56)
INSERT INTO Locations (LocationID, LocationName, LocationType, PrimaryAddressID) VALUES
(1, 'Detroit Main Factory', 'Factory', 1),(2, 'Toledo Assembly Plant', 'Factory', 2),(3, 'Arlington Production Facility', 'Factory', 3),
(4, 'Chicago Headquarters', 'Office', 12),(5, 'Atlanta Regional Office', 'Office', 13),(6, 'Boston Corporate Center', 'Office', 14),
(7, 'LA Premium Auto Mall', 'Dealership', 20),(8, 'Miami Motors Dealership', 'Dealership', 21),(9, 'Phoenix Auto Gallery', 'Dealership', 22),
(10, 'Seattle Service Hub', 'Service Center', 5),(11, 'Denver Maintenance Center', 'Service Center', 6),(12, 'Houston Service Complex', 'Service Center', 7),
(13, 'Memphis Central Warehouse', 'Warehouse', 8),(14, 'Louisville Distribution Center', 'Warehouse', 9),(15, 'Jacksonville Storage Facility', 'Warehouse', 10),
(16, 'San Francisco Bay Dealership', 'Dealership', 52),(17, 'Dallas Premium Center', 'Dealership', 38),(18, 'Austin Luxury Cars', 'Dealership', 26),
(19, 'Portland Motors', 'Dealership', 24),(20, 'San Diego Auto Gallery', 'Dealership', 27),(21, 'Cincinnati Service Excellence', 'Service Center', 5),
(22, 'Milwaukee Maintenance Hub', 'Service Center', 6),(23, 'Oklahoma City Service Center', 'Service Center', 7),(24, 'Hartford Business Center', 'Office', 16),
(25, 'Richmond Corporate Hub', 'Office', 17),(26, 'Providence Office Complex', 'Office', 18),(27, 'Northeast Distribution Center', 'Warehouse', 45),
(28, 'Southeast Storage Hub', 'Warehouse', 46),(29, 'Midwest Logistics Center', 'Warehouse', 47),(30, 'Nashville Production Plant', 'Factory', 31),
(31, 'Indianapolis Assembly Center', 'Factory', 4),(32, 'Kansas City Manufacturing', 'Factory', 47),(33, 'Las Vegas Auto Complex', 'Dealership', 33),
(34, 'Minneapolis Auto Center', 'Dealership', 35),(35, 'Salt Lake City Motors', 'Dealership', 34),(36, 'Philadelphia Auto Plaza', 'Service Center', 45),
(37, 'Cleveland Motor World', 'Dealership', 46),(38, 'St. Louis Auto Complex', 'Service Center', 29),(39, 'New York Regional HQ', 'Office', 51),
(40, 'Washington DC Office', 'Office', 53),(41, 'Sacramento Branch', 'Office', 36),(42, 'Raleigh Service Point', 'Service Center', 15),
(43, 'Charlotte Auto Care', 'Service Center', 28),(44, 'Pittsburgh Service Hub', 'Service Center', 30),(45, 'Orlando Performance Center', 'Service Center', 37),
(46, 'Tampa Custom Shop', 'Service Center', 48),(47, 'Fort Lauderdale Luxury Service', 'Service Center', 50),(48, 'Albuquerque Distribution', 'Warehouse', 48),
(49, 'Tucson Logistics Center', 'Warehouse', 49),(50, 'Fresno Storage Facility', 'Warehouse', 50),(51, 'Honolulu Auto Complex', 'Dealership', 42),
(52, 'Anchorage Motors', 'Dealership', 19),(53, 'Baltimore Auto Center', 'Dealership', 11),(54, 'Columbus Full Service', 'Service Center', 43),
(55, 'Toronto Canada Branch', 'Office', 40),(56, 'Mexico City Operations', 'Office', 41);

-- Suppliers Table (IDs 1-50)
INSERT INTO Suppliers (SupplierID, SupplierName, ContactPerson, ContactEmail, PrimaryAddressID) VALUES
(1, 'AutoTech Solutions', 'James Wilson', 'jwilson@autotech.com', 1),(2, 'Elite Electronics Systems', 'Sarah Chen', 'schen@eliteelec.com', 2),
(3, 'PowerTrain Dynamics', 'Michael Rodriguez', 'mrodriguez@ptdynamics.com', 3),(4, 'Global Chassis Corp', 'David Kim', 'dkim@globalchassis.com', 4),
(5, 'Premier Parts Manufacturing', 'Lisa Thompson', 'lthompson@premierparts.com', 8),(6, 'Smart Systems Inc', 'Robert Chang', 'rchang@smartsys.com', 20),
(7, 'Connected Car Technologies', 'Emma Davis', 'edavis@connectedcar.com', 22),(8, 'Digital Dashboard Solutions', 'Alan Moore', 'amoore@digidash.com', 52),
(9, 'Sensor Tech Industries', 'Patricia Lee', 'plee@sensortech.com', 36),(10, 'AutoSoft Innovations', 'George Martinez', 'gmartinez@autosoft.com', 15),
(11, 'Comfort Seating Systems', 'Nancy White', 'nwhite@comfortseating.com', 5),(12, 'Interior Dynamics LLC', 'Kevin Johnson', 'kjohnson@interiordyn.com', 6),
(13, 'Luxury Trim Specialists', 'Maria Garcia', 'mgarcia@luxtrim.com', 7),(14, 'Climate Control Corp', 'Thomas Brown', 'tbrown@climatecorp.com', 16),
(15, 'Acoustic Solutions Ltd', 'Jennifer Wilson', 'jwilson@acousticsol.com', 17),(16, 'MetalForm Industries', 'Richard Lee', 'rlee@metalform.com', 18),
(17, 'Advanced Composites Corp', 'Susan Miller', 'smiller@advcomp.com', 8),(18, 'GlassTech Solutions', 'Paul Anderson', 'panderson@glasstech.com', 9),
(19, 'Lighting Systems International', 'Diana Taylor', 'dtaylor@lsi.com', 10),(20, 'Paint & Finish Specialists', 'Carlos Ruiz', 'cruiz@paintfinish.com', 48),
(21, 'Engine Technologies Inc', 'Mark Williams', 'mwilliams@enginetech.com', 45),(22, 'Transmission Dynamics', 'Laura Chen', 'lchen@transdyn.com', 46),
(23, 'Hybrid Systems Corp', 'Steven Jones', 'sjones@hybridsys.com', 47),(24, 'Electric Drive Solutions', 'Rachel Kim', 'rkim@electricdrive.com', 51),
(25, 'Brake Systems Advanced', 'Brian Miller', 'bmiller@brakesys.com', 53),(26, 'SafetyFirst Systems', 'Amanda Peters', 'apeters@safetyfirst.com', 49),
(27, 'Airbag Technologies', 'Eric Johnson', 'ejohnson@airbagtec.com', 50),(28, 'Sensor Safety Corp', 'Michelle Lee', 'mlee@sensorsafety.com', 42),
(29, 'Guardian Systems Ltd', 'Chris Thompson', 'cthompson@guardian.com', 19),(30, 'Protective Equipment Inc', 'Daniel Harris', 'dharris@protectequip.com', 11),
(31, 'Steel Dynamics Corp', 'Frank Anderson', 'fanderson@steeldyn.com', 21),(32, 'Aluminum Solutions', 'Helen Martinez', 'hmartinez@alusol.com', 23),
(33, 'Polymer Technologies', 'Wayne Davis', 'wdavis@polytech.com', 24),(34, 'Advanced Materials Inc', 'Gloria Rodriguez', 'grodriguez@advmat.com', 25),
(35, 'Composite Structures LLC', 'Peter Chang', 'pchang@composites.com', 26),(36, 'Performance Parts Pro', 'Tracy Wilson', 'twilson@perfparts.com', 27),
(37, 'Custom Components Ltd', 'Isaac Brown', 'ibrown@customcomp.com', 31),(38, 'Precision Engineering Corp', 'Olivia Martin', 'omartin@precision.com', 32),
(39, 'Innovation Systems', 'Kyle Thompson', 'kthompson@innovsys.com', 33),(40, 'Quality Components Inc', 'Nina Patel', 'npatel@qualitycomp.com', 34),
(41, 'Canadian Auto Parts', 'John MacDonald', 'jmacdonald@canparts.com', 40),(42, 'Mexican Components SA', 'Luis Hernandez', 'lhernandez@mexcomp.com', 41),
(43, 'European Systems GmbH', 'Anna Schmidt', 'aschmidt@eurosys.com', 12),(44, 'Asian Technologies Ltd', 'James Wong', 'jwong@asiantech.com', 13),
(45, 'Global Supply Co', 'Mary Johnson', 'mjohnson@globalsup.com', 14),(46, 'Battery Tech Solutions', 'William Chen', 'wchen@batterytech.com', 28),
(47, 'Autonomous Systems Inc', 'Rebecca Lewis', 'rlewis@autosys.com', 29),(48, 'Connected Vehicle Corp', 'Howard Grant', 'hgrant@connectedveh.com', 30),
(49, 'Smart Sensor Solutions', 'Karen Wu', 'kwu@smartsensor.com', 37),(50, 'AI Automotive Systems', 'Ted Richards', 'trichards@aiauto.com', 38);

-- Components Table (IDs 1-50)
INSERT INTO Components (ComponentID, ComponentName, Description, Category, UnitCost, Material, SupplierID) VALUES
(1, 'V6 Engine Block', 'Standard 3.0L V6 engine block', 'Engine', 3200.00, 'Aluminum Alloy', 3),(2, 'V8 Engine Block', 'Premium 4.0L V8 engine block', 'Engine', 4500.00, 'Aluminum Alloy', 3),
(3, 'Cylinder Head', 'Performance cylinder head assembly', 'Engine', 850.00, 'Aluminum', 21),(4, 'Crankshaft', 'Forged steel crankshaft', 'Engine', 600.00, 'Steel', 21),
(5, 'Piston Set', 'High-performance piston set', 'Engine', 400.00, 'Aluminum Alloy', 21),(6, 'Automatic Transmission', '8-speed automatic transmission', 'Transmission', 2800.00, 'Various', 22),
(7, 'Manual Transmission', '6-speed manual transmission', 'Transmission', 2200.00, 'Various', 22),(8, 'Transmission Control Module', 'Electronic control unit', 'Electronics', 450.00, 'Electronic', 22),
(9, 'Clutch Assembly', 'Heavy-duty clutch system', 'Transmission', 380.00, 'Various', 22),(10, 'Gear Set', 'Precision-engineered gear set', 'Transmission', 750.00, 'Hardened Steel', 22),
(11, 'Engine Control Unit', 'Main engine management system', 'Electronics', 890.00, 'Electronic', 6),(12, 'Infotainment System', 'Premium entertainment and navigation', 'Electronics', 1200.00, 'Electronic', 7),
(13, 'Digital Dashboard', '12.3" digital instrument cluster', 'Electronics', 980.00, 'Electronic', 8),(14, 'Battery Management System', 'Advanced BMS for hybrids', 'Electronics', 650.00, 'Electronic', 46),
(15, 'LED Headlight Assembly', 'Adaptive LED lighting system', 'Lighting', 450.00, 'Various', 19),(16, 'Leather Seat Set', 'Premium leather seat assembly', 'Interior', 2200.00, 'Leather', 11),
(17, 'Dashboard Assembly', 'Complete dashboard unit', 'Interior', 1500.00, 'Plastic/Various', 12),(18, 'Climate Control Unit', 'Dual-zone climate system', 'Interior', 580.00, 'Various', 14),
(19, 'Door Panel Set', 'Premium door panels', 'Interior', 800.00, 'Various', 13),(20, 'Center Console', 'Storage and control console', 'Interior', 400.00, 'Plastic/Leather', 13),
(21, 'Airbag System', 'Complete airbag safety system', 'Safety', 600.00, 'Various', 27),(22, 'ABS Module', 'Anti-lock braking system', 'Safety', 420.00, 'Electronic', 26),
(23, 'Radar Sensor', 'Forward collision detection', 'Safety', 380.00, 'Electronic', 28),(24, 'Camera System', '360-degree camera system', 'Safety', 750.00, 'Electronic', 29),
(25, 'Stability Control Module', 'Electronic stability control', 'Safety', 480.00, 'Electronic', 26),(26, 'Hood Assembly', 'Lightweight hood structure', 'Exterior', 580.00, 'Aluminum', 16),
(27, 'Door Shell Set', 'Complete door structures', 'Exterior', 1200.00, 'Steel', 16),(28, 'Windshield', 'Acoustic laminated glass', 'Exterior', 450.00, 'Glass', 18),
(29, 'Bumper Assembly', 'Front bumper with sensors', 'Exterior', 380.00, 'Composite', 17),(30, 'Side Mirror Set', 'Power-folding mirrors', 'Exterior', 290.00, 'Various', 19),
(31, 'Chassis Frame', 'Main vehicle frame', 'Chassis', 2800.00, 'High-Strength Steel', 4),(32, 'Suspension System', 'Adaptive suspension setup', 'Chassis', 1500.00, 'Various', 4),
(33, 'Brake System', 'Performance brake package', 'Chassis', 980.00, 'Various', 25),(34, 'Wheel Hub Assembly', 'Precision wheel bearing hub', 'Chassis', 180.00, 'Steel', 4),
(35, 'Control Arms', 'Suspension control arms', 'Chassis', 250.00, 'Aluminum', 4),(36, 'Drive Shaft', 'High-performance drive shaft', 'Powertrain', 420.00, 'Steel', 3),
(37, 'Differential', 'Limited-slip differential', 'Powertrain', 890.00, 'Steel', 3),(38, 'Transfer Case', '4WD transfer case', 'Powertrain', 1200.00, 'Various', 3),
(39, 'CV Joint Set', 'Constant velocity joints', 'Powertrain', 180.00, 'Steel', 3),(40, 'Axle Assembly', 'Complete axle system', 'Powertrain', 750.00, 'Steel', 3),
(41, 'Battery Pack', 'Hybrid battery system', 'Electric', 3800.00, 'Various', 46),(42, 'Electric Motor', 'Hybrid drive motor', 'Electric', 2200.00, 'Various', 47),
(43, 'Autonomous Driving Unit', 'Self-driving computer', 'Electronics', 4500.00, 'Electronic', 47),(44, 'LiDAR Sensor', 'Advanced distance sensing', 'Electronics', 1800.00, 'Electronic', 48),
(45, 'Vehicle Control Module', 'Central control unit', 'Electronics', 1200.00, 'Electronic', 48),(46, 'Steel Frame Rails', 'Structural frame components', 'Structure', 380.00, 'Steel', 31),
(47, 'Aluminum Panels', 'Body panels', 'Structure', 290.00, 'Aluminum', 32),(48, 'Carbon Fiber Roof', 'Lightweight roof panel', 'Structure', 1500.00, 'Carbon Fiber', 34),
(49, 'Polymer Dashboard Base', 'Dashboard substrate', 'Interior', 180.00, 'Polymer', 33),(50, 'Composite Floor Pan', 'Structural floor component', 'Structure', 450.00, 'Composite', 35);

-- Customers Table (IDs 1-30)
INSERT INTO Customers (CustomerID, FirstName, LastName, CompanyName, Email, Phone, PrimaryAddressID, RegistrationDate, LoyaltyPointsBalance) VALUES
(1, NULL, NULL, 'Fleet Motors Inc', 'fleet@fleetmotors.com', '555-0100', 12, '2023-01-15', 5000),(2, NULL, NULL, 'Luxury Car Rentals', 'info@luxuryrentals.com', '555-0101', 13, '2023-02-20', 7500),
(3, NULL, NULL, 'City Taxi Corporation', 'fleet@citytaxi.com', '555-0102', 14, '2023-03-10', 10000),(4, NULL, NULL, 'Express Delivery Services', 'fleet@expressdelivery.com', '555-0103', 15, '2023-04-05', 8000),
(5, NULL, NULL, 'Corporate Fleet Solutions', 'info@corpfleet.com', '555-0104', 16, '2023-05-15', 15000),(6, 'Robert', 'Anderson', NULL, 'r.anderson@email.com', '555-0105', 31, '2023-06-01', 3000),
(7, 'Maria', 'Garcia', NULL, 'm.garcia@email.com', '555-0106', 32, '2023-06-15', 2800),(8, 'James', 'Wilson', NULL, 'j.wilson@email.com', '555-0107', 33, '2023-07-01', 4200),
(9, 'Emily', 'Brown', NULL, 'e.brown@email.com', '555-0108', 34, '2023-07-15', 3500),(10, 'Michael', 'Taylor', NULL, 'm.taylor@email.com', '555-0109', 35, '2023-08-01', 5000),
(11, 'David', 'Martinez', NULL, 'd.martinez@email.com', '555-0110', 36, '2023-08-15', 1500),(12, 'Sarah', 'Johnson', NULL, 's.johnson@email.com', '555-0111', 37, '2023-09-01', 1200),
(13, 'Thomas', 'Lee', NULL, 't.lee@email.com', '555-0112', 38, '2023-09-15', 800),(14, 'Jennifer', 'White', NULL, 'j.white@email.com', '555-0113', 39, '2023-10-01', 1000),
(15, 'Christopher', 'Harris', NULL, 'c.harris@email.com', '555-0114', 42, '2023-10-15', 500),(16, NULL, NULL, 'Tech Transport Solutions', 'fleet@techts.com', '555-0115', 17, '2023-11-01', 6000),
(17, NULL, NULL, 'Green Fleet Services', 'info@greenfleet.com', '555-0116', 18, '2023-11-15', 4500),(18, NULL, NULL, 'Regional Delivery Co', 'fleet@regdelivery.com', '555-0117', 19, '2023-12-01', 5500),
(19, NULL, NULL, 'Urban Mobility Group', 'info@urbanmobility.com', '555-0118', 11, '2023-12-15', 7000),(20, NULL, NULL, 'Executive Car Services', 'fleet@execcar.com', '555-0119', 4, '2024-01-01', 8500),
(21, 'Jean', 'Dubois', NULL, 'j.dubois@email.com', '555-0120', 40, '2024-01-15', 2000),(22, 'Hans', 'Schmidt', NULL, 'h.schmidt@email.com', '555-0121', 40, '2024-02-01', 1800),
(23, NULL, NULL, 'Canadian Fleet Management', 'info@canfleet.com', '555-0122', 40, '2024-02-15', 9000),(24, NULL, NULL, 'Mexico Transport Solutions', 'info@mextransport.com', '555-0123', 41, '2024-03-01', 7500),
(25, 'William', 'Davis', NULL, 'w.davis@email.com', '555-0124', 43, '2024-03-15', 200),(26, 'Emma', 'Wilson', NULL, 'e.wilson@email.com', '555-0125', 31, '2024-04-01', 300),
(27, 'Oliver', 'Thompson', NULL, 'o.thompson@email.com', '555-0126', 32, '2024-04-15', 150),(28, 'Sophia', 'Rodriguez', NULL, 's.rodriguez@email.com', '555-0127', 33, '2024-05-01', 250),
(29, 'Lucas', 'Martinez', NULL, 'l.martinez@email.com', '555-0128', 34, '2024-05-15', 100),(30, 'Isabella', 'Clark', NULL, 'i.clark@email.com', '555-0129', 35, '2024-06-01', 50);

-- Products Table (IDs 1-46) - ADDED
INSERT INTO Products (ProductID, ModelName, BodyStyle, BasePrice, LaunchYear, IsActive) VALUES
-- Velocity Series (1-10)
(1, 'Velocity S1', 'Sedan', 29500.00, 2022, TRUE),
(2, 'Velocity S2', 'Sport Sedan', 38500.00, 2022, TRUE),
(3, 'Velocity S3', 'Luxury Sedan', 45000.00, 2022, TRUE),
(4, 'Velocity S4', 'Premium Sedan', 55000.00, 2023, TRUE),
(5, 'Velocity C1', 'Coupe', 32000.00, 2022, TRUE),
(6, 'Velocity C2', 'Sport Coupe', 42000.00, 2022, FALSE),

-- Atlas Series (11-20)
(11, 'Atlas X1', 'SUV', 34000.00, 2022, TRUE),
(12, 'Atlas X2', 'Luxury SUV', 45000.00, 2022, TRUE),
(13, 'Atlas X3', 'Premium SUV', 58000.00, 2023, TRUE),
(14, 'Atlas X4', 'Full-Size SUV', 65000.00, 2023, TRUE),
(15, 'Atlas T1', 'Compact Crossover', 28000.00, 2022, TRUE),
(16, 'Atlas T2', 'Crossover', 32000.00, 2022, FALSE),

-- Horizon Series (21-30)
(21, 'Horizon C1', 'Compact', 24000.00, 2022, TRUE),
(22, 'Horizon C2', 'Hatchback', 26000.00, 2022, TRUE),
(23, 'Horizon C3', 'Premium Compact', 29000.00, 2023, TRUE),
(24, 'Horizon C4', 'Sport Compact', 32000.00, 2023, TRUE),
(25, 'Horizon M1', 'Mini', 22000.00, 2022, TRUE),
(26, 'Horizon M2', 'City Car', 20000.00, 2022, FALSE),

-- Titan Series (31-40)
(31, 'Titan T1', 'Pickup', 36000.00, 2022, TRUE),
(32, 'Titan T2', 'Full-Size Pickup', 42000.00, 2022, TRUE),
(33, 'Titan T3', 'Heavy Duty Pickup', 48000.00, 2023, TRUE),
(34, 'Titan T4', 'Luxury Pickup', 55000.00, 2023, TRUE),
(35, 'Titan V1', 'Van', 32000.00, 2022, TRUE),
(36, 'Titan V2', 'Cargo Van', 34000.00, 2022, FALSE),

-- Spark Series (41-50, Electric Vehicles)
(41, 'Spark E1', 'Electric Sedan', 38000.00, 2022, TRUE),
(42, 'Spark E2', 'Electric SUV', 45000.00, 2022, TRUE),
(43, 'Spark E3', 'Electric Luxury Sedan', 58000.00, 2023, TRUE),
(44, 'Spark E4', 'Electric Crossover', 48000.00, 2023, TRUE),
(45, 'Spark H1', 'Hybrid Sedan', 32000.00, 2022, TRUE),
(46, 'Spark H2', 'Hybrid SUV', 36000.00, 2022, FALSE);

-- ProductFeatures Table (Linking Products and Features)
INSERT INTO ProductFeatures (ProductID, FeatureID) VALUES
(1, 3),(1, 4),(1, 8),(1, 12),(1, 19),(2, 1),(2, 2),(2, 31),(2, 32),(2, 33),(2, 37),(2, 38),(3, 11),(3, 13),(3, 14),(3, 15),(3, 16),(3, 17),(3, 18),(4, 1),(4, 2),(4, 3),(4, 4),(4, 5),(4, 11),(4, 12),(4, 13),(4, 14),(4, 41),(4, 42),(4, 43),(4, 44),(11, 1),(11, 4),(11, 8),(11, 24),(11, 34),(12, 1),(12, 2),(12, 3),(12, 11),(12, 12),(12, 15),(12, 21),(12, 22),(12, 23),(12, 34),(13, 1),(13, 2),(13, 3),(13, 4),(13, 5),(13, 11),(13, 12),(13, 13),(13, 14),(13, 35),(13, 41),(13, 42),(21, 3),(21, 4),(21, 8),(21, 34),(22, 1),(22, 2),(22, 3),(22, 4),(22, 11),(22, 12),(22, 15),(22, 34),(22, 35),(23, 1),(23, 2),(23, 3),(23, 4),(23, 5),(23, 11),(23, 12),(23, 13),(23, 14),(23, 41),(23, 42),(23, 43),(31, 4),(31, 8),(31, 24),(31, 34),(32, 1),(32, 2),(32, 3),(32, 4),(32, 31),(32, 32),(32, 34),(32, 35),(33, 1),(33, 2),(33, 3),(33, 4),(33, 5),(33, 31),(33, 32),(33, 33),(33, 34),(33, 41),(33, 42),(41, 3),(41, 4),(41, 8),(41, 41),(42, 1),(42, 2),(42, 3),(42, 4),(42, 11),(42, 12),(42, 15),(42, 41),(42, 42),(42, 43),(43, 1),(43, 2),(43, 3),(43, 4),(43, 5),(43, 11),(43, 12),(43, 13),(43, 14),(43, 41),(43, 42),(43, 43),(43, 44),(43, 45);

-- ProductComponents Table (Linking Products and Components)
INSERT INTO ProductComponents (ProductID, ComponentID, QuantityRequired) VALUES
(1, 1, 1),(1, 3, 1),(1, 4, 1),(1, 5, 6),(1, 7, 1),(1, 11, 1),(1, 16, 1),(1, 17, 1),(1, 26, 1),(1, 27, 4),(1, 28, 1),(1, 31, 1),(1, 32, 1),(1, 33, 1),(1, 34, 4),(1, 36, 1),
(2, 2, 1),(2, 3, 1),(2, 4, 1),(2, 5, 8),(2, 6, 1),(2, 11, 1),(2, 16, 1),(2, 17, 1),(2, 26, 1),(2, 27, 4),(2, 28, 1),(2, 31, 1),(2, 32, 1),(2, 33, 1),(2, 34, 4),(2, 36, 1),
(11, 2, 1),(11, 3, 1),(11, 4, 1),(11, 5, 8),(11, 6, 1),(11, 11, 1),(11, 16, 2),(11, 17, 1),(11, 26, 1),(11, 27, 4),(11, 28, 1),(11, 31, 1),(11, 32, 1),(11, 33, 1),(11, 34, 4),(11, 38, 1),
(21, 1, 1),(21, 3, 1),(21, 4, 1),(21, 5, 6),(21, 6, 1),(21, 11, 1),(21, 16, 2),(21, 17, 1),(21, 26, 1),(21, 27, 4),(21, 28, 1),(21, 31, 1),(21, 32, 1),(21, 33, 1),(21, 34, 4),(21, 38, 1),
(31, 2, 1),(31, 3, 1),(31, 4, 1),(31, 5, 8),(31, 6, 1),(31, 11, 1),(31, 16, 1),(31, 17, 1),(31, 26, 1),(31, 27, 2),(31, 28, 1),(31, 31, 1),(31, 32, 1),(31, 33, 1),(31, 34, 4),(31, 38, 1),
(41, 41, 1),(41, 42, 1),(41, 14, 1),(41, 11, 1),(41, 16, 1),(41, 17, 1),(41, 26, 1),(41, 27, 4),(41, 28, 1),(41, 31, 1),(41, 32, 1),(41, 33, 1),(41, 34, 4),(41, 45, 1),
(43, 41, 1),(43, 42, 2),(43, 14, 1),(43, 11, 1),(43, 16, 1),(43, 17, 1),(43, 26, 1),(43, 27, 4),(43, 28, 1),(43, 31, 1),(43, 32, 1),(43, 33, 1),(43, 34, 4),(43, 45, 1);

-- WorkOrders Table (IDs 1-50)
INSERT INTO WorkOrders (WorkOrderID, ProductID, Quantity, DateCreated, DueDate, Status) VALUES
(1, 1, 150, '2024-01-15', '2024-03-15', 'Completed'),(2, 2, 200, '2024-01-20', '2024-03-20', 'Completed'),(3, 3, 100, '2024-02-01', '2024-04-01', 'In Progress'),
(4, 4, 75, '2024-02-15', '2024-04-15', 'In Progress'),(5, 1, 125, '2024-03-01', '2024-05-01', 'Pending'),(6, 2, 175, '2024-03-15', '2024-05-15', 'Pending'),
(7, 3, 80, '2024-02-10', '2024-04-10', 'In Progress'),(8, 4, 90, '2024-02-20', '2024-04-20', 'In Progress'),(9, 6, 60, '2024-01-05', '2024-03-05', 'Cancelled'),
(10, 6, 100, '2024-03-10', '2024-05-10', 'Pending'),(11, 11, 200, '2024-01-10', '2024-03-10', 'Completed'),(12, 12, 250, '2024-01-25', '2024-03-25', 'Completed'),
(13, 13, 150, '2024-02-05', '2024-04-05', 'In Progress'),(14, 14, 100, '2024-02-25', '2024-04-25', 'In Progress'),(15, 11, 175, '2024-03-05', '2024-05-05', 'Pending'),
(16, 12, 225, '2024-03-20', '2024-05-20', 'Pending'),(17, 13, 120, '2024-02-15', '2024-04-15', 'In Progress'),(18, 14, 80, '2024-01-30', '2024-03-30', 'Completed'),
(19, 16, 50, '2024-01-08', '2024-03-08', 'Cancelled'),(20, 16, 150, '2024-03-12', '2024-05-12', 'Pending'),(21, 21, 175, '2024-01-12', '2024-03-12', 'Completed'),
(22, 22, 200, '2024-01-28', '2024-03-28', 'Completed'),(23, 23, 125, '2024-02-08', '2024-04-08', 'In Progress'),(24, 24, 150, '2024-02-28', '2024-04-28', 'In Progress'),
(25, 21, 160, '2024-03-08', '2024-05-08', 'Pending'),(26, 22, 180, '2024-03-22', '2024-05-22', 'Pending'),(27, 23, 140, '2024-02-18', '2024-04-18', 'In Progress'),
(28, 24, 120, '2024-02-22', '2024-04-22', 'In Progress'),(29, 26, 40, '2024-01-15', '2024-03-15', 'Cancelled'),(30, 26, 130, '2024-03-15', '2024-05-15', 'Pending'),
(31, 31, 100, '2024-01-18', '2024-03-18', 'Completed'),(32, 32, 150, '2024-01-30', '2024-03-30', 'Completed'),(33, 33, 80, '2024-02-12', '2024-04-12', 'In Progress'),
(34, 34, 120, '2024-03-01', '2024-05-01', 'Pending'),(35, 31, 90, '2024-03-10', '2024-05-10', 'Pending'),(36, 32, 130, '2024-03-25', '2024-05-25', 'Pending'),
(37, 33, 75, '2024-02-20', '2024-04-20', 'In Progress'),(38, 34, 100, '2024-02-25', '2024-04-25', 'In Progress'),(39, 36, 30, '2024-01-20', '2024-03-20', 'Cancelled'),
(40, 36, 110, '2024-03-18', '2024-05-18', 'Pending'),(41, 41, 125, '2024-01-22', '2024-03-22', 'Completed'),(42, 42, 175, '2024-02-02', '2024-04-02', 'In Progress'),
(43, 43, 100, '2024-02-15', '2024-04-15', 'In Progress'),(44, 44, 150, '2024-03-05', '2024-05-05', 'Pending'),(45, 41, 115, '2024-03-12', '2024-05-12', 'Pending'),
(46, 42, 160, '2024-03-28', '2024-05-28', 'Pending'),(47, 43, 90, '2024-02-22', '2024-04-22', 'In Progress'),(48, 44, 135, '2024-02-28', '2024-04-28', 'In Progress'),
(49, 46, 25, '2024-01-25', '2024-03-25', 'Cancelled'),(50, 46, 140, '2024-03-20', '2024-05-20', 'Pending');

-- Vehicles Table (IDs 1-31)
INSERT INTO Vehicles (VehicleID, VIN, ProductID, ManufactureDate, Color, WorkOrderID, CurrentMileage, LastServiceDate, CurrentStatus, CurrentHolderCustomerID) VALUES
(1, 'VEL1S12401', 1, '2024-02-01', 'Midnight Black', 1, 1000, '2024-03-15', 'Sold', 6),(2, 'VEL1S12402', 1, '2024-02-01', 'Pearl White', 1, 500, '2024-03-10', 'Sold', 7),
(3, 'VEL1S12403', 1, '2024-02-02', 'Silver Metallic', 1, 750, '2024-03-12', 'Leased', 8),(4, 'VEL2S24001', 2, '2024-02-05', 'Racing Red', 2, 300, '2024-03-18', 'Sold', 9),
(5, 'VEL2S24002', 2, '2024-02-05', 'Carbon Black', 2, 450, '2024-03-20', 'Sold', 10),(6, 'ATL1X12401', 11, '2024-01-20', 'Graphite Grey', 11, 800, '2024-03-01', 'Sold', 1),
(7, 'ATL1X12402', 11, '2024-01-21', 'Arctic White', 11, 600, '2024-03-05', 'Sold', 2),(8, 'ATL2X24001', 12, '2024-01-28', 'Ocean Blue', 12, 400, '2024-03-10', 'Leased', 3),
(9, 'ATL2X24002', 12, '2024-01-29', 'Forest Green', 12, 550, '2024-03-12', 'Sold', 4),(10, 'ATL4X24001', 14, '2024-02-15', 'Diamond Black', 18, 200, '2024-03-15', 'Sold', 5),
(11, 'HOR1C12401', 21, '2024-01-25', 'Silver Sky', 21, 650, '2024-03-08', 'Sold', 11),(12, 'HOR1C12402', 21, '2024-01-26', 'Cosmic Blue', 21, 480, '2024-03-11', 'Leased', 12),
(13, 'HOR2C24001', 22, '2024-02-01', 'Desert Sand', 22, 320, '2024-03-14', 'Sold', 13),(14, 'HOR2C24002', 22, '2024-02-02', 'Mountain Grey', 22, 250, '2024-03-16', 'Sold', 14),
(15, 'TIT1T12401', 31, '2024-02-01', 'Granite Black', 31, 900, '2024-03-05', 'Sold', 16),(16, 'TIT1T12402', 31, '2024-02-02', 'Arctic White', 31, 850, '2024-03-08', 'Sold', 17),
(17, 'TIT2T24001', 32, '2024-02-05', 'Steel Grey', 32, 700, '2024-03-12', 'Leased', 18),(18, 'TIT2T24002', 32, '2024-02-06', 'Deep Blue', 32, 600, '2024-03-15', 'Sold', 19),
(19, 'SPK1E12401', 41, '2024-02-10', 'Electric Blue', 41, 400, '2024-03-18', 'Sold', 21),(20, 'SPK1E12402', 41, '2024-02-11', 'Pearl White', 41, 350, '2024-03-20', 'Leased', 22),
(21, 'VEL3S24003', 3, '2024-03-01', 'Sapphire Blue', 3, 0, NULL, 'Inventory', NULL),(22, 'VEL4S24004', 4, '2024-03-05', 'Ruby Red', 4, 0, NULL, 'Inventory', NULL),
(23, 'ATL3X24003', 13, '2024-03-08', 'Emerald Green', 13, 0, NULL, 'Inventory', NULL),(24, 'HOR3C24003', 23, '2024-03-10', 'Sunset Orange', 23, 0, NULL, 'Inventory', NULL),
(25, 'TIT3T24003', 33, '2024-03-12', 'Midnight Black', 33, 0, NULL, 'Inventory', NULL),(26, 'SPK2E24003', 42, '2024-03-15', 'Stellar Silver', 42, 0, NULL, 'Inventory', NULL),
(27, 'VEL1S24005', 1, '2024-03-18', 'Crystal White', 5, 0, NULL, 'Inventory', NULL),(28, 'ATL1X24004', 11, '2024-03-19', 'Obsidian Black', 15, 0, NULL, 'Inventory', NULL),
(29, 'HOR1C24004', 21, '2024-03-20', 'Platinum Silver', 25, 0, NULL, 'Inventory', NULL),(30, 'TIT1T24004', 31, '2024-03-21', 'Glacier White', 35, 0, NULL, 'Inventory', NULL),
(31, 'SPK1E24004', 41, '2024-03-22', 'Cosmic Grey', 45, 0, NULL, 'Inventory', NULL);

-- VehicleFeatures Table (Linking Vehicles and Features)
INSERT INTO VehicleFeatures (VehicleID, FeatureID) VALUES
(1, 3),(1, 4),(1, 8),(1, 12),(1, 19),(2, 3),(2, 4),(2, 8),(2, 12),(2, 19),(3, 3),(3, 4),(3, 8),(3, 12),(3, 19),
(4, 1),(4, 2),(4, 31),(4, 32),(4, 33),(4, 37),(5, 1),(5, 2),(5, 31),(5, 32),(5, 33),(5, 37),
(6, 1),(6, 4),(6, 8),(6, 24),(6, 34),(7, 1),(7, 4),(7, 8),(7, 24),(7, 34),
(8, 1),(8, 2),(8, 3),(8, 11),(8, 12),(8, 15),(8, 21),(8, 22),(8, 23),(8, 34),(9, 1),(9, 2),(9, 3),(9, 11),(9, 12),(9, 15),(9, 21),(9, 22),(9, 23),(9, 34),(10, 1),(10, 2),(10, 3),(10, 11),(10, 12),(10, 15),(10, 21),(10, 22),(10, 23),(10, 34),
(11, 3),(11, 4),(11, 8),(11, 34),(12, 3),(12, 4),(12, 8),(12, 34),
(13, 1),(13, 2),(13, 3),(13, 4),(13, 11),(13, 12),(13, 15),(14, 1),(14, 2),(14, 3),(14, 4),(14, 11),(14, 12),(14, 15),
(15, 4),(15, 8),(15, 24),(15, 34),(16, 4),(16, 8),(16, 24),(16, 34),
(17, 1),(17, 2),(17, 3),(17, 4),(17, 31),(17, 32),(17, 34),(17, 35),(18, 1),(18, 2),(18, 3),(18, 4),(18, 31),(18, 32),(18, 34),(18, 35),
(19, 3),(19, 4),(19, 8),(19, 41),(20, 3),(20, 4),(20, 8),(20, 41),
(21, 1),(21, 2),(21, 3),(21, 11),(21, 12),(21, 13),(21, 14),(22, 1),(22, 2),(22, 3),(22, 11),(22, 12),(22, 13),(22, 14),
(23, 1),(23, 2),(23, 3),(23, 11),(23, 12),(23, 15),(24, 1),(24, 2),(24, 3),(24, 11),(24, 12),(24, 15),
(25, 1),(25, 2),(25, 3),(25, 31),(25, 32),(25, 33),(26, 41),(26, 42),(26, 43),(26, 44),(26, 45),
(27, 3),(27, 4),(27, 8),(27, 12),(27, 19),(28, 1),(28, 4),(28, 8),(28, 24),(28, 34),
(29, 3),(29, 4),(29, 8),(29, 34),(30, 4),(30, 8),(30, 24),(30, 34),(31, 3),(31, 4),(31, 8),(31, 41);

-- SalesOrders Table (IDs 1-20)
INSERT INTO SalesOrders (SalesOrderID, CustomerID, OrderTimestamp, ShippingAddressID, Status, TotalAmount) VALUES
(1, 1, '2024-02-01 09:00:00', 1, 'Delivered', 135000.00),(2, 2, '2024-02-02 10:30:00', 2, 'Delivered', 142000.00),
(3, 3, '2024-02-03 11:15:00', 3, 'Delivered', 168000.00),(4, 4, '2024-02-04 14:20:00', 12, 'Delivered', 175000.00),
(5, 5, '2024-02-05 15:45:00', 13, 'Delivered', 188000.00),(6, 6, '2024-02-06 09:30:00', 31, 'Delivered', 32500.00),
(7, 7, '2024-02-07 10:45:00', 32, 'Delivered', 32500.00),(8, 8, '2024-02-08 11:30:00', 33, 'Delivered', 32500.00),
(9, 9, '2024-02-09 13:15:00', 34, 'Delivered', 45000.00),(10, 10, '2024-02-10 14:30:00', 35, 'Delivered', 45000.00),
(11, 16, '2024-02-11 09:15:00', 36, 'Delivered', 142000.00),(12, 17, '2024-02-12 10:20:00', 15, 'Delivered', 142000.00),
(13, 18, '2024-02-13 11:45:00', 4, 'Delivered', 152000.00),(14, 19, '2024-02-14 13:30:00', 28, 'Delivered', 152000.00),
(15, 11, '2024-02-15 15:20:00', 37, 'Delivered', 34000.00),(16, 12, '2024-02-16 16:30:00', 38, 'Delivered', 34000.00),
(17, 13, '2024-02-17 09:45:00', 39, 'Delivered', 42000.00),(18, 14, '2024-02-18 10:15:00', 40, 'Delivered', 42000.00),
(19, 21, '2024-02-19 11:30:00', 40, 'Delivered', 45000.00),(20, 22, '2024-02-20 14:20:00', 40, 'Delivered', 45000.00);

-- SalesOrderItems Table (IDs 1-20)
INSERT INTO SalesOrderItems (OrderItemID, SalesOrderID, VehicleID, Quantity, AgreedPrice) VALUES
(1, 1, 6, 1, 135000.00),(2, 2, 7, 1, 142000.00),(3, 3, 8, 1, 168000.00),(4, 4, 9, 1, 175000.00),(5, 5, 10, 1, 188000.00),
(6, 6, 1, 1, 32500.00),(7, 7, 2, 1, 32500.00),(8, 8, 3, 1, 32500.00),(9, 9, 4, 1, 45000.00),(10, 10, 5, 1, 45000.00),
(11, 11, 15, 1, 142000.00),(12, 12, 16, 1, 142000.00),(13, 13, 17, 1, 152000.00),(14, 14, 18, 1, 152000.00),
(15, 15, 11, 1, 34000.00),(16, 16, 12, 1, 34000.00),(17, 17, 13, 1, 42000.00),(18, 18, 14, 1, 42000.00),
(19, 19, 19, 1, 45000.00),(20, 20, 20, 1, 45000.00);

-- LeaseRentalAgreements Table (IDs 1-10)
INSERT INTO LeaseRentalAgreements (AgreementID, CustomerID, VehicleID, AgreementType, StartDate, EndDate, MonthlyPayment, RentalRatePerDay, Status, Notes) VALUES
(1, 8, 3, 'Lease', '2024-02-02', '2027-02-02', 550.00, NULL, 'Active', 'Standard 36-month lease, Velocity S1, includes maintenance package'),
(2, 3, 8, 'Lease', '2024-01-28', '2027-01-28', 850.00, NULL, 'Active', 'Fleet lease - City Taxi Corporation, Atlas X2 Premium'),
(3, 12, 12, 'Lease', '2024-01-26', '2027-01-26', 600.00, NULL, 'Active', 'Standard 36-month lease, Horizon C1'),
(4, 18, 17, 'Lease', '2024-02-05', '2027-02-05', 900.00, NULL, 'Active', 'Commercial lease - Regional Delivery Co, Titan T2'),
(5, 22, 20, 'Lease', '2024-02-11', '2027-02-11', 750.00, NULL, 'Active', 'International lease - Spark E1, includes charging package'),
(6, 2, 7, 'Rental', '2024-03-01', '2024-05-01', NULL, 150.00, 'Active', 'Corporate rental - Luxury Car Rentals'),
(7, 4, 9, 'Rental', '2024-03-05', '2024-04-05', NULL, 175.00, 'Active', 'Corporate rental - Express Delivery Services'),
(8, 5, 10, 'Rental', '2024-03-10', '2024-04-10', NULL, 200.00, 'Active', 'Corporate rental - Corporate Fleet Solutions'),
(9, 13, 13, 'Rental', '2024-03-15', '2024-03-22', NULL, 125.00, 'Active', 'Personal rental - Weekly'),
(10, 14, 14, 'Rental', '2024-03-18', '2024-03-25', NULL, 125.00, 'Active', 'Personal rental - Weekly');

-- Departments Table (Step 1: Insert with NULL ManagerID) (IDs 1-60)
INSERT INTO Departments (DepartmentID, DepartmentName, ManagerID) VALUES
(1, 'Executive Office', NULL), (2, 'Corporate Administration', NULL), (3, 'Legal Affairs', NULL), (4, 'Corporate Communications', NULL), (5, 'Internal Audit', NULL),
(6, 'Vehicle Assembly', NULL), (7, 'Quality Control', NULL), (8, 'Production Planning', NULL), (9, 'Manufacturing Engineering', NULL), (10, 'Plant Maintenance', NULL),
(11, 'Product Engineering', NULL), (12, 'Powertrain Engineering', NULL), (13, 'Electrical Systems Engineering', NULL), (14, 'Chassis Engineering', NULL), (15, 'Safety Engineering', NULL),
(16, 'Research & Development', NULL), (17, 'Innovation Lab', NULL), (18, 'Advanced Technologies', NULL), (19, 'Electric Vehicle Development', NULL), (20, 'Autonomous Systems', NULL),
(21, 'Supply Chain Management', NULL), (22, 'Procurement', NULL), (23, 'Inventory Management', NULL), (24, 'Logistics', NULL), (25, 'Supplier Relations', NULL),
(26, 'Sales Operations', NULL), (27, 'Marketing', NULL), (28, 'Brand Management', NULL), (29, 'Market Research', NULL), (30, 'Dealer Relations', NULL),
(31, 'Customer Experience', NULL), (32, 'After Sales Service', NULL), (33, 'Warranty Claims', NULL), (34, 'Customer Support', NULL), (35, 'Service Training', NULL),
(36, 'Finance', NULL), (37, 'Accounting', NULL), (38, 'Financial Planning', NULL), (39, 'Cost Management', NULL), (40, 'Treasury', NULL),
(41, 'Human Resources', NULL), (42, 'Talent Acquisition', NULL), (43, 'Employee Relations', NULL), (44, 'Training & Development', NULL), (45, 'Compensation & Benefits', NULL),
(46, 'IT Operations', NULL), (47, 'Software Development', NULL), (48, 'Network Infrastructure', NULL), (49, 'Cybersecurity', NULL), (50, 'Digital Transformation', NULL),
(51, 'Quality Assurance', NULL), (52, 'Environmental Health & Safety', NULL), (53, 'Facilities Management', NULL), (54, 'Project Management Office', NULL), (55, 'Business Intelligence', NULL),
(56, 'Compliance', NULL), (57, 'Risk Management', NULL), (58, 'Strategic Planning', NULL), (59, 'Global Operations', NULL), (60, 'Innovation Management', NULL);

-- Employees Table (Step 2: Insert with sequential IDs 1-31, mapped FKs, NULL SupervisorID initially)
INSERT INTO Employees (EmployeeID, FirstName, LastName, JobTitle, DepartmentID, HireDate, TerminationDate, Status, SalaryOrRate, PayType, Email, WorkPhone, LocationID, HomeAddressID, SupervisorID) VALUES
(1, 'John', 'Mitchell', 'Chief Executive Officer', 1, '2020-01-15', NULL, 'Active', 350000.00, 'Salary', 'john.mitchell@autocompany.com', '555-0001', 4, 1, NULL),
(2, 'Sarah', 'Chen', 'Chief Operating Officer', 1, '2020-03-20', NULL, 'Active', 280000.00, 'Salary', 'sarah.chen@autocompany.com', '555-0002', 4, 2, NULL),
(3, 'Michael', 'Rodriguez', 'Chief Financial Officer', 1, '2020-02-10', NULL, 'Active', 275000.00, 'Salary', 'michael.rodriguez@autocompany.com', '555-0003', 4, 3, NULL),
(4, 'David', 'Kim', 'Manufacturing Director', 6, '2020-04-15', NULL, 'Active', 180000.00, 'Salary', 'david.kim@autocompany.com', '555-0004', 1, 12, NULL),
(5, 'Robert', 'Chang', 'Chief Engineer', 11, '2020-05-12', NULL, 'Active', 190000.00, 'Salary', 'robert.chang@autocompany.com', '555-0006', 12, 14, NULL),
(6, 'Alan', 'Moore', 'R&D Director', 16, '2020-08-20', NULL, 'Active', 175000.00, 'Salary', 'alan.moore@autocompany.com', '555-0008', 12, 21, NULL),
(7, 'George', 'Martinez', 'Supply Chain Director', 21, '2020-10-01', NULL, 'Active', 165000.00, 'Salary', 'george.martinez@autocompany.com', '555-0010', 4, 23, NULL),
(8, 'Kevin', 'Johnson', 'Sales Director', 26, '2021-01-10', NULL, 'Active', 170000.00, 'Salary', 'kevin.johnson@autocompany.com', '555-0012', 4, 25, NULL),
(9, 'Charles', 'Evans', 'Customer Service Director', 31, '2021-09-01', NULL, 'Active', 150000.00, 'Salary', 'charles.evans@autocompany.com', '555-0020', 4, 45, NULL),
(10, 'Brian', 'Walker', 'Finance Controller', 36, '2021-11-05', NULL, 'Active', 155000.00, 'Salary', 'brian.walker@autocompany.com', '555-0022', 4, 47, NULL),
(11, 'Steven', 'Young', 'HR Manager', 41, '2022-01-15', NULL, 'Active', 130000.00, 'Salary', 'steven.young@autocompany.com', '555-0024', 4, 52, NULL),
(12, 'Edward', 'Hernandez', 'IT Director', 46, '2022-03-01', NULL, 'Active', 145000.00, 'Salary', 'edward.hernandez@autocompany.com', '555-0026', 4, 36, NULL),
(13, 'Lisa', 'Thompson', 'Quality Control Manager', 7, '2020-06-01', NULL, 'Active', 150000.00, 'Salary', 'lisa.thompson@autocompany.com', '555-0005', 1, 13, NULL),
(14, 'Emma', 'Davis', 'Electrical Systems Lead', 13, '2020-07-15', NULL, 'Active', 160000.00, 'Salary', 'emma.davis@autocompany.com', '555-0007', 12, 20, NULL),
(15, 'Patricia', 'Lee', 'Innovation Lab Manager', 17, '2020-09-10', NULL, 'Active', 145000.00, 'Salary', 'patricia.lee@autocompany.com', '555-0009', 12, 22, NULL),
(16, 'Nancy', 'White', 'Procurement Manager', 22, '2020-11-15', NULL, 'Active', 135000.00, 'Salary', 'nancy.white@autocompany.com', '555-0011', 4, 24, NULL),
(17, 'Maria', 'Garcia', 'Marketing Manager', 27, '2021-02-15', NULL, 'Active', 140000.00, 'Salary', 'maria.garcia@autocompany.com', '555-0013', 4, 26, NULL),
(18, 'Laura', 'Scott', 'Support Manager', 34, '2021-10-12', NULL, 'Active', 110000.00, 'Salary', 'laura.scott@autocompany.com', '555-0021', 4, 46, NULL),
(19, 'Angela', 'Hall', 'Accountant Lead', 37, '2021-12-10', NULL, 'Active', 90000.00, 'Salary', 'angela.hall@autocompany.com', '555-0023', 4, 51, NULL),
(20, 'Karen', 'Baker', 'Recruiter Lead', 42, '2022-02-20', NULL, 'Active', 85000.00, 'Salary', 'karen.baker@autocompany.com', '555-0025', 4, 53, NULL),
(21, 'Betty', 'Lopez', 'Software Developer Lead', 47, '2022-04-15', NULL, 'Active', 95000.00, 'Salary', 'betty.lopez@autocompany.com', '555-0027', 4, 15, NULL),
(22, 'Frank', 'Gonzalez', 'EH&S Specialist Lead', 52, '2022-05-10', NULL, 'Active', 87000.00, 'Salary', 'frank.gonzalez@autocompany.com', '555-0028', 1, 4, NULL),
(23, 'Deborah', 'Perez', 'Compliance Officer Lead', 56, '2022-06-20', NULL, 'Active', 98000.00, 'Salary', 'deborah.perez@autocompany.com', '555-0029', 4, 28, NULL),
(24, 'Thomas', 'Brown', 'Assembly Line Worker', 6, '2021-03-01', NULL, 'Active', 25.00, 'Hourly', 'thomas.brown@autocompany.com', '555-0014', 1, 27, NULL),
(25, 'Jennifer', 'Wilson', 'Quality Inspector', 7, '2021-04-15', NULL, 'Active', 28.00, 'Hourly', 'jennifer.wilson@autocompany.com', '555-0015', 1, 31, NULL),
(26, 'Richard', 'Lee', 'Mechanical Engineer', 11, '2021-05-20', NULL, 'Active', 95000.00, 'Salary', 'richard.lee@autocompany.com', '555-0016', 12, 32, NULL),
(27, 'Susan', 'Miller', 'Electrical Engineer', 13, '2021-06-10', NULL, 'Active', 92000.00, 'Salary', 'susan.miller@autocompany.com', '555-0017', 12, 33, NULL),
(28, 'Paul', 'Anderson', 'Research Scientist', 16, '2021-07-01', NULL, 'Active', 98000.00, 'Salary', 'paul.anderson@autocompany.com', '555-0018', 12, 34, NULL),
(29, 'Diana', 'Taylor', 'Innovation Specialist', 17, '2021-08-15', NULL, 'Active', 88000.00, 'Salary', 'diana.taylor@autocompany.com', '555-0019', 12, 35, NULL),
(30, 'Ethan', 'King', 'Technician', 10, '2022-07-10', NULL, 'Active', 30.00, 'Hourly', 'ethan.king@autocompany.com', '555-0030', 1, 29, NULL),
(31, 'Natalie', 'Price', 'Data Entry Clerk', 37, '2022-08-15', NULL, 'Active', 24.00, 'Hourly', 'natalie.price@autocompany.com', '555-0031', 4, 30, NULL);

-- InventoryLevels Table (IDs 1-50)
INSERT INTO InventoryLevels (InventoryID, LocationID, ProductID, ComponentID, QuantityOnHand, LastUpdated) VALUES
(1, 1, 1, NULL, 25, '2024-03-20 09:00:00'),(2, 1, 2, NULL, 20, '2024-03-20 09:00:00'),(3, 1, 3, NULL, 15, '2024-03-20 09:00:00'),(4, 1, 4, NULL, 10, '2024-03-20 09:00:00'),
(5, 1, NULL, 1, 50, '2024-03-20 09:00:00'),(6, 1, NULL, 2, 30, '2024-03-20 09:00:00'),(7, 1, NULL, 3, 100, '2024-03-20 09:00:00'),(8, 1, NULL, 4, 100, '2024-03-20 09:00:00'),
(9, 1, NULL, 5, 600, '2024-03-20 09:00:00'),(10, 2, 11, NULL, 20, '2024-03-20 09:00:00'),(11, 2, 12, NULL, 15, '2024-03-20 09:00:00'),(12, 2, 13, NULL, 10, '2024-03-20 09:00:00'),
(13, 2, 14, NULL, 8, '2024-03-20 09:00:00'),(14, 2, NULL, 6, 40, '2024-03-20 09:00:00'),(15, 2, NULL, 7, 30, '2024-03-20 09:00:00'),(16, 2, NULL, 8, 80, '2024-03-20 09:00:00'),
(17, 2, NULL, 9, 60, '2024-03-20 09:00:00'),(18, 2, NULL, 10, 100, '2024-03-20 09:00:00'),(19, 3, 21, NULL, 18, '2024-03-20 09:00:00'),(20, 3, 22, NULL, 15, '2024-03-20 09:00:00'),
(21, 3, 23, NULL, 12, '2024-03-20 09:00:00'),(22, 3, 24, NULL, 10, '2024-03-20 09:00:00'),(23, 3, NULL, 11, 50, '2024-03-20 09:00:00'),(24, 3, NULL, 12, 40, '2024-03-20 09:00:00'),
(25, 3, NULL, 13, 35, '2024-03-20 09:00:00'),(26, 3, NULL, 14, 30, '2024-03-20 09:00:00'),(27, 3, NULL, 15, 45, '2024-03-20 09:00:00'),(28, 30, 31, NULL, 15, '2024-03-20 09:00:00'),
(29, 30, 32, NULL, 12, '2024-03-20 09:00:00'),(30, 30, NULL, 16, 60, '2024-03-20 09:00:00'),(31, 30, NULL, 17, 50, '2024-03-20 09:00:00'),(32, 30, NULL, 18, 40, '2024-03-20 09:00:00'),
(33, 31, 41, NULL, 20, '2024-03-20 09:00:00'),(34, 31, 42, NULL, 15, '2024-03-20 09:00:00'),(35, 31, NULL, 41, 40, '2024-03-20 09:00:00'),(36, 31, NULL, 42, 35, '2024-03-20 09:00:00'),
(37, 31, NULL, 45, 35, '2024-03-20 09:00:00'),(38, 27, NULL, 31, 100, '2024-03-20 09:00:00'),(39, 27, NULL, 32, 80, '2024-03-20 09:00:00'),(40, 27, NULL, 33, 120, '2024-03-20 09:00:00'),
(41, 28, NULL, 36, 90, '2024-03-20 09:00:00'),(42, 28, NULL, 37, 75, '2024-03-20 09:00:00'),(43, 28, NULL, 38, 60, '2024-03-20 09:00:00'),(44, 29, NULL, 46, 150, '2024-03-20 09:00:00'),
(45, 29, NULL, 47, 120, '2024-03-20 09:00:00'),(46, 29, NULL, 48, 80, '2024-03-20 09:00:00'),(47, 29, NULL, 49, 100, '2024-03-20 09:00:00'),(48, 29, NULL, 50, 90, '2024-03-20 09:00:00'),
(49, 13, NULL, 1, 100, '2025-05-03 19:22:28'),(50, 14, NULL, 2, 150, '2025-05-03 19:22:28');

-- ServiceRecords Table (IDs 1-10)
INSERT INTO ServiceRecords (ServiceID, VehicleID, CustomerID, LocationID, TechnicianID, ServiceDate, ServiceType, IsWarrantyClaim, Notes, LaborHours, PartsCost, LaborCost, TotalCost, PointsEarned) VALUES
(1, 1, 6, 10, 12, '2024-03-15', 'Regular Maintenance', false, 'First service - Oil change, filters, inspection', 2.5, 150.00, 250.00, 400.00, 400),
(2, 2, 7, 11, 12, '2024-03-10', 'Regular Maintenance', false, 'First service - Oil change, filters, inspection', 2.5, 150.00, 250.00, 400.00, 400),
(3, 3, 8, 12, 12, '2024-03-12', 'Warranty Repair', true, 'Electronic system diagnostic and software update', 1.5, 0.00, 0.00, 0.00, 100),
(4, 4, 9, 21, 12, '2024-03-18', 'Warranty Repair', true, 'Brake system inspection and adjustment', 2.0, 0.00, 0.00, 0.00, 100),
(5, 6, 1, 22, 12, '2024-03-01', 'Major Service', false, 'Fleet vehicle full service - brakes, transmission, fluids', 6.0, 800.00, 600.00, 1400.00, 1400),
(6, 7, 2, 23, 12, '2024-03-05', 'Major Service', false, 'Fleet vehicle full service - suspension, alignment, fluids', 5.5, 750.00, 550.00, 1300.00, 1300),
(7, 8, 3, 36, 12, '2024-03-10', 'Repair', false, 'Replace worn brake pads and rotors', 3.0, 450.00, 300.00, 750.00, 750),
(8, 9, 4, 38, 12, '2024-03-12', 'Repair', false, 'Replace faulty oxygen sensor', 2.0, 300.00, 200.00, 500.00, 500),
(9, 19, 21, 45, 12, '2024-03-18', 'EV Service', false, 'Battery system check and software update', 2.0, 100.00, 200.00, 300.00, 300),
(10, 20, 22, 46, 12, '2024-03-20', 'EV Service', false, 'Charging system inspection and calibration', 1.5, 50.00, 150.00, 200.00, 200);

-- ServicePartsUsed Table (Linking ServiceRecords and Components)
INSERT INTO ServicePartsUsed (ServiceID, ComponentID, QuantityUsed, UnitPrice) VALUES
(1, 8, 1, 50.00),(1, 33, 1, 100.00),(2, 8, 1, 50.00),(2, 33, 1, 100.00),(5, 9, 1, 300.00),
(5, 10, 1, 500.00),(6, 32, 1, 400.00),(7, 33, 1, 450.00),(8, 11, 1, 300.00),(9, 14, 1, 100.00);

-- LoyaltyTransactions Table (IDs 1-27)
INSERT INTO LoyaltyTransactions (TransactionID, CustomerID, TransactionType, PointsChanged, TransactionDate, RelatedServiceID, RelatedAgreementID, Notes) VALUES
(1, 6, 'Earned', 400, '2024-03-15', 1, NULL, 'Points earned from regular maintenance service'),(2, 7, 'Earned', 400, '2024-03-10', 2, NULL, 'Points earned from regular maintenance service'),
(3, 8, 'Earned', 100, '2024-03-12', 3, NULL, 'Points earned from warranty service'),(4, 9, 'Earned', 100, '2024-03-18', 4, NULL, 'Points earned from warranty service'),
(5, 1, 'Earned', 1400, '2024-03-01', 5, NULL, 'Points earned from fleet vehicle major service'),(6, 2, 'Earned', 1300, '2024-03-05', 6, NULL, 'Points earned from fleet vehicle major service'),
(7, 3, 'Earned', 750, '2024-03-10', 7, NULL, 'Points earned from repair service'),(8, 4, 'Earned', 500, '2024-03-12', 8, NULL, 'Points earned from repair service'),
(9, 21, 'Earned', 300, '2024-03-18', 9, NULL, 'Points earned from EV service'),(10, 22, 'Earned', 200, '2024-03-20', 10, NULL, 'Points earned from EV service'),
(11, 8, 'Earned', 1000, '2024-02-02', NULL, 1, 'Sign-up bonus points for new lease agreement'),(12, 3, 'Earned', 2000, '2024-01-28', NULL, 2, 'Fleet lease agreement bonus points'),
(13, 12, 'Earned', 1000, '2024-01-26', NULL, 3, 'Sign-up bonus points for new lease agreement'),(14, 18, 'Earned', 2000, '2024-02-05', NULL, 4, 'Commercial lease agreement bonus points'),
(15, 22, 'Earned', 1000, '2024-02-11', NULL, 5, 'International lease agreement bonus points'),(16, 6, 'Redeemed', -500, '2024-03-20', NULL, NULL, 'Points redeemed for service discount'),
(17, 1, 'Redeemed', -1000, '2024-03-21', NULL, NULL, 'Points redeemed for fleet service discount'),(18, 21, 'Redeemed', -200, '2024-03-22', NULL, NULL, 'Points redeemed for EV charging credit'),
(19, 25, 'Earned', 500, '2024-03-15', NULL, NULL, 'New customer welcome bonus'),(20, 26, 'Earned', 500, '2024-04-01', NULL, NULL, 'New customer welcome bonus'),
(21, 27, 'Earned', 500, '2024-04-15', NULL, NULL, 'New customer welcome bonus'),(22, 1, 'Adjustment', 200, '2024-03-01', NULL, NULL, 'Monthly fleet customer bonus'),
(23, 2, 'Adjustment', 200, '2024-03-01', NULL, NULL, 'Monthly fleet customer bonus'),(24, 3, 'Adjustment', 200, '2024-03-01', NULL, NULL, 'Monthly fleet customer bonus'),
(25, 11, 'Expired', -100, '2024-03-31', NULL, NULL, 'Points expired after 12 months'),(26, 12, 'Expired', -150, '2024-03-31', NULL, NULL, 'Points expired after 12 months'),
(27, 13, 'Expired', -75, '2024-03-31', NULL, NULL, 'Points expired after 12 months');


-- ----------------------------------------------------------------------------
-- UPDATE Statements (Should be run AFTER all INSERTs are complete)
-- ----------------------------------------------------------------------------

-- Update Department Manager IDs
UPDATE Departments SET ManagerID = 1 WHERE DepartmentID = 1; UPDATE Departments SET ManagerID = 4 WHERE DepartmentID = 6;
UPDATE Departments SET ManagerID = 13 WHERE DepartmentID = 7; UPDATE Departments SET ManagerID = 5 WHERE DepartmentID = 11;
UPDATE Departments SET ManagerID = 6 WHERE DepartmentID = 16; UPDATE Departments SET ManagerID = 15 WHERE DepartmentID = 17;
UPDATE Departments SET ManagerID = 7 WHERE DepartmentID = 21; UPDATE Departments SET ManagerID = 16 WHERE DepartmentID = 22;
UPDATE Departments SET ManagerID = 8 WHERE DepartmentID = 26; UPDATE Departments SET ManagerID = 17 WHERE DepartmentID = 27;
UPDATE Departments SET ManagerID = 9 WHERE DepartmentID = 31; UPDATE Departments SET ManagerID = 18 WHERE DepartmentID = 34;
UPDATE Departments SET ManagerID = 10 WHERE DepartmentID = 36; UPDATE Departments SET ManagerID = 19 WHERE DepartmentID = 37;
UPDATE Departments SET ManagerID = 11 WHERE DepartmentID = 41; UPDATE Departments SET ManagerID = 20 WHERE DepartmentID = 42;
UPDATE Departments SET ManagerID = 12 WHERE DepartmentID = 46; UPDATE Departments SET ManagerID = 21 WHERE DepartmentID = 47;
UPDATE Departments SET ManagerID = 22 WHERE DepartmentID = 52; UPDATE Departments SET ManagerID = 23 WHERE DepartmentID = 56;

-- Update Employee Supervisor IDs
UPDATE Employees SET SupervisorID = 1 WHERE EmployeeID = 2; UPDATE Employees SET SupervisorID = 1 WHERE EmployeeID = 3;
UPDATE Employees SET SupervisorID = 2 WHERE EmployeeID = 4; UPDATE Employees SET SupervisorID = 2 WHERE EmployeeID = 5;
UPDATE Employees SET SupervisorID = 2 WHERE EmployeeID = 6; UPDATE Employees SET SupervisorID = 2 WHERE EmployeeID = 7;
UPDATE Employees SET SupervisorID = 2 WHERE EmployeeID = 8; UPDATE Employees SET SupervisorID = 2 WHERE EmployeeID = 9;
UPDATE Employees SET SupervisorID = 3 WHERE EmployeeID = 10; UPDATE Employees SET SupervisorID = 3 WHERE EmployeeID = 11;
UPDATE Employees SET SupervisorID = 3 WHERE EmployeeID = 12; UPDATE Employees SET SupervisorID = 4 WHERE EmployeeID = 13;
UPDATE Employees SET SupervisorID = 5 WHERE EmployeeID = 14; UPDATE Employees SET SupervisorID = 6 WHERE EmployeeID = 15;
UPDATE Employees SET SupervisorID = 7 WHERE EmployeeID = 16; UPDATE Employees SET SupervisorID = 8 WHERE EmployeeID = 17;
UPDATE Employees SET SupervisorID = 9 WHERE EmployeeID = 18; UPDATE Employees SET SupervisorID = 10 WHERE EmployeeID = 19;
UPDATE Employees SET SupervisorID = 11 WHERE EmployeeID = 20; UPDATE Employees SET SupervisorID = 12 WHERE EmployeeID = 21;
UPDATE Employees SET SupervisorID = 4 WHERE EmployeeID = 22; UPDATE Employees SET SupervisorID = 3 WHERE EmployeeID = 23;
UPDATE Employees SET SupervisorID = 13 WHERE EmployeeID = 24; UPDATE Employees SET SupervisorID = 13 WHERE EmployeeID = 25;
UPDATE Employees SET SupervisorID = 14 WHERE EmployeeID = 26; UPDATE Employees SET SupervisorID = 14 WHERE EmployeeID = 27;
UPDATE Employees SET SupervisorID = 15 WHERE EmployeeID = 28; UPDATE Employees SET SupervisorID = 15 WHERE EmployeeID = 29;
UPDATE Employees SET SupervisorID = 13 WHERE EmployeeID = 30; UPDATE Employees SET SupervisorID = 19 WHERE EmployeeID = 31;