# Rent Settlement App

**Feature Document + App Flow + Development Phases + Rough Timeline**

## 1. Product Overview

This app is a **shared rent and bill settlement platform** for **tenants and owners**. Its purpose is to remove confusion, verbal disputes, missing proofs, and messy monthly calculations.

The tenant submits monthly rent details, utility bills, deductions, and proof images. The owner reviews the submission, verifies the proofs, and either approves or rejects it. Once approved, the monthly record is frozen and saved permanently for both parties.

The app is designed to be **simple enough for non-technical and low-literacy users**, using large buttons, minimal text, clear icons, guided steps, and optional local language support.

## 2. Core Goal

The app solves 5 real problems:

* no clear monthly record
* missing or weak proof of bills
* confusion over deductions
* owner/tenant disputes
* no final approved version saved for both sides

## 3. User Roles

### Tenant

The tenant can:

* create monthly rent entries
* add rent amount
* add electricity, water, gas, and other bills
* upload images as proof
* enter manual deductions
* add notes
* submit month to owner
* view status of submissions
* view approved/frozen monthly history

### Owner

The owner can:

* receive month submissions
* review rent and bill entries
* view all proof images
* approve or reject submission
* add rejection reason or comments
* freeze record after approval
* view all approved/frozen history
* get notified on every submission and change

---

## 4. Product Scope

### In Scope for V1

* authentication
* role-based login
* tenant dashboard
* owner dashboard
* monthly record creation
* bill entry
* image proof upload
* manual deduction entry
* monthly submission
* owner approval/rejection
* freeze approved month
* notifications
* monthly history
* user-friendly interface

### Out of Scope for V1

* smart automatic deduction rules
* payment gateway integration
* advanced accounting/reporting
* OCR bill reading
* voice commands
* AI-based validation
* legal digital contracts

That stuff can come later. Don’t bloat version 1.

---

## 5. Main Features

### 5.1 Authentication

Users sign in based on their role:

* Tenant
* Owner

#### Options

* Phone number + OTP
* Email + password

#### Best option

For your target users, **phone number + OTP** is better. Easier and more practical.

---

### 5.2 Role-Based Dashboards

#### Tenant Dashboard

Shows:

* current month status
* create new monthly entry
* pending submissions
* approved months
* rejected months
* notifications

#### Owner Dashboard

Shows:

* pending approvals
* recently approved months
* rejected submissions
* linked properties/tenants
* notifications

---

### 5.3 Monthly Record Creation

The tenant creates a monthly record for a selected month.

#### Main fields

* month
* base rent
* electricity bill amount
* water bill amount
* gas bill amount
* other bill amount
* deduction amount(s)
* reason for deduction
* notes

#### Important

In V1, the split logic stays **manual**.

That means the tenant can enter:

* water bill = 1000
* deduction = 500
* reason = half water share

or

* electricity bill = 6200
* deduction = 4000
* reason = full house electric bill paid

This is better than trying to hardcode every agreement.

---

### 5.4 Bill Proof Upload

For every bill, tenant can upload proof image.

#### Proof types

* electricity bill image
* water bill image
* gas bill image
* payment screenshot
* other proof

#### Proof requirements

* image preview
* re-upload option
* delete before submission
* view full-screen
* timestamp
* linked to bill and month

---

### 5.5 Monthly Summary

Before submission, tenant sees final summary:

* base rent
* all deductions
* total deductions
* final payable amount
* proof attached count
* notes
* submit button

This is the review screen.

---

### 5.6 Submission Flow

When tenant submits:

* record status becomes **Submitted**
* owner receives notification
* tenant cannot silently change submitted record unless owner rejects it

---

### 5.7 Owner Review & Verification

Owner opens submission and reviews:

* month
* rent amount
* all bill entries
* deduction values
* proof images
* notes

Owner can:

* approve
* reject
* add comments

---

### 5.8 Approval and Freeze

When owner approves:

* month status becomes **Approved**
* record becomes **Frozen**
* no edits allowed
* final data is stored for both users
* both users get notification

This is critical.

If approved data can still be edited, the app becomes unreliable.

---

### 5.9 Rejection Flow

If owner rejects:

* status becomes **Rejected**
* owner adds reason
* tenant receives notification
* tenant can edit and resubmit

---

### 5.10 Notifications

Both users receive notifications.

#### Tenant notifications

* submission successful
* owner approved month
* owner rejected month
* reminder to submit current month
* comment added by owner

#### Owner notifications

* new month submitted
* resubmission received
* pending approval reminder

