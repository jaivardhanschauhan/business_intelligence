-- loading dimension tables

CREATE OR REPLACE TABLE Dim_Product(
    DimProductID INT IDENTITY(1,1) CONSTRAINT PK_DimProductID PRIMARY KEY NOT NULL --Surrogate Key
    ,ProductID NUMBER(38,0) NOT NULL --Natural Key
    ,ProductTypeID NUMBER(38,0) NOT NULL
    ,ProductCategoryID NUMBER(38,0) NOT NULL
    ,ProductName VARCHAR(255) NOT NULL
    ,ProductType VARCHAR(255) NOT NULL
    ,ProductCategory VARCHAR(255) NOT NULL
    ,ProductRetailPrice NUMBER(38,4) NOT NULL
    ,ProductWholesalePrice NUMBER(38,4) NOT NULL
    ,ProductCost NUMBER(38,4) NOT NULL
    ,ProductRetailProfit NUMBER(38,4) NOT NULL
    ,ProductWholesaleUnitProfit NUMBER(38,4) NOT NULL
    ,ProductProfitMarginUnitPercent NUMBER(38,4) NOT NULL
    );

--Load unknown members
INSERT INTO Dim_Product
(DimProductID,
ProductID,
ProductTypeID,
ProductCategoryID,
ProductName,
ProductType,
ProductCategory,
ProductRetailPrice,
ProductWholesalePrice,
ProductCost,
ProductRetailProfit,
ProductWholesaleUnitProfit,
ProductProfitMarginUnitPercent 
)
VALUES
( 
     -1
    ,-1
    ,-1
    ,-1
    ,'Unknown'
    ,'Unknown'
    ,'Unknown'
    ,-1
    ,-1
    ,-1
    ,-1
    ,-1
    ,-1
        
);

SELECT * FROM Dim_Product;

--Load characters
INSERT INTO Dim_Product
(DimProductID,
ProductID,
ProductTypeID,
ProductCategoryID,
ProductName,
ProductType,
ProductCategory,
ProductRetailPrice,
ProductCost,
ProductWholesalePrice,
ProductRetailProfit,
ProductWholesaleUnitProfit,
ProductProfitMarginUnitPercent 
)
    SELECT 
     STAGE_Product.ProductID as DimProductID
    ,STAGE_Product.ProductID 
    ,STAGE_ProductType.ProductTypeID
    ,STAGE_ProductCategory.ProductCategoryID
    ,STAGE_Product.Product as ProductName
    ,STAGE_ProductType.ProductType as ProductType
    ,STAGE_PRODUCTCATEGORY.PRODUCTCATEGORY as PRODUCTCATEGORY
    ,STAGE_Product.Price as ProductRetailPrice
    ,STAGE_Product.Cost as ProductCost 
    ,STAGE_Product.WholesalePrice as ProductWholesalePrice
    ,STAGE_Product.Price - STAGE_Product.Cost as ProductRetailProfit
    ,STAGE_Product.WholesalePrice - STAGE_Product.Cost as ProductWholesaleUnitProfit
    ,ROUND(((Stage_Product.Price - Stage_Product.Cost) / Stage_Product.Price), 2) as PRODUCTPROFITMARGINUNITPERCENT
    FROM STAGE_PRODUCT
    LEFT JOIN STAGE_PRODUCTTYPE on STAGE_PRODUCT.PRODUCTTYPEID = STAGE_PRODUCTTYPE.PRODUCTTYPEID
    LEFT JOIN STAGE_PRODUCTCATEGORY on STAGE_PRODUCTTYPE.PRODUCTCATEGORYID = STAGE_PRODUCTCATEGORY.PRODUCTCATEGORYID

    

SELECT * FROM Dim_Product;

--CREATE TABLE DIM_LOCATION

CREATE OR REPLACE TABLE Dim_Location(
    DimLocationID INTEGER IDENTITY(1,1) CONSTRAINT PK_DimLocationID PRIMARY KEY NOT NULL --Surrogate Key
    ,Address VARCHAR(255) NOT NULL
    ,City VARCHAR(255) NOT NULL
    ,PostalCode VARCHAR(255) NOT NULL
    ,State_Province VARCHAR(255) NOT NULL
    ,Country VARCHAR(50) NOT NULL
);

