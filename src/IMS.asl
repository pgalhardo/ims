/*
 * Author: Pedro Miguel da Silva Galhardo
 * Date: September/2021
 * 
 * Specification, in ASL, of an electronic invoicing system
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
]

DataEntity e_Product "Product" : Master [
	attribute ID "Product ID" : Integer [constraints (PrimaryKey NotNull Unique)]
	attribute vatCode "VAT code" : Integer [ constraints (NotNull ForeignKey(e_VAT)) ]
	attribute productName "Name" : String(100)
	attribute valueWithoutVAT "Value Without VAT" : Decimal(16.2) [constraints (NotNull)]
	attribute valueWithVAT "Value With VAT" : Decimal(16.2) [constraints (NotNull)]
	attribute VATValue "VAT value" : Decimal [ formula arithmetic (e_VAT.VATValue) ]
]

DataEntity e_Customer "Customer" : Master [
	attribute ID "Customer ID" : Integer [constraints (PrimaryKey NotNull Unique)]
	attribute customerName "Name" : String(100)
	attribute fiscalID "Fiscal ID" : String(9)
	attribute logoImage "Logo image" : Image
	attribute address "Address" : String(200)
	attribute IBAN "IBAN" : String(34)
	attribute SWIFT "SWIFT" : String(8)
]

DataEntity e_CustomerVIP "CustomerVIP" : Master [
	attribute ID "CustomerVIP ID" : Integer [constraints (PrimaryKey NotNull Unique)]
	attribute customerID "Customer ID" : Integer [ constraints (NotNull ForeignKey(e_Customer)) ]
	attribute discountRate "Discount rate" : Integer
]

DataEntity e_Invoice "Invoice" : Document [
	attribute ID "Invoice ID" : Integer [constraints (PrimaryKey NotNull Unique)]
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
]

DataEntity e_InvoiceLine "InvoiceLine" : Document [
	attribute ID "InvoiceLine ID" : Integer [constraints (PrimaryKey NotNull Unique)]
	attribute invoiceID "Invoice ID" : Integer  [constraints (NotNull ForeignKey(e_Invoice))]
	attribute productID "Product ID" : Integer [constraints (NotNull ForeignKey(e_Product))]
	attribute order "InvoiceLine Order" : Integer [constraints (NotNull)]
	attribute valueWithoutVAT "Value Without VAT" : Decimal
	
	attribute valueWithVAT "Value With VAT" : Decimal [
		formula arithmetic (e_InvoiceLine.valueWithoutVAT * e_Product.VATValue)
	]

	//check ck_InvoiceLine1 "isUnique(invoiceID+order)"
]

/********************************************************
   Forms
*********************************************************/

// INVOICE

UIContainer uiCt_InvoiceCreator : Window [
  component uiCo_CreateInvoice "Invoice" : Form [
    dataBinding e_Invoice
	
	part client "Client" : Field : Field_Input
		[ dataAttributeBinding e_Customer.customerName ]
	part dateCreation "Creation Date" : Field : Field_Input
		[ dataAttributeBinding e_Invoice.dateCreation ]
	part dateApproval "Approval Date" : Field : Field_Input
		[ dataAttributeBinding e_Invoice.dateApproval ]
	part datePaid "Payment Date" : Field : Field_Input
		[ dataAttributeBinding e_Invoice.datePaid ]
	part dateDeleted "Delete Date" : Field : Field_Input
		[ dataAttributeBinding e_Invoice.dateDeleted ]
	part totalValueWithoutVAT "Total Value Without VAT" : Field : Field_Input
		[ dataAttributeBinding e_Invoice.totalValueWithoutVAT ]
	part totalValueWithVAT "Total Value With VAT" : Field : Field_Input
		[ dataAttributeBinding e_Invoice.totalValueWithVAT ]
      
    event ev_cancel "Back" : Submit : Submit_Back
      [ navigationFlowTo Invoices ]
      
    event ev_save "Save" : Submit : Submit_Create
      [ navigationFlowTo Invoices ]
  ]
]

