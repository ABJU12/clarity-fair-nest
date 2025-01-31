;; FairNest - Decentralized Rental Marketplace

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-invalid-dates (err u101))
(define-constant err-already-booked (err u102))
(define-constant err-not-found (err u103))
(define-constant err-insufficient-funds (err u104))

;; Data structures
(define-map Properties
  { property-id: uint }
  {
    owner: principal,
    name: (string-utf8 100),
    description: (string-utf8 500), 
    daily-rate: uint,
    security-deposit: uint,
    available: bool
  }
)

(define-map Bookings
  { booking-id: uint }
  {
    property-id: uint,
    tenant: principal,
    check-in: uint,
    check-out: uint,
    total-amount: uint,
    status: (string-ascii 20)
  }
)

(define-map PropertyReviews
  { property-id: uint, reviewer: principal }
  {
    rating: uint,
    review: (string-utf8 500),
    timestamp: uint
  }
)

;; Data variables
(define-data-var next-property-id uint u1)
(define-data-var next-booking-id uint u1)

;; Public functions
(define-public (list-property (name (string-utf8 100)) (description (string-utf8 500)) (daily-rate uint) (security-deposit uint))
  (let
    (
      (property-id (var-get next-property-id))
    )
    (map-set Properties
      { property-id: property-id }
      {
        owner: tx-sender,
        name: name,
        description: description,
        daily-rate: daily-rate,
        security-deposit: security-deposit,
        available: true
      }
    )
    (var-set next-property-id (+ property-id u1))
    (ok property-id)
  )
)

(define-public (book-property (property-id uint) (check-in uint) (check-out uint))
  (let
    (
      (property (unwrap! (map-get? Properties {property-id: property-id}) (err err-not-found)))
      (booking-id (var-get next-booking-id))
      (days (- check-out check-in))
      (total-amount (* days (get daily-rate property)))
    )
    ;; Add validation logic here
    (try! (stx-transfer? total-amount tx-sender (get owner property)))
    (map-set Bookings
      { booking-id: booking-id }
      {
        property-id: property-id,
        tenant: tx-sender,
        check-in: check-in,
        check-out: check-out,
        total-amount: total-amount,
        status: "confirmed"
      }
    )
    (var-set next-booking-id (+ booking-id u1))
    (ok booking-id)
  )
)

;; Read only functions  
(define-read-only (get-property (property-id uint))
  (map-get? Properties {property-id: property-id})
)

(define-read-only (get-booking (booking-id uint))
  (map-get? Bookings {booking-id: booking-id})
)
