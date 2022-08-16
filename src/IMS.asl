/*
 * ASL specification of the Invoice Management System (IMS)
 */

Package ims

/********************************************************
    System definition 
*********************************************************/

System IMS "Invoice Management System" : Application : Application_Web

/********************************************************
    Entities 
*********************************************************/

DataEntity e_VAT "VAT Category" : Reference [
    attribute VATCode "VAT code" : String [constraints (PrimaryKey NotNull Unique)]
    attribute VATName "VAT name" : String
    attribute VATValue "VAT value" : String
    
    constraints ( showAs(VATName) )
]

DataEntity e_Product "Product" : Master [
    attribute ID "Product ID" : Integer [constraints (PrimaryKey NotNull Unique)]
    attribute vatCode "VAT code" : Integer [ constraints (NotNull ForeignKey(e_VAT)) ]
    attribute productName "Name" : String(100)
    attribute valueWithoutVAT "Value Without VAT" : Decimal(16.2) [constraints (NotNull)]
    attribute valueWithVAT "Value With VAT" : Decimal(16.2) [constraints (NotNull)]
    attribute VATValue "VAT value" : Decimal [ formula arithmetic (e_VAT.VATValue) ]
    
    constraints ( showAs(productName) )
]

DataEntity e_Customer "Customer" : Master [
    attribute ID "Customer ID" : Integer [constraints (PrimaryKey NotNull Unique)]
    attribute customerName "Name" : String(100)
    attribute fiscalID "Fiscal ID" : String(9)
    attribute logoImage "Logo image" : Image
    attribute address "Address" : String(200)
    attribute IBAN "IBAN" : String(34)
    attribute SWIFT "SWIFT" : String(8)
    
    constraints ( showAs(customerName) )
]

DataEntity e_CustomerVIP "CustomerVIP" : Master [
    attribute ID "CustomerVIP ID" : Integer [constraints (PrimaryKey NotNull Unique)]
    attribute customerID "Customer ID" : Integer [ constraints (NotNull ForeignKey(e_Customer)) ]
    attribute discountRate "Discount rate" : Integer
]

DataEntity e_Invoice "Invoice" : Document [
    attribute ID "Invoice ID" : Integer [constraints (PrimaryKey NotNull Unique)]
    attribute type "Type" : DataEnumeration enum_DocumentType
    attribute customerID "Customer ID" : Integer [ constraints (NotNull ForeignKey(e_Customer)) ]
    attribute dateCreation "Creation Date" : Date [defaultValue "today" constraints (NotNull)]
    attribute dateApproval "Approval Date" : Date
    attribute datePaid "Payment Date" : Date
    attribute dateDeleted "Delete Date" : Date
    attribute isApproved "Is Approved" : Boolean [defaultValue "False"]
    attribute totalValueWithoutVAT "Total Value Without VAT" : Decimal(16.2) [
        formula details : sum (e_InvoiceLine.valueWithoutVAT)
        constraints (NotNull)
    ]
    attribute totalValueWithVAT "Total Value With VAT" : Decimal(16.2) [
        formula details : sum (e_InvoiceLine.valueWithVAT)
        constraints (NotNull)
    ]
    attribute totalInvoiceLines "Total invoice lines" : Integer [
        formula details : count (e_InvoiceLine)
    ]
    
    constraints ( showAs(ID) )
]

DataEntity e_InvoiceLine "InvoiceLine" : Document [
    attribute ID "InvoiceLine ID" : Integer [constraints (PrimaryKey NotNull Unique)]
    attribute invoiceID "Invoice ID" : Integer    [constraints (NotNull ForeignKey(e_Invoice))]
    attribute productID "Product ID" : Integer [constraints (NotNull ForeignKey(e_Product))]
    attribute order "InvoiceLine Order" : Integer [constraints (NotNull)]
    attribute valueWithoutVAT "Value Without VAT" : Decimal
    attribute valueWithVAT "Value With VAT" : Decimal [
        formula arithmetic (e_InvoiceLine.valueWithoutVAT * e_Product.VATValue)
    ]
    
    constraints ( showAs(order) )
]

/********************************************************
    Actors & Use Cases
*********************************************************/

Actor aU_TechnicalAdmin "TechnicalAdmin" : User [ description "Admin manage Users, VAT, etc." ]
Actor aU_Operator "Operator" : User [ description "Operator manages Invoices and Customers" ]
Actor aU_Manager "Manager" : User [ description "Manager approves Invoices, etc." ]
Actor aU_Customer "Customer" : User [ description "Customer receives Invoices to pay" ]

// TechnicalAdmin

UseCase uc_Manage_Products "Manage Products" : EntitiesManage [
	actorInitiates aU_TechnicalAdmin
	dataEntity e_Product
	actions aCreate, aRead, aUpdate, aDelete
]

UseCase uc_Manage_VAT_Categories "Manage VAT Categories" : EntitiesManage [
	actorInitiates aU_TechnicalAdmin
	dataEntity e_VAT
	actions aCreate, aRead, aUpdate, aDelete
]

// Operator

UseCase uc_Manage_Invoices "Manage Customers" : EntitiesManage [
	actorInitiates aU_Operator
	dataEntity e_Customer
	actions aCreate, aRead, aUpdate, aDelete
]

UseCase uc_Manage_Invoices "Manage Invoices" : EntitiesManage [
	actorInitiates aU_Operator
	dataEntity e_Invoice
	actions aCreate, aRead, aUpdate, aDelete
]

// Manager

UseCase uc_Manage_Products "Approve Invoices" : EntitiesManage [
	actorInitiates aU_Manager
	dataEntity e_Invoice
	actions aRead
	extensionPoints aApprove
]

// Customer

UseCase uc_Manage_Invoices "Browse Invoices" : EntitiesBrowse [
	actorInitiates aU_Customer
	dataEntity e_Invoice
	actions aRead
	extensionPoints aPay
]

/********************************************************
    Data enumerations
*********************************************************/

DataEnumeration enum_DocumentType "Document Type" values (
    SI "Standard Invoice",
    CI "Credit Invoice",
    DI "Debit Invoice",
    MI "Mixed Invoice"
)