SELECT * FROM Dim_Location;

INSERT INTO Dim_Location
(
    DimLocationID
    ,Address
    ,City
    ,PostalCode
    ,State_Province
    ,Country
)
VALUES
( 
    -1
    ,'Unknown'
    ,'Unknown'
    ,'Unknown'
    ,'Unknown'
    ,'Unknown'
);

SELECT * FROM Dim_Location;

--Load rows from reseller, customer, and store
INSERT INTO Dim_Location
(
    Address
    ,City
    ,PostalCode
    ,State_Province
    ,Country
)
SELECT 
    Address
    ,City
    ,PostalCode
    ,StateProvince AS State_Province
    ,Country
     
	FROM STAGE_RESELLER

    UNION

    SELECT 
    Address
    ,City
    ,PostalCode
    ,StateProvince AS State_Province
    ,Country
     
	FROM STAGE_Customer

    UNION

    SELECT 
    Address
    ,City
    ,PostalCode
    ,StateProvince AS State_Province
    ,Country

    FROM STAGE_Store;

SELECT * FROM Dim_Location;

--CREATE TABLE DIM_STORE
CREATE OR REPLACE TABLE Dim_Store(
    DimStoreID INTEGER IDENTITY(1,1) CONSTRAINT PK_DimStoreID PRIMARY KEY NOT NULL --Surrogate Key
    ,DimLocationID INTEGER CONSTRAINT FK_DimLocationIDCustomer FOREIGN KEY REFERENCES Dim_Location (DimLocationID) NOT NULL --Foreign Key
    ,SourceStoreID INTEGER NOT NULL
    ,StoreNumber INTEGER NOT NULL
    ,StoreManager VARCHAR(255) NOT NULL
);

SELECT * FROM Dim_Store;


INSERT INTO Dim_Store
(
    DimStoreID
    ,DimLocationID
    ,SourceStoreID
    ,StoreNumber
    ,StoreManager
)
VALUES
( 
     -1
    ,-1
    ,-1
    ,-1
    ,'Unknown'
);

SELECT * FROM Dim_Store;

INSERT INTO Dim_Store
(
    DimLocationID
    ,SourceStoreID
    ,StoreNumber
    ,StoreManager
)
SELECT 
    Dim_Location.DimLocationID
    ,Stage_Store.StoreID AS SourceStoreID
    ,Stage_Store.StoreNumber AS StoreNumber
    ,Stage_Store.StoreManager AS StoreManager
FROM Stage_Store
INNER JOIN Dim_Location ON
Dim_Location.Address = Stage_Store.Address;

SELECT * FROM Dim_Store;

--CREATE TABLE DIM_RESELLER
CREATE OR REPLACE TABLE Dim_Reseller(
    DimResellerID INTEGER IDENTITY(1,1) CONSTRAINT PK_DimResellerID PRIMARY KEY NOT NULL --Surrogate Key
    ,DimLocationID INTEGER CONSTRAINT FK_DimLocationIDCustomer FOREIGN KEY REFERENCES Dim_Location (DimLocationID) NOT NULL --Foreign Key
    ,SourceResellerID VARCHAR(255) NOT NULL
    ,ResellerName VARCHAR(255) NOT NULL
    ,ContactName VARCHAR(255) NOT NULL
    ,PhoneNumber STRING NOT NULL
    ,Email VARCHAR(255) NOT NULL
);

SELECT * FROM Dim_Reseller;


INSERT INTO Dim_Reseller
(
    DimResellerID
    ,DimLocationID
    ,SourceResellerID
    ,ResellerName
    ,ContactName
    ,PhoneNumber
    ,Email
)
VALUES
( 
     -1
    ,-1
    ,'Unknown' 
    ,'Unknown'
    ,'Unknown'
    ,'Unknown'
    ,'Unknown'
);

SELECT * FROM Dim_Reseller;