---

### 5.11 History & Record Keeping

Both users can view:

* approved months
* rejected months
* pending months
* frozen records
* proof images for each month
* approval dates

This becomes the permanent history.

---

## 6. Status Model

Keep status simple.

* Draft
* Submitted
* Under Review
* Rejected
* Approved
* Frozen

Honestly, “Approved” and “Frozen” can be merged in backend logic if approval immediately freezes the record.

For UI, you can show:

* Draft
* Submitted
* Rejected
* Approved

And backend can lock it automatically.

---

## 7. User Experience Design Principles

This app must not look like an accounting tool. That would be a stupid mistake.

It should feel like a guided step-by-step assistant.

### Design rules

* large buttons
* big input fields
* one action per screen
* minimal text
* icons with labels
* clear colors
* photo-first workflow
* strong visual status badges
* avoid dense tables
* support Urdu + English

### Good UI pattern

#### Step flow for tenant

1. Select month
2. Enter rent
3. Add electricity bill
4. Add water bill
5. Add gas bill
6. Add other deduction
7. Upload proofs
8. Review summary
9. Submit

This is usable.

A giant form on one screen is trash for this audience.

---

## 8. Functional App Flow

### Tenant App Flow

#### Onboarding / Login

* open app
* choose Tenant
* login with phone/email
* land on dashboard

#### Create Monthly Entry

* tap “Create Month”
* select month
* enter rent
* enter bills
* add deduction
* upload images
* review summary
* submit

#### After Submission

* see status: Submitted
* wait for owner review
* receive approval/rejection notification

#### If Rejected

* open rejected month
* view owner comments
* edit data
* resubmit

#### If Approved

* view frozen record
* export/share record later

---

### Owner App Flow

#### Onboarding / Login

* open app
* choose Owner
* login
* land on dashboard

#### Review Submission

* tap pending submission
* review details
* open proof images
* approve or reject

#### If Approved

* record freezes
* both sides notified

#### If Rejected

* owner enters reason
* tenant notified
* record goes back for correction

---

## 9. Suggested Screen List

### Common

* splash screen
* language selection
* role selection
* login
* OTP verification
* notifications
* profile/settings

### Tenant Screens

* tenant dashboard
* create/select month
* rent entry
* bill entry
* proof upload
* review summary
* month details
* history list
* notification center

### Owner Screens

* owner dashboard
* pending approvals
* month review details
* proof viewer
* approve/reject screen
* approved history
* notification center

---

## 10. Key Data Model

### Users

* id
* name
* phone
* email
* role
* language
* profile_image
* created_at

### Properties / Rentals

* id
* owner_id
* tenant_id
* title
* address
* active_status

### Monthly Records

* id
* property_id
* month
* base_rent
* total_deduction
* final_payable
* notes
* status
* submitted_at
* approved_at
* frozen_at
* submitted_by
* approved_by

### Bills

* id
* monthly_record_id
* type
* amount
* deduction_amount
* reason
* note

### Proofs

* id
* bill_id
* monthly_record_id
* file_url
* file_type
* uploaded_by
* uploaded_at
* verification_status

### Comments / Review Notes

* id
* monthly_record_id
* user_id
* message
* type
* created_at

### Notifications

* id
* user_id
* title
* body
* type
* read_status
* created_at

---

## 11. Business Rules

These rules matter.

### Rule 1

Only one active monthly record per property per month.

### Rule 2

Tenant can edit only while record is:

* Draft
* Rejected

### Rule 3

Tenant cannot edit after:

* Submitted
* Approved
* Frozen

### Rule 4

Owner cannot alter tenant data directly after approval.
Owner approves or rejects. That’s it.

### Rule 5

Approved record becomes frozen permanently.

### Rule 6

Each proof image must stay linked to specific month and bill type.

### Rule 7

All important actions must be logged:

* created
* edited
* submitted
* rejected
* approved
* frozen

Without audit logs, this app becomes unreliable during disputes.

---

## 12. Non-Functional Requirements

### Performance

* app should open quickly
* image upload should be optimized
* list screens should load fast

### Security

* secure authentication
* role-based access
* protected file storage
* encrypted API communication

### Reliability

* submission must not be lost
* frozen records must remain immutable

### Usability

* simple language
* minimal clicks
* large touch targets
* clear labels

### Scalability

* support multiple properties and users later

---

## 13. Notification Events

### Tenant receives notification when:

* month submitted
* owner approved
* owner rejected
* owner added review note
* monthly reminder triggered

