\# Banking Risk Data Warehouse | SSIS ETL Pipeline



\### SQL Server • SSIS • ETL • Data Quality • Banking Risk Analytics



\## Project Overview



An end-to-end banking risk data engineering project using SQL Server Integration Services (SSIS) and Microsoft SQL Server.



The project demonstrates a \*\*Bronze–Silver–Gold data warehouse architecture\*\*, covering data ingestion, validation, error handling, audit logging, risk classification, and reporting.



\## System Architecture



```text

Customer CSV Files

&#x20;       |

&#x20;       v

BRONZE LAYER

Raw Customer Data

&#x20;       |

&#x20;       v

SILVER LAYER

Data Quality Validation

Conditional Split

Lookup / Duplicate Handling

Rejected Records

ETL Audit Logging

&#x20;       |

&#x20;       v

GOLD LAYER

Customer Risk Classification

Risk Analytics

Reporting Views

```



```mermaid

flowchart TD

&#x20;   A\["Customer CSV Files"] --> B\["SSIS: Load\_Customers\_Bronze"]

&#x20;   B --> C\[("bronze.Customers")]



&#x20;   C --> D\["SSIS: Load\_Customers\_Silver"]

&#x20;   D --> E{"Conditional Split: Data Quality"}



&#x20;   E -->|"Valid Records"| F\["Lookup: Existing Customers"]

&#x20;   E -->|"Invalid Records"| G\["Derived Column: Rejection Reason"]



&#x20;   F -->|"New Customers"| H\[("silver.Customers")]

&#x20;   F -->|"Existing Customers"| I\["Skip Duplicate Insert"]

&#x20;   G --> J\[("audit.RejectedCustomers")]



&#x20;   D -.-> K\[("audit.ETLExecutionLog")]



&#x20;   H --> L\["SSIS: Load\_Customers\_Gold"]

&#x20;   L --> M\["Derived Column: Risk Category"]

&#x20;   M --> N\["Lookup: Existing Gold Customers"]

&#x20;   N -->|"New Customers"| O\[("gold.CustomerRiskSummary")]

&#x20;   N -->|"Existing Customers"| P\["Skip Duplicate Insert"]



&#x20;   O --> Q\["gold.vw\_CustomerRiskAnalytics"]

&#x20;   Q --> R\["Risk Reporting and Portfolio Analytics"]



&#x20;   classDef source fill:#e0f2fe,stroke:#0284c7,color:#075985

&#x20;   classDef bronze fill:#fef3c7,stroke:#d97706,color:#78350f

&#x20;   classDef silver fill:#e5e7eb,stroke:#6b7280,color:#111827

&#x20;   classDef gold fill:#fef08a,stroke:#ca8a04,color:#713f12

&#x20;   classDef audit fill:#fee2e2,stroke:#dc2626,color:#7f1d1d



&#x20;   class A,B source

&#x20;   class C bronze

&#x20;   class H silver

&#x20;   class O,Q,R gold

&#x20;   class G,J,K audit

```



\## Implemented SSIS Packages



| Package | Purpose |

|---|---|

| Load\_Customers\_Bronze.dtsx | Ingest customer CSV data into SQL Server |

| Load\_Customers\_Silver.dtsx | Validate records, handle duplicates, and reject invalid customers |

| Load\_Customers\_Gold.dtsx | Calculate risk categories and load reporting-ready customer data |



\## Key Technical Features



\- SSIS Data Flow and Control Flow

\- OLE DB Sources and Destinations

\- Conditional Split and Derived Column transformations

\- Lookup transformations for duplicate prevention

\- Rejected-record handling

\- SQL Server ETL execution audit logging

\- Bronze–Silver–Gold data modeling

\- Data reconciliation and quality validation

\- SQL reporting views



\## Demonstrated Results



\- \*\*10,001 validated customer records\*\* in Silver

\- \*\*10,001 customer records\*\* in Gold

\- \*\*0 missing customer IDs\*\* in Gold

\- Successful validation of customer risk classifications



\## Customer Risk Segmentation



| Credit Score | Classification |

|---|---|

| 750–850 | Low Risk |

| 650–749 | Medium Risk |

| 300–649 | High Risk |



\*These thresholds are illustrative and are not a production credit risk model.\*



\## Technology Stack



\- Microsoft SQL Server

\- SQL Server Integration Services (SSIS)

\- SQL Server Management Studio (SSMS)

\- Visual Studio 2026

\- T-SQL

\- PowerShell

\- Git and GitHub



\## Planned Enhancements



\- Loan and payment ETL pipelines

\- Portfolio credit exposure analysis

\- Advanced ETL error handling and reconciliation

\- Incremental loading and update handling

\- CI/CD and deployment automation



\## Project Purpose



This project was developed as a practical demonstration of enterprise ETL development, SQL Server data warehousing, data quality controls, and banking risk reporting.