INSERT INTO Dim_Reseller
(
    DimLocationID
    ,SourceResellerID
    ,ResellerName
    ,ContactName
    ,PhoneNumber
    ,Email
)
SELECT 
    Dim_Location.DimLocationID
    ,Stage_Reseller.ResellerID AS SourceResellerID
    ,Stage_Reseller.ResellerName AS ResellerName
    ,Stage_Reseller.Contact AS ContactName
    ,Stage_Reseller.PhoneNumber AS PhoneNumber
    ,Stage_Reseller.EmailAddress AS Email
FROM Stage_Reseller
INNER JOIN Dim_Location ON
Dim_Location.Address = Stage_Reseller.Address;

SELECT * FROM Dim_Reseller;

--CREATE TABLE DIM_CUSTOMER
CREATE OR REPLACE TABLE Dim_Customer(
    DimCustomerID INTEGER IDENTITY(1,1) CONSTRAINT PK_DimCustomerID PRIMARY KEY NOT NULL --Surrogate Key
    ,DimLocationID INTEGER CONSTRAINT FK_DimLocationIDCustomer FOREIGN KEY REFERENCES Dim_Location (DimLocationID) NOT NULL --Foreign Key
    ,SourceCustomerID VARCHAR(255) NOT NULL
    ,CustomerFullName VARCHAR(255) NOT NULL
    ,CustomerFirstName VARCHAR(255) NOT NULL
    ,CustomerLastName VARCHAR(255) NOT NULL
    ,CustomerGender VARCHAR(255) NOT NULL
);

SELECT * FROM Dim_Customer;


INSERT INTO Dim_Customer
(
    DimCustomerID
    ,DimLocationID
    ,SourceCustomerID
    ,CustomerFullName
    ,CustomerFirstName
    ,CustomerLastName
    ,CustomerGender
  
)
VALUES
( 
     -1
    ,-1
    ,'Unknown' 
    ,'Unknown'
    ,'Unknown'
    ,'Unknown'
    ,'Unknown'
    
);

SELECT * FROM Dim_Customer;

INSERT INTO Dim_Customer
(
    DimLocationID
    ,SourceCustomerID
    ,CustomerFullName
    ,CustomerFirstName
    ,CustomerLastName
    ,CustomerGender
    
)
SELECT 
    Dim_Location.DimLocationID
    ,Stage_Customer.CustomerID AS SourceCustomerID
    ,CONCAT(Stage_Customer.FirstName,SPACE(1),Stage_Customer.LastName) AS CustomerFullName
    ,Stage_Customer.FirstName AS CustomerFirstName
    ,Stage_Customer.LastName AS CustomerLastName
    ,Stage_Customer.Gender AS CustomerGender
FROM Stage_Customer
INNER JOIN Dim_Location ON
Dim_Location.Address = Stage_Customer.Address;

SELECT * FROM Dim_Customer;

--CREATE TABLE DIM_CHANNEL
CREATE OR REPLACE TABLE Dim_Channel(
    DimChannelID INTEGER IDENTITY(1,1) CONSTRAINT PK_DimChannelID PRIMARY KEY NOT NULL --Surrogate Key
    ,SourceChannelID INTEGER NOT NULL
    ,SourceChannelCategoryID INTEGER NOT NULL
    ,ChannelName VARCHAR(255) NOT NULL
    ,ChannelCategory VARCHAR(255) NOT NULL
);

SELECT * FROM Dim_Channel;


INSERT INTO Dim_Channel
(
    DimChannelID
    ,SourceChannelID
    ,SourceChannelCategoryID
    ,ChannelName
    ,ChannelCategory
)
VALUES
( 
     -1
    ,-1
    ,-1
    ,'Unknown' 
    ,'Unknown'
);

SELECT * FROM Dim_Channel;

INSERT INTO Dim_Channel
(
    SourceChannelID
    ,SourceChannelCategoryID
    ,ChannelName
    ,ChannelCategory
)
SELECT 
    Stage_Channel.ChannelID AS SourceChannelID
    ,Stage_Channel.ChannelCategoryID AS SourceChannelCategoryID
    ,Stage_Channel.Channel AS ChannelName
    ,Stage_ChannelCategory.ChannelCategory AS ChannelCategory
FROM Stage_Channel
INNER JOIN Stage_ChannelCategory ON
Stage_ChannelCategory.ChannelCategoryID = Stage_Channel.ChannelCategoryID

SELECT * FROM Dim_Channel;