UIContainer uiCt_InvoiceReader : Window [
  component uiCo_ReadInvoice "Invoice" : Form [
    dataBinding e_Invoice
    
    part client "Client" : Field : Field_Output
      [ dataAttributeBinding e_Customer.customerName ]
    part dateCreation "Creation Date" : Field : Field_Output
      [ dataAttributeBinding e_Invoice.dateCreation ]
    part dateApproval "Approval Date" : Field : Field_Output
      [ dataAttributeBinding e_Invoice.dateApproval ]
    part datePaid "Payment Date" : Field : Field_Output
      [ dataAttributeBinding e_Invoice.datePaid ]
    part dateDeleted "Delete Date" : Field : Field_Output
      [ dataAttributeBinding e_Invoice.dateDeleted ]
    part totalValueWithoutVAT "Total Value Without VAT" : Field : Field_Output
      [ dataAttributeBinding e_Invoice.totalValueWithoutVAT ]
    part totalValueWithVAT "Total Value With VAT" : Field : Field_Output
      [ dataAttributeBinding e_Invoice.totalValueWithVAT ]
      
    event ev_cancel "Back" : Submit : Submit_Back
      [ navigationFlowTo Invoices ]	
  ]
]

UIContainer uiCt_InvoiceEditor : Window [
  component uiCo_EditInvoice "Invoice" : Form [
    dataBinding e_Invoice
    
    part client "Client" : Field : Field_Input
		[ dataAttributeBinding e_Customer.customerName ]
	part dateCreation "Creation Date" : Field : Field_Input
		[ dataAttributeBinding e_Invoice.dateCreation ]
	part dateApproval "Approval Date" : Field : Field_Input
		[ dataAttributeBinding e_Invoice.dateApproval ]
	part datePaid "Payment Date" : Field : Field_Input
		[ dataAttributeBinding e_Invoice.datePaid ]
	part dateDeleted "Delete Date" : Field : Field_Input
		[ dataAttributeBinding e_Invoice.dateDeleted ]
	part totalValueWithoutVAT "Total Value Without VAT" : Field : Field_Input
		[ dataAttributeBinding e_Invoice.totalValueWithoutVAT ]
	part totalValueWithVAT "Total Value With VAT" : Field : Field_Input
		[ dataAttributeBinding e_Invoice.totalValueWithVAT ]
      
    event ev_cancel "Back" : Submit : Submit_Back
      [ navigationFlowTo Invoices ]
      
    event ev_save "Save" : Submit : Submit_Update
      [ navigationFlowTo Invoices ]
  ]
]

// CUSTOMER

UIContainer uiCt_CustomerCreator : Window [
	component uiCo_CreateCustomer "Customer" : Form [
		dataBinding e_Customer
			
		part customerName "Name" : Field
			[ dataAttributeBinding e_Customer.customerName ]
		part fiscalID "Fiscal ID" : Field
			[ dataAttributeBinding e_Customer.fiscalID ]
		part logoImage "Logo Image" : Field
			[ dataAttributeBinding e_Customer.logoImage ]
		part address "Address" : Field
			[ dataAttributeBinding e_Customer.address ]
		part IBAN "IBAN" : Field
			[ dataAttributeBinding e_Customer.IBAN ]
		part SWIFT "SWIFT" : Field
			[ dataAttributeBinding e_Customer.SWIFT ]
			
		event ev_cancel "Back" : Submit : Submit_Back
      		[ navigationFlowTo Customers ]
      		
      	event ev_create "Create" : Submit : Submit_Create
      		[ navigationFlowTo Customers ]
	]
]

UIContainer uiCt_CustomerReader : Window [
	component uiCo_ReadCustomer "Customer" : Form [
		dataBinding e_Customer
			
		part customerName "Name" : Field : Field_Output
			[ dataAttributeBinding e_Customer.customerName ]
		part fiscalID "Fiscal ID" : Field : Field_Output
			[ dataAttributeBinding e_Customer.fiscalID ]
		part logoImage "Logo Image" : Field : Field_Output
			[ dataAttributeBinding e_Customer.logoImage ]
		part address "Address" : Field : Field_Output
			[ dataAttributeBinding e_Customer.address ]
		part IBAN "IBAN" : Field : Field_Output
			[ dataAttributeBinding e_Customer.IBAN ]
		part SWIFT "SWIFT" : Field : Field_Output
			[ dataAttributeBinding e_Customer.SWIFT ]
			
		event ev_cancel "Back" : Submit : Submit_Back
      		[ navigationFlowTo Customers ]
	]
]

/********************************************************
   Modules & Menus
*********************************************************/

UIContainer MainPage : Window [
  component TopMenu : Menu : Menu_Main [
    part mg_IMS "Invoice Management System" : Slot : Slot_MenuGroup [
      part mo_Invoices "Invoices" : Slot : Slot_MenuOption [
        event click : Select
          [ navigationFlowTo Invoices ] 
      ]
    ]
  ]
]

