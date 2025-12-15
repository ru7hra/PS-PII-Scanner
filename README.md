**PS-PII-Scanner** is a PowerShell-based **Personally Identifiable Information (PII) scanning tool** designed to detect sensitive data such as **Email IDs, PAN numbers, Aadhaar numbers, and phone numbers** across files and documents.

It helps organizations and individuals perform **data privacy audits**, **compliance checks**, and **security assessments** by identifying exposed personal data stored in file systems.

---

## 📌 Key Highlights

* Built entirely in **PowerShell (PS 5 compatible)**
* Supports **Indian PII formats** (PAN & Aadhaar)
* Optional **PII masking (tokenization)**
* Generates **CSV reports** for audit evidence
* Works **offline** – no data exfiltration
* No third-party dependencies

---

## 🚀 Features

### 🔎 PII Detection

* **Email Addresses**
* **Indian PAN Numbers**
* **Indian Aadhaar Numbers**

  * Validated using the **Verhoeff checksum algorithm**
* **Indian Mobile Phone Numbers**

---

### 📁 File Types Supported

* Text & data files:

  * `.txt`, `.csv`, `.xml`, `.json`
* Microsoft Office documents:

  * `.docx`
  * `.xlsx`
  * `.pptx`

---

### 🛡️ Security & Privacy

* **Read-only scanning**
* No modification of original files
* Optional **PII tokenization (masking)**
* Fully **offline execution**

---

### 📊 Reporting

* Exports results to **CSV**
* Includes:

  * File path
  * PII type
  * Masked or raw PII value
  * File creation & modification timestamps
  * File owner
  * Per-file scan time
  * Error details (if any)

---

### 📈 Usability

* Folder selection via **GUI dialog** (with CLI fallback)
* CSV save dialog
* **Real-time progress bar**
* Estimated time remaining (ETA)

---

## 🧠 What PS-PII-Scanner Can Do

✔ Identify sensitive personal data exposure
✔ Assist with **GDPR, DPDP, ISO 27001, SOC2** compliance
✔ Detect hard-coded or exported PII in documents
✔ Support internal audits and data discovery exercises
✔ Provide structured reports for governance teams

---

## 🎯 Why This Tool Exists

Sensitive personal data often ends up in:

* Shared drives
* Email exports
* Reports and spreadsheets
* Logs and backups

**PS-PII-Scanner** was created to:

* Automate PII discovery
* Reduce manual audit effort
* Improve data privacy posture
* Offer an **open-source alternative** to costly DLP tools
* Enable fast, transparent, and local scanning

---

## 👥 Intended Users

* Security Engineers
* GRC & Compliance Teams
* Data Protection Officers (DPOs)
* IT Administrators
* Internal & External Auditors
* Developers handling sensitive data

Especially useful for **India-specific compliance use cases**.

---

## ⚙️ Requirements

* Windows OS
* PowerShell 5.x or later
* .NET Framework (pre-installed on Windows)

---

## 🛠️ How It Works (High Level)

1. User selects a folder to scan
2. User selects output CSV location
3. Script recursively scans supported files
4. Extracts text from files (including Office documents)
5. Applies regex-based PII detection
6. Validates Aadhaar using checksum
7. Optionally masks detected PII
8. Writes results to CSV

---

## 📄 CSV Output Format

| Column Name | Description                   |
| ----------- | ----------------------------- |
| FilePath    | Full path of the scanned file |
| PII_Type    | Type of detected PII          |
| PII_Value   | Masked or raw value           |
| Created     | File creation timestamp       |
| Modified    | Last modified timestamp       |
| Owner       | File owner                    |
| ScanSeconds | Time taken to scan the file   |
| Error       | Error message (if any)        |

---

## 📦 Repository Structure

```
PS-PII-Scanner/
│
├── PS-PII-Scanner.ps1
├── README.md
├── LICENSE
└── .gitignore
```

---

## ⚠️ Disclaimer

> **Important Notice**

This tool is intended **only for authorized security testing, compliance audits, and data privacy assessments**.

* You must have **explicit permission** to scan files or systems containing personal data.
* Unauthorized scanning or misuse may violate local or international privacy laws.
* The author assumes **no responsibility or liability** for misuse, data exposure, or legal consequences.

Use responsibly.

---

## 📜 License

This project is licensed under the **MIT License**.

You are free to use, modify, and distribute this tool, provided the license terms are followed.

---

## 🔑 Keywords (SEO)

PII Scanner, PowerShell Security Tool, Aadhaar Scanner, PAN Detection, Data Privacy Audit, DLP Tool, Compliance Automation, Information Security

---

## 👤 Author

Developed by **Ru7hra** & **ITAuditMaverick**
Security | Privacy | Automation
