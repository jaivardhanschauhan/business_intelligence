-- fact sales actual

CREATE OR REPLACE TABLE Fact_SalesActual(
    DimProductID INTEGER CONSTRAINT FK_DimProductID FOREIGN KEY REFERENCES Dim_Product(DimProductID) --Foreign Key
    ,DimStoreID INTEGER CONSTRAINT FK_DimStoreID FOREIGN KEY REFERENCES Dim_Store(DimStoreID) --Foreign Key
    ,DimResellerID INTEGER CONSTRAINT FK_DimResellerID FOREIGN KEY REFERENCES Dim_Reseller(DimResellerID) --Foreign Key
    ,DimCustomerID INTEGER CONSTRAINT FK_DimCustomerID FOREIGN KEY REFERENCES Dim_Customer(DimCustomerID) --Foreign Key
    ,DimChannelID INTEGER CONSTRAINT FK_DimChannelID FOREIGN KEY REFERENCES Dim_Channel(DimChannelID) --Foreign Key
    ,DimSaleDateID NUMBER(9) CONSTRAINT FK_DimTargetDateID FOREIGN KEY REFERENCES Dim_Date(Date_Pkey) --Foreign Key
    ,DimLocationID INTEGER CONSTRAINT FK_DimLocationID FOREIGN KEY REFERENCES Dim_Location(DimLocationID) --Foreign Key
    ,SalesHeaderID INTEGER NOT NULL
    ,SalesDetailID INTEGER NOT NULL
    ,SaleAmount FLOAT NOT NULL
    ,SaleQuantity FLOAT NOT NULL
    ,SaleUnitPrice FLOAT NOT NULL
    ,SaleExtendedCost FLOAT NOT NULL
    ,SaleTotalProfit FLOAT NOT NULL
);

SELECT * FROM Fact_SalesActual;

INSERT INTO Fact_SalesActual
(
    DimProductID
    ,DimStoreID
    ,DimResellerID
    ,DimCustomerID 
    ,DimChannelID
    ,DimSaleDateID
    ,DimLocationID
    ,SalesHeaderID
    ,SalesDetailID
    ,SaleAmount
    ,SaleQuantity
    ,SaleUnitPrice
    ,SaleExtendedCost
    ,SaleTotalProfit
)
SELECT DISTINCT 
    NVL(Dim_Product.DimProductID,-1) as DimProductID,
    NVL(Dim_Store.DimStoreID,-1) as DimStoreID,
    NVL(Dim_Reseller.DimResellerID,-1) as DimResellerID,
    NVL(Dim_Customer.DimCustomerID,-1) as DimCustomerID,
    NVL(Dim_Channel.DimChannelID,-1) as DimChannelID,
    Dim_Date.DATE_PKEY as DimSaleDateID,
    NVL(Dim_Location.DimlocationID,-1) as DimlocationID,
    STAGE_SalesHeader.SalesHeaderID,
    STAGE_SalesDetail.SalesDetailID,
    STAGE_SalesDetail.SalesAmount as SaleAmount,
    STAGE_SalesDetail.SalesQuantity as SaleQuantity,
    STAGE_SalesDetail.SalesAmount/STAGE_SalesDetail.SalesQuantity as SaleUnitPrice,
    (STAGE_SalesDetail.SalesQuantity * Dim_Product.ProductCost) as SaleExtendedCost,
    STAGE_SalesDetail.SalesAmount - (Dim_Product.ProductCost * STAGE_SalesDetail.SalesQuantity) as SaleTotalProfit
    FROM STAGE_SalesHeader
    LEFT JOIN STAGE_SalesDetail ON STAGE_SalesHeader.SalesHeaderID = STAGE_SalesDetail.SalesHeaderID
    LEFT JOIN Dim_Product ON STAGE_SalesDetail.ProductID = Dim_Product.ProductID
    LEFT JOIN Dim_Store ON STAGE_SalesHeader.StoreID = Dim_Store.SourceStoreID
    LEFT JOIN Dim_Reseller ON STAGE_SalesHeader.ResellerID = Dim_Reseller.SOURCERESELLERID
    LEFT JOIN Dim_Customer ON STAGE_SalesHeader.CustomerID = Dim_Customer.SOURCECUSTOMERID
    LEFT JOIN Dim_Channel ON STAGE_SalesHeader.ChannelID = Dim_Channel.SOURCECHANNELID
    LEFT JOIN Dim_Date ON TO_DATE(STAGE_SalesHeader.DATE,'MM/DD/YY')  = Dim_Date.DATE
    LEFT JOIN Dim_Location ON Dim_Store.DimLocationID = Dim_Location.DimLocationID
    OR Dim_Reseller.DimLocationID = Dim_Location.DimLocationID
    OR Dim_Customer.DimLocationID = Dim_Location.DimLocationID;