UIContainer Invoices "Invoices" : Window [
  component InvoiceList : List : List_Table [
    dataBinding e_Invoice
      [ orderBy e_Invoice.dateCreation DESC ]
  
    part uip_Client : Field : Field_Output
      [ dataAttributeBinding e_Customer.customerName ]
    part uip_dateCreation : Field : Field_Output
      [ dataAttributeBinding e_Invoice.dateCreation ]
    part uip_dateApproval : Field : Field_Output
      [ dataAttributeBinding e_Invoice.dateApproval ]
    part uip_datePaid : Field : Field_Output
      [ dataAttributeBinding e_Invoice.datePaid ]
    part uip_dateDeleted : Field : Field_Output
      [ dataAttributeBinding e_Invoice.dateDeleted ]
    part uip_totalValueWithoutVAT : Field : Field_Output
      [ dataAttributeBinding e_Invoice.totalValueWithoutVAT ]
    part uip_totalValueWithVAT : Field : Field_Output
      [ dataAttributeBinding e_Invoice.totalValueWithVAT ]
  ]
  
  component uiCo_Filter_Invoice : Details
    [ dataBinding e_Invoice ]
				
  component uiCo_Search_Invoice : Details
    [ dataBinding e_Invoice ]
				
  component uiCo_Actions : Menu [ 	
    event ev_read "View Invoice" : Submit : Submit_Read
      [ navigationFlowTo uiCt_InvoiceReader ]
   	event ev_edit "Edit Invoice" : Submit : Submit_Update
      [ navigationFlowTo uiCt_InvoiceEditor ]
  ]
]

UIContainer Customers "Customers" : Window [
  component CustomerList : List : List_Table [
    dataBinding e_Customer
      [ orderBy e_Customer.customerName DESC ]

  ]
  
  component uiCo_Filter_Customer : Details
    [ dataBinding e_Customer ]
				
  component uiCo_Search_Customer : Details
    [ dataBinding e_Customer ]
				
  component uiCo_Actions : Menu [ 	
    event ev_read "View Invoice" : Submit : Submit_Read
      [ navigationFlowTo uiCt_CustomerReader ]
   	event ev_create "Create Invoice" : Submit : Submit_Create
      [ navigationFlowTo uiCt_CustomerCreator ]
  ]
]

/********************************************************
   Actors & Use Cases
*********************************************************/

ContextActor aU_TechnicalAdmin "TechnicalAdmin" : User [
	description "Admin manage Users, VAT, etc."
]
ContextActor aU_Operator "Operator" : User [
	description "Operator manages Invoices and Customers"
]
ContextActor aU_Manager "Manager" : User [
	description "Manager approves Invoices, etc."
]
ContextActor aU_Customer "Customer" : User [
	description "Customer receives Invoices to pay"
]
ContextActor aS_ERP "ERP" : ExternalSystem [
	description "ERP receives info of paid invoices"
]
ContextActor aT_BeginningOfYear : Timer [
	description "Beginning of each Year"
]
ContextActor aT_InvoiceNotPaidAfter30d : Timer [
	description "Invoices not paid after 30d of issue"
]

/********************************************************
   Enumerations
*********************************************************/

DataEnumeration enum_DocType "Tipo de documento"
	values (
		"Fatura",
		"Nota de crédito"
	)

DataEnumeration tipoFact "Tipo de faturação eletrónica"
	values (
		"Não definido",
		"Não usa",
		"Através de plataforma",
		"Automática (integrada)"
	)
	
DataEnumeration estadosf "Estado da integração da faturação eletrónica"
	values (
		"Por submeter",
		"Processamento aceite",
		"Processamento rejeitado",
		"Submetido manualmente",
		"Em processamento",
		"Recebido",
		"Regularização",
		"Devolução",
		"Emissão de pagamento",
		"Pago",
		"Processado",
		"Aceitação da NC"
	)
	
DataEnumeration meioPaga "Forma de pagamento"
	values (
		"Numerário",
		"Cheque",
		"Cartão débito",
		"Cartão crédito",
		"Transferência bancária",
		"Ticket restaurante"
	)
	
DataEnumeration tipoEfac "Tipo de faturação eletrónica automática"
	values (
		"ESPAP",
		"SAPHETY"
	)
	
DataEnumeration platafor "Plataforma de submissão manual"
	values (
		"ILINK"
	)