### Owner receives notification when:

* tenant submitted month
* tenant resubmitted after rejection
* reminder for pending approvals

---

## 14. Reporting / Export Possibilities Later

Not necessary in first build, but useful later:

* monthly PDF statement
* proof summary export
* printable approval receipt
* annual settlement report

---

## 15. Recommended Tech Stack

Since you already work in Flutter, this is the practical stack.

### Frontend

* Flutter

### Backend options

#### Option A: Laravel + MySQL

Best if you want full control, structured backend, admin panel, approval logic, future growth.

#### Option B: Firebase

Best for faster MVP, auth, push notifications, file storage.

### Recommendation

If you want speed and simpler MVP:

* Flutter + Firebase

If you want long-term product structure:

* Flutter + Laravel + MySQL + Firebase notifications

---

## 16. Suggested Architecture

### Mobile App

* Flutter
* BLoC or Provider

### Backend

* REST APIs
* role-based auth
* property-user mapping
* monthly record workflow
* proof storage service
* notification service

### Storage

* cloud file storage for images

### Push

* Firebase Cloud Messaging

---

## 17. Development Phases

### Phase 1 — Discovery & Planning

Deliverables:

* feature document
* user flow
* wireframes
* DB design
* API planning

#### Time

**3 to 5 days**

---

### Phase 2 — UI/UX Design

Deliverables:

* user-friendly screens
* tenant flow design
* owner flow design
* clickable design prototype

#### Time

**5 to 8 days**

---

### Phase 3 — Backend Development

Deliverables:

* auth APIs
* monthly record APIs
* bill APIs
* proof upload APIs
* approval/rejection APIs
* notification logic
* DB setup

#### Time

**10 to 15 days**

---

### Phase 4 — Flutter App Development

Deliverables:

* authentication flow
* tenant side screens
* owner side screens
* forms
* image upload
* notifications
* history screens

#### Time

**15 to 22 days**

---

### Phase 5 — Testing & Bug Fixing

Deliverables:

* QA testing
* role testing
* approval flow testing
* image upload testing
* freeze record testing
* notification testing

#### Time

**5 to 8 days**

---

### Phase 6 — Deployment

Deliverables:

* production backend
* Android app build
* app release prep
* handover documentation

#### Time

**3 to 5 days**

---

## 18. Rough Total Timeline

### MVP Timeline

A realistic MVP is:

**6 to 9 weeks**

That’s the real answer.

Not fake agency nonsense like “done in 10 days.”

If someone says they’ll build this properly in one week, they’re either lying or building garbage.

---

## 19. Rough Team Requirement

### Minimum team

* 1 Flutter developer
* 1 backend developer
* 1 UI/UX designer
* 1 QA tester

### Lean startup version

If one person handles Flutter + some backend:

* 1 Flutter/full-stack developer
* 1 designer
* 1 QA support

---

## 20. MVP Build Priority

If budget or time is tight, build in this order:

### Priority 1

* login
* role selection
* tenant dashboard
* owner dashboard
* monthly entry
* bill entry
* proof upload
* owner approval/rejection
* freeze month
* notifications

### Priority 2

* history
* comments
* export/share
* multi-property support

### Priority 3

* smart deduction presets
* PDF exports
* admin panel
* analytics
* voice help
* Urdu full localization

---

## 21. Risks & Challenges

### 1. Overcomplicated split rules

Fix: keep deductions manual in V1

### 2. Weak audit history

Fix: action logs for all important events

### 3. Bad UX for low-literacy users

Fix: step-by-step flow, big buttons, simple labels

### 4. Image upload problems

Fix: compression, retry upload, image preview

### 5. Approval loopholes

Fix: hard freeze after approval

---

## 22. Final Product Summary

This app is a **shared monthly rent verification system** between tenant and owner.
The tenant enters rent and bill details with image proofs.
The owner verifies and approves.
Once approved, the month is frozen and stored permanently for both sides.
Both users receive notifications throughout the process.
The interface is intentionally simple so even less educated users can operate it comfortably.

---

## 23. Brutally Honest Product Verdict

This is a **good practical app idea**, not because it’s flashy, but because it removes a real recurring pain point.

What makes it valuable is not rent entry. That’s easy.
What makes it valuable is:

* proof
* approval
* freeze
* shared history
* trust

That is the real product.

If you keep it focused, it can work.
If you try to turn it into a giant accounting monster in version 1, you’ll ruin it.

Next step should be one of these:
**wireframes**, **SRS**, or **API + DB schema**.