SELECT * FROM Fact_SalesActual
ORDER by DIMPRODUCTID;

--SRC Sales Target

CREATE OR REPLACE TABLE Fact_SRCSalesTarget(
    DimStoreID INTEGER CONSTRAINT FK_DimStoreID FOREIGN KEY REFERENCES Dim_Store(DimStoreID) --Foreign Key
    ,DimResellerID INTEGER CONSTRAINT FK_DimResellerID FOREIGN KEY REFERENCES Dim_Reseller(DimResellerID) --Foreign Key
    ,DimChannelID INTEGER CONSTRAINT FK_DimChannelID FOREIGN KEY REFERENCES Dim_Channel(DimChannelID) --Foreign Key
    ,DimTargetDateID NUMBER(9) CONSTRAINT FK_DimTargetDateID FOREIGN KEY REFERENCES Dim_Date(Date_Pkey) --Foreign Key
    ,SalesTargetAmount FLOAT NOT NULL
);

SELECT * FROM Fact_SRCSalesTarget;

INSERT INTO Fact_SRCSalesTarget
(
    DimStoreID
    ,DimResellerID
    ,DimChannelID
    ,DimTargetDateID
    ,SalesTargetAmount
)
SELECT DISTINCT
        NVL(Dim_Store.DimStoreID, -1) AS DimStoreID
        ,NVL(Dim_Reseller.DimResellerID, -1) AS DimResellerID
        ,NVL(Dim_Channel.DimChannelID, -1)AS DimChannelID
        ,Dim_Date.Date_Pkey AS DimTargetDateID
        ,Stage_SalesTarget.TargetSalesAmount/365 AS SalesTargetAmount
	FROM STAGE_SALESTARGET
    
    INNER JOIN Dim_Date ON
    Dim_Date.Year = Stage_SalesTarget.Year
    
    INNER JOIN Dim_Channel ON
    Dim_Channel.ChannelName = 
    CASE 
        WHEN Stage_SalesTarget.ChannelName = 'Online' THEN 'On-line' 
        ELSE Stage_SalesTarget.ChannelName
    END
    
    LEFT JOIN Dim_Reseller ON
    Dim_Reseller.ResellerName = Stage_SalesTarget.TargetName
    LEFT JOIN Dim_Store ON
    Dim_Store.StoreNumber = 
    CASE
        WHEN Stage_SalesTarget.TargetName = 'Store Number 5' THEN 5
        WHEN Stage_SalesTarget.TargetName = 'Store Number 8' THEN 8
        WHEN Stage_SalesTarget.TargetName = 'Store Number 10' THEN 10
        WHEN Stage_SalesTarget.TargetName = 'Store Number 21' THEN 21
        WHEN Stage_SalesTarget.TargetName = 'Store Number 34' THEN 34
        WHEN Stage_SalesTarget.TargetName = 'Store Number 39' THEN 39
    END;
    
SELECT * FROM Fact_SRCSalesTarget;

-- FACT_PRODUCTSALESTARGET
CREATE OR REPLACE TABLE Fact_ProductSalesTarget(
    DimProductID INTEGER CONSTRAINT FK_DimProductID FOREIGN KEY REFERENCES Dim_Product(DimProductID) --Foreign Key
    ,DimTargetDateID NUMBER(9) CONSTRAINT FK_DimTargetDateID FOREIGN KEY REFERENCES Dim_Date(Date_Pkey) --Foreign Key
    ,ProductTargetSalesQuantity FLOAT NOT NULL
);

SELECT * FROM Fact_ProductSalesTarget;

INSERT INTO Fact_ProductSalesTarget
(
    DimProductID
    ,DimTargetDateID
    ,ProductTargetSalesQuantity
)
SELECT DISTINCT
        NVL(Dim_Product.DimProductID, -1) AS DimProductID
        ,Dim_Date.Date_Pkey AS DimTargetDateID
        ,ROUND(Stage_Salestargetproduct.SalesQuantityTarget/365) AS ProductTargetSalesQuantity
	FROM Stage_Salestargetproduct
    INNER JOIN Dim_Date ON
    Dim_Date.Year = Stage_Salestargetproduct.Year
    LEFT JOIN Dim_Product ON
    Dim_Product.ProductID = Stage_Salestargetproduct.ProductID;

SELECT * FROM FACT_PRODUCTSALESTARGET;
  
    

  
   