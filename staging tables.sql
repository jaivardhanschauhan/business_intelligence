CREATE or REPLACE DATABASE IMT577_DW_JAIVARDHAN_CHAUHAN_STAGE

CREATE OR REPLACE WAREHOUSE "IMT577_DW_JAIVARDHAN_CHAUHAN_STAGE" WITH WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 600 AUTO_RESUME = TRUE COMMENT = '';

CREATE or REPLACE STAGE "IMT577_DW_JAIVARDHAN_CHAUHAN_STAGE"."PUBLIC"."STAGE_ITSESSION"

CREATE OR REPLACE FILE FORMAT CSV_SKIP_HEADER
type = 'CSV'
field_delimiter = ','
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
skip_header = 1;

CREATE OR REPLACE FILE FORMAT CSV_SKIP_HEADER_DATE
type = 'CSV'
field_delimiter = ','
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
skip_header = 1
date_format = 'MM/DD/YY';

IMT577_DW_JAIVARDHAN_CHAUHAN_STAGE.PUBLIC.STAGE_CHANNEL

CREATE OR REPLACE TABLE STAGE_CHANNEL (
    ChannelID NUMBER(38,0),
    ChannelCategoryID NUMBER(38,0),
    Channel VARCHAR(255),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255)
);

CREATE OR REPLACE TABLE STAGE_ChannelCategory (
    ChannelCategoryID NUMBER(38,0),
    ChannelCategory VARCHAR(255),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255)
);

CREATE OR REPLACE TABLE STAGE_Customer (
    CustomerID VARCHAR(255),
    SubSegmentID NUMBER(38, 0),
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    Gender VARCHAR(50),
    EmailAddress VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    StateProvince VARCHAR(255),
    Country VARCHAR(255),
    PostalCode VARCHAR(255),
    PhoneNumber VARCHAR(255),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255)
);

CREATE OR REPLACE TABLE STAGE_Product (
    ProductID NUMBER(38,0),
    ProductTypeID NUMBER(38,0),
    Product VARCHAR(255),
    Color VARCHAR(255),
    Style VARCHAR(255),
    UnitofMeasureID NUMBER(38,0),
    Weight NUMBER(38,4),
    Price NUMBER(38,4),
    Cost NUMBER(38,4),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255),
    WholesalePrice NUMBER(38,4)  
);

CREATE OR REPLACE TABLE STAGE_PRODUCTCATEGORY (
    ProductCategoryID NUMBER(38,0),
    ProductCategory VARCHAR(255),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255)
);

CREATE OR REPLACE TABLE STAGE_Reseller (
    ResellerID VARCHAR(50),
    Contact VARCHAR(255),
    EmailAddress VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    StateProvince VARCHAR(255),
    Country VARCHAR(255),
    PostalCode VARCHAR(50),
    PhoneNumber VARCHAR(50),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255),
    ResellerName VARCHAR(255)
);


CREATE or REPLACE TABLE STAGE_ProductType (
    ProductTypeID NUMBER(38,0),
    ProductCategoryID NUMBER(38,0),
    ProductType VARCHAR(255),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255)
);

CREATE or REPLACE TABLE STAGE_SalesDetail (
    SalesDetailID NUMBER(38,0),
    SalesHeaderID NUMBER(38,0),
    ProductID NUMBER(38,0),
    SalesQuantity NUMBER(38,0),
    SalesAmount NUMBER(38,2),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255)
);

CREATE or REPLACE TABLE STAGE_SalesHeader (
    SalesHeaderID NUMBER(38,0),
    Date VARCHAR(255),
    ChannelID NUMBER(38,0),
    StoreID VARCHAR(50),
    CustomerID VARCHAR(50),
    ResellerID VARCHAR(50),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255)
);

CREATE or REPLACE TABLE STAGE_Segment (
    SegmentID NUMBER(38,0),
    Segment VARCHAR(255),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255)
);

CREATE or REPLACE TABLE STAGE_Store (
    StoreID NUMBER(38,0),
    SubSegmentID NUMBER(38,0),
    StoreNumber NUMBER(38,0),
    StoreManager VARCHAR(255),
    Address VARCHAR(255),
    City VARCHAR(255),
    StateProvince VARCHAR(255),
    Country VARCHAR(255),
    PostalCode VARCHAR(50),
    PhoneNumber VARCHAR(50),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255)
);

CREATE or REPLACE TABLE STAGE_SubSegment (
    SubSegmentID NUMBER(38,0),
    SegmentID NUMBER(38,0),
    SubSegment VARCHAR(255),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255)
);

CREATE or REPLACE TABLE STAGE_SalesTarget (
    Year NUMBER(38,0),
    ChannelName VARCHAR(255),
    TargetName VARCHAR(255),
    TargetSalesAmount NUMBER(38,0)
);

CREATE or REPLACE TABLE STAGE_SalesTargetProduct (
    ProductID NUMBER(38,0),
    Product VARCHAR(255),
    Year NUMBER(38,0),
    SalesQuantityTarget NUMBER(38,0)
);

CREATE or REPLACE TABLE STAGE_UnitOfMeasure (
    UnitOfMeasureID NUMBER(38,0),
    UnitOfMeasure VARCHAR(255),
    CreatedDate VARCHAR(255),
    CreatedBy VARCHAR(255),
    ModifiedDate VARCHAR(255),
    ModifiedBy VARCHAR(255)
);

